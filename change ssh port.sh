#!binbash

apt install net-tools

nano /etc/ssh/sshd_config

systemctl restart sshd.service