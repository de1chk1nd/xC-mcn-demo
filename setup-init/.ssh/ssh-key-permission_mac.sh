#!/usr/bin/env bash
set -euo pipefail

#######################################
# Load Common Configuration
#######################################
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$REPO_ROOT" ]; then
    echo "ERROR: Not in a git repository"
    exit 1
fi

CONFIG_FILE="${REPO_ROOT}/setup-init/config.yaml"
if ! command -v yq &> /dev/null; then
    echo "ERROR: yq not installed (brew install yq)"
    exit 1
fi
if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Config file not found: ${CONFIG_FILE}"
    exit 1
fi

STUDENT=$(yq '.student.name' "$CONFIG_FILE")
SSH_KEY="${REPO_ROOT}/setup-init/.ssh/${STUDENT}-ssh.pem"
SSH_OPTIONS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o ServerAliveInterval=60 -o ServerAliveCountMax=3 -o ConnectTimeout=10 -o TCPKeepAlive=yes"

#######################################
# Fix SSH key permissions & known_hosts
#######################################
if [ -f "$SSH_KEY" ]; then
    chmod 600 "$SSH_KEY"
    echo "Fixed permissions on ${SSH_KEY}"
else
    echo "WARNING: SSH key not found: ${SSH_KEY}"
fi
# Remove only lab hosts from known_hosts (preserve other entries like github.com)
LAB_SUFFIX="${STUDENT}.xc-mcn-lab.aws"
if [ -f ~/.ssh/known_hosts ]; then
    grep -o "^[^ ,]*" ~/.ssh/known_hosts | grep "${LAB_SUFFIX}" | while read -r host; do
        ssh-keygen -R "${host}" 2>/dev/null
    done || true
    echo "Removed lab hosts (*${LAB_SUFFIX}) from ~/.ssh/known_hosts"
else
    echo "No ~/.ssh/known_hosts found, skipping cleanup"
fi

#######################################
# SSH Connection Definitions
# Format: "user@host|Tab Title"
#######################################
SSH_CONNECTIONS=(
    "ubuntu@ubuntu-01-eu-central-1.${STUDENT}.xc-mcn-lab.aws|Ubuntu EU-Central-1 01"
    "ubuntu@ubuntu-02-eu-central-1.${STUDENT}.xc-mcn-lab.aws|Ubuntu EU-Central-1 02"
    "ubuntu@ubuntu-01-eu-west-1.${STUDENT}.xc-mcn-lab.aws|Ubuntu EU-West-1 01"
    "ubuntu@ubuntu-02-eu-west-1.${STUDENT}.xc-mcn-lab.aws|Ubuntu EU-West-1 02"
    "admin@bigip-mgmt-eu-central-1.${STUDENT}.xc-mcn-lab.aws|BigIP EU-Central-1"
    "admin@bigip-mgmt-eu-west-1.${STUDENT}.xc-mcn-lab.aws|BigIP EU-West-1"
)

#######################################
# Usage
#######################################
usage() {
    echo "Usage: $0 [target]"
    echo ""
    echo "Targets:"
    echo "  all          - Open SSH to all hosts (default)"
    echo "  ubuntu       - All 4 Ubuntu servers"
    echo "  bigip        - Both BigIP management interfaces"
    echo "  central      - Ubuntu 01+02 and BigIP in eu-central-1"
    echo "  west         - Ubuntu 01+02 and BigIP in eu-west-1"
    echo "  fix-perms    - Only fix SSH key permissions (no SSH sessions)"
    echo ""
    echo "Each session opens in a new terminal tab."
    echo "Supports: Terminal.app (default), iTerm2"
    exit 1
}

#######################################
# Detect macOS terminal emulator
#######################################
detect_terminal() {
    if [ -d "/Applications/iTerm.app" ]; then
        echo "iterm2"
    elif [ -d "/System/Applications/Utilities/Terminal.app" ] || [ -d "/Applications/Terminal.app" ]; then
        echo "terminal"
    else
        echo "none"
    fi
}

#######################################
# Open SSH in a new tab — Terminal.app
#######################################
open_tab_terminal_app() {
    local title="$1"
    local ssh_cmd="$2"

    osascript <<EOF
tell application "Terminal"
    activate
    do script "${ssh_cmd}"
    set custom title of front tab of front window to "${title}"
end tell
EOF
}

#######################################
# Open SSH in a new tab — iTerm2
#######################################
open_tab_iterm2() {
    local title="$1"
    local ssh_cmd="$2"

    osascript <<EOF
tell application "iTerm2"
    activate
    tell current window
        create tab with default profile
        tell current session of current tab
            set name to "${title}"
            write text "${ssh_cmd}"
        end tell
    end tell
end tell
EOF
}

#######################################
# Open SSH in a new terminal tab
#######################################
open_ssh_window() {
    local title="$1"
    local host="$2"
    local terminal="$3"
    local ssh_cmd="ssh ${SSH_OPTIONS} -i ${SSH_KEY} ${host}"

    case "$terminal" in
        "iterm2")
            open_tab_iterm2 "${title}" "${ssh_cmd}"
            ;;
        "terminal")
            open_tab_terminal_app "${title}" "${ssh_cmd}"
            ;;
        *)
            echo "Error: No supported terminal emulator found"
            return 1
            ;;
    esac
}

#######################################
# Open sessions by index filter
#   Args: terminal, index list (space-separated)
#######################################
open_sessions() {
    local terminal="$1"
    shift
    local indices=("$@")
    local count=0

    for idx in "${indices[@]}"; do
        local entry="${SSH_CONNECTIONS[$idx]}"
        local host="${entry%%|*}"
        local title="${entry##*|}"

        echo "  Opening: ${title} (${host})"
        if open_ssh_window "${title}" "${host}" "${terminal}"; then
            count=$((count + 1))
            sleep 1.5
        else
            echo "  Failed to open session for ${host}"
        fi
    done

    echo ""
    echo "Opened ${count} SSH session(s)."
}

#######################################
# Main
#######################################
if [ "$(uname -s)" != "Darwin" ]; then
    echo "ERROR: This script is for macOS only. Use ssh-key-permission_lnx.sh on Linux."
    exit 1
fi

TARGET="${1:-all}"

# fix-perms exits early -- permissions already fixed above
if [ "$TARGET" = "fix-perms" ]; then
    echo "Done. SSH key permissions fixed."
    exit 0
fi

# Validate SSH key exists
if [ ! -f "$SSH_KEY" ]; then
    echo "ERROR: SSH key not found: ${SSH_KEY}"
    exit 1
fi

TERMINAL=$(detect_terminal)
if [ "$TERMINAL" = "none" ]; then
    echo "Error: No supported terminal emulator found."
    echo "Expected: Terminal.app or iTerm2 in /Applications"
    exit 1
fi

echo ""
echo "=== SSH Multi-Tab Connection Script (macOS) ==="
echo "Student:  ${STUDENT}"
echo "SSH Key:  ${SSH_KEY}"
echo "Terminal: ${TERMINAL}"
echo ""

case "$TARGET" in
    all)
        echo "Opening all SSH sessions..."
        open_sessions "$TERMINAL" 0 1 2 3 4 5
        ;;
    ubuntu)
        echo "Opening Ubuntu SSH sessions..."
        open_sessions "$TERMINAL" 0 1 2 3
        ;;
    bigip)
        echo "Opening BigIP SSH sessions..."
        open_sessions "$TERMINAL" 4 5
        ;;
    central)
        echo "Opening eu-central-1 SSH sessions..."
        open_sessions "$TERMINAL" 0 1 4
        ;;
    west)
        echo "Opening eu-west-1 SSH sessions..."
        open_sessions "$TERMINAL" 2 3 5
        ;;
    -h|--help|help)
        usage
        ;;
    *)
        echo "Unknown target: ${TARGET}"
        echo ""
        usage
        ;;
esac

echo "Done!"
