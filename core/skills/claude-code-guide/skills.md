# Agent Skills

Define skills that Claude automatically selects and executes.

## File Placement

```
~/.claude/skills/skill-name/SKILL.md   # User level
.claude/skills/skill-name/SKILL.md     # Project level
```

## SKILL.md Template

```markdown
---
name: skill-name
description: "Description and trigger keywords"
allowed-tools: Read, Grep
model: sonnet
context: fork               # Optional: Independent context
user-invocable: true        # Optional: Show in / menu
---

Skill instructions...
```

## Metadata Options

| Field | Description | Default |
|-------|-------------|---------|
| `name` | Skill name (lowercase, hyphens, max 64 chars) | Required |
| `description` | Description and trigger keywords (Claude uses for auto-selection) | Required |
| `allowed-tools` | Tool restrictions (comma-separated) | All allowed |
| `model` | Execution model (sonnet, opus, haiku) | inherit |
| `context` | `fork` for independent context | Share parent context |
| `user-invocable` | Show in `/` menu | true |

## Progressive Disclosure

When skills get large, split into related files:

```
my-skill/
├── SKILL.md          # Overview (recommended: under 500 lines)
├── reference.md      # Details (loaded on reference)
├── examples.md       # Usage examples
└── scripts/
    └── helper.py     # Execute only (content not loaded)
```

Reference from SKILL.md:

```markdown
See reference.md for details.
```

## Skill Auto-Selection

Claude auto-selects skills based on keywords in the `description` field.

### Writing Effective Descriptions

```yaml
# Good example
description: "Git operations help. Triggers: git, commit, push, branch, merge"

# Bad example
description: "Version control tool"
```

## user-invocable Usage

| Setting | Purpose |
|---------|---------|
| `true` | User can explicitly invoke with `/skill-name` |
| `false` | Auto-selection only, not shown in menu |

## Using context: fork

Execute as independent sub-agent:

```yaml
context: fork
```

- Does not pollute parent context
- Independent tool execution environment
- Returns only results to parent
