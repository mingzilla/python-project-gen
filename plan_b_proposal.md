# Plan B: Self-Contained Script with LLM-Updatable Sections

## Overview

This document outlines Plan B for the UV project generator, designed as a fallback if the current LLM-based script generation approach becomes problematic or unreliable.

## Current Solution (Plan A)

**Workflow:**
1. `uv-project-gen.sh` creates project + generates `prompt-init.md`
2. User gives `prompt-init.md` + `pyproject.toml` to LLM
3. LLM generates `extend_project.sh` script
4. User runs generated script to create configuration files

**Issues that might arise:**
- LLM services become unreliable or expensive
- Generated scripts have inconsistent quality
- Extra dependency on LLM for basic project setup
- Complex workflow for simple configuration

## Plan B: Self-Contained with Marked Sections

### **Core Philosophy**
Create a fully self-contained script that works offline but includes clearly marked sections that can be easily updated by LLMs when needed.

### **Implementation Strategy**

#### **1. Self-Contained Script**
```bash
# All configuration generation built directly into uv-project-gen.sh
# No external LLM dependency for normal operation
# No intermediate script generation

./uv-project-gen.sh my-project  # Complete project ready to use
```

#### **2. LLM-Updatable Section Markers**
```bash
# === LLM-UPDATABLE SECTION: DEPENDENCY VERSIONS ===
uv add --dev pytest pytest-cov ruff build pre-commit
# === END LLM-UPDATABLE SECTION ===

# === LLM-UPDATABLE SECTION: PRE-COMMIT TOOL VERSIONS ===
-   repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.11.13
# === END LLM-UPDATABLE SECTION ===
```

#### **3. Maintenance Workflow**
```bash
# Normal use (no LLM needed)
./uv-project-gen.sh my-project

# When versions get stale (every 6-12 months)
# Give script to LLM: "Update library versions in marked sections"

# Post-generation sync (optional)
# Give pyproject.toml + script to LLM: "Sync versions between these"
```

### **What Gets Built Into Main Script**

1. **Project Structure Creation** ✅ (already there)
2. **Dependency Installation** ✅ (already there)
3. **`.pre-commit-config.yaml` Generation** ⭐ NEW
4. **`install-hooks.sh` Helper Script** ⭐ NEW
5. **Basic Configuration Files** ⭐ NEW

### **Benefits of Plan B**

| Aspect | Plan A (Current) | Plan B (Proposed) |
|--------|------------------|-------------------|
| **Reliability** | Depends on LLM availability | Always works offline |
| **Simplicity** | Multi-step process | Single command |
| **Maintenance** | LLM generates new script | LLM updates sections in-place |
| **Error Handling** | Script generation can fail | Static script always works |
| **Version Updates** | Manual LLM interaction | Marked sections + LLM |
| **Team Adoption** | Requires LLM access | No external dependencies |

### **Migration Path**

If Plan A becomes problematic:

1. **Phase 1**: Move configuration generation into main script
   - Add `.pre-commit-config.yaml` creation to `uv-project-gen.sh`
   - Add `install-hooks.sh` creation to main script
   - Remove `prompt-init.md` generation

2. **Phase 2**: Enhance version management
   - Ensure all version-dependent sections are clearly marked
   - Create update documentation for LLM usage
   - Test LLM section updating workflow

3. **Phase 3**: Deprecate current workflow
   - Remove `extend_project_script.sh`
   - Update documentation
   - Simplify README workflow

### **Implementation Details**

#### **New Script Structure**
```bash
# Current workflow remains until this point:
uv add --dev pytest pytest-cov ruff build pre-commit

# NEW: Add configuration generation
echo -e "${BLUE}Creating development configuration...${NC}"

# Generate .pre-commit-config.yaml
cat > .pre-commit-config.yaml << 'EOF'
# === LLM-UPDATABLE SECTION: PRE-COMMIT TOOLS ===
# (current extend_project_script.sh content goes here)
# === END LLM-UPDATABLE SECTION ===
EOF

# Generate install-hooks.sh
cat > install-hooks.sh << 'EOF'
# (current install-hooks.sh content goes here)
EOF
chmod +x install-hooks.sh

echo -e "${GREEN}Project setup complete! Run ./install-hooks.sh when ready.${NC}"
```

#### **LLM Update Instructions**
```markdown
# For future maintenance:
# 1. Give this script to an LLM
# 2. Say: "Update tool versions in LLM-UPDATABLE sections to latest stable versions"
# 3. LLM identifies marked sections and updates version numbers
# 4. Test updated script with a sample project
```

## When to Switch to Plan B

Consider switching when:
- LLM-based generation becomes unreliable
- Team needs offline project generation
- Maintenance overhead of current approach becomes burdensome
- Simpler workflow is preferred for consistency

## Future Considerations

**What could make both plans obsolete:**
- UV adds built-in project templates
- Community standardizes on different tools
- Python packaging ecosystem changes significantly
- Better project generators emerge

**Staying flexible:**
- Keep both approaches documented
- Monitor UV development for built-in solutions
- Be ready to adapt to ecosystem changes
- Maintain minimal viable generator regardless of approach
