#!/bin/bash
# رنگ‌ها
GREEN="\033[1;32m"
CYAN="\033[1;36m"
RED="\033[1;31m"
RESET="\033[0m"

# دریافت پورت جدید از کاربر
echo -e "${CYAN}Please Enter the new SSH port:${RESET}"
read -p "> " new_port

# بررسی معتبر بودن پورت وارد شده
if [[ ! "$new_port" =~ ^[0-9]+$ ]] || [ "$new_port" -lt 1 ] || [ "$new_port" -gt 65535 ]; then
    echo -e "${RED}خطا:${RESET} پورت وارد شده معتبر نیست! پورت باید یک عدد بین 1 تا 65535 باشد."
    exit 1
fi

# تغییر پورت SSH
echo -e "${CYAN}در حال بروزرسانی پورت SSH به $new_port...${RESET}"
sudo sed -i -E "s/^#?Port .*/Port $new_port/" /etc/ssh/sshd_config
grep -q "^Port $new_port" /etc/ssh/sshd_config || echo "Port $new_port" | sudo tee -a /etc/ssh/sshd_config

# راه‌اندازی مجدد SSH
echo -e "${CYAN}در حال راه‌اندازی مجدد سرویس SSH...${RESET}"
if sudo systemctl restart sshd; then
    echo -e "${GREEN}سرویس SSH با موفقیت راه‌اندازی مجدد شد!${RESET}"
else
    echo -e "${RED}خطا:${RESET} راه‌اندازی مجدد سرویس SSH با شکست مواجه شد!"
    exit 1
fi

# نصب UFW و تنظیم قوانین
echo -e "${CYAN}در حال پیکربندی UFW...${RESET}"
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/m3hdiclub/myfiles/main/ufw.sh)" && \
echo -e "${GREEN}UFW با موفقیت پیکربندی شد!${RESET}"

# نمایش پورت جدید
echo -e "${GREEN}موفقیت!${RESET} پورت جدید SSH: ${CYAN}$new_port${RESET}"
