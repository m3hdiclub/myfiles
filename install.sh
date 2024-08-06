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
    yellow "--------------------INSTALL----------------------------"
    echo
    green "1. UPDATE                2. Change SSH Port"
    echo
    green "3. Firewall              4. UFW [ ADD ]"
    echo
    yellow "--------------------Panels-----------------------------"
    echo
    green "5. S-UI                  6. H-UI"
    echo
    green "7. X-UI [alireza]        8. X-UI [3x]"
    echo
	green "9. reality-ezpz          10. Hiddify"
    echo
	green "11. XPanel				12. SSH [vfarid]"
    echo
	yellow "--------------------Another-----------------------------"
	echo
	green "13. MTProxy				14. Add SSH"
	echo
    echo "------------------------------------------------------"
	echo
	rred  "0. Exit"
	echo
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

change_ssh_port() {
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
    while true; do
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
            
            # بررسی موفقیت باز کردن پورت‌ها
            if [ $? -eq 0 ]; then
                echo "$(green "Ports configured successfully.")"
                
                echo "$(green "Enabling UFW...")"
                
                # فعال کردن ufw
                sudo ufw enable
                
                # بررسی موفقیت فعال‌سازی ufw
                if [ $? -eq 0 ]; then
                    echo "$(green "UFW has been enabled successfully.")"
                else
                    echo "$(red "Failed to enable UFW.")"
                fi
            else
                echo "$(red "Failed to configure ports.")"
            fi
        else
            echo "$(red "Failed to install UFW.")"
        fi

        # بررسی وضعیت نصب
        read -p "$(yellow "Is UFW setup correct? (y/n): ")" answer
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

ufw_add() {
    while true; do
        # درخواست ورودی برای پورت
        read -p "$(yellow "Enter the port number to allow: ")" port
        
        # بررسی اینکه ورودی عددی است
        if [[ $port =~ ^[0-9]+$ ]]; then
            # اضافه کردن پورت به ufw و ذخیره خروجی در متغیر
            output=$(sudo ufw allow $port 2>&1)
            
            # بررسی موفقیت اجرای دستور
            if [[ $output == *"Rule added"* ]]; then
                echo "$(green "Port $port has been added successfully.")"
            elif [[ $output == *"Skipping adding existing rule"* ]]; then
                echo "$(yellow "Port $port is already in the list.")"
            else
                echo "$(red "Failed to add port $port. Output: $output")"
                # ادامه یافتن در حلقه برای دریافت پورت جدید
                continue
            fi

            # نمایش وضعیت فعلی ufw
            echo "$(green "Current UFW status:")"
            sudo ufw status
            
            # بررسی وضعیت نصب
            read -p "$(yellow "Is the port addition correct? (y/n): ")" answer
            case $answer in
                y|Y)
                    echo "$(green "Port addition confirmed. Returning to the menu...")"
                    break ;;
                n|N)
                    echo "$(yellow "Let's try adding another port.")"
                    # ادامه یافتن در حلقه برای دریافت پورت جدید
                    continue ;;
                *)
                    echo "$(red "Invalid input. Please type y or n.")"
                    # ادامه یافتن در حلقه برای دریافت پورت جدید
                    continue ;;
            esac
        else
            echo "$(red "Invalid port number. Please enter a valid number.")"
            # ادامه یافتن در حلقه برای دریافت پورت جدید
            continue
        fi
    done
}

s_ui() {
    while true; do
        echo "Installing S-UI..."
        bash <(curl -Ls https://raw.githubusercontent.com/alireza0/s-ui/master/install.sh)

        # بررسی وضعیت نصب
        read -p "$(yellow "Is the S-UI installed correctly? (y/n): ")" answer
        case $answer in
            y|Y)
                echo "$(green "S-UI installation confirmed. Returning to the menu...")"
                break ;;
            n|N)
                echo "$(red "Re-running S-UI installation...")"
                ;;
            *)
                echo "$(red "Invalid input. Please type y or n.")"
                ;;
        esac
    done
}

h_ui() {
    while true; do
        echo "Installing H-UI..."
        bash <(curl -fsSL https://raw.githubusercontent.com/jonssonyan/h-ui/main/install.sh)

        # بررسی وضعیت نصب
        read -p "$(yellow "Is the H-UI installed correctly? (y/n): ")" answer
        case $answer in
            y|Y)
                echo "$(green "H-UI installation confirmed. Returning to the menu...")"
                break ;;
            n|N)
                echo "$(red "Re-running H-UI installation...")"
                ;;
            *)
                echo "$(red "Invalid input. Please type y or n.")"
                ;;
        esac
    done
}

x_ui_3x() {
    while true; do
        echo "Installing x-ui 3x..."
        bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)

        # بررسی وضعیت نصب
        read -p "$(yellow "Is the x-ui 3x installed correctly? (y/n): ")" answer
        case $answer in
            y|Y)
                echo "$(green "x-ui 3x installation confirmed. Returning to the menu...")"
                break ;;
            n|N)
                echo "$(red "Re-running x-ui 3x installation...")"
                ;;
            *)
                echo "$(red "Invalid input. Please type y or n.")"
                ;;
        esac
    done
}

x_ui_alireza() {
    while true; do
        echo "Installing x-ui alireza..."
        bash <(curl -Ls https://raw.githubusercontent.com/alireza0/x-ui/master/install.sh)

        # بررسی وضعیت نصب
        read -p "$(yellow "Is the x-ui alireza installed correctly? (y/n): ")" answer
        case $answer in
            y|Y)
                echo "$(green "x-ui alireza installation confirmed. Returning to the menu...")"
                break ;;
            n|N)
                echo "$(red "Re-running x-ui alireza installation...")"
                ;;
            *)
                echo "$(red "Invalid input. Please type y or n.")"
                ;;
        esac
    done
}

ezpz() {
    while true; do
        echo "Installing reality-ezpz..."
        bash <(curl -sL https://bit.ly/realityez)

        # بررسی وضعیت نصب
        read -p "$(yellow "Is the reality-ezpz installed correctly? (y/n): ")" answer
        case $answer in
            y|Y)
                echo "$(green "reality-ezpz installation confirmed. Returning to the menu...")"
                break ;;
            n|N)
                echo "$(red "Re-running reality-ezpz installation...")"
                ;;
            *)
                echo "$(red "Invalid input. Please type y or n.")"
                ;;
        esac
    done
}

hiddify() {
    while true; do
        echo "Installing Hiddify..."
        bash <(curl i.hiddify.com/release)

        # بررسی وضعیت نصب
        read -p "$(yellow "Is the Hiddify installed correctly? (y/n): ")" answer
        case $answer in
            y|Y)
                echo "$(green "Hiddify installation confirmed. Returning to the menu...")"
                break ;;
            n|N)
                echo "$(red "Re-running Hiddify installation...")"
                ;;
            *)
                echo "$(red "Invalid input. Please type y or n.")"
                ;;
        esac
    done
}

xpanel() {
    while true; do
        echo "Installing XPanel..."
        bash <(curl -Ls https://raw.githubusercontent.com/xpanel-cp/XPanel-SSH-User-Management/master/install.sh --ipv4)

        # بررسی وضعیت نصب
        read -p "$(yellow "Is the XPanel installed correctly? (y/n): ")" answer
        case $answer in
            y|Y)
                echo "$(green "XPanel installation confirmed. Returning to the menu...")"
                break ;;
            n|N)
                echo "$(red "Re-running XPanel installation...")"
                ;;
            *)
                echo "$(red "Invalid input. Please type y or n.")"
                ;;
        esac
    done
}

ssh_vfarid() {
    while true; do
        echo "Installing SSH vfarid..."
        wget -O ssh-panel-install.sh https://raw.githubusercontent.com/vfarid/ssh-panel/main/install.sh && sudo sh ssh-panel-install.sh

        # بررسی وضعیت نصب
        read -p "$(yellow "Is the SSH vfarid installed correctly? (y/n): ")" answer
        case $answer in
            y|Y)
                echo "$(green "SSH vfarid installation confirmed. Returning to the menu...")"
                break ;;
            n|N)
                echo "$(red "Re-running SSH vfarid installation...")"
                ;;
            *)
                echo "$(red "Invalid input. Please type y or n.")"
                ;;
        esac
    done
}

mtproxy() {
    while true; do
        echo "Installing MTproto..."
        curl -L -o mtp_install.sh https://git.io/fj5ru && bash mtp_install.sh

        # بررسی وضعیت نصب
        read -p "$(yellow "Is the MTproto installed correctly? (y/n): ")" answer
        case $answer in
            y|Y)
                echo "$(green "MTproto installation confirmed. Returning to the menu...")"
                break ;;
            n|N)
                echo "$(red "Re-running MTproto installation...")"
                ;;
            *)
                echo "$(red "Invalid input. Please type y or n.")"
                ;;
        esac
    done
}

add_ssh() {
    while true; do
        clear
        echo "$(yellow "SSH User Management")"
        echo
        echo "$(green "1. Add SSH User")"
        echo "$(green "2. Remove SSH User")"
        echo "$(green "3. List SSH Users")"
        echo "$(rred "0. Back to Main Menu")"
        echo
        read -p "$(yellow "Select an option: ")" option
        case $option in
            1) add_ssh_user ;;
            2) remove_ssh_user ;;
            3) list_ssh_users ;;
            0) break ;;
            *) echo "$(red "Invalid option. Please try again.")" ;;
        esac
    done
}

add_ssh_user() {
    read -p "$(yellow "Enter new SSH username: ")" username
    if id "$username" &>/dev/null; then
        echo "$(red "User '$username' already exists.")"
    else
        # اضافه کردن کاربر جدید با شل nologin
        sudo adduser --shell /usr/sbin/nologin "$username"
        echo "$(green "User '$username' added successfully with nologin shell.")"
    fi
}


remove_ssh_user() {
    read -p "$(yellow "Enter SSH username to remove: ")" username
    if id "$username" &>/dev/null; then
        sudo deluser "$username"
        sudo rm -rf /home/"$username"
        echo "$(green "User '$username' removed successfully.")"
    else
        echo "$(red "User '$username' does not exist.")"
    fi
}

list_ssh_users() {
    echo "$(green "Listing SSH users:")"
    awk -F: '{ print $1}' /etc/passwd
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
        2) change_ssh_port ;;
        3) ufw ;;
		4) ufw_add ;;
        5) s_ui ;;
        6) h_ui ;;
        7) x_ui_alireza ;;
        8) x_ui_3x ;;
		9) ezpz ;;
		10) hiddify ;;
		11) xpanel ;;
		12) ssh_vfarid ;;
		13) mtproxy ;;
		14) add_ssh ;;
        0) exit_script ;;
        *) echo "$(red "Invalid option!")" ;;
    esac
done
