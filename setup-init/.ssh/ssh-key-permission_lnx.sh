#/bin/bash

chmod 600 ./setup-init/.ssh/de1chk1nd-ssh.pem
gnome-terminal -e 'ssh -i ./setup-init/.ssh/de1chk1nd-ssh.pem sudo ./setup-init/.ssh/ssh-key-permission_lnx.sh ubuntu@ubuntu-eu-central-1.de1chk1nd-lab.aws'
gnome-terminal -e 'ssh -i ./setup-init/.ssh/de1chk1nd-ssh.pem sudo ./setup-init/.ssh/ssh-key-permission_lnx.sh ubuntu@ubuntu-eu-west-1.de1chk1nd-lab.aws'