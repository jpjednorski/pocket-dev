# Troubleshooting

## Connection Issues

### Can't SSH into server

**Symptom**: Connection refused or timeout

**Causes**:
1. Tailscale not running on your phone
2. Server's Tailscale not connected
3. Using public IP instead of Tailscale IP

**Fix**:
```bash
sudo tailscale status
sudo tailscale up --ssh
tailscale ip -4
```

### mosh connection fails

**Symptom**: mosh: Connection refused

**Causes**:
1. mosh not installed
2. UDP ports blocked

**Fix**:
```bash
sudo apt install mosh
sudo nft list ruleset | grep 60000
```

### Connection drops frequently

**Symptom**: SSH disconnects, mosh shows "detached"

**Fix**: mosh should handle this automatically. If not:
- Check Tailscale status on both ends
- Try reconnecting: `mosh user@ip`

## Tailscale Issues

### Tailscale won't authenticate

**Symptom**: `tailscale up` hangs or fails

**Fix**:
```bash
sudo systemctl restart tailscaled
sudo tailscale up --auth-key=YOUR_KEY --ssh --reset
```

### Wrong Tailscale IP

**Symptom**: Can't connect to Tailscale IP

**Fix**:
```bash
tailscale ip -4
```

Use this IP, not the public IP.

## Notification Issues

### No notifications

**Symptom**: Claude asks questions but phone doesn't buzz

**Check**:
1. ntfy topic configured:
   ```bash
   cat ~/.pocket-dev.env
   ```
2. Test notification works:
   ```bash
   just test-notify
   ```
3. ntfy app subscribed to correct topic
4. iOS notifications enabled for ntfy

### Notifications delayed

**Symptom**: Notifications arrive minutes late

**Cause**: iOS background app restrictions

**Fix**:
- Open ntfy app occasionally
- Enable "Background App Refresh" for ntfy
- Check iOS Focus mode isn't blocking

## AI Tools Issues

### Claude not installed

**Symptom**: `command not found: claude`

**Fix**:
```bash
eval "$(~/.local/bin/mise activate bash)"
npm install -g @anthropic-ai/claude-code
```

### Claude not authenticated

**Symptom**: Claude asks for login repeatedly

**Fix**:
```bash
claude logout
claude login
```

### OpenCode not working

**Symptom**: `command not found: opencode`

**Fix**:
```bash
curl -fsSL https://opencode.ai/install | bash
```

## Git/SSH Issues

### Permission denied (publickey)

**Symptom**: Can't push/pull from GitHub

**Causes**:
1. SSH key not registered with GitHub
2. Wrong key being used

**Fix**:
```bash
just auth
ssh -T git@github.com
```

### SSH key not in agent

**Symptom**: Prompts for passphrase repeatedly

**Fix**:
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

## Shell Issues

### zsh not default

**Symptom**: Logging in shows bash

**Fix**:
```bash
chsh -s $(which zsh)
```

Log out and back in.

### tmux not auto-attaching

**Symptom**: Login shows regular shell, not tmux

**Check** `~/.zshrc` contains:
```bash
if [[ -z "$TMUX" ]] && [[ -n "$SSH_CONNECTION" ]]; then
    tmux attach -t main 2>/dev/null || tmux new -s main
fi
```

### mise tools not found

**Symptom**: `node: command not found` after install

**Fix**:
```bash
eval "$(~/.local/bin/mise activate zsh)"
mise current
```

Add to `~/.zshrc` if missing.

## Firewall Issues

### Locked out after firewall change

**Prevention**: Always test from a second terminal before closing your current one.

**Recovery**:
- Use VPS provider's console
- Or restore from snapshot

### Services blocked

**Symptom**: Can't reach external services

**Check**:
```bash
sudo nft list ruleset
```

Output chain should be `policy accept`.

## Performance Issues

### Slow response

**Causes**:
1. Geographic distance (choose closer datacenter)
2. Server under load

**Check**:
```bash
htop
```

### High CPU from Claude

**Expected**: Claude/OpenCode can use significant CPU during inference.

**Tip**: Use `htop` to monitor, consider larger instance if consistently maxed.

## Reset Everything

Nuclear option - reinstall:

```bash
cd ~/.pocket-dev
git stash
git pull
./install.sh
just auth
```
