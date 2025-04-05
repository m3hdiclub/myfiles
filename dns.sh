#!/bin/bash
# رنگ‌ها
GREEN="\033[1;32m"
CYAN="\033[1;36m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
RESET="\033[0m"

echo -e "${CYAN}┌──────────────────────────────────┐${RESET}"
echo -e "${CYAN}│       تنظیم DNS سرور اوبونتو       │${RESET}"
echo -e "${CYAN}└──────────────────────────────────┘${RESET}"
echo

# بررسی دسترسی روت
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}خطا: این اسکریپت باید با دسترسی روت اجرا شود${RESET}"
    echo -e "لطفا با دستور ${YELLOW}sudo bash dns.sh${RESET} اجرا کنید"
    exit 1
fi

# تنظیم مقادیر DNS
echo -e "${CYAN}در حال تنظیم سرورهای DNS...${RESET}"
PRIMARY_DNS="8.8.8.8 8.8.4.4"
FALLBACK_DNS="1.1.1.1 1.0.0.1"

# بررسی و اصلاح فایل resolved.conf
CONFIG_FILE="/etc/systemd/resolved.conf"

# اگر خط DNS وجود داشته باشد (با یا بدون کامنت)، آن را با مقدار جدید جایگزین کنید
if grep -q "^#*DNS=" "$CONFIG_FILE"; then
    # جایگزینی خط موجود با مقدار جدید (کامنت شده یا نشده)
    sudo sed -i "s/^#*DNS=.*/DNS=$PRIMARY_DNS/" "$CONFIG_FILE"
    echo -e "${GREEN}DNS به ${YELLOW}$PRIMARY_DNS${GREEN} تنظیم شد${RESET}"
else
    # اضافه کردن خط DNS در صورت عدم وجود
    echo "DNS=$PRIMARY_DNS" | sudo tee -a "$CONFIG_FILE" > /dev/null
    echo -e "${GREEN}DNS به ${YELLOW}$PRIMARY_DNS${GREEN} اضافه شد${RESET}"
fi

# اگر خط FallbackDNS وجود داشته باشد (با یا بدون کامنت)، آن را با مقدار جدید جایگزین کنید
if grep -q "^#*FallbackDNS=" "$CONFIG_FILE"; then
    # جایگزینی خط موجود با مقدار جدید (کامنت شده یا نشده)
    sudo sed -i "s/^#*FallbackDNS=.*/FallbackDNS=$FALLBACK_DNS/" "$CONFIG_FILE"
    echo -e "${GREEN}FallbackDNS به ${YELLOW}$FALLBACK_DNS${GREEN} تنظیم شد${RESET}"
else
    # اضافه کردن خط FallbackDNS در صورت عدم وجود
    echo "FallbackDNS=$FALLBACK_DNS" | sudo tee -a "$CONFIG_FILE" > /dev/null
    echo -e "${GREEN}FallbackDNS به ${YELLOW}$FALLBACK_DNS${GREEN} اضافه شد${RESET}"
fi

# راه‌اندازی مجدد سرویس resolved
echo -e "${CYAN}در حال راه‌اندازی مجدد سرویس systemd-resolved...${RESET}"
if sudo systemctl restart systemd-resolved; then
    echo -e "${GREEN}سرویس systemd-resolved با موفقیت راه‌اندازی مجدد شد!${RESET}"
else
    echo -e "${RED}خطا: راه‌اندازی مجدد سرویس systemd-resolved با شکست مواجه شد!${RESET}"
    exit 1
fi

# نمایش اطلاعات فعلی DNS
echo -e "\n${CYAN}اطلاعات DNS سیستم بعد از تغییرات:${RESET}"
echo -e "${YELLOW}$(systemd-resolve --status | grep -A 2 'DNS Servers')${RESET}"

echo -e "\n${GREEN}تنظیمات DNS با موفقیت انجام شد!${RESET}"
