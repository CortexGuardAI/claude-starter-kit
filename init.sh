#!/usr/bin/env bash

# Claude Code Starter Kit - Zero-Install Initialization Script
# Usage: curl -fsSL https://raw.githubusercontent.com/your-org/claude-starter-kit/main/init.sh | bash

set -e

# Configuration
REPO_OWNER="your-org"
REPO_NAME="claude-starter-kit"
BRANCH="main"
TARBALL_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/heads/${BRANCH}.tar.gz"

echo "🚀 Initializing Claude Code Starter Kit..."

# Check requirements
if ! command -v curl &> /dev/null; then
  echo "❌ Error: 'curl' is required but not installed."
  exit 1
fi

if ! command -v tar &> /dev/null; then
  echo "❌ Error: 'tar' is required but not installed."
  exit 1
fi

# Create a temporary directory for the download
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

echo "📥 Downloading starter kit artifacts..."
curl -fsSL "$TARBALL_URL" -o "$TMP_DIR/repo.tar.gz"

echo "📦 Extracting files into current directory ($PWD)..."

# Extract only the specific folders we need from the tarball
# The tarball root folder is formatted as REPO_NAME-BRANCH (e.g., claude-starter-kit-main)
TAR_ROOT="${REPO_NAME}-${BRANCH}"

# Create directories if they don't exist
mkdir -p .claude/hooks agents commands skills mcp-configs

# Extract the relevant folders and CLAUDE.md
# We use --strip-components=1 to remove the $TAR_ROOT top-level directory from the extraction paths
tar -xzf "$TMP_DIR/repo.tar.gz" -C "$PWD" \
  --strip-components=1 \
  "$TAR_ROOT/agents" \
  "$TAR_ROOT/commands" \
  "$TAR_ROOT/skills" \
  "$TAR_ROOT/hooks" \
  "$TAR_ROOT/CLAUDE.md" 2>/dev/null || true

# If the hooks were extracted to ./hooks instead of .claude/hooks, move them
if [ -d "hooks" ] && [ ! -d ".claude/hooks" ]; then
    mv hooks .claude/
elif [ -d "hooks" ] && [ -d ".claude/hooks" ]; then
    cp -r hooks/* .claude/hooks/
    rm -rf hooks
fi

echo "✅ Success! Claude Code Starter Kit applied to the project."
echo ""
echo "Installed components:"
echo "  - agents/     Specific workflow sub-agents"
echo "  - commands/   Interactive slash commands"
echo "  - skills/     Deep workflow knowledge bases"
echo "  - .claude/    Hooks configuration"
echo "  - CLAUDE.md   Project-level instructions"
echo ""
echo "Next steps:"
echo "1. Review and update CLAUDE.md to match your project instructions."
echo "2. Run 'claude' in this directory to start testing your new commands!"
