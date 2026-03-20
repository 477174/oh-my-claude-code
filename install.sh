#!/usr/bin/env bash
set -euo pipefail

# oh-my-claude-code installer
# Installs agents and orchestration rules into ~/.claude/

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
AGENTS_DIR="${CLAUDE_DIR}/agents"
COMMANDS_DIR="${CLAUDE_DIR}/commands"
CLAUDE_MD="${CLAUDE_DIR}/CLAUDE.md"
MARKER_START="<!-- oh-my-claude-code START -->"
MARKER_END="<!-- oh-my-claude-code END -->"

echo "oh-my-claude-code installer"
echo "=========================="
echo ""

# Check ~/.claude exists
if [ ! -d "$CLAUDE_DIR" ]; then
    echo "Error: ${CLAUDE_DIR} does not exist."
    echo "Please install Claude Code first: https://docs.anthropic.com/en/docs/claude-code"
    exit 1
fi

# Create agents directory if needed
if [ ! -d "$AGENTS_DIR" ]; then
    mkdir -p "$AGENTS_DIR"
    echo "Created ${AGENTS_DIR}"
fi

# --- Install agents ---
echo ""
echo "Installing agents..."

AGENT_COUNT=0
for agent_file in "${SCRIPT_DIR}/agents/"*.md; do
    filename="$(basename "$agent_file")"
    # Skip sisyphus.md (documentation only, not a real agent)
    if [ "$filename" = "sisyphus.md" ]; then
        continue
    fi
    cp "$agent_file" "${AGENTS_DIR}/${filename}"
    agent_name="${filename%.md}"
    echo "  + ${agent_name}"
    AGENT_COUNT=$((AGENT_COUNT + 1))
done

echo "${AGENT_COUNT} agents installed to ${AGENTS_DIR}"

# --- Install slash commands ---
echo ""
echo "Installing slash commands..."

if [ ! -d "$COMMANDS_DIR" ]; then
    mkdir -p "$COMMANDS_DIR"
    echo "Created ${COMMANDS_DIR}"
fi

CMD_COUNT=0
for cmd_file in "${SCRIPT_DIR}/commands/"*.md; do
    filename="$(basename "$cmd_file")"
    cp "$cmd_file" "${COMMANDS_DIR}/${filename}"
    cmd_name="${filename%.md}"
    echo "  + /${cmd_name}"
    CMD_COUNT=$((CMD_COUNT + 1))
done

echo "${CMD_COUNT} slash commands installed to ${COMMANDS_DIR}"

# --- Install orchestration rules ---
echo ""
echo "Installing orchestration rules..."

# Check if already installed (idempotent)
if [ -f "$CLAUDE_MD" ] && grep -qF "$MARKER_START" "$CLAUDE_MD"; then
    echo "Orchestration rules already present in CLAUDE.md — updating..."
    # Remove old rules between markers (inclusive)
    tmp_file=$(mktemp)
    awk -v start="$MARKER_START" -v end="$MARKER_END" '
        $0 == start { skip=1; next }
        $0 == end { skip=0; next }
        !skip { print }
    ' "$CLAUDE_MD" > "$tmp_file"
    mv "$tmp_file" "$CLAUDE_MD"
fi

# Backup existing CLAUDE.md
if [ -f "$CLAUDE_MD" ]; then
    backup="${CLAUDE_MD}.bak.$(date +%Y%m%d%H%M%S)"
    cp "$CLAUDE_MD" "$backup"
    echo "Backed up CLAUDE.md to $(basename "$backup")"
fi

# Append orchestration rules
echo "" >> "$CLAUDE_MD"
cat "${SCRIPT_DIR}/orchestration/claude-md-append.md" >> "$CLAUDE_MD"

echo "Orchestration rules appended to CLAUDE.md"

# --- Optional hooks ---
if [ -f "${SCRIPT_DIR}/config/hooks.json" ]; then
    echo ""
    echo "Optional: hooks configuration available at config/hooks.json"
    echo "To install hooks, manually merge into your Claude Code settings."
fi

# --- Summary ---
echo ""
echo "=========================="
echo "Installation complete!"
echo ""
echo "Installed agents:"
for agent_file in "${SCRIPT_DIR}/agents/"*.md; do
    filename="$(basename "$agent_file")"
    if [ "$filename" = "sisyphus.md" ]; then
        continue
    fi
    agent_name="${filename%.md}"
    echo "  - ${agent_name}"
done
echo ""
echo "Slash commands (type / in Claude Code):"
for cmd_file in "${SCRIPT_DIR}/commands/"*.md; do
    filename="$(basename "$cmd_file")"
    cmd_name="${filename%.md}"
    echo "  /${cmd_name}"
done
echo ""
echo "Orchestration rules (Sisyphus) added to CLAUDE.md"
echo ""
echo "Start a new Claude Code session to use the agents."
echo "The main Claude instance will auto-delegate based on the orchestration protocol."
