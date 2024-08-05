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
    green "1. UPDATE"
    echo
    green "2. Change SSH            3. UFW"
    echo
    yellow "--------------------Panels-----------------------------"
    echo
    green "4. S-UI                  5. H-UI"
    echo
    green "6. X-UI [3x]             7. X-UI [alireza]"
    echo
    rred  "0. Exit"
    echo "------------------------------------------------------"
}

# توابع برای اجرای دستورات مربوط به هر گزینه
update() {
    while true; do
        echo "$(green "Updating system...")"
        
        # اجرای دستور apt update
        sudo apt update -y
        
        # بررسی موفقیت دستور apt update
        if [ $? -eq 0 ]; then
            echo "$(green "Update successful. Proceeding with upgrade...")"
            
            # اجرای دستور apt upgrade
            sudo apt upgrade -y
            
            # بررسی موفقیت دستور apt upgrade
            if [ $? -eq 0 ]; then
                echo "$(green "Upgrade successful.")"
            else
                echo "$(red "Upgrade failed.")"
            fi
        else
            echo "$(red "Update failed.")"
        fi

        # بررسی وضعیت نصب
        read -p "$(yellow "Is the script installed correctly? (y/n): ")" answer
        case $answer in
            y|Y)
                echo "$(green "Returning to the menu...")"
                break ;;
            n|N)
                echo "$(red "Reinstalling...")"
                ;;
            *)
                echo "$(red "Invalid input. Please type y or n.")"
                ;;
        esac
    done
}

change_ssh() {
    while true; do
        echo "$(green "Installing net-tools...")"
        
        # نصب بسته net-tools
        sudo apt install net-tools -y
        
        # بررسی موفقیت نصب net-tools
        if [ $? -eq 0 ]; then
            echo "$(green "net-tools installed successfully.")"
            
            echo "$(green "Opening SSH configuration file...")"
            
            # باز کردن فایل پیکربندی SSH با nano
            sudo nano /etc/ssh/sshd_config
            
            # بررسی موفقیت خروج از nano و ذخیره تغییرات
            if [ $? -eq 0 ]; then
                echo "$(green "Configuration file edited successfully.")"
                
                echo "$(green "Restarting SSH service...")"
                
                # راه‌اندازی مجدد سرویس SSH
                sudo systemctl restart sshd.service
                
                # بررسی موفقیت راه‌اندازی مجدد سرویس
                if [ $? -eq 0 ]; then
                    echo "$(green "SSH service restarted successfully.")"
                else
                    echo "$(red "Failed to restart SSH service.")"
                fi
            else
                echo "$(red "Failed to edit SSH configuration file.")"
            fi
        else
            echo "$(red "Failed to install net-tools.")"
        fi

        # بررسی وضعیت نصب
        read -p "$(yellow "Is the SSH configuration correct? (y/n): ")" answer
        case $answer in
            y|Y)
                echo "$(green "Returning to the menu...")"
                break ;;
            n|N)
                echo "$(red "Reinstalling...")"
                ;;
            *)
                echo "$(red "Invalid input. Please type y or n.")"
                ;;
        esac
    done
}

ufw() {
    echo "$(green "Installing UFW...")"
    
    # نصب بسته ufw
    sudo apt install ufw -y
    
    # بررسی موفقیت نصب ufw
    if [ $? -eq 0 ]; then
        echo "$(green "UFW installed successfully.")"
        
        echo "$(green "Configuring UFW...")"
        
        # باز کردن پورت‌های مورد نظر
        sudo ufw allow 7710
        sudo ufw allow 9877
        sudo ufw allow 443
        sudo ufw allow 8443
        
        # فعال کردن ufw
        sudo ufw enable -y
        
        # بررسی موفقیت فعال‌سازی ufw
        if [ $? -eq 0 ]; then
            echo "$(green "UFW has been enabled successfully.")"
        else
            echo "$(red "Failed to enable UFW.")"
        fi
    else
        echo "$(red "Failed to install UFW.")"
    fi
}

s_ui() {
    echo "Executing S-UI..."
    # دستوراتی که مربوط به گزینه 4 هستند
}

h_ui() {
    echo "Executing H-UI..."
    # دستوراتی که مربوط به گزینه 5 هستند
}

x_ui_3x() {
    echo "Executing X-UI [3x]..."
    # دستوراتی که مربوط به گزینه 6 هستند
}

x_ui_alireza() {
    echo "Executing X-UI [alireza]..."
    # دستوراتی که مربوط به گزینه 7 هستند
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
        2) change_ssh ;;
        3) ufw ;;
        4) s_ui ;;
        5) h_ui ;;
        6) x_ui_3x ;;
        7) x_ui_alireza ;;
        0) exit_script ;;
        *) echo "$(red "Invalid option!")" ;;
    esac
done
