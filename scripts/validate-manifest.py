#!/usr/bin/env python3
"""
Validate skills/manifest.json structure and content
"""

import json
import sys
from pathlib import Path
from typing import Dict, List, Any, Tuple

# Colors
GREEN = '\033[0;32m'
RED = '\033[0;31m'
YELLOW = '\033[1;33m'
NC = '\033[0m'

def validate_manifest(manifest_path: Path) -> Tuple[bool, List[str]]:
    """Validate manifest.json structure and content"""
    errors = []
    warnings = []

    # Load manifest
    try:
        with open(manifest_path) as f:
            manifest = json.load(f)
    except json.JSONDecodeError as e:
        return False, [f"Invalid JSON syntax: {e}"]
    except FileNotFoundError:
        return False, [f"Manifest not found: {manifest_path}"]

    # Check required top-level keys
    required_keys = ['version', 'skills', 'groups', 'commands', 'mcpServers']
    for key in required_keys:
        if key not in manifest:
            errors.append(f"Missing required key: {key}")

    if errors:
        return False, errors

    # Validate skills
    skills = manifest.get('skills', {})
    for skill_name, skill_data in skills.items():
        # Check required skill fields
        required_fields = ['name', 'displayName', 'description', 'path', 'type']
        for field in required_fields:
            if field not in skill_data:
                errors.append(f"Skill '{skill_name}' missing field: {field}")

        # Validate skill path exists
        skill_path = Path(__file__).parent.parent / 'skills' / skill_data.get('path', '')
        if not skill_path.exists():
            warnings.append(f"Skill path does not exist: {skill_data.get('path')}")

        # Check dependencies structure
        if 'dependencies' in skill_data:
            deps = skill_data['dependencies']
            if not isinstance(deps, dict):
                errors.append(f"Skill '{skill_name}' dependencies must be a dict")
            else:
                for dep_type in ['mcp', 'npm', 'pip']:
                    if dep_type in deps and not isinstance(deps[dep_type], list):
                        errors.append(f"Skill '{skill_name}' {dep_type} dependencies must be a list")

    # Validate groups
    groups = manifest.get('groups', {})
    for group_name, group_data in groups.items():
        if 'skills' not in group_data:
            errors.append(f"Group '{group_name}' missing 'skills' field")
        else:
            # Check that all skills in group exist
            for skill in group_data['skills']:
                if skill not in skills:
                    errors.append(f"Group '{group_name}' references unknown skill: {skill}")

    # Validate commands
    commands = manifest.get('commands', {})
    for cmd_name, cmd_data in commands.items():
        if 'file' not in cmd_data:
            errors.append(f"Command '{cmd_name}' missing 'file' field")
        else:
            # Check if command file exists
            cmd_file = Path(__file__).parent.parent / cmd_data['file']
            if not cmd_file.exists():
                warnings.append(f"Command file does not exist: {cmd_data['file']}")

    # Validate MCP servers
    mcp_servers = manifest.get('mcpServers', {})
    for server_name, server_data in mcp_servers.items():
        if 'name' not in server_data:
            errors.append(f"MCP server '{server_name}' missing 'name' field")
        if 'type' not in server_data:
            errors.append(f"MCP server '{server_name}' missing 'type' field")

    return len(errors) == 0, errors + [f"WARNING: {w}" for w in warnings]

def main():
    manifest_path = Path(__file__).parent.parent / 'skills' / 'manifest.json'

    print(f"{YELLOW}Validating manifest.json...{NC}\n")

    success, messages = validate_manifest(manifest_path)

    if success:
        print(f"{GREEN}✓ manifest.json is valid{NC}")
        if messages:
            print(f"\n{YELLOW}Warnings:{NC}")
            for msg in messages:
                print(f"  {msg}")
        return 0
    else:
        print(f"{RED}✗ manifest.json validation failed{NC}\n")
        print("Errors:")
        for msg in messages:
            if msg.startswith("WARNING"):
                print(f"  {YELLOW}{msg}{NC}")
            else:
                print(f"  {RED}{msg}{NC}")
        return 1

if __name__ == '__main__':
    sys.exit(main())
