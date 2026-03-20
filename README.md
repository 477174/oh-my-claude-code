# oh-my-claude-code

Multi-agent orchestration system for Claude Code, inspired by [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) (OMO).

Transforms Claude Code into a coordinated multi-agent system where the main Claude instance acts as an orchestrator (Sisyphus), automatically delegating work to specialized agents based on task type and complexity.

## Quick Start

```bash
git clone https://github.com/477174/oh-my-claude-code.git
cd oh-my-claude-code
bash install.sh
```

Start a new Claude Code session. The orchestration protocol activates automatically.

## What Gets Installed

- **10 agent files** into `~/.claude/agents/` (custom subagent types)
- **Orchestration rules** appended to `~/.claude/CLAUDE.md` (Sisyphus protocol)

## Agent Roster

| Agent | Role | Model | Mode |
|-------|------|-------|------|
| **sisyphus** | Main orchestrator (lives in CLAUDE.md) | — | You ARE Sisyphus |
| **sisyphus-junior** | Focused task executor | sonnet | Implementation |
| **hephaestus** | Deep autonomous worker | opus | Complex multi-file work |
| **prometheus** | Strategic planner | opus | Planning only (no code) |
| **atlas** | Plan executor & coordinator | sonnet | Delegation only (no code) |
| **oracle** | Architecture consultant | opus | Read-only advice |
| **librarian** | External docs/code search | haiku | Read-only research |
| **explore** | Codebase search | haiku | Read-only search |
| **metis** | Pre-planning consultant | opus | Scope analysis |
| **momus** | Plan reviewer | opus | QA gate |
| **multimodal-looker** | Media file analyzer | haiku | PDF/image analysis |

## How Delegation Works

### Intent Gate (Automatic)

Every request is classified before action:

```
User request
    |
    v
Intent Gate (Phase 0)
    |
    +-- Trivial? -----------> Execute directly
    +-- Implementation? ----> sisyphus-junior or hephaestus
    +-- Research? -----------> explore + librarian (parallel, background)
    +-- Planning needed? ----> prometheus -> momus -> atlas
    +-- Architecture? ------> oracle
    +-- Ambiguous? ----------> Ask ONE question, then classify
```

### Workflow Chains

**Non-trivial features:**
`explore` (bg) -> `prometheus` -> `momus` (bg) -> `atlas` -> `sisyphus-junior` (per task)

**Bug fixes:**
`explore` (bg) -> `sisyphus-junior` -> verify

**Research:**
`explore` + `librarian` (parallel bg) -> synthesize

**Architecture decisions:**
`explore` (bg) -> `oracle` -> present to user

### Manual Agent Selection

Prefix your message with `/agent-name` to bypass auto-delegation and force a specific agent:

```
/oracle why is this architecture slow?
/prometheus plan a caching layer for the API
/explore where are the API route handlers?
/sisyphus-junior fix the login validation bug
/hephaestus refactor the entire auth module
/librarian what do the Next.js docs say about server actions?
/metis analyze scope before we plan this feature
/momus review the plan in .claude/plans/auth-refactor.md
/atlas execute the plan in .claude/plans/auth-refactor.md
/multimodal-looker analyze this screenshot
```

### Delegation Prompt Standard

Every delegation uses a mandatory 6-section structure:
1. **TASK** — Atomic, specific goal
2. **EXPECTED OUTCOME** — Concrete success criteria
3. **MUST DO** — Exhaustive requirements
4. **MUST NOT DO** — Forbidden actions
5. **REQUIRED TOOLS** — Tool whitelist
6. **CONTEXT** — File paths, patterns, constraints

## Customization

### Override agent models

Edit the frontmatter in `~/.claude/agents/<agent>.md`:

```yaml
---
model: haiku  # change to: sonnet, opus, or haiku
---
```

### Disable an agent

Delete its file from `~/.claude/agents/`.

### Modify orchestration rules

Edit the section between `<!-- oh-my-claude-code START -->` and `<!-- oh-my-claude-code END -->` in `~/.claude/CLAUDE.md`.

### Optional hooks

The `config/hooks.json` file contains post-edit verification hooks (type checking, linting). Merge them manually into your Claude Code settings if desired.

## Uninstall

```bash
bash uninstall.sh
```

Removes all agents and orchestration rules. CLAUDE.md backups are preserved.

## Differences from OMO

| Feature | OMO (OpenCode) | oh-my-claude-code |
|---------|---------------|-------------------|
| Runtime | OpenCode plugin (Go) | Claude Code native |
| Models | Multi-provider (GPT, Gemini, Claude, Grok) | Claude-only (opus/sonnet/haiku) |
| Tool restrictions | Code-level enforcement | Prompt-level enforcement |
| Categories | 8 built-in with model routing | Mapped to agent + model tier |
| Background tasks | Concurrency manager with queues | Claude Code's native `run_in_background` |
| Prompt variants | Per-model (GPT/Gemini/Claude) | Single Claude-optimized prompt |
| Hooks | 46 lifecycle hooks | Simplified post-edit hooks |

## Credits

Architecture and philosophy adapted from [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) by code-yeongyu. This is an independent adaptation, not affiliated with the original project.
