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
