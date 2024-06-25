**Setup Server**


**Update**
```
apt update -y && apt upgrade -y
```


**Change SSH port**
```
apt install net-tools
nano /etc/ssh/sshd_config
```
```
systemctl restart sshd.service
```


**Install Firewall**
```
apt install ufw
ufw allow 7710
ufw allow 9877
ufw allow 443
ufw allow 8443
ufw enable
```


**s-ui Alireza0**
https://github.com/alireza0/s-ui
```
bash <(curl -Ls https://raw.githubusercontent.com/alireza0/s-ui/master/install.sh)
```


**x-ui Alireza0**
https://github.com/alireza0/x-ui
```
bash <(curl -Ls https://raw.githubusercontent.com/alireza0/x-ui/master/install.sh)
```


**x-ui MHSanaei**
https://github.com/MHSanaei/3x-ui
```
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
```


**ezpz Panel**
https://github.com/aleskxyz/reality-ezpz
```
bash <(curl -sL https://bit.ly/realityez)
```


**Install MTProto**
https://github.com/seriyps/mtproto_proxy
```
curl -L -o mtp_install.sh https://git.io/fj5ru && bash mtp_install.sh
```
