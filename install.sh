#!/bin/bash

# تعریف رنگ‌ها
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

# تابع برای نمایش پیام‌ها با رنگ
print_red() { echo -e "${red}$1${plain}"; }
print_green() { echo -e "${green}$1${plain}"; }
print_yellow() { echo -e "${yellow}$1${plain}"; }

# بررسی و نصب نرم‌افزارهای مورد نیاز
install_requirements() {
    if ! command -v curl &> /dev/null; then
        print_red "curl نصب نشده است. در حال نصب..."
        sudo apt-get update
        if sudo apt-get install curl -y; then
            print_green "curl با موفقیت نصب شد."
        else
            print_red "خطا: نصب curl شکست خورد."
            exit 1
        fi
    else
        print_green "curl از قبل نصب شده است."
    fi

    if ! command -v git &> /dev/null; then
        print_red "git نصب نشده است. در حال نصب..."
        sudo apt-get update
        if sudo apt-get install git -y; then
            print_green "git با موفقیت نصب شد."
        else
            print_red "خطا: نصب git شکست خورد."
            exit 1
        fi
    else
        print_green "git از قبل نصب شده است."
    fi
}

# نمایش منوی اصلی
display_main_menu() {
    clear
    echo
    print_yellow "----------------- منوی اصلی ---------------------"
    print_green "1. نمایش وضعیت سیستم"
    print_green "2. به‌روزرسانی سیستم"
    print_green "3. خروج"
    echo "--------------------------------------------------"
    read -p "لطفاً گزینه‌ای را انتخاب کنید: " choice

    case $choice in
        1)
            print_yellow "وضعیت سیستم:"
            uname -a
            ;;
        2)
            print_yellow "در حال به‌روزرسانی سیستم..."
            sudo apt-get update && sudo apt-get upgrade -y
            ;;
        3)
            print_red "خروج از برنامه"
            exit 0
            ;;
        *)
            print_red "گزینه نادرست است. لطفاً مجدداً امتحان کنید."
            display_main_menu
            ;;
    esac
}

# اجرای تابع نصب وابستگی‌ها
install_requirements

# نمایش منوی اصلی
display_main_menu
