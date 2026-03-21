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

echo "📦 Extracting files..."

# The tarball root folder is formatted as REPO_NAME-BRANCH
TAR_ROOT="$TMP_DIR/${REPO_NAME}-${BRANCH}"

# Extract the entire tarball into the temp directory
tar -xzf "$TMP_DIR/repo.tar.gz" -C "$TMP_DIR"

# Ensure .claude directory exists in the destination project
mkdir -p "$PWD/.claude"

# Move the files to their correct locations in .claude
if [ -d "$TAR_ROOT/agents" ]; then cp -r "$TAR_ROOT/agents" "$PWD/.claude/"; fi
if [ -d "$TAR_ROOT/commands" ]; then cp -r "$TAR_ROOT/commands" "$PWD/.claude/"; fi
if [ -d "$TAR_ROOT/skills" ]; then cp -r "$TAR_ROOT/skills" "$PWD/.claude/"; fi
if [ -d "$TAR_ROOT/hooks" ]; then cp -r "$TAR_ROOT/hooks" "$PWD/.claude/"; fi
if [ -f "$TAR_ROOT/CLAUDE.md" ]; then cp "$TAR_ROOT/CLAUDE.md" "$PWD/"; fi

echo "✅ Success! Claude Code Starter Kit applied to the project."
echo ""
echo "Installed components in .claude/:"
echo "  - .claude/agents/     Specific workflow sub-agents"
echo "  - .claude/commands/   Interactive slash commands"
echo "  - .claude/skills/     Deep workflow knowledge bases"
echo "  - .claude/hooks/      Hooks configuration"
echo "  - CLAUDE.md           Project-level instructions (in project root)"
echo ""
echo "Next steps:"
echo "1. Review and update CLAUDE.md to match your project instructions."
echo "2. Run 'claude' in this directory to start testing your new commands!"
