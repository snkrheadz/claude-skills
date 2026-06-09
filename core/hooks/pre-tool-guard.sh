#!/bin/bash
# PreToolUse hook: Block Bash commands that access sensitive files
# This provides defense-in-depth alongside deny rules in settings.json

input=$(cat)

tool_name=$(echo "$input" | jq -r '.tool_name // empty' 2>/dev/null)
if [ "$tool_name" != "Bash" ]; then
    exit 0
fi

command=$(echo "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)
if [ -z "$command" ]; then
    exit 0
fi

# Sensitive file patterns to block
SENSITIVE_PATTERNS=(
    "$HOME/.secrets.env"
    "$HOME/.aws/credentials"
    "$HOME/.ssh/id_"
    "$HOME/.kube/config"
    "$HOME/.docker/config.json"
    "$HOME/.gnupg/"
    "$HOME/.netrc"
)

for pattern in "${SENSITIVE_PATTERNS[@]}"; do
    if [[ "$command" == *"$pattern"* ]]; then
        echo "BLOCKED: Command accesses sensitive file matching: ${pattern}"
        echo "Use environment variables or dedicated secret managers instead."
        exit 2
    fi
done

# Block pipe-to-shell patterns
if echo "$command" | grep -qE '(curl|wget)\s.*\|\s*(bash|sh|zsh)'; then
    echo "BLOCKED: Pipe-to-shell execution detected. Download and review scripts before executing."
    exit 2
fi

exit 0
