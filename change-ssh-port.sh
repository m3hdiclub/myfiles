#!binbash

apt install net-tools -y

nano /etc/ssh/sshd_config

systemctl restart sshd.service
