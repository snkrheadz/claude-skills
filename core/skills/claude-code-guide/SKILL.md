---
name: claude-code-guide
description: "Claude Code extension (sub-agents, plugins, skills) creation and configuration guide. Triggers: extensions, agent creation, skill creation, plugin creation, CLI auto-approval, headless, agents, plugins, skills"
user-invocable: true
allowed-tools: Read
model: haiku
---

# Claude Code Extension Guide

Reference for creating and configuring Claude Code extensions.

## Overview

| Extension | Purpose | Details |
|-----------|---------|---------|
| Sub-agents | Custom agents that delegate specific tasks | sub-agents.md |
| Plugins | Extension packages shared across projects | plugins.md |
| Skills | Condition-based processing auto-selected and executed | skills.md |
| CLI Auto-approval | Non-interactive mode for CI/CD | cli-automation.md |

## Quick Reference

### File Placement

```
~/.claude/                    # User level (all projects)
├── agents/agent-name.md
├── skills/skill-name/SKILL.md
└── plugins/...

.claude/                      # Project level (version control recommended)
├── agents/agent-name.md
└── skills/skill-name/SKILL.md
```

### Built-in Sub-agents

- `Explore`: Read-only, for codebase exploration
- `Plan`: For planning
- `general-purpose`: Complex multi-step tasks

## Detailed Documentation

See the following for details on each extension:

- `sub-agents.md` - How to create sub-agents
- `plugins.md` - Plugin structure and configuration
- `skills.md` - Skill definition and metadata
- `cli-automation.md` - CLI auto-approval and headless mode

## Official Documentation

- [Sub-agents](https://code.claude.com/docs/sub-agents)
- [Plugins](https://code.claude.com/docs/plugins)
- [Skills](https://code.claude.com/docs/skills)
- [Headless/CLI](https://code.claude.com/docs/headless)
- [CHANGELOG](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md) - **Always check when researching latest features**

## Research Notes

When researching Claude Code features and settings, always check:

1. **CHANGELOG.md** - Understand features added/changed in latest versions
2. **Official documentation** - Verify detailed specs at links above
3. **Consistency with existing settings** - Ensure no conflicts with this repository's settings
