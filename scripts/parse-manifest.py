#!/usr/bin/env python3
"""
Manifest Parser for CC-Suite
Reads skills/manifest.json and outputs information for shell scripts.

Usage:
    parse-manifest.py list-skills          # List all skill names
    parse-manifest.py get-path <skill>     # Get source path for a skill
    parse-manifest.py get-deps <skill>     # Get MCP dependencies for a skill
    parse-manifest.py expand-group <name>  # Expand a skill group to individual skills
    parse-manifest.py list-commands        # List all commands
    parse-manifest.py get-versions         # Get MCP server versions
"""

import json
import sys
import os

def load_manifest():
    """Load manifest.json from the skills directory."""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    manifest_path = os.path.join(script_dir, '..', 'skills', 'manifest.json')

    try:
        with open(manifest_path, 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"Error: manifest.json not found at {manifest_path}", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON in manifest.json: {e}", file=sys.stderr)
        sys.exit(1)

def list_skills(manifest):
    """List all skill names."""
    skills = list(manifest.get('skills', {}).keys())
    print(' '.join(skills))

def get_skill_path(manifest, skill_name):
    """Get the source path for a skill."""
    skills = manifest.get('skills', {})
    if skill_name in skills:
        print(skills[skill_name].get('path', skill_name))
    else:
        print(f"Error: Unknown skill '{skill_name}'", file=sys.stderr)
        sys.exit(1)

def get_skill_deps(manifest, skill_name):
    """Get MCP dependencies for a skill."""
    skills = manifest.get('skills', {})
    if skill_name in skills:
        deps = skills[skill_name].get('dependencies', {})
        mcp_deps = deps.get('mcp', [])
        print(' '.join(mcp_deps))
    else:
        print(f"Error: Unknown skill '{skill_name}'", file=sys.stderr)
        sys.exit(1)

def expand_group(manifest, group_name):
    """Expand a skill group to individual skills."""
    groups = manifest.get('groups', {})
    if group_name in groups:
        skills = groups[group_name].get('skills', [])
        print(' '.join(skills))
    else:
        # Not a group, return as-is
        print(group_name)

def list_commands(manifest):
    """List all command names."""
    commands = list(manifest.get('commands', {}).keys())
    print(' '.join(commands))

def get_versions(manifest):
    """Get MCP server versions in KEY=VALUE format."""
    servers = manifest.get('mcpServers', {})
    versions = []

    for name, config in servers.items():
        if 'version' in config:
            versions.append(f"{name.upper()}_VERSION={config['version']}")
        if 'cliVersion' in config:
            versions.append(f"{name.upper()}_CLI_VERSION={config['cliVersion']}")
        if 'mcpVersion' in config:
            versions.append(f"{name.upper()}_MCP_VERSION={config['mcpVersion']}")

    print('\n'.join(versions))

def get_mcp_command(manifest, server_name):
    """Get MCP server command."""
    servers = manifest.get('mcpServers', {})
    if server_name in servers:
        print(servers[server_name].get('mcpCommand', ''))
    else:
        print(f"Error: Unknown MCP server '{server_name}'", file=sys.stderr)
        sys.exit(1)

def has_post_install(manifest, skill_name):
    """Check if skill has post-install hook."""
    skills = manifest.get('skills', {})
    if skill_name in skills:
        hook = skills[skill_name].get('postInstall', '')
        print(hook if hook else '')
    else:
        print('')

def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    command = sys.argv[1]
    manifest = load_manifest()

    if command == 'list-skills':
        list_skills(manifest)
    elif command == 'get-path' and len(sys.argv) >= 3:
        get_skill_path(manifest, sys.argv[2])
    elif command == 'get-deps' and len(sys.argv) >= 3:
        get_skill_deps(manifest, sys.argv[2])
    elif command == 'expand-group' and len(sys.argv) >= 3:
        expand_group(manifest, sys.argv[2])
    elif command == 'list-commands':
        list_commands(manifest)
    elif command == 'get-versions':
        get_versions(manifest)
    elif command == 'get-mcp-command' and len(sys.argv) >= 3:
        get_mcp_command(manifest, sys.argv[2])
    elif command == 'has-post-install' and len(sys.argv) >= 3:
        has_post_install(manifest, sys.argv[2])
    else:
        print(f"Unknown command: {command}", file=sys.stderr)
        print(__doc__)
        sys.exit(1)

if __name__ == '__main__':
    main()
