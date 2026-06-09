# Plugins

Extension packages shared across multiple projects.

## Directory Structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json         # Required
├── commands/               # Slash commands
│   └── hello.md
├── agents/                 # Sub-agents
├── skills/                 # Skills
└── hooks/
    └── hooks.json
```

## plugin.json

```json
{
  "name": "plugin-name",
  "description": "Description",
  "version": "1.0.0"
}
```

## Slash Commands

### Basic Template

```markdown
# commands/review.md
---
description: Code review
---
Review $ARGUMENTS code...
```

### Variables

- `$ARGUMENTS` - Arguments when command is invoked
- `$FILE_PATH` - Current file path (if applicable)

## Testing Method

```bash
# Test local plugin
claude --plugin-dir ./my-plugin

# Invoke command
/plugin-name:command
```

## Enabling Plugins at Project Level

Plugins disabled globally can be enabled per-project.

### Configuration File

`.claude/settings.local.json`:

```json
{
  "permissions": {
    "allow": [
      "mcp__plugin_playwright_playwright__*",
      "mcp__awslabs_aws-documentation-mcp-server__*"
    ]
  },
  "enabledPlugins": {
    "playwright@claude-plugins-official": true
  }
}
```

## Available Plugins (Disabled by Default)

| Plugin | Description | Use Case |
|--------|-------------|----------|
| `playwright@claude-plugins-official` | Browser automation | Web development projects |
| `github@claude-plugins-official` | GitHub integration | Usually disabled (gh CLI recommended) |

## Plugin Distribution

1. Publish plugin to GitHub repository
2. Users clone to `~/.claude/plugins/`
3. Or load temporarily with `claude --plugin-dir`
