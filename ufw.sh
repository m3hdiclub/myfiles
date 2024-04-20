#!binbash

apt install ufw -y

ufw allow 7710

ufw allow 443

ufw allow 8443

ufw enable
