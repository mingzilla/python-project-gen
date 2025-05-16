#!/bin/bash

# extend_project.sh - Extends a Python project with development tooling
# Adds pre-commit hooks for code quality following Mingzilla Python Style Guide

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

# Create .pre-commit-config.yaml file
echo "Creating .pre-commit-config.yaml file..."
cat > .pre-commit-config.yaml << 'EOF'
# pre-commit hooks configuration
# See https://pre-commit.com for more information
repos:
-   repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
    -   id: trailing-whitespace
    -   id: end-of-file-fixer
    -   id: check-yaml
    -   id: check-added-large-files
    -   id: check-ast
    -   id: check-json
    -   id: debug-statements
    -   id: detect-private-key

-   repo: https://github.com/psf/black
    rev: 24.2.0
    hooks:
    -   id: black
        args: [--line-length=999]

-   repo: https://github.com/pycqa/isort
    rev: 5.13.2
    hooks:
    -   id: isort
        args: [--profile=black, --line-length=999]
        
-   repo: https://github.com/charliermarsh/ruff-pre-commit
    rev: v0.3.2
    hooks:
    -   id: ruff
        args: [--fix]

-   repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.8.0
    hooks:
    -   id: mypy
        additional_dependencies: [pydantic>=2.0.0]
        args: [--disallow-untyped-defs, --disallow-incomplete-defs]
EOF

echo ".pre-commit-config.yaml created successfully"

# Check if pre-commit is installed
if ! command -v pre-commit &> /dev/null; then
    echo "Warning: pre-commit is not installed. You may want to install it with:"
    echo "    uv pip install pre-commit"
fi

# Ensure script has executable permissions
chmod +x "$0"
echo "Set executable permissions on script"

echo "Project extension completed successfully!"
echo "You can now install pre-commit hooks with: cd $PROJECT_NAME && pre-commit install"