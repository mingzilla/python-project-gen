# Python UV Project Generator

A script for generating Python projects with the UV package manager that follows best practices and enforces strict typing.

## What This Offers

| Feature | Description |
|---------|-------------|
| **Standard Project Structure** | Source and test directories follow Python best practices with proper separation of concerns |
| **Testable From Day One** | Includes unit tests that verify the structure works correctly |
| **UV Integration** | Leverages UV for fast package management while maintaining compatibility with pip |
| **Type Safety** | Fixes generated files to pass mypy strict type checking |
| **LLM-Friendly Configuration** | Generates prompt files for LLMs to extend the project without hardcoding version numbers |
| **Ready-to-Use Scripts** | Includes pre-generated extension scripts that can be used directly |

## Directory Structure

The generator creates a comprehensive project structure following the style guide:

```
project_root/
├── .venv/                           # Virtual environment
├── src/                             # EXPLICIT SOURCE ROOT
│   └── github_username/             # Top-level package (organization/username)
│       └── api_link/                # PROJECT NAME (e.g., api_link, data_processor, web_scraper)
│           ├── __init__.py
│           ├── api/                 # FastAPI routes (Integration layer)
│           ├── models/              # Pydantic models
│           ├── services/            # Business logic services
│           ├── core/                # Core functionality
│           └── utils/               # Utility functions and helpers
├── tests/                           # Unit tests (mirrors src/ structure)
├── integration/                     # SEPARATE ROOT for integration tests
├── functional/                      # SEPARATE ROOT for functional/E2E tests
├── pyproject.toml                   # Project metadata and dependencies
└── README.md                        # Project documentation
```

## Configuration

You can modify these variables in the script to match your environment:

```bash
PYTHON_VERSION="3.11"
SETUPTOOLS_VERSION="64.0.0"
GITHUB_USERNAME="mingzilla"
```

## Workflow

```
[START]
  │
  ▼
[Run Generator]─────────────────────────────>"./uv-project-gen.sh my-project"
  │
  ▼
[Project Created]
  │
  ├─────► [main.py]          # Fixed with proper type annotations
  │
  ├─────► [pyproject.toml]   # Configured with development tools
  │
  ├─────► [run_pre-commit.sh]# Script for running pre-commit hooks
  │
  ├─────► [prompt-init.md]   # Instructions for LLM
  │
  ▼
[Use LLM to Generate Extension]────> "Give prompt-init.md & pyproject.toml to LLM"*
  │
  ▼
[LLM Creates extend_project.sh]
  │
  ▼
[Run Extension Script]─────────────────────────> "./extend_project.sh my-project"
  │
  ▼
[Install Pre-commit Hooks]───────────────────> "cd my-project && ./run_pre-commit.sh"
  │
  ▼
[START DEVELOPMENT]

* Legend:
  - "Give prompt-init.md & pyproject.toml to LLM" - Use prompt: 'generate file'
  - Optional: Skip LLM step by using the included extend_project_script.sh file
```

## How to Use

1. **Generate the project**:
   ```bash
   ./uv-project-gen.sh my-project
   ```
   This creates the complete project structure with a passing unit test.

2. **Generate additional configuration files** (Option A - using included script):
   - Use the included `extend_project_script.sh` if tool versions are still current:
     ```bash
     ./extend_project_script.sh my-project
     ```

   **OR**

   **Generate additional configuration files** (Option B - using LLM):
   - Give `prompt-init.md` and `pyproject.toml` to an LLM
   - Simply say "generate file" to the LLM
   - The LLM will generate `extend_project.sh`

3. **Add version-specific configuration**:
   ```bash
   # If using LLM-generated script:
   ./extend_project.sh my-project

   # OR if using included script:
   ./extend_project_script.sh my-project
   ```
   This will create `.pre-commit-config.yaml` with appropriate versions.

4. **Set up pre-commit hooks**:
   ```bash
   cd my-project
   ./run_pre-commit.sh
   ```

5. **Start developing your project!**

## Key Benefits

- **Fast Environment Setup**: Uses UV's performance (8-10× faster than pip)
- **Consistent Structure**: Follows the style guide recommendations
- **Future-Proof**: Easy to update tool versions via LLM
- **IDE-Ready**: Includes VSCode configuration

## Requirements

- [UV package manager](https://github.com/astral-sh/uv)
- Python 3.11 or higher
- Bash shell

## License

MIT
