#!/usr/bin/env bash
chmod 600 ./setup-init/.ssh/de1chk1nd-ssh.pem
rm ~/.ssh/known_hosts

# Improved SSH Multi-Tab Terminal Script
# Adapted from existing x-terminal-emulator script with better timeout handling

# Configuration
SSH_KEY="/home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.ssh/de1chk1nd-ssh.pem"

# SSH Connection Options (improved for better reliability)
SSH_OPTIONS="-o ServerAliveInterval=60 -o ServerAliveCountMax=3 -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o TCPKeepAlive=yes -o ExitOnForwardFailure=yes"

# SSH Connections Configuration
# Format: "connection_string|tab_title"
SSH_CONNECTIONS=(
    "ubuntu@ubuntu-01-eu-central-1.de1chk1nd-lab.aws|Ubuntu EU-Central-1 01"
    "ubuntu@ubuntu-02-eu-central-1.de1chk1nd-lab.aws|Ubuntu EU-Central-1 02"
    "ubuntu@ubuntu-01-eu-west-1.de1chk1nd-lab.aws|Ubuntu EU-West-1 01"
    "ubuntu@ubuntu-02-eu-west-1.de1chk1nd-lab.aws|Ubuntu EU-West-1 02"
    "admin@bigip-mgmt-eu-central-1.de1chk1nd-lab.aws|BigIP EU-Central-1"
    "admin@bigip-mgmt-eu-west-1.de1chk1nd-lab.aws|BigIP EU-West-1"
)

# Function to detect available terminal emulator
detect_terminal() {
    if command -v gnome-terminal &> /dev/null; then
        echo "gnome-terminal"
    elif command -v x-terminal-emulator &> /dev/null; then
        echo "x-terminal-emulator"
    elif command -v xfce4-terminal &> /dev/null; then
        echo "xfce4-terminal"
    elif command -v konsole &> /dev/null; then
        echo "konsole"
    elif command -v terminator &> /dev/null; then
        echo "terminator"
    else
        echo "none"
    fi
}

# Function to open SSH session based on terminal type
open_ssh_session() {
    local connection=$1
    local title=$2
    local terminal=$3
    local ssh_command="/usr/bin/ssh $SSH_OPTIONS -i $SSH_KEY $connection"
    
    case $terminal in
        "gnome-terminal")
            gnome-terminal --tab --title="$title" -- bash -c "$ssh_command; echo 'Connection closed. Press Enter to exit.'; read; exit"
            ;;
        "x-terminal-emulator")
            x-terminal-emulator -T "$title" -e bash -c "$ssh_command; echo 'Connection closed. Press Enter to exit.'; read; exit"
            ;;
        "xfce4-terminal")
            xfce4-terminal --tab --title="$title" -e "bash -c '$ssh_command; echo \"Connection closed. Press Enter to exit.\"; read; exit'"
            ;;
        "konsole")
            konsole --new-tab -p tabtitle="$title" -e bash -c "$ssh_command; echo 'Connection closed. Press Enter to exit.'; read; exit"
            ;;
        "terminator")
            terminator --new-tab --title="$title" -e "bash -c '$ssh_command; echo \"Connection closed. Press Enter to exit.\"; read; exit'"
            ;;
        *)
            echo "Error: No supported terminal emulator found"
            return 1
            ;;
    esac
}

# Function to validate SSH key
validate_ssh_key() {
    if [ ! -f "$SSH_KEY" ]; then
        echo "Error: SSH key not found at $SSH_KEY"
        echo "Please check the path and ensure the key file exists."
        return 1
    fi
    
    if [ ! -r "$SSH_KEY" ]; then
        echo "Error: SSH key at $SSH_KEY is not readable"
        echo "Please check file permissions."
        return 1
    fi
    
    # Check if key has correct permissions (should be 600 or 400)
    local perms=$(stat -c "%a" "$SSH_KEY")
    if [ "$perms" != "600" ] && [ "$perms" != "400" ]; then
        echo "Warning: SSH key permissions are $perms. Recommended: 600 or 400"
        echo "You can fix this with: chmod 600 $SSH_KEY"
    fi
    
    return 0
}

# Function to test connectivity (optional)
test_connectivity() {
    local host=$1
    echo "Testing connectivity to $host..."
    
    # Extract hostname from user@host format
    local hostname=$(echo "$host" | sed 's/.*@//')
    
    # Quick connectivity test with timeout
    if timeout 5 nc -z "$hostname" 22 2>/dev/null; then
        echo "✓ $hostname:22 is reachable"
        return 0
    else
        echo "✗ $hostname:22 is not reachable (this might be normal if using jump hosts)"
        return 1
    fi
}

# Main execution
main() {
    echo "=== SSH Multi-Tab Connection Script ==="
    echo "Setting up connections to AWS infrastructure..."
    echo
    
    # Validate SSH key
    if ! validate_ssh_key; then
        exit 1
    fi
    
    # Detect terminal
    TERMINAL=$(detect_terminal)
    if [ "$TERMINAL" = "none" ]; then
        echo "Error: No supported terminal emulator found."
        echo "Please install one of: gnome-terminal, xfce4-terminal, konsole, terminator"
        exit 1
    fi
    
    echo "Using terminal: $TERMINAL"
    echo "SSH Key: $SSH_KEY"
    echo "SSH Options: $SSH_OPTIONS"
    echo
    
    # Optional: Test connectivity (uncomment if needed)
    # echo "Testing connectivity..."
    # for connection_info in "${SSH_CONNECTIONS[@]}"; do
    #     connection=$(echo "$connection_info" | cut -d'|' -f1)
    #     test_connectivity "$connection"
    # done
    # echo
    
    echo "Opening SSH sessions..."
    
    # Process each connection
    local count=0
    for connection_info in "${SSH_CONNECTIONS[@]}"; do
        connection=$(echo "$connection_info" | cut -d'|' -f1)
        title=$(echo "$connection_info" | cut -d'|' -f2)
        
        echo "Opening: $title ($connection)"
        
        if open_ssh_session "$connection" "$title" "$TERMINAL"; then
            ((count++))
            # Staggered delay to prevent overwhelming the system
            sleep 1.5
        else
            echo "Failed to open session for $connection"
        fi
    done
    
    echo
    echo "Successfully opened $count SSH sessions!"
    echo
    echo "Tips:"
    echo "- If a connection fails, the terminal tab will remain open with an error message"
    echo "- Use Ctrl+Shift+T to open new tabs manually if needed"
    echo "- SSH keepalive is set to 60 seconds with 3 retries for better stability"
}

# Run the script
main "$@"







## ubuntu-eu-central-1
#sleep 2
#x-terminal-emulator -e '/usr/bin/ssh -o ServerAliveInterval=180 -o ServerAliveCountMax=2 -o StrictHostKeyChecking=no -i /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.ssh/de1chk1nd-ssh.pem ubuntu@ubuntu-01-eu-central-1.de1chk1nd-lab.aws' &
#sleep 2
#x-terminal-emulator -e '/usr/bin/ssh -o ServerAliveInterval=180 -o ServerAliveCountMax=2 -o StrictHostKeyChecking=no -i /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.ssh/de1chk1nd-ssh.pem ubuntu@ubuntu-02-eu-central-1.de1chk1nd-lab.aws' &
## ubuntu-eu-west-1
#sleep 2
#x-terminal-emulator -e '/usr/bin/ssh -o ServerAliveInterval=180 -o ServerAliveCountMax=2 -o StrictHostKeyChecking=no -i /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.ssh/de1chk1nd-ssh.pem ubuntu@ubuntu-01-eu-west-1.de1chk1nd-lab.aws' &
#sleep 2
#x-terminal-emulator -e '/usr/bin/ssh -o ServerAliveInterval=180 -o ServerAliveCountMax=2 -o StrictHostKeyChecking=no -i /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.ssh/de1chk1nd-ssh.pem ubuntu@ubuntu-02-eu-west-1.de1chk1nd-lab.aws' &
## bigip-mgmt all regions
#sleep 2
#x-terminal-emulator -e '/usr/bin/ssh -o ServerAliveInterval=180 -o ServerAliveCountMax=2 -o StrictHostKeyChecking=no -i /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.ssh/de1chk1nd-ssh.pem admin@bigip-mgmt-eu-central-1.de1chk1nd-lab.aws' &
#sleep 2
#x-terminal-emulator -e '/usr/bin/ssh -o ServerAliveInterval=180 -o ServerAliveCountMax=2 -o StrictHostKeyChecking=no -i /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.ssh/de1chk1nd-ssh.pem admin@bigip-mgmt-eu-west-1.de1chk1nd-lab.aws' &