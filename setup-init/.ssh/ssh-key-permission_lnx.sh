#/bin/bash

chmod 600 ./setup-init/.ssh/de1chk1nd-ssh.pem
x-terminal-emulator -e '/usr/bin/ssh -o ServerAliveInterval=180 -o ServerAliveCountMax=2 -o StrictHostKeyChecking=no -i /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.ssh/de1chk1nd-ssh.pem ubuntu@ubuntu-eu-central-1.de1chk1nd-lab.aws' &
x-terminal-emulator -e '/usr/bin/ssh -o ServerAliveInterval=180 -o ServerAliveCountMax=2 -o StrictHostKeyChecking=no -i /home/de1chk1nd/Documents/git-repositories/xC-mcn-demo/setup-init/.ssh/de1chk1nd-ssh.pem ubuntu@ubuntu-eu-west-1.de1chk1nd-lab.aws' &