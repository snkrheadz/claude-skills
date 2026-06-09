# Sub-agents

Define custom agents that delegate specific tasks.

## File Placement

```
~/.claude/agents/          # User level (all projects)
.claude/agents/            # Project level (version control recommended)
```

## Template

```markdown
---
name: agent-name
description: Agent description (when to use)
tools: Read, Grep, Glob
model: sonnet
permissionMode: default
---

Instructions...
```

## Configuration Options

| Field | Values |
|-------|--------|
| `tools` | `Read`, `Edit`, `Write`, `Bash`, `Glob`, `Grep`, `Task`, etc. |
| `model` | `sonnet`, `opus`, `haiku`, `inherit` |
| `permissionMode` | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan` |
| `hooks` | `PreToolUse`, `PostToolUse`, `Stop` events |

## permissionMode Details

| Mode | Description |
|------|-------------|
| `default` | Normal permission confirmation |
| `acceptEdits` | Auto-approve edits |
| `dontAsk` | Execute without confirmation (dangerous) |
| `bypassPermissions` | Bypass all permissions (dangerous) |
| `plan` | Plan mode (don't execute) |

## Built-in Sub-agents

- `Explore`: Read-only, for codebase exploration
- `Plan`: For planning
- `general-purpose`: Complex multi-step tasks

## Usage Examples

### Invoking with Task tool

```json
{
  "subagent_type": "agent-name",
  "prompt": "Task description",
  "description": "Short description (3-5 words)"
}
```

### Defining Hooks within Agent

```markdown
---
name: my-agent
hooks:
  PostToolUse:
    - matcher: Bash
      hooks:
        - type: command
          command: echo "Bash executed"
---
```
