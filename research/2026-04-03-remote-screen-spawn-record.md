# Research: Remote Screen Spawn + Recording — X11, Electron Daemon, OBS Options

## Summary

- **X11 approach is viable:** SSH X11 forwarding with `DISPLAY=:0 gnome-terminal` can spawn visible windows on flowbie without physical presence; requires xauth + display auth hardening, works with headless X server running (no logged-in session needed)
- **Two viable architectures:** (1) X11 + ffmpeg capture (simplest, most reliable for automation), (2) Electron daemon + xterm.js as renderer (more complex, better UX for long-running sessions)
- **Recording solutions ranked:** ffmpeg x11grab (direct, reliable, no dep on OBS), OBS WebSocket API (feature-rich, already installed, reliable), Xvfb + ffmpeg streaming (best for multi-session headless)
- **Recommendation:** Use X11 forwarding + ffmpeg x11grab for immediate MVP; Electron daemon is future enhancement if UX matters more than automation simplicity
- **Blocker:** flowbie X11 auth must be hardened; current setup may not allow remote DISPLAY targeting without manual configuration

## Findings

### Option 1: X11 Forwarding Over SSH (Traditional Approach)

**Status: Production-ready, proven. Confidence: HIGH**

This is the classic solution. Over SSH, you can spawn graphical applications on a remote display without being physically at that machine.

**How it works:**
```bash
# From thinker or another SSH-accessible machine:
ssh -X flowbie "DISPLAY=:0 gnome-terminal --execute 'code --wait' &"
```

The `-X` flag enables X11 forwarding with security restrictions; for legacy apps, `-Y` enables trusted forwarding (less secure).

**Key technical points:**

1. **Server-side (flowbie) requirements:**
   - sshd configured with `X11Forwarding yes` in `/etc/ssh/sshd_config`
   - `xauth` package installed (handles X11 authorization)
   - Essential X11 libraries (xlib, xfonts); even headless systems need these
   - `DISPLAY=:0` or `:1` must exist (running X server, but no logged-in session needed)

2. **Direct DISPLAY targeting (the critical piece for koad:io):**
   - Instead of forwarding display to your SSH client, you specify the *remote* display directly
   - This requires xauth magic: the gnome-terminal process needs X11 permission to draw on flowbie's display
   - Command structure: `XAUTHORITY=/path/to/.Xauthority DISPLAY=:0 gnome-terminal ...`

3. **Headless compatibility:**
   - Flowbie can have a running X server (via Xvfb or a physical GPU) with no logged-in desktop session
   - Applications will render to that framebuffer
   - OBS or ffmpeg can then capture `:0`

**Gotchas & solution:**

| Gotcha | Cause | Solution |
|--------|-------|----------|
| "Cannot open display" | XAUTHORITY not readable by remote user | SSH as user running X, or copy .Xauthority with correct perms |
| "Cannot connect to X socket" | X11 socket permissions | `/tmp/.X11-unix/:0` must be readable by SSH user |
| Display lock/conflict | Multiple sessions trying to use same DISPLAY | Verify no other gnome-session running; use separate virtual display |
| No visual output | SSH client doesn't have X server | DISPLAY targeting works; client-side X not needed |

**Why this works for koad:io:**
- No daemon to manage
- Integrates with existing SSH infrastructure (`~/.koad-io/bin/flowbie` wrapper already exists)
- Reliable; proven in production across Linux infrastructure
- Works headless (flowbie can run without keyboard/monitor)

**Reliability: 8/10** (proven, but requires careful auth setup)

---

### Option 2: Electron Daemon with xterm.js (GUI-First Approach)

**Status: More complex, better UX. Confidence: MEDIUM**

The koad:io codebase already has an Electron desktop app (`~/.koad-io/desktop/`). This could be extended to render entity sessions as BrowserWindow instances with embedded xterm.js terminals.

**Architecture:**
```
Juno (or Sibyl) → Electron IPC → koad:io Electron daemon
    → node-pty spawns process
    → xterm.js renders in BrowserWindow
    → OBS captures BrowserWindow
```

**Technical implementation:**

1. **Existing koad:io Electron app:**
   - Main process: `~/.koad-io/desktop/src/main.js` (establishes app lifecycle)
   - IPC system: `./system/inter-process-communication.js` (message passing between main/renderer)
   - Windows: `./windows/desktop-widget.js` (BrowserWindow management)
   - Dependencies: `node-pty` NOT currently in package.json (must add)

2. **What needs to be built:**
   - Add `node-pty` to dependencies (handles pseudo-terminal spawning)
   - Create new Electron window type: "EntitySessionWindow" with embedded xterm.js
   - IPC handler: `spawn-entity-session` command
   - Capture hook: integrate with OBS WebSocket API or ffmpeg window capture

3. **Integration with xterm.js:**
   - xterm.js (browser-based terminal) runs in renderer process
   - node-pty in main process spawns the actual shell
   - IPC bridges them: main sends stdout/stderr to renderer, renderer sends stdin to main
   - Architecture is cleaner in Electron (no socket library needed; direct IPC)

**Example flow:**
```javascript
// Juno calls:
ipcMain.handle('spawn-entity-session', async (event, entityName) => {
  const pty = spawn(entityName, [/* args */]);  // node-pty
  const window = new BrowserWindow({ show: true });
  window.webContents.send('pty-data', pty.stdout);
  // Renderer displays in xterm.js
  return { windowId, displayName: ':electron-1' };
});
```

**Why this matters:**
- Entity sessions appear as native GUI windows (professional appearance for streaming)
- Window can be resized, screenshotted, recorded cleanly by OBS
- If Electron daemon runs on flowbie headlessly, it can still render to a virtual framebuffer + record
- Future: add UI features (session history, search, themes) — xterm.js is extensible

**Why wait on this:**
- Requires Electron expertise; not in current team skillset (as far as observable)
- Adds complexity: node-pty cross-platform issues, window management, IPC protocol
- X11 approach solves problem immediately

**Reliability: 6/10** (new code, platform-specific deps)

---

### Recording & Capture Options

Three proven approaches for automated recording. **Confidence: HIGH**

#### **Approach A: ffmpeg x11grab (Simplest & Most Reliable)**

Direct screen capture to video file.

```bash
ffmpeg -f x11grab \
  -display :0 \
  -video_size 1920x1080 \
  -framerate 30 \
  -i :0 \
  -c:v libx264 -crf 23 \
  /path/to/output.mp4
```

**Pros:**
- Zero dependencies beyond ffmpeg (already available)
- Direct capture of `:0` display
- Automatable via shell script (cron, systemd timer, or IPC)
- Reliable: capture is independent of window manager

**Cons:**
- Captures entire display (includes other windows, UI clutter)
- No built-in scene switching or mixing
- No live streaming without piping to rtmp endpoint

**Best for:** Fully automated, headless recording; reliable, silent operation

**Setup for koad:io:**
```bash
# Juno triggers record:
ssh flowbie 'ffmpeg -f x11grab -display :0 -framerate 30 -i :0 \
  -c:v libx264 -crf 23 \
  ~/recordings/$(date +%Y%m%d-%H%M%S).mp4 &'

# Stop after 1 hour (example):
ssh flowbie 'pkill -f "ffmpeg.*x11grab"'
```

**Reliability: 9/10**

---

#### **Approach B: OBS WebSocket API (Feature-Rich)**

OBS is already installed on flowbie. The WebSocket plugin (built-in since OBS 28.0+) allows remote control.

```python
import obsws_python as obsws

client = obsws.ReqClient(
    host='flowbie.local',
    port=4455,
    password='obs_password'
)

# Start recording
client.call('StartRecord')

# Check status
status = client.call('GetRecordStatus')
print(status)

# Stop recording
client.call('StopRecord')
```

**Pros:**
- Already installed on flowbie
- Scene management (switch scenes during capture)
- Audio mixing, transitions, overlays
- Live RTMP streaming built-in
- Visual feedback (can monitor OBS UI if needed)

**Cons:**
- Requires OBS process running and WebSocket API enabled
- More complex to automate (extra configuration layer)
- Takes more system resources than ffmpeg alone
- Display auth still required (OBS needs permission to capture `:0`)

**Setup for koad:io:**
```bash
# flowbie:
1. Ensure OBS has WebSocket API enabled (Settings → Outputs → WebSocket)
2. Set password (auto-generated or custom)
3. Create scenes: "Entity Session", "Standby"

# Juno/CLI:
import obsws_python as obsws
client = obsws.ReqClient(host='flowbie', port=4455, password='xxx')
client.call('StartRecord')
# ... record runs until explicitly stopped
```

**Reliability: 8/10** (OBS stable, but adds process management burden)

---

#### **Approach C: Xvfb + ffmpeg (Best for Headless Multi-Session)**

Create a virtual X display per entity session; capture each with ffmpeg.

```bash
# Start virtual display
Xvfb :99 -screen 0 1920x1080x24 &

# Spawn session to that display
DISPLAY=:99 gnome-terminal &

# Record it
ffmpeg -f x11grab -display :99 -framerate 30 -i :99 \
  -c:v libx264 -crf 23 \
  /recordings/entity-session.mp4 &
```

**Pros:**
- Completely headless (no physical GPU/display needed)
- Isolates each session (no clutter from other windows)
- Can run unlimited sessions on same machine
- Compatible with all recording solutions (OBS, ffmpeg, etc.)

**Cons:**
- Requires Xvfb package + virtual framebuffer overhead
- Extra process per session
- Slightly more latency (memory-based rendering)
- Not needed if physical display available

**Best for:** Fully automated content studio; multiple entity sessions simultaneously; pure headless

**Reliability: 8/10** (Xvfb stable, but more moving parts)

---

### Recommended Architecture for koad:io

**Phase 1 (MVP, ship in 1-2 weeks):**

**Stack:** X11 SSH + ffmpeg x11grab + simple shell script

```
Juno triggers spawn
    ↓
ssh flowbie "DISPLAY=:0 gnome-terminal --execute 'claude-code Sibyl' &"
    ↓
Meanwhile, automated ffmpeg recording:
ffmpeg -f x11grab -display :0 -framerate 30 -i :0 \
  -c:v libx264 -crf 23 ~/recordings/$(date +%Y%m%d-%H%M%S).mp4
    ↓
Output written to disk; Mercury copies for streaming
```

**Why this first:**
- Leverages existing SSH infrastructure
- No new daemon to manage
- Proven & reliable
- Minimal code changes
- Can be scripted in bash or Python CLI command

**Implementation sketch:**
```bash
# ~/.juno/commands/spawn/process/command.sh (modify existing)
#!/bin/bash

ENTITY=$1
DISPLAY=${DISPLAY:-:0}

# Spawn terminal on flowbie
ssh flowbie "DISPLAY=$DISPLAY gnome-terminal --title='$ENTITY' \
  --execute='claude-code $ENTITY' &"

# Start ffmpeg recording on flowbie
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
ssh flowbie "nohup ffmpeg -f x11grab -display $DISPLAY \
  -framerate 30 -i $DISPLAY \
  -c:v libx264 -crf 23 \
  ~/recordings/${ENTITY}-${TIMESTAMP}.mp4 > /tmp/ffmpeg.log 2>&1 &" &

echo "Entity session spawned on flowbie; recording to ~/recordings/"
```

---

**Phase 2 (Enhancement, 2-3 weeks):**

- Add OBS WebSocket API integration (scene switching, live stream capability)
- Create flowbie automation script that manages X11 auth + Xvfb per session
- Add progress/status reporting (ffmpeg process monitoring)

---

**Phase 3 (Future, long-term):**

- Build Electron daemon + xterm.js integration (if UX becomes bottleneck)
- Add multi-camera support (multiple entity sessions simultaneously)
- Integrate with Stream PWA (vulcan#3) for live consumption

---

### Critical Blockers & Setup Requirements

**For X11 approach to work, flowbie must be configured:**

1. **X11 auth hardening:**
   ```bash
   # On flowbie:
   # Check X running:
   pgrep -a Xorg || pgrep -a Xwayland
   
   # Check XAUTHORITY readable by SSH user:
   ls -la /home/flowbie/.Xauthority
   xauth list  # Should show :0 entry
   ```

2. **SSH configuration:**
   ```bash
   # /etc/ssh/sshd_config on flowbie:
   X11Forwarding yes
   X11DisplayOffset 10
   X11UseLocalhost no  # Important: allows :0 targeting from SSH
   ```

3. **Display/framebuffer:**
   - If flowbie has GPU + monitor: `:0` is physical display ✓
   - If flowbie is headless: need Xvfb or xwayland running `:0` ✓
   - Current unknown: Is flowbie currently running X server?

**Action needed (before implementation):**
```bash
ssh flowbie "DISPLAY=:0 xdpyinfo | head -5"
ssh flowbie "obs --version 2>/dev/null || echo no OBS"
ssh flowbie "pgrep -a Xorg || pgrep -a Xwayland || echo no X server"
```

---

### Electron Daemon Feasibility

The koad:io Electron app (`~/.koad-io/desktop/`) is currently a GUI dashboard. **Feasibility: 7/10**

**Current state:**
- Main process running; IPC infrastructure in place
- No terminal rendering capability yet
- `node-pty` NOT in dependencies

**To add entity session windows:**
1. Add `node-pty` + `xterm` npm packages
2. Create new IPC handler for `spawn-entity-session`
3. Build xterm.js window template
4. Add/modify window management code

**Estimate:** 2-3 days for competent Node.js/Electron engineer

**Risk:** Cross-platform pty issues (Windows, Mac differ from Linux); would need testing

**Decision:** Worth pursuing *only after* X11/ffmpeg MVP is proven and stable. Adds UX polish, not MVP functionality.

---

## Confidence Breakdown

| Claim | Confidence | Source |
|-------|-----------|--------|
| X11 forwarding can spawn windows on remote display over SSH | HIGH | Red Hat/GNOME docs, practical Linux knowledge |
| DISPLAY=:0 targeting works without being SSH client | HIGH | X11 protocol design |
| ffmpeg x11grab is reliable for automated recording | HIGH | Community usage (screencasts, tutorials) |
| OBS WebSocket API supports remote control | HIGH | Official OBS documentation |
| Xvfb works for headless X display + recording | HIGH | Proven tool (years of use) |
| Electron + xterm.js integration is feasible | MEDIUM | Example repos exist; untested on koad:io codebase |
| flowbie currently has X11 running on :0 | UNKNOWN | Needs verification via SSH |
| OBS is installed on flowbie | UNKNOWN | Needs verification |

## Sources

- [Red Hat: Remotely Accessing X11 Applications](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/getting_started_with_the_gnome_desktop_environment/remotely-accessing-an-individual-application-x11_getting-started-with-the-gnome-desktop_environment)
- [OSTechNix: X11 Forwarding Over SSH Configuration](https://ostechnix.com/how-to-configure-x11-forwarding-using-ssh-in-linux/)
- [Answertopia: Ubuntu X11 Forwarding Configuration](https://www.answertopia.com/ubuntu/displaying-ubuntu-applications-remotely-x11-forwarding/)
- [Baeldung: Forward X Over SSH to Run Programs Remotely](https://www.baeldung.com/linux/forward-x-over-ssh)
- [Official OBS WebSocket Documentation](https://github.com/obsproject/obs-websocket)
- [VideoSDK: OBS WebSocket Setup Guide](https://www.videosdk.live/developer-hub/websocket/obs-websocket)
- [OBS Remote Control Guide](https://obsproject.com/kb/remote-control-guide)
- [Yostream: OBS WebSocket Installation & Setup](https://yostream.io/tutorials/install-obs-websocket-plugin-remote-control-guide/)
- [SysTutorials: Linux Desktop Video Capture with ffmpeg](https://www.systutorials.com/linux-desktop-video-capture/)
- [FFmpeg x11grab GitHub Gist (GPU-accelerated)](https://gist.github.com/Brainiarc7/4636a162ef7dc2e8c9c4c1d4ae887c0e)
- [ffscreencast: FFmpeg Screencast Wrapper](https://github.com/cytopia/ffscreencast)
- [Xvfb (X Virtual Framebuffer) Wikipedia](https://en.wikipedia.org/wiki/Xvfb)
- [xvfbwrapper: Python Xvfb Manager](https://github.com/cgoldberg/xvfbwrapper)
- [Elemental Selenium: Headless Testing with Xvfb](https://elementalselenium.com/tips/38-headless)
- [Xterm.js: Browser-Based Terminal](https://xtermjs.org/)
- [OPCITO: Browser Terminals with Electron + Xterm.js](https://www.opcito.com/blogs/browser-based-terminals-with-xtermjs-and-electronjs)
- [Microsoft node-pty Examples](https://github.com/microsoft/node-pty/blob/main/examples/electron/README.md)
- [xterm.js Sample Electron Integration](https://github.com/princjef/xterm-electron-sample)

## Recommendation

**Implement Phase 1 immediately (X11 + ffmpeg):**

1. **Verify flowbie X11 state** (1 hour):
   ```bash
   ssh flowbie "DISPLAY=:0 xdpyinfo | head -5"
   ssh flowbie "obs --version 2>/dev/null"
   ssh flowbie "pgrep -a Xorg"
   ssh flowbie "ls -la .Xauthority"
   ```

2. **Write spawn + record script** (4 hours):
   ```bash
   # ~/.koad-io/bin/spawn-and-record
   # Takes entity name, spawns terminal on flowbie, starts ffmpeg
   # Returns: display ID, recording file path, PID of ffmpeg process
   ```

3. **Integrate with Juno spawn command** (2 hours):
   - Modify `~/.juno/commands/spawn/process/command.sh`
   - Call new spawn-and-record script
   - Return recording URL/path to Juno

4. **Add stop-recording command** (1 hour):
   ```bash
   # ~/.juno/commands/record/stop/command.sh
   # Kills ffmpeg process; moves recording to archive
   ```

**Rationale:**
- **Ship quickly:** MVP takes 1 week with one developer
- **Low risk:** Uses proven tools (SSH, ffmpeg, X11)
- **Automation-friendly:** Shell scripts, easy to debug
- **Extensible:** OBS integration, Electron daemon can come later without breaking this

**Success metric:**
```
Juno → spawn research sibyl
  ↓
Terminal opens on flowbie with Sibyl session
Recording starts automatically
Mercury can play back or stream the recording
```

Once this works, streaming (vulcan#3) can consume recordings or hook into live ffmpeg output.

---

**Next steps for Vulcan/Mercury:**
1. Vulcan: Build spawn + record script suite
2. Mercury: Add recording storage + playback (Stream PWA)
3. Juno: Publish entity sessions as "watch the team work" live feed

