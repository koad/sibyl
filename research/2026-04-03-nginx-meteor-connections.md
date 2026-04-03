---
title: "nginx + Meteor: Diagnosing Incomplete DDP Connections"
date: 2026-04-03
researcher: Sibyl
status: complete
priority: high
tags: [nginx, meteor, ddp, websocket, bot-traffic, diagnosis]
---

# nginx + Meteor: Diagnosing Incomplete DDP Connections

**Commissioned by:** Juno (on behalf of koad)  
**Site:** kingofalldata.com (Meteor.js + nginx reverse proxy)  
**Symptom:** High connection volume from diverse IPs with real-browser user-agents, no DDP handshakes completing, no Piwik visits, per-IP patterns suggesting automation.

---

## FINDINGS

### Quick Triage — Run These Now

These five commands give immediate signal. Run them in order.

**1. Count connections by TCP state right now**
```bash
ss -tn state syn-recv | wc -l && \
ss -tn state established | grep ':80\|:443' | wc -l && \
ss -tn state time-wait | grep ':80\|:443' | wc -l
```
- High SYN-RECV count (>50–100) = SYN flood / TCP-level scanner
- High ESTABLISHED but no DDP = connections open but idle (slowloris-style or crawlers stalling)
- High TIME-WAIT = many connections completing quickly and cycling fast (scan pattern)

**2. Top IPs by request count in the last 5 minutes of nginx access log**
```bash
tail -5000 /var/log/nginx/access.log | \
  awk '{print $1}' | sort | uniq -c | sort -rn | head -30
```
Concentrations of >50 requests from a single IP in 5 minutes is mechanical. Spread across 100s of IPs with similar counts is a coordinated scanner/botnet.

**3. Status code distribution — find 400s and 499s**
```bash
awk '{print $9}' /var/log/nginx/access.log | sort | uniq -c | sort -rn
```
- **499** = nginx-specific: client closed the connection before nginx sent a response. High 499 count = connections that open and immediately abort. This is the fingerprint of scanners probing WebSocket endpoints.
- **400** = bad HTTP request (malformed headers, no Upgrade header) — also scanner fingerprint.
- **101** = successful WebSocket upgrade. If this count is near zero while 499/400s are high, nothing is completing a DDP handshake.

**4. Check for WebSocket upgrade attempts vs completions**
```bash
grep -E '"GET /websocket|/sockjs' /var/log/nginx/access.log | \
  awk '{print $9}' | sort | uniq -c | sort -rn
```
Expected for legitimate Meteor traffic: most requests should show 101 (Switching Protocols). If you see mostly 400 or 499 on WebSocket paths, clients are either sending malformed upgrade requests or aborting before completion.

**5. Top user-agents hitting the site**
```bash
awk -F'"' '{print $6}' /var/log/nginx/access.log | \
  sort | uniq -c | sort -rn | head -20
```
Look for:
- Unusual concentrations on a single agent string
- Headless browser agents (`HeadlessChrome`, `PhantomJS`, `python-requests`, `Go-http-client`)
- Generic/stripped agents (just `Mozilla/5.0` with no further detail)
- Legitimate-looking but suspiciously uniform distribution (all Chrome/120 on Windows 10 — a sign of cloned UA strings)

---

## QUESTION 1: Reading nginx Access Logs for Diagnosis

### Default combined format
nginx's default `combined` log format captures:
```
$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent"
```
The `$status` field is the most immediately useful — 101 means WebSocket upgrade succeeded, 400/499 mean it did not.

### Extended log format — add this to nginx.conf
Add a custom format in the `http {}` block to get timing and upstream data:

```nginx
log_format websocket_debug '$remote_addr - $remote_user [$time_local] '
    '"$request" $status $body_bytes_sent "$http_referer" "$http_user_agent" '
    'rt=$request_time uct=$upstream_connect_time uht=$upstream_header_time '
    'urt=$upstream_response_time ups=$upstream_status '
    'upgrade="$http_upgrade" conn="$connection" bytes_in=$request_length';

access_log /var/log/nginx/access.log websocket_debug;
```

Key fields for this diagnosis:
- `$upstream_status` — if this is `-` (dash), the request never reached Meteor at all (nginx rejected it before proxying). If `101`, Meteor accepted the WebSocket upgrade. If `400`, Meteor refused it.
- `$upstream_connect_time` — time to establish connection to Meteor. `-` means no upstream connection was attempted.
- `$request_time` — total time nginx spent on this request. Very short times (0.001s) + 499 status = client connected and immediately disconnected.
- `$http_upgrade` — logs what Upgrade header the client sent. Empty string = not a WebSocket request at all. `websocket` = it was (or claimed to be).
- `$request_length` — bytes received from client. Very small values (under ~200 bytes) mean the client sent almost nothing — a TCP probe or truncated request.

**Confidence: High** — these are documented nginx variables from official nginx.org documentation.

### What connections do NOT appear in access logs
nginx access logs only record entries when a complete enough HTTP request has been parsed. Connections that:
- Connect at TCP level and send nothing
- Send partial HTTP headers and then disconnect

...will appear in the **error log** (`/var/log/nginx/error.log`) with messages like:
```
client closed connection while waiting for request
client closed connection while reading client request headers
```

Check error log for these patterns:
```bash
grep "client closed connection" /var/log/nginx/error.log | tail -50
grep "no host in upstream" /var/log/nginx/error.log | tail -20
grep "upstream prematurely closed" /var/log/nginx/error.log | tail -20
```

**Confidence: High**

---

## QUESTION 2: Identifying Incomplete Handshakes

### TCP connects that never complete HTTP
These are invisible to the access log. They show up as:
- SYN-RECV state in `ss` output (TCP handshake in progress, no ACK yet — SYN flood)
- ESTABLISHED state with no data transferred — connection open, client silent (slowloris)
- nginx error log: `"client closed connection while waiting for request"`

### HTTP requests that never complete WebSocket upgrade
These ARE logged in access.log. The signatures:
- `$status = 400` + short `$request_time` + `$http_upgrade = websocket` = client sent a WebSocket upgrade request but it was malformed or rejected
- `$status = 499` + very short `$request_time` = client connected, may have sent request, then disconnected before receiving response
- `$status = 101` but then the connection closes within milliseconds = WebSocket opened but DDP `connect` message never sent (this is Meteor-specific and shows in Meteor server logs, not nginx logs)

### What a failed DDP session looks like in nginx logs
A legitimate Meteor DDP session in nginx logs:
1. Initial HTTP request — status 200 or 304 (loading the app bundle)
2. WebSocket upgrade — `GET /websocket HTTP/1.1` or `/sockjs/...` with status 101
3. The `$request_time` for the WebSocket entry is very long (hours, the lifetime of the connection)

A bot/scanner that gives up before DDP:
1. Possibly a GET / with status 200 (page load)
2. Either NO WebSocket upgrade attempt at all, or a WebSocket attempt with status 400/499
3. Short `$request_time` values (under 1 second)

If you're seeing lots of status-200 page loads with no follow-up 101 upgrades from the same IPs, the client is loading HTML but not executing JavaScript (headless fetch, not a real browser).

**Confidence: High**

---

## QUESTION 3: DDP-Specific Nginx Perspective

### What Meteor's DDP-over-WebSocket looks like at the nginx layer
1. Client requests the app: `GET / HTTP/1.1` → nginx serves static assets or proxies to Meteor → 200
2. Client upgrades to WebSocket: `GET /websocket HTTP/1.1` with headers `Upgrade: websocket`, `Connection: Upgrade`, `Sec-WebSocket-Key: <base64>` → nginx proxies to Meteor → Meteor returns `101 Switching Protocols`
3. Over the open WebSocket, client sends DDP `connect` message: `{"msg":"connect","version":"1","support":["1","pre2","pre1"]}`
4. Meteor responds with `{"msg":"connected","session":"<id>"}`

**nginx only sees steps 1 and 2.** Steps 3–4 are application-layer messages over an opaque WebSocket tunnel — nginx passes them through without inspecting them. So from nginx's perspective, a "successful" connection is just a 101. Whether DDP actually completes is invisible to nginx.

This means: your hooks.js logging at the Meteor layer is the only place you can see DDP-level failures. The correlation you need is:
- nginx sees: 101 upgrade from IP X
- Meteor hooks.js does NOT log a session for IP X → DDP connect was never sent

### Most diagnostic nginx fields for this scenario
| Field | What it tells you |
|---|---|
| `$status` | 101 = WS upgrade OK; 400 = bad upgrade request; 499 = client gave up |
| `$upstream_status` | `-` = nginx never proxied it; `101` = Meteor accepted it |
| `$http_upgrade` | Was `websocket` header even present? |
| `$request_time` | Very short = connection aborted immediately |
| `$request_length` | Small = client sent almost nothing |
| `$body_bytes_sent` | For 499s, if 0 = nothing was sent before client disconnected |

**Confidence: High**

### nginx config check — ensure WebSocket proxying is correct
If your nginx config is missing these, legitimate WebSocket upgrades will fail with 400:
```nginx
map $http_upgrade $connection_upgrade {
    default upgrade;
    ''      close;
}

server {
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_read_timeout 86400s;
        proxy_send_timeout 86400s;
    }
}
```
Also set `HTTP_FORWARDED_COUNT=1` in Meteor's environment so it trusts X-Forwarded-For from nginx.

**Confidence: High**

---

## QUESTION 4: Best Tools for Real-Time nginx Traffic Analysis

### 1. GoAccess — fastest to set up, highest immediate value
**Install:** `apt install goaccess` (Debian/Ubuntu)  
**Run against live log:**
```bash
goaccess /var/log/nginx/access.log --log-format=COMBINED -c
```
Gives you: top IPs, top user-agents, status code breakdown, traffic by hour — all in a terminal ncurses UI, updating live.

For tailing a live log in real-time:
```bash
tail -f /var/log/nginx/access.log | goaccess --log-format=COMBINED --no-global-config -
```

GoAccess automatically flags known bots/crawlers. The user-agent and IP panels will immediately surface concentration patterns. It's the single best first tool for this situation.

**Confidence: High — widely validated, actively maintained**

### 2. ss — socket-level real-time view
```bash
watch -n 2 'ss -tn state established | grep ":443\|:80" | wc -l'
```
Gives a live count of open connections. Compare to GoAccess active sessions to see if connections are staying open without generating log traffic.

**Confidence: High**

### 3. nginx stub_status module — built-in metrics
If enabled in nginx config:
```nginx
location /nginx_status {
    stub_status;
    allow 127.0.0.1;
    deny all;
}
```
Then:
```bash
watch -n 2 'curl -s http://127.0.0.1/nginx_status'
```
Output shows:
- Active connections
- Reading (nginx reading request headers) — high = many half-open requests
- Writing (nginx writing response) — normal
- Waiting (keepalive connections idle) — high = many idle connections (potential slowloris or crawlers between requests)

If "Reading" is persistently elevated while "Writing" is low, clients are connecting and sending headers very slowly — Slowloris pattern.

**Confidence: High**

### 4. tcpdump — packet-level inspection (use sparingly)
```bash
tcpdump -i eth0 -n 'tcp port 443 and (tcp-syn != 0 or tcp-fin != 0 or tcp-rst != 0)' -c 200
```
Shows connection opens and closes without the data payload. Useful for confirming TCP-level flood vs. HTTP-level abort.

**Confidence: High — standard Linux network tool**

### 5. fail2ban + nginx-limit-req jail — reactive blocking
Not an analysis tool, but if the analysis confirms bot IPs: fail2ban with nginx jails can auto-block IPs after threshold. Worth setting up once cause is confirmed.

---

## QUESTION 5: Likely Causes

Listed in rough order of probability for this symptom profile (real-browser UAs, diverse IPs, no DDP completion, no Piwik visits):

### 1. Web crawlers / SEO bots (High probability)
Googlebot, Bingbot, SemRush, Ahrefs, Majestic, and dozens of others crawl sites constantly. They fetch HTML but don't execute JavaScript — so they load the page, see a Meteor app (which renders almost nothing without JS), and never establish a WebSocket. They spoof real browser UAs to avoid being blocked. No DDP, no Piwik (JS-based), lots of 200s on GET / with no follow-up 101.

Signs: IPs trace back to major cloud providers (Google, Microsoft, AWS, Cloudflare ranges). Requests clustered on root path and a few others. `$http_upgrade` empty (no WebSocket attempt at all).

**Confidence: High**

### 2. Headless browser scrapers / data harvesters (Medium-High probability)
Puppeteer/Playwright/Selenium bots fetch full pages but often don't stay connected long enough to complete DDP. Or they fetch the page once, extract metadata/links, and disconnect. They use full Chrome UAs. No Piwik (depends — some execute JS, some don't).

Signs: Chrome UA strings but from cloud/VPS IP ranges. Requests follow a pattern (/, /about, /contact, etc.) in rapid succession from each IP.

**Confidence: Medium-High**

### 3. Security scanners / vulnerability probers (Medium probability)
Shodan, Censys, security research orgs scan all IPs continuously. They attempt WebSocket connections to identify what's running — but use generic HTTP upgrade requests that Meteor may reject. Diverse IPs, short `$request_time`, 400 status on WebSocket paths.

Signs: IPs in known scanner ranges (Shodan: 66.240.192.0/19, 66.240.219.0/24; Censys: 162.142.125.0/24). Very short connections.

**Confidence: Medium**

### 4. CDN or load balancer health checks (Medium probability)
If kingofalldata.com is behind Cloudflare or another CDN, the CDN's edge nodes send periodic health probes to the origin server. These are usually simple GET / requests with non-browser UAs — but some CDNs use real browser UAs for "enhanced" probing. No JavaScript execution, no DDP, no Piwik.

Signs: All traffic from a small set of CDN IP ranges. Regular cadence (every N seconds). Check if the site uses Cloudflare.

**Confidence: Medium**

### 5. Coordinated DDoS / botnet (Lower probability given current symptoms)
True DDoS would cause server resource exhaustion. The described symptoms (no app impact reported, no Piwik visits, consistent pattern) suggest noise rather than attack. But if server load is elevated, this escalates in probability. Botnets often use real browser UAs.

Signs: Server load/memory high. nginx worker processes at capacity. Connection counts growing over time.

**Confidence: Low-Medium** (absent server resource symptoms)

### 6. Misconfigured clients / broken Meteor installs (Low probability)
Other Meteor apps or DDP clients misconfigured to hit the wrong endpoint. Unlikely to produce diverse IPs but possible if a popular app has the wrong server URL.

**Confidence: Low**

---

## QUESTION 6: Quick Triage Commands (consolidated)

```bash
# 1. TCP state snapshot — see if connections are stacking up at socket level
ss -tn state syn-recv | wc -l
ss -s   # summary: established, time-wait, etc.

# 2. Top IPs in recent logs
awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -rn | head -30

# 3. Status code distribution
awk '{print $9}' /var/log/nginx/access.log | sort | uniq -c | sort -rn

# 4. Connections doing WebSocket upgrade (or trying to)
grep -E '"(GET|HEAD) /(websocket|sockjs)' /var/log/nginx/access.log | \
  awk '{print $1, $9}' | sort | uniq -c | sort -rn | head -20

# 5. Check nginx stub_status if enabled (shows live reading/writing/waiting counts)
curl -s http://127.0.0.1/nginx_status

# 6. Error log scan for partial connections
grep "client closed connection" /var/log/nginx/error.log | wc -l
grep "upstream prematurely closed" /var/log/nginx/error.log | tail -20

# 7. GoAccess quick terminal view (install if not present: apt install goaccess)
goaccess /var/log/nginx/access.log --log-format=COMBINED -c
```

---

## Recommended Next Steps for koad

1. **Run triage commands above** (5 minutes). Status code distribution and top IPs will immediately indicate whether this is crawlers (lots of 200s, no 101s) or something more hostile (lots of 400s/499s on WebSocket paths).

2. **Add extended nginx log format** (the `websocket_debug` format above) and let it run for 30 minutes. The `$http_upgrade` and `$upstream_status` fields will confirm whether clients are even attempting WebSocket upgrades.

3. **Correlate nginx 101s with Meteor session logs**. For each IP that gets a 101 from nginx, check hooks.js output — is a DDP session created? If nginx shows 101 but Meteor never sees a DDP connect message, the client is opening the WebSocket and then sending nothing. That's a scanner fingerprint, not a broken browser.

4. **Check if stub_status is already enabled** (`curl -s http://127.0.0.1/nginx_status`). If not, enable it — it's safe and adds no meaningful overhead.

5. **Install GoAccess** if not present. Fastest visual triage available without installing a monitoring stack.

6. **Respond based on findings:**
   - Crawlers (no WS attempts): add `X-Robots-Tag: noindex` if desired, or use nginx to return 403 for known crawler IPs. Consider adding robots.txt disallow for the entire site during diagnostics.
   - Scanners (WS attempts with 400/499): nginx `limit_conn` per IP + fail2ban.
   - Slowloris/incomplete HTTP: `client_body_timeout 10s; client_header_timeout 10s;` in nginx.
   - CDN probes: whitelist CDN IP ranges, block direct access to origin.

---

## Sources

- [nginx WebSocket proxying — nginx.org official docs](http://nginx.org/en/docs/http/websocket.html)
- [Module ngx_http_upstream_module — nginx.org](https://nginx.org/en/docs/http/ngx_http_upstream_module.html)
- [Module ngx_http_stub_status_module — nginx.org](https://nginx.org/en/docs/http/ngx_http_stub_status_module.html)
- [Configuring Logging — NGINX Documentation](https://docs.nginx.com/nginx/admin-guide/monitoring/logging/)
- [Using NGINX Logging for Application Performance Monitoring — nginx blog](https://blog.nginx.org/blog/using-nginx-logging-for-application-performance-monitoring)
- [Rate Limiting with NGINX — nginx blog](https://blog.nginx.org/blog/rate-limiting-nginx)
- [GoAccess — Real-Time Web Log Analyzer](https://goaccess.io/)
- [GoAccess GitHub — allinurl/goaccess](https://github.com/allinurl/goaccess)
- [HTTP 499 Status Code explained — Scrapfly](https://scrapfly.io/blog/posts/what-is-499-status-code-client-closed-request)
- [NGINX as a WebSocket Proxy — F5/NGINX blog](https://www.f5.com/company/blog/nginx/websocket-nginx)
- [WebSocket Proxy — websocket.org guide](https://websocket.org/guides/infrastructure/nginx/)
- [Killing Bots at the Gate — DEV Community](https://dev.to/lovestaco/killing-bots-at-the-gate-detecting-malicious-crawlers-with-nginx-3m6a)
- [Checking TCP Connections States in Linux — computingforgeeks](https://computingforgeeks.com/how-to-check-tcp-connections-states-in-linux-with-netstat/)
- [Meteor WebSocket handshake error 400 with nginx — deepbee.org](https://deepbee.org/article/nginx/meteor-websocket-handshake-error-400-with-nginx)
- [Meteor DDP — meteor/meteor GitHub README](https://github.com/meteor/meteor/blob/devel/packages/ddp/README.md)
- [Websocket failure with nginx reverse proxy — Meteor Forums](https://forums.meteor.com/t/websocket-failure-with-nginx-reverse-proxy/48667)
- [nginx $upstream_response_time dash meaning — nginx mailing list](https://mailman.nginx.org/pipermail/nginx/2021-February/060407.html)
- [GoAccess Real-Time log analysis — Reintech](https://reintech.io/blog/install-use-goaccess-real-time-web-log-analysis-centos-9)
