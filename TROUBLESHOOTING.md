# Troubleshooting Guide

This guide covers common issues encountered during Mac development environment setup and their solutions.

## Table of Contents

- [Homebrew Issues](#homebrew-issues)
- [Python/Pip Conflicts](#pythonpip-conflicts)
- [Git Credential Problems](#git-credential-problems)
- [Docker Desktop Issues](#docker-desktop-issues)
- [SSH Key Problems](#ssh-key-problems)
- [Ansible Issues](#ansible-issues)
- [macOS Permission Issues](#macos-permission-issues)
- [Shell Configuration](#shell-configuration)

---

## Homebrew Issues

### Homebrew Installation Fails

**Problem:** Homebrew installation fails with permission errors.

**Solution:**
```bash
# Fix Homebrew directories ownership
sudo chown -R $(whoami) /opt/homebrew
sudo chown -R $(whoami) /usr/local/Homebrew

# If you need to reinstall Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Homebrew Doctor Shows Warnings

**Problem:** `brew doctor` shows various warnings.

**Solution:**
```bash
# Update Homebrew
brew update

# Run cleanup
brew cleanup

# Check for issues
brew doctor

# Fix common issues
brew cleanup --prune=all
```

### Package Installation Fails

**Problem:** Installing a package fails with "Error: Permission denied".

**Solution:**
```bash
# Fix permissions on Homebrew directories
sudo chown -R $(whoami):admin /opt/homebrew
sudo chmod -R g+w /opt/homebrew

# Clear Homebrew cache
rm -rf ~/Library/Caches/Homebrew
```

### Cask Installation Fails

**Problem:** Cask app fails to install with quarantine error.

**Solution:**
```bash
# Remove quarantine attribute (only for trusted apps)
xattr -dr com.apple.quarantine /Applications/AppName.app

# Or disable Gatekeeper temporarily (not recommended for security)
sudo spctl --master-disable
# Re-enable after installation
sudo spctl --master-enable
```

---

## Python/Pip Conflicts

### Multiple Python Versions Conflict

**Problem:** System has multiple Python versions causing conflicts.

**Solution:**
```bash
# Check which Python you're using
which python3
python3 --version

# Use pyenv to manage Python versions
brew install pyenv
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc

# Install specific Python version
pyenv install 3.14.0
pyenv global 3.14.0
```

### Pip Install Permission Denied

**Problem:** `pip install` fails with permission errors.

**Solution:**
```bash
# NEVER use sudo pip! Use --user flag instead
pip3 install --user package-name

# Or use virtual environments (recommended)
python3 -m venv venv
source venv/bin/activate
pip install package-name
```

### pip3 not found

**Problem:** `pip3` command not found after Python installation.

**Solution:**
```bash
# Ensure pip is installed
python3 -m ensurepip --upgrade

# Add Python bin to PATH
export PATH="$HOME/Library/Python/$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)/bin:$PATH"

# Add to ~/.zshrc permanently
echo 'export PATH="$HOME/Library/Python/$(python3 --version | cut -d'"'"' '"'"' -f2 | cut -d'"'"'.'"'"' -f1,2)/bin:$PATH"' >> ~/.zshrc
```

---

## Git Credential Problems

### Git Asks for Password Every Time

**Problem:** Git prompts for username/password on every push/pull.

**Solution:**
```bash
# Use macOS Keychain for credentials
git config --global credential.helper osxkeychain

# For GitHub/GitLab, use SSH instead of HTTPS
git remote set-url origin git@github.com:username/repo.git
```

### Git SSL Certificate Errors

**Problem:** Git operations fail with SSL certificate errors.

**Solution:**
```bash
# Update CA certificates
brew install ca-certificates

# If behind corporate proxy, you may need to set proxy
git config --global http.proxy http://proxy.company.com:8080
git config --global https.proxy https://proxy.company.com:8080

# Only as last resort (security risk!)
git config --global http.sslVerify false
```

### Git Push Fails - "Permission Denied"

**Problem:** Cannot push to remote repository.

**Solution:**
```bash
# Check SSH key is added to ssh-agent
ssh-add -l

# Add your SSH key
ssh-add --apple-use-keychain ~/.ssh/id_ed25519

# Test connection
ssh -T git@github.com
# or
ssh -T git@gitlab.com

# Make sure your SSH key is added to GitHub/GitLab
cat ~/.ssh/id_ed25519.pub | pbcopy
# Then paste at: github.com/settings/keys
```

---

## Docker Desktop Issues

### Docker Desktop Won't Start

**Problem:** Docker Desktop fails to start or crashes.

**Solution:**
```bash
# Reset Docker Desktop to factory defaults
# Docker Desktop -> Troubleshoot -> Reset to factory defaults

# Check if virtualization is enabled
sysctl kern.hv_support
# Should return: kern.hv_support: 1

# Remove Docker config files
rm -rf ~/Library/Group\ Containers/group.com.docker
rm -rf ~/Library/Containers/com.docker.docker
rm -rf ~/.docker

# Reinstall Docker Desktop
brew reinstall --cask docker
```

### Docker Commands Require Sudo

**Problem:** Docker commands only work with sudo.

**Solution:**
```bash
# Add user to docker group (if it exists)
sudo dscl . -append /Groups/docker GroupMembership $(whoami)

# On macOS, this is usually not needed. If you need sudo:
# 1. Open Docker Desktop
# 2. Go to Settings > Advanced
# 3. Enable "Allow the default Docker socket to be used"
```

### Docker Desktop Licensing Issues

**Problem:** Docker Desktop requires license for corporate use.

**Solution:**
- Docker Desktop requires a paid subscription for companies with >250 employees or >$10M revenue
- Alternatives:
  - Use [Colima](https://github.com/abiosoft/colima): `brew install colima docker docker-compose`
  - Use [OrbStack](https://orbstack.dev/): Faster Docker Desktop alternative
  - Use [Podman](https://podman.io/): `brew install podman`

---

## SSH Key Problems

### SSH Key Generation Fails

**Problem:** Cannot generate SSH key.

**Solution:**
```bash
# Generate Ed25519 key (recommended)
ssh-keygen -t ed25519 -C "your.email@company.com"

# If Ed25519 not supported, use RSA
ssh-keygen -t rsa -b 4096 -C "your.email@company.com"

# Set proper permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

### SSH Connection Fails

**Problem:** Cannot connect to remote hosts via SSH.

**Solution:**
```bash
# Test connection with verbose output
ssh -vvv git@github.com

# Check SSH config
cat ~/.ssh/config

# Add to ~/.ssh/config if needed:
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519
  AddKeysToAgent yes
  UseKeychain yes

# Restart ssh-agent
killall ssh-agent
eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

---

## Ansible Issues

### Ansible Command Not Found

**Problem:** `ansible` command not found after installation.

**Solution:**
```bash
# Ensure pip installed ansible to correct location
which ansible

# Add Python bin to PATH
export PATH="$HOME/Library/Python/$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)/bin:$PATH"

# Reinstall Ansible
pip3 install --user --upgrade ansible
```

### Ansible Playbook Fails with Permission Error

**Problem:** Playbook fails with "Permission denied" errors.

**Solution:**
```bash
# Run with --ask-become-pass
ansible-playbook main.yml --ask-become-pass

# For specific tasks, check sudo access
sudo -l
```

### Ansible Can't Find Roles/Collections

**Problem:** "role not found" or "collection not found" errors.

**Solution:**
```bash
# Install required roles and collections
ansible-galaxy install -r requirements.yml

# Check installed roles
ansible-galaxy role list

# Check installed collections
ansible-galaxy collection list

# Clear cache and reinstall
rm -rf ~/.ansible
ansible-galaxy install -r requirements.yml --force
```

---

## macOS Permission Issues

### Operation Not Permitted

**Problem:** Commands fail with "Operation not permitted" even with sudo.

**Solution:**
1. Grant Full Disk Access to Terminal/iTerm2:
   - System Settings > Privacy & Security > Full Disk Access
   - Click the lock to make changes
   - Add Terminal.app or iTerm.app

### Xcode License Agreement

**Problem:** Commands fail requiring Xcode license agreement.

**Solution:**
```bash
# Accept Xcode license
sudo xcodebuild -license accept

# Install command line tools if needed
xcode-select --install
```

### Rosetta 2 Issues (Apple Silicon)

**Problem:** Intel-only apps won't run on Apple Silicon Mac.

**Solution:**
```bash
# Install Rosetta 2
softwareupdate --install-rosetta --agree-to-license

# Run commands under Rosetta
arch -x86_64 /bin/bash
```

---

## Shell Configuration

### Commands Not Found After Installation

**Problem:** Newly installed commands not found in PATH.

**Solution:**
```bash
# Check your PATH
echo $PATH

# Reload shell configuration
source ~/.zshrc

# Check if Homebrew is in PATH
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
source ~/.zshrc
```

### Oh My Zsh Conflicts

**Problem:** Plugins or themes causing issues.

**Solution:**
```bash
# Disable all plugins temporarily
# Edit ~/.zshrc and comment out plugins line

# Update Oh My Zsh
omz update

# Reload configuration
source ~/.zshrc
```

### Zsh Completions Not Working

**Problem:** Tab completion doesn't work for kubectl, terraform, etc.

**Solution:**
```bash
# Ensure completion scripts are loaded
# Run the dev-environment.yml task or add manually:

# Add to ~/.zshrc
autoload -Uz compinit && compinit

# For kubectl
[[ $commands[kubectl] ]] && source <(kubectl completion zsh)

# For terraform
complete -o nospace -C /opt/homebrew/bin/terraform terraform

# Reload
source ~/.zshrc
```

---

## Getting Help

If you're still experiencing issues:

1. **Run the health check script:**
   ```bash
   ./scripts/healthcheck.sh
   ```

2. **Check system logs:**
   ```bash
   log show --predicate 'processImagePath contains "homebrew"' --last 1h
   ```

3. **Consult team resources:**
   - Check internal wiki/documentation
   - Ask in team Slack channel
   - Contact IT support for corporate-specific issues

4. **Verify system requirements:**
   - macOS version: macOS 13+ recommended
   - Disk space: 50GB+ free space recommended
   - RAM: 16GB+ recommended for development work
