#cloud-config
repo_update: true
repo_upgrade: all

system_info:
  default_user:
    name: ${ssh_user}

packages:
  - tmux
  - git
  - wget
  - netcat

write_files:
- content: |
    PRJNAME=${hostname}
    HOST=$PRJNAME-$(hostname -I|awk '{print $1}')
    if [ "$EUID" = "0" ] ; then
      PS1='\[\033[01;31m\]$HOST\[\033[01;34m\] \W \$\[\033[00m\] '
    else
      PS1='\[\033[01;${prompt_color}\]\u@$HOST\[\033[01;34m\] \W \$\[\033[00m\] '
    fi
  path: /etc/profile.d/ps1.sh

runcmd:
  - systemctl stop postfix && systemctl disable postfix
  - echo "\n. /etc/profile.d/ps1.sh" | tee -a /home/${ssh_user}/.bashrc
  - echo "\n. /etc/profile.d/ps1.sh" | tee -a /root/.bashrc
