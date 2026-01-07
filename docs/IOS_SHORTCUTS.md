# iOS Setup Guide

## Terminal App

### Termius (Recommended)

1. Install from App Store
2. Add new host:
   - **Label**: pocket-dev
   - **Hostname**: Your Tailscale IP (get via `tailscale ip -4` on server)
   - **Username**: Your server username
   - **Use mosh**: ON
3. Import or generate SSH key in Termius
4. Connect

### Shellfish

Alternative with good iOS keyboard support.

### Blink Shell

Another option, supports mosh natively.

## Push Notifications

### ntfy App

1. Install **ntfy** from App Store
2. Open app, tap "+" to subscribe
3. Enter your topic name (same as `NTFY_TOPIC` in `.env`)
4. Enable notifications when prompted

### Test

On your server:

```bash
just test-notify
```

Your phone should buzz.

## Tailscale App

Install Tailscale on your iPhone to:
- See your devices
- Get your server's Tailscale IP
- Ensure VPN is connected before using Termius

## Tips for Mobile Coding

### tmux Navigation

| Key | Action |
|-----|--------|
| `C-a c` | New window |
| `C-a n` | Next window |
| `C-a p` | Previous window |
| `C-a 1-5` | Switch to window 1-5 |
| `M-l` | Next window (Alt+L) |
| `M-h` | Previous window (Alt+H) |
| `C-a \|` | Split vertical |
| `C-a -` | Split horizontal |
| `C-a d` | Detach (session persists) |

### Termius Keyboard Tips

- Hold `Ctrl` key to access control characters
- Use the extra key row for common keys
- `Esc` is usually mapped to a gesture

### Workflow

1. Start a Claude task
2. Pocket your phone
3. Get notification when Claude needs input
4. Tap notification to jump back to Termius
5. Respond and continue

### Multiple Sessions

Create named tmux sessions for different projects:

```bash
tmux new -s project1
tmux new -s project2
```

Switch between them:

```bash
tmux attach -t project1
```
