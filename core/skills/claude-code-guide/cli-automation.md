# Tool Auto-Approval (CLI)

Auto-approve tool execution in non-interactive mode (CI/CD etc.).

## Basic Usage

```bash
# Tool auto-approval
claude -p "Fix the bug" --allowedTools "Read,Edit,Bash"

# Allow specific commands only
claude -p "Create commit" \
  --allowedTools "Bash(git diff:*),Bash(git commit:*)"

# Structured JSON output
claude -p "Extract functions" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array"}}}'

# Continue conversation
claude -p "Start task" --continue
```

## Available Tools

### Basic Tools

| Tool | Description |
|------|-------------|
| `Read` | File reading |
| `Edit` | File editing |
| `Write` | File creation |
| `Bash` | Command execution |
| `Glob` | File search |
| `Grep` | Text search |

### Restricted Tools

```bash
# Allow only git commands
--allowedTools "Bash(git:*)"

# Allow only npm commands
--allowedTools "Bash(npm:*)"

# Specific command patterns
--allowedTools "Bash(git diff:*),Bash(git commit:*)"
```

### Agent Tools

```bash
# All agents
--allowedTools "Task"

# Specific agent only
--allowedTools "Task(agent-name)"
```

### Other Tools

| Tool | Description |
|------|-------------|
| `Skill` | Skill invocation |
| `AskUserQuestion` | Ask user question |

## Output Formats

### JSON Output

```bash
claude -p "List files" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"files":{"type":"array","items":{"type":"string"}}}}'
```

### Text Output (default)

```bash
claude -p "Explain the code"
```

## CI/CD Usage Examples

### GitHub Actions

```yaml
- name: Run Claude
  run: |
    claude -p "Fix linting errors" \
      --allowedTools "Read,Edit,Bash(npm:*)" \
      --output-format json
```

### Environment Variables

```bash
export ANTHROPIC_API_KEY="your-key"
claude -p "Your prompt"
```

## Security Considerations

1. **Principle of least privilege**: Allow only necessary tools
2. **Command restrictions**: Restrict to specific commands with `Bash(command:*)`
3. **Output validation**: Validate output with JSON schema
4. **Secret management**: Manage API keys via environment variables
