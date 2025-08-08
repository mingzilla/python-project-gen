#!/bin/bash
# UV Python Project Generator
# This script creates a new Python project using UV with the recommended structure
#
# Usage: ./uv-project-gen.sh <project_name>

set -e  # Exit on error

# Define variables for versions and configurations
PYTHON_VERSION="3.11"
SETUPTOOLS_VERSION="64.0.0"
GITHUB_USERNAME="mingzilla"  # Change this to your GitHub username

PROJECT_NAME=$1
PACKAGE_NAME=$(echo $PROJECT_NAME | tr '-' '_')
PACKAGE_PATH="github_${GITHUB_USERNAME}/${PACKAGE_NAME}"

# Define colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if project name is provided
if [ -z "$1" ]; then
  echo -e "${YELLOW}Error: Project name is required${NC}"
  echo "Usage: ./uv-project-gen.sh <project_name>"
  exit 1
fi

echo -e "${BLUE}Creating Python project: ${GREEN}$PROJECT_NAME${NC}"
echo -e "${BLUE}Package name: ${GREEN}$PACKAGE_NAME${NC}"
echo -e "${BLUE}Package path: ${GREEN}$PACKAGE_PATH${NC}"

# Create project directory using UV
echo -e "${BLUE}Creating project with UV...${NC}"
uv init "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Fix main.py with proper type annotations
echo -e "${BLUE}Updating main.py with proper type annotations...${NC}"
MAIN_PY_PATH="main.py"
if [ -f "$MAIN_PY_PATH" ]; then
  cat > "$MAIN_PY_PATH" << EOL
def main() -> None:
    print("Hello!")


if __name__ == "__main__":
    main()
EOL
  echo -e "${GREEN}Updated main.py with proper type annotations${NC}"
else
  echo -e "${YELLOW}Warning: main.py not found at $MAIN_PY_PATH${NC}"
fi

# Create virtual environment
echo -e "${BLUE}Creating virtual environment...${NC}"
uv venv

# Add dependencies using uv add command
echo -e "${BLUE}Adding dependencies...${NC}"
# === LLM-UPDATABLE SECTION: CORE DEPENDENCIES ===
uv add pydantic
# === END LLM-UPDATABLE SECTION ===

# === LLM-UPDATABLE SECTION: DEV DEPENDENCIES ===
uv add --dev pytest pytest-cov ruff build pre-commit
# === END LLM-UPDATABLE SECTION ===

# Create source directory structure
echo -e "${BLUE}Creating directory structure...${NC}"
mkdir -p src/github_${GITHUB_USERNAME}/${PACKAGE_NAME}/{api/{endpoints,middleware},models/{entities,requests,responses},services/{integration,cache/{long_term,l1,l2},db},core,utils}
mkdir -p tests/github_${GITHUB_USERNAME}/${PACKAGE_NAME}/{api,models/{entities,requests,responses},services,core,utils}
mkdir -p integration/github_${GITHUB_USERNAME}/${PACKAGE_NAME}/{api,services}
mkdir -p functional/github_${GITHUB_USERNAME}/${PACKAGE_NAME}/{api,workflows}
mkdir -p .vscode

# Create __init__.py files - CRITICAL for imports to work
touch src/__init__.py
touch src/github_${GITHUB_USERNAME}/__init__.py
touch src/github_${GITHUB_USERNAME}/${PACKAGE_NAME}/__init__.py
find src/github_${GITHUB_USERNAME}/${PACKAGE_NAME} -type d -exec touch {}/__init__.py \;

# For test imports to work
mkdir -p tests/github_${GITHUB_USERNAME}
touch tests/__init__.py
touch tests/github_${GITHUB_USERNAME}/__init__.py
touch tests/github_${GITHUB_USERNAME}/${PACKAGE_NAME}/__init__.py
find tests/github_${GITHUB_USERNAME}/${PACKAGE_NAME} -type d -exec touch {}/__init__.py \;

# Create address.py with just line1
cat > src/github_${GITHUB_USERNAME}/${PACKAGE_NAME}/models/entities/address.py << 'EOL'
"""
Address entity model.
"""
from pydantic import BaseModel, Field


class Address(BaseModel):
    """Address model with validation."""

    line1: str = Field(..., description="First line of the address")
EOL

# Create test_address.py
cat > tests/github_${GITHUB_USERNAME}/${PACKAGE_NAME}/models/entities/test_address.py << EOL
"""
Tests for the Address model.
"""
import pytest
from github_${GITHUB_USERNAME}.${PACKAGE_NAME}.models.entities.address import Address


def test_address_creation() -> None:
    """Test that an Address can be created with the required line1 field."""
    address = Address(line1="123 Main Street")
    assert address.line1 == "123 Main Street"


def test_address_missing_required_field() -> None:
    """Test that an Address cannot be created without required fields."""
    with pytest.raises(ValueError):
        Address()  # Missing required line1 field
EOL

# Update pyproject.toml for proper package configuration
cat > pyproject.toml << EOL
[build-system]
requires = ["setuptools>=${SETUPTOOLS_VERSION}", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "github-${GITHUB_USERNAME}-${PACKAGE_NAME}"
version = "0.1.0"
description = "A Python project"
authors = [
    {name = "${GITHUB_USERNAME}", email = "contact@github.com/${GITHUB_USERNAME}"}
]
readme = "README.md"
requires-python = ">=${PYTHON_VERSION}"
# Note: Dependencies are managed by uv add and will be populated here

[project.optional-dependencies]
dev = []  # Will be populated by uv add --dev

[tool.uv]
link-mode = "copy"

[tool.setuptools]
package-dir = {"" = "src"}
packages = [
    "github_${GITHUB_USERNAME}",
    "github_${GITHUB_USERNAME}.${PACKAGE_NAME}",
    "github_${GITHUB_USERNAME}.${PACKAGE_NAME}.models",
    "github_${GITHUB_USERNAME}.${PACKAGE_NAME}.models.entities",
    "github_${GITHUB_USERNAME}.${PACKAGE_NAME}.core",
    "github_${GITHUB_USERNAME}.${PACKAGE_NAME}.api",
    "github_${GITHUB_USERNAME}.${PACKAGE_NAME}.services",
    "github_${GITHUB_USERNAME}.${PACKAGE_NAME}.utils",
]

[tool.ruff]
line-length = 999
target-version = "py311"
fix = true  # Auto-fix issues when possible

[tool.ruff.lint]
select = ["E", "F", "I", "W"]
ignore = ["E501"]

[tool.ruff.lint.isort]
known-first-party = ["github_${GITHUB_USERNAME}"]

[tool.pytest.ini_options]
testpaths = ["tests", "integration", "functional"]
python_files = "test_*.py"
python_classes = "Test*"
python_functions = "test_*"
pythonpath = [".", "src"]
EOL

# Create setup.py for legacy compatibility
cat > setup.py << 'EOL'
#!/usr/bin/env python3
"""Legacy setup.py for compatibility with older tooling."""

import setuptools

if __name__ == "__main__":
    setuptools.setup()
EOL

# Create VSCode settings
cat > .vscode/settings.json << EOL
{
    "python.defaultInterpreterPath": "\${workspaceFolder}/.venv/bin/python",
    "python.analysis.extraPaths": ["\${workspaceFolder}/src"],
    "python.linting.enabled": true,
    "python.testing.pytestEnabled": true,
    "python.testing.unittestEnabled": false,
    "python.testing.nosetestsEnabled": false,
    "python.testing.pytestArgs": [
        "tests",
        "integration",
        "functional"
    ],
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.organizeImports": true
    }
}
EOL

# Create run_pre-commit.sh
echo -e "${BLUE}Creating run_pre-commit.sh script...${NC}"
cat > run_pre-commit.sh << 'EOL'
#!/bin/bash
git add .
uv run pre-commit run --all
EOL
chmod +x run_pre-commit.sh
echo -e "${GREEN}Created run_pre-commit.sh script${NC}"

# Create a minimal README.md with just the command table
cat > README.md << EOL
# ${PROJECT_NAME}

## Development Commands

| Task | Command |
|------|---------|
| Run tests | \`uv run -- pytest\` |
| Run with coverage | \`uv run -- pytest --cov=src\` |
| Sort imports & format | \`uv run -- ruff check --fix . && uv run -- ruff format .\` |
| Run pre-commit hooks | \`./run_pre-commit.sh\` |
EOL

# Create the prompt-init.md file for LLM
echo -e "${BLUE}Creating prompt-init.md for LLM use...${NC}"
cat > prompt-init.md << EOL
# Python Project Extension Prompt

## Overview
This prompt is designed to guide an LLM in generating a shell script that will extend a Python project created with the UV generator script. The script should add essential development tooling configuration.

## Project Context
- The project was initialized using UV (Python package manager)
- The project structure follows the Mingzilla Python Style Guide
- Basic structure is in place with src/ and tests/ directories
- pyproject.toml is already configured with basic settings

## Requirements
Generate a shell script (extend_project.sh) that will:

1. Create the following configuration file:
   - .pre-commit-config.yaml

## File Specifications

### .pre-commit-config.yaml
Set up pre-commit hooks for:
- Code linting, formatting, and import sorting with Ruff (line-length=999)
- Basic checks (trailing whitespace, YAML validity, etc.)

## Important Notes
- Use the most recent versions of development tools
- Follow the project's Python version requirements
- Maintain consistent code style with the existing project
- Set executable permissions on the generated script

## Shell Script Structure
The generated shell script should:
1. Check if a project name is provided as an argument
2. Navigate to the project directory
3. Create the .pre-commit-config.yaml file with appropriate content
4. Print progress and success messages
5. Set proper permissions

---

Please generate a complete shell script (extend_project.sh) based on these requirements. The script should be executable and follow best practices for shell scripting.
EOL

# Run unit tests
echo -e "${BLUE}Running unit tests to verify the project...${NC}"
# Install the package in development mode first
uv pip install -e .
uv run -- python -c "import sys; print(sys.path)"
uv run -- pytest -v

# Build the project
echo -e "${BLUE}Building the project...${NC}"
uv run -- python -m build

echo -e "${GREEN}Project creation complete!${NC}"
echo -e "${BLUE}Next steps:${NC}"
echo -e "1. ${YELLOW}To extend your project, use prompt-init.md with an LLM to generate an extend_project.sh script${NC}"
echo -e "2. ${YELLOW}Start developing your project!${NC}"
