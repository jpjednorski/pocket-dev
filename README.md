# pocket-dev

One-command setup for mobile coding with Claude Code & OpenCode via Tailscale.

```
iPhone (Termius) ──▶ Tailscale VPN ──▶ VPS (Claude Code + OpenCode)
       ▲                                         │
       └─────────── ntfy.sh push ◀───────────────┘
```

## Features

- **Tailscale-only access** - No public SSH, maximum security
- **mosh + tmux** - Resilient connections, session persistence
- **Push notifications** - Get notified when Claude needs input
- **Claude Code + OpenCode** - Both AI tools, your choice
- **mise-managed runtimes** - node, python, bun, uv (extensible)
- **Git SSH ready** - Key generation + GitHub registration

## Quick Start

### 1. Provision a VPS

Recommended: [Hetzner](https://www.hetzner.com/cloud) CCX33 (8 vCPU, 32GB RAM) - ~€0.10/hr

- Ubuntu 22.04 or 24.04
- Any region (US: Ashburn or Hillsboro)

### 2. Get your keys

- **Tailscale auth key**: https://login.tailscale.com/admin/settings/keys
  - Create a reusable, ephemeral key
- **ntfy topic**: Pick a secret name (e.g., `pocket-dev-abc123xyz`)

### 3. Install

SSH into your VPS and run the one-liner:

```bash
curl -fsSL https://raw.githubusercontent.com/jpjednorski/pocket-dev/master/install.sh | \
  TAILSCALE_AUTH_KEY=tskey-auth-xxxxx NTFY_TOPIC=pocket-dev-your-secret-topic bash
```

Or clone first if you prefer:

```bash
git clone https://github.com/jpjednorski/pocket-dev ~/.pocket-dev
cd ~/.pocket-dev
cp .env.example .env
# edit .env with your keys
./install.sh
```

### 4. Authenticate

After install completes:

```bash
just auth
```

This will:
- Authenticate with GitHub (browser OAuth)
- Register your SSH key with GitHub
- Set git user.name/email from your GitHub profile
- Authenticate Claude Code
- Authenticate OpenCode

### 5. Clone your repos

Create `repos.txt`:

```bash
cp repos.txt.example repos.txt
# Edit repos.txt with your repos
```

Clone them:

```bash
just clone-repos
```

### 6. Connect from mobile

Install on your iPhone:
- **Termius** (or Shellfish) - SSH/mosh client
- **ntfy** - Push notifications (subscribe to your topic)

Connect via mosh:

```bash
mosh your-user@YOUR_TAILSCALE_IP
```

## Commands

```bash
just install      # Full installation
just auth         # Interactive authentication
just clone-repos  # Clone repos from repos.txt
just status       # Check system status
just connect-info # Show connection info
just test-notify  # Test push notification
just add-tool go 1.22.0  # Add a new tool
just update-tools # Update all tools
just update       # Update pocket-dev itself
```

## Push Notifications

Claude Code will notify you via ntfy.sh when it calls `AskUserQuestion`.

Test it:

```bash
just test-notify
```

Custom notifications from shell:

```bash
ping-phone "Build complete!"
notify-done npm run build  # Notifies when command finishes
```

## Security

- **No public SSH** - Only accessible via Tailscale
- **nftables firewall** - Drops all non-Tailscale traffic
- **fail2ban** - Bans repeated auth failures
- **SSH hardened** - No passwords, no root, key-only

## File Structure

```
~/.pocket-dev/          # Installation directory
├── .env                # Your secrets (git-ignored)
├── repos.txt           # Repos to clone (git-ignored)
├── justfile            # Commands
├── scripts/            # Setup and command scripts
├── config/             # System configs (tmux, nftables, etc)
└── dotfiles/           # Shell configs, Claude hooks

~/.claude/              # Claude Code config
├── settings.json       # Hooks configuration
└── hooks/notify.sh     # Push notification script

~/.pocket-dev.env       # Runtime env (NTFY_TOPIC)
```

## Customization

### Add more tools

```bash
just add-tool go 1.22.0
just add-tool rust latest
```

Or edit `tools.toml` and run `mise install`.

### Change tmux prefix

Edit `~/.tmux.conf` and change `C-a` to your preference.

### Custom notification hooks

Edit `~/.claude/hooks/notify.sh` to customize notification format.

## Troubleshooting

### Can't connect via Tailscale

```bash
sudo tailscale status
sudo tailscale up --ssh
```

### mosh connection fails

Ensure UDP ports 60000-61000 are allowed (should be by default).

### Push notifications not working

```bash
just test-notify
```

Check that:
1. NTFY_TOPIC is set in `~/.pocket-dev.env`
2. You're subscribed to the topic in the ntfy app

### Claude hooks not firing

Verify `~/.claude/settings.json` has the hook configured.

## License

MIT
