#!/bin/bash

# تعریف رنگ‌ها
red='\033[0;31m'
bblue='\033[0;34m'
yellow='\033[0;33m'
green='\033[0;32m'
plain='\033[0m'

# توابع برای نمایش متن رنگی
red() { echo -e "\033[31m\033[01m$1\033[0m"; }
green() { echo -e "\033[32m\033[01m$1\033[0m"; }
yellow() { echo -e "\033[33m\033[01m$1\033[0m"; }
blue() { echo -e "\033[36m\033[01m$1\033[0m"; }
white() { echo -e "\033[37m\033[01m$1\033[0m"; }
bblue() { echo -e "\033[34m\033[01m$1\033[0m"; }
rred() { echo -e "\033[35m\033[01m$1\033[0m"; }
readtp() { read -t5 -n26 -p "$(yellow "$1")" $2; }
readp() { read -p "$(yellow "$1")" $2; }

# ----------------------------------------نمایش منو اصلی------------------------------------------------
display_main_menu() {
    clear 
    echo
    echo
    bblue "                 ███╗   ███╗███████╗██╗  ██╗██████═╗ ██╗              "
    bblue "                 ████╗ ████║██╔════╝██║  ██║██   ██║ ██║             "
    bblue "                 ██╔████╔██║█████╗  ███████║██   ██║ ██║             "
    bblue "                 ██║╚██╔╝██║██╔══╝  ██╔══██║██   ██║ ██║             "
    bblue "                 ██║ ╚═╝ ██║███████╗██║  ██║██████ ║ ██║            "
    bblue "                 ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝             "
    white "------------------------------------------------------------------"
    white " Telegram: https://t.me/m3hdiclubsupport"
    echo
    echo
    yellow "-----------------INSTALL----------------------------"
    echo
    green "1. UPDATE                2. UPDATE2"
    echo
    yellow "--------------------Panels-----------------------------"
    echo
    green "3. S-UI                  4. H-UI"
    echo
    green "5. X-UI [3x]                  6. X-UI [alireza]"
    echo
    rred "0. Exit"
    echo "------------------------------------------------------"
}

# توابع برای اجرای دستورات مربوط به هر گزینه
update() {
    echo "Executing UPDATE..."
    # دستوراتی که مربوط به گزینه 1 هستند
}

update2() {
    echo "Executing UPDATE2..."
    # دستوراتی که مربوط به گزینه 2 هستند
}

s_ui() {
    echo "Executing S-UI..."
    # دستوراتی که مربوط به گزینه 3 هستند
}

h_ui() {
    echo "Executing H-UI..."
    # دستوراتی که مربوط به گزینه 4 هستند
}

x_ui_3x() {
    echo "Executing X-UI [3x]..."
    # دستوراتی که مربوط به گزینه 5 هستند
}

x_ui_alireza() {
    echo "Executing X-UI [alireza]..."
    # دستوراتی که مربوط به گزینه 6 هستند
}

exit_script() {
    echo "Exiting..."
    exit 0
}

# حلقه برای نمایش منو و دریافت ورودی از کاربر
while true; do
    display_main_menu
    read -p "$(yellow "Select an option: ")" option
    case $option in
        1) update ;;
        2) update2 ;;
        3) s_ui ;;
        4) h_ui ;;
        5) x_ui_3x ;;
        6) x_ui_alireza ;;
        0) exit_script ;;
        *) echo "$(red "Invalid option!")" ;;
    esac
done
