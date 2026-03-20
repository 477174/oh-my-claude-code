#!/usr/bin/env bash
set -euo pipefail

# oh-my-claude-code uninstaller
# Removes agents and orchestration rules from ~/.claude/

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
AGENTS_DIR="${CLAUDE_DIR}/agents"
COMMANDS_DIR="${CLAUDE_DIR}/commands"
CLAUDE_MD="${CLAUDE_DIR}/CLAUDE.md"
MARKER_START="<!-- oh-my-claude-code START -->"
MARKER_END="<!-- oh-my-claude-code END -->"

echo "oh-my-claude-code uninstaller"
echo "============================="
echo ""

# --- Remove agents ---
echo "Removing agents..."

REMOVED=0
for agent_file in "${SCRIPT_DIR}/agents/"*.md; do
    filename="$(basename "$agent_file")"
    if [ "$filename" = "sisyphus.md" ]; then
        continue
    fi
    target="${AGENTS_DIR}/${filename}"
    if [ -f "$target" ]; then
        rm "$target"
        agent_name="${filename%.md}"
        echo "  - ${agent_name}"
        REMOVED=$((REMOVED + 1))
    fi
done

echo "${REMOVED} agents removed"

# --- Remove slash commands ---
echo ""
echo "Removing slash commands..."

CMD_REMOVED=0
for cmd_file in "${SCRIPT_DIR}/commands/"*.md; do
    filename="$(basename "$cmd_file")"
    target="${COMMANDS_DIR}/${filename}"
    if [ -f "$target" ]; then
        rm "$target"
        cmd_name="${filename%.md}"
        echo "  - /${cmd_name}"
        CMD_REMOVED=$((CMD_REMOVED + 1))
    fi
done

echo "${CMD_REMOVED} slash commands removed"

# --- Remove orchestration rules from CLAUDE.md ---
echo ""
echo "Removing orchestration rules from CLAUDE.md..."

if [ -f "$CLAUDE_MD" ] && grep -qF "$MARKER_START" "$CLAUDE_MD"; then
    tmp_file=$(mktemp)
    awk -v start="$MARKER_START" -v end="$MARKER_END" '
        $0 == start { skip=1; next }
        $0 == end { skip=0; next }
        !skip { print }
    ' "$CLAUDE_MD" > "$tmp_file"

    # Remove trailing blank lines
    sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$tmp_file"

    mv "$tmp_file" "$CLAUDE_MD"
    echo "Orchestration rules removed from CLAUDE.md"
else
    echo "No orchestration rules found in CLAUDE.md (already clean)"
fi

# --- Summary ---
echo ""
echo "============================="
echo "Uninstallation complete."
echo "Your CLAUDE.md backup files (*.bak.*) were preserved."
echo "Start a new Claude Code session for changes to take effect."
