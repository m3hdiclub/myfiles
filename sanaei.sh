#!/bin/bash

# اجرای دستور apt update با گزینه -y برای تایید خودکار
apt update -y

# اجرای دستور apt upgrade با گزینه -y برای تایید خودکار
apt upgrade -y

# اجرای دستور bash با استفاده از curl برای دانلود و اجرای اسکریپت install.sh
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
