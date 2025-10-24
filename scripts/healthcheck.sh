#!/bin/bash
# Corporate Mac Development Environment Health Check
# Verifies all essential tools are installed and configured

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

MISSING_TOOLS=()
WARNINGS=()

echo "======================================"
echo "Mac Dev Environment Health Check"
echo "======================================"
echo ""

# Function to check if a command exists
check_command() {
    local cmd=$1
    local name=${2:-$1}

    if command -v "$cmd" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $name"
        return 0
    else
        echo -e "${RED}✗${NC} $name"
        MISSING_TOOLS+=("$name")
        return 1
    fi
}

# Function to check configuration
check_config() {
    local path=$1
    local name=$2

    if [ -f "$path" ]; then
        echo -e "${GREEN}✓${NC} $name configured"
        return 0
    else
        echo -e "${YELLOW}⚠${NC} $name not configured"
        WARNINGS+=("$name not configured at $path")
        return 1
    fi
}

echo "=== Essential Tools ==="
check_command "git" "Git"
check_command "brew" "Homebrew"
check_command "ansible" "Ansible"
check_command "python3" "Python 3"
check_command "node" "Node.js"
check_command "npm" "npm"
echo ""

echo "=== Modern CLI Tools ==="
check_command "bat" "bat"
check_command "eza" "eza"
check_command "fzf" "fzf"
check_command "zoxide" "zoxide"
check_command "delta" "git-delta"
check_command "direnv" "direnv"
check_command "ripgrep" "ripgrep (rg)"
check_command "fd" "fd"
check_command "jq" "jq"
check_command "yq" "yq"
check_command "jless" "jless"
check_command "tree" "tree"
check_command "htop" "htop"
echo ""

echo "=== AWS Tools ==="
check_command "aws" "AWS CLI"
check_command "eksctl" "eksctl"
check_command "aws-iam-authenticator" "aws-iam-authenticator"
check_command "sam" "SAM CLI"
echo ""

echo "=== Container & Kubernetes ==="
check_command "docker" "Docker"
check_command "kubectl" "kubectl"
check_command "helm" "Helm"
check_command "k9s" "k9s" || true  # Optional
echo ""

echo "=== Infrastructure as Code ==="
check_command "terraform" "Terraform"
check_command "terraform-docs" "terraform-docs"
check_command "tflint" "tflint"
echo ""

echo "=== Git Tools ==="
check_command "gh" "GitHub CLI"
check_command "glab" "GitLab CLI"
check_command "git-lfs" "Git LFS"
echo ""

echo "=== Code Quality ==="
check_command "shellcheck" "shellcheck"
check_command "yamllint" "yamllint"
check_command "hadolint" "hadolint"
check_command "actionlint" "actionlint"
echo ""

echo "=== Database Tools ==="
check_command "mysql" "MySQL Client"
check_command "psql" "PostgreSQL Client"
echo ""

echo "=== Build Tools ==="
check_command "maven" "Maven" || true  # Optional
check_command "make" "Make"
echo ""

echo "=== Network Tools ==="
check_command "curl" "curl"
check_command "wget" "wget"
check_command "mtr" "mtr"
check_command "speedtest" "speedtest-cli" || check_command "speedtest-cli" "speedtest-cli" || true
echo ""

echo "=== Security Tools ==="
check_command "gpg" "GPG"
check_command "age" "age"
check_command "ssh" "SSH"
echo ""

echo "=== Configuration Files ==="
check_config "$HOME/.gitconfig" "Git config"
check_config "$HOME/.ssh/config" "SSH config"
check_config "$HOME/.zshrc" "Zsh config"
echo ""

echo "=== Applications ==="
if [ -d "/Applications/Visual Studio Code.app" ]; then
    echo -e "${GREEN}✓${NC} Visual Studio Code"
else
    echo -e "${RED}✗${NC} Visual Studio Code"
fi

if [ -d "/Applications/Docker.app" ]; then
    echo -e "${GREEN}✓${NC} Docker Desktop"
else
    echo -e "${RED}✗${NC} Docker Desktop"
fi

if [ -d "/Applications/Slack.app" ]; then
    echo -e "${GREEN}✓${NC} Slack"
else
    echo -e "${YELLOW}⚠${NC} Slack"
fi

if [ -d "/Applications/Rectangle.app" ]; then
    echo -e "${GREEN}✓${NC} Rectangle"
else
    echo -e "${YELLOW}⚠${NC} Rectangle"
fi

if [ -d "/Applications/iTerm.app" ]; then
    echo -e "${GREEN}✓${NC} iTerm2"
else
    echo -e "${YELLOW}⚠${NC} iTerm2"
fi
echo ""

echo "=== Git Configuration Check ==="
if git config --global user.name >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Git user.name: $(git config --global user.name)"
else
    echo -e "${YELLOW}⚠${NC} Git user.name not set"
    WARNINGS+=("Git user.name not configured")
fi

if git config --global user.email >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Git user.email: $(git config --global user.email)"
else
    echo -e "${YELLOW}⚠${NC} Git user.email not set"
    WARNINGS+=("Git user.email not configured")
fi
echo ""

echo "=== SSH Keys ==="
if [ -f "$HOME/.ssh/id_ed25519" ] || [ -f "$HOME/.ssh/id_rsa" ]; then
    echo -e "${GREEN}✓${NC} SSH key exists"
else
    echo -e "${YELLOW}⚠${NC} No SSH key found"
    WARNINGS+=("SSH key not generated")
fi
echo ""

echo "======================================"
echo "Summary"
echo "======================================"

if [ ${#MISSING_TOOLS[@]} -eq 0 ]; then
    echo -e "${GREEN}✓ All essential tools are installed!${NC}"
else
    echo -e "${RED}✗ Missing tools:${NC}"
    printf '%s\n' "${MISSING_TOOLS[@]}" | sed 's/^/  - /'
    echo ""
    echo "Run the Ansible playbook to install missing tools:"
    echo "  ansible-playbook main.yml --ask-become-pass"
fi

if [ ${#WARNINGS[@]} -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}⚠ Warnings:${NC}"
    printf '%s\n' "${WARNINGS[@]}" | sed 's/^/  - /'
fi

echo ""
echo "For detailed setup instructions, see:"
echo "  - README.md for installation"
echo "  - TROUBLESHOOTING.md for common issues"
echo ""

# Exit with error if there are missing essential tools
if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    exit 1
fi

exit 0
