#!/bin/bash
set -e  # Exit on error

#######################################
# Load Common Configuration
#######################################
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
source "${REPO_ROOT}/setup-init/lib/common-config-loader.sh"

STUDENT=$(yq '.student.name' "${REPO_ROOT}/setup-init/config.yaml")
SSH_KEY="${REPO_ROOT}/setup-init/.ssh/${STUDENT}-ssh.pem"
SSH_OPTIONS="-o StrictHostKeyChecking=no -o ServerAliveInterval=60 -o ServerAliveCountMax=3"

HOST_CENTRAL="ubuntu@ubuntu-01-eu-central-1.${STUDENT}-lab.aws"
HOST_WEST="ubuntu@ubuntu-01-eu-west-1.${STUDENT}-lab.aws"

#######################################
# Usage
#######################################
usage() {
    echo "Usage: $0 [central|west|both]"
    echo ""
    echo "  central  - SSH to Ubuntu EU-Central-1 Web 01"
    echo "  west     - SSH to Ubuntu EU-West-1 Web 01"
    echo "  both     - Open both sessions (default)"
    echo ""
    echo "  Each session opens in a new terminal window."
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
            gnome-terminal --window --title="${title}" -- bash -c "${ssh_cmd}; echo 'Connection closed. Press Enter to exit.'; read"
            ;;
        "xfce4-terminal")
            xfce4-terminal --title="${title}" -e "bash -c '${ssh_cmd}; echo \"Connection closed. Press Enter to exit.\"; read'" &
            ;;
        "konsole")
            konsole -p tabtitle="${title}" -e bash -c "${ssh_cmd}; echo 'Connection closed. Press Enter to exit.'; read" &
            ;;
        "x-terminal-emulator")
            x-terminal-emulator -T "${title}" -e bash -c "${ssh_cmd}; echo 'Connection closed. Press Enter to exit.'; read" &
            ;;
    esac
}

#######################################
# Main
#######################################
TERMINAL=$(detect_terminal)
if [ "$TERMINAL" = "none" ]; then
    echo "Error: No supported terminal emulator found."
    exit 1
fi

echo "Using terminal: ${TERMINAL}"

case "${1:-both}" in
    central)
        open_ssh_window "EU-Central-1 Web 01" "${HOST_CENTRAL}" "${TERMINAL}"
        ;;
    west)
        open_ssh_window "EU-West-1 Web 01" "${HOST_WEST}" "${TERMINAL}"
        ;;
    both)
        open_ssh_window "EU-Central-1 Web 01" "${HOST_CENTRAL}" "${TERMINAL}"
        sleep 1
        open_ssh_window "EU-West-1 Web 01" "${HOST_WEST}" "${TERMINAL}"
        ;;
    *)
        usage
        ;;
esac

echo "Done!"
