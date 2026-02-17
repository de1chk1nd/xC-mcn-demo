#!/usr/bin/env bash
set -e

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
    echo "ERROR: yq not installed"
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
rm -f ~/.ssh/known_hosts 2>/dev/null
echo "Cleared ~/.ssh/known_hosts"

#######################################
# SSH Connection Definitions
# Format: "user@host|Tab Title"
#######################################
SSH_CONNECTIONS=(
    "ubuntu@ubuntu-01-eu-central-1.${STUDENT}-lab.aws|Ubuntu EU-Central-1 01"
    "ubuntu@ubuntu-02-eu-central-1.${STUDENT}-lab.aws|Ubuntu EU-Central-1 02"
    "ubuntu@ubuntu-01-eu-west-1.${STUDENT}-lab.aws|Ubuntu EU-West-1 01"
    "ubuntu@ubuntu-02-eu-west-1.${STUDENT}-lab.aws|Ubuntu EU-West-1 02"
    "admin@bigip-mgmt-eu-central-1.${STUDENT}-lab.aws|BigIP EU-Central-1"
    "admin@bigip-mgmt-eu-west-1.${STUDENT}-lab.aws|BigIP EU-West-1"
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
    echo "Each session opens in a new terminal tab/window."
    exit 1
}

#######################################
# Detect terminal emulator
#######################################
detect_terminal() {
    if command -v gnome-terminal &> /dev/null; then
        echo "gnome-terminal"
    elif command -v xfce4-terminal &> /dev/null; then
        echo "xfce4-terminal"
    elif command -v konsole &> /dev/null; then
        echo "konsole"
    elif command -v x-terminal-emulator &> /dev/null; then
        echo "x-terminal-emulator"
    elif command -v terminator &> /dev/null; then
        echo "terminator"
    else
        echo "none"
    fi
}

#######################################
# Open SSH in a new terminal window
#######################################
open_ssh_window() {
    local title="$1"
    local host="$2"
    local terminal="$3"
    local ssh_cmd="ssh ${SSH_OPTIONS} -i ${SSH_KEY} ${host}"

    case $terminal in
        "gnome-terminal")
            gnome-terminal --tab --title="${title}" -- bash -c "${ssh_cmd}; echo 'Connection closed. Press Enter to exit.'; read"
            ;;
        "xfce4-terminal")
            xfce4-terminal --tab --title="${title}" -e "bash -c '${ssh_cmd}; echo \"Connection closed. Press Enter to exit.\"; read'" &
            ;;
        "konsole")
            konsole --new-tab -p tabtitle="${title}" -e bash -c "${ssh_cmd}; echo 'Connection closed. Press Enter to exit.'; read" &
            ;;
        "x-terminal-emulator")
            x-terminal-emulator -T "${title}" -e bash -c "${ssh_cmd}; echo 'Connection closed. Press Enter to exit.'; read" &
            ;;
        "terminator")
            terminator --new-tab --title="${title}" -e "bash -c '${ssh_cmd}; echo \"Connection closed. Press Enter to exit.\"; read'" &
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
            ((count++))
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
    echo "Install one of: gnome-terminal, xfce4-terminal, konsole, x-terminal-emulator, terminator"
    exit 1
fi

echo ""
echo "=== SSH Multi-Tab Connection Script ==="
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
