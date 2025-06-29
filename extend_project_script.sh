#!/bin/bash

# extend_project.sh - Extends a Python project with minimal development tooling
# Adds lightweight pre-commit hooks for basic code quality

# Check if project name is provided
if [ $# -eq 0 ]; then
    echo "Error: Project name is required"
    echo "Usage: $0 <project_name>"
    exit 1
fi

PROJECT_NAME=$1
echo "Extending project: $PROJECT_NAME"

# Navigate to project directory
if [ ! -d "$PROJECT_NAME" ]; then
    echo "Error: Project directory '$PROJECT_NAME' not found"
    exit 1
fi

cd "$PROJECT_NAME" || exit 1
echo "Working in directory: $(pwd)"

# Create .pre-commit-config.yaml file with minimal configuration
echo "Creating lightweight .pre-commit-config.yaml file..."
cat > .pre-commit-config.yaml << 'EOF'
# Lightweight pre-commit hooks configuration
# Only essential formatting tools are enabled by default
repos:
# === LLM-UPDATABLE SECTION: PRE-COMMIT CORE HOOKS ===
-   repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
    -   id: trailing-whitespace
        exclude: '^docker-volumes/.*'
    -   id: end-of-file-fixer
        exclude: '^.*\.(lock|min\.js|svg)$|^docker-volumes/.*'
    -   id: check-yaml
        args: [--allow-multiple-documents]
    -   id: check-added-large-files
        args: ['--maxkb=1000']
        exclude: '^docker-volumes/.*'
# === END LLM-UPDATABLE SECTION ===

# === LLM-UPDATABLE SECTION: RUFF LINTING AND FORMATTING ===
-   repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.11.13
    hooks:
    -   id: ruff
        args: [--fix]
        exclude: '^docker-volumes/.*'
    -   id: ruff-format
        exclude: '^docker-volumes/.*'
# === END LLM-UPDATABLE SECTION ===
EOF

echo "Lightweight .pre-commit-config.yaml created successfully"

# Create a script to install pre-commit hooks
cat > install-hooks.sh << 'EOF'
#!/bin/bash
echo "Installing pre-commit hooks..."
uv pip install pre-commit
pre-commit install --install-hooks
echo "Done! Pre-commit hooks installed."
EOF

chmod +x install-hooks.sh
echo "Created install-hooks.sh helper script"

echo "Project extension completed successfully!"
echo "To start using the lightweight pre-commit setup:"
echo "  1. Run ./install-hooks.sh (only when you're ready)"
echo "  2. Pre-commit will now automatically format your code when you commit"
echo ""
echo "TIP: You can bypass pre-commit hooks temporarily with: git commit --no-verify"
