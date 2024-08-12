#!/bin/bash

# بررسی نصب بودن curl و نصب در صورت نیاز
if ! command -v curl &> /dev/null; then
    echo "curl is not installed. Installing curl..."
    sudo apt update -y
    sudo apt install curl -y
fi

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
    red " Telegram: https://t.me/m3hdiclubsupport"
    echo
    echo
    yellow "--------------------INSTALL----------------------------"
    echo
    green "1. UPDATE                2. Change SSH Port"
    echo
    green "3. Firewall"
    echo
    yellow "--------------------Panels-----------------------------"
    echo
    green "4. S-UI                  5. H-UI"
    echo
    green "6. X-UI [alireza]        7. X-UI [3x]"
    echo
    green "8. reality-ezpz          9. Hiddify"
    echo
    green "10. XPanel               11. SSH [vfarid]"
    echo
    green "12. Marzban"
    echo
    yellow "--------------------Another-----------------------------"
    echo
    green "13. MTProxy              14. Add SSH"
    echo
    green "15. SpeedTest"
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
	clear
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
		answer=${answer:-Y}
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
	clear
 	sudo apt install nano
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
		answer=${answer:-Y}
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
		clear
        echo "$(bblue "UFW Menu")"
        echo
        echo "$(green "1. Install")"
        echo "$(green "2. Add Port")"
        echo "$(green "3. Enable")"
        echo "$(green "4. Disable")"
        echo "$(green "5. Delete Port")"
		echo "$(green "6. Status")"
        echo "$(red "0. Back to Main Menu")"
		echo
		
        read -p "$(yellow "Select an option: ")" ufw_option
        case $ufw_option in
            1)  # نصب UFW
                echo "$(green "Installing UFW...")"
                sudo apt install ufw -y
                if [ $? -eq 0 ]; then
                    echo "$(green "UFW installed successfully.")"
                else
                    echo "$(red "Failed to install UFW.")"
                fi
                ;;
            2)  # اضافه کردن پورت
                while true; do
                    read -p "Enter the port you want to allow: " port
                    if sudo ufw status | grep -q "$port.*ALLOW"; then
                        echo "$(yellow "Port $port is already allowed.")"
                    else
                        sudo ufw allow "$port"
                        if [ $? -eq 0 ]; then
                            echo "$(green "Port $port has been allowed successfully.")"
                        else
                            echo "$(red "Failed to allow port $port.")"
                        fi
                    fi
                    read -p "Do you want to add another port? (y/n): " add_another
                    add_another=${add_another:-Y}
                    if [[ $add_another =~ ^(n|N)$ ]]; then
                        break
                    fi
                done
                ;;
            3)  # فعال کردن UFW
                echo "$(green "Enabling UFW...")"
                sudo ufw enable
                if [ $? -eq 0 ]; then
                    echo "$(green "UFW has been enabled successfully.")"
                else
                    echo "$(red "Failed to enable UFW.")"
                fi
                ;;
            4)  # غیرفعال کردن UFW
                echo "$(green "Disabling UFW...")"
                sudo ufw disable
                if [ $? -eq 0 ]; then
                    echo "$(green "UFW has been disabled successfully.")"
                else
                    echo "$(red "Failed to disable UFW.")"
                fi
                ;;
            5)  # حذف پورت
                while true; do
                    sudo ufw status numbered
                    read -p "Enter the number of the rule you want to delete: " rule_number
                    sudo ufw delete "$rule_number"
                    if [ $? -eq 0 ]; then
                        echo "$(green "Rule number $rule_number has been deleted successfully.")"
                    else
                        echo "$(red "Failed to delete rule number $rule_number.")"
                    fi
                    read -p "Do you want to delete another rule? (y/n): " delete_another
                    delete_another=${delete_another:-Y}
                    if [[ $delete_another =~ ^(n|N)$ ]]; then
                        break
                    fi
                done
                ;;
			6)  # status
                echo "$(green "status...")"
                sudo ufw status
                if [ $? -eq 0 ]; then
                    echo "$(green "UFW port Enable: ")"
                else
                    echo "$(red "Failed to show")"
                fi
                ;;	
            0)
                echo "$(green "Returning to the main menu...")"
                break
                ;;
            *)
                echo "$(red "Invalid choice. Please enter a number between 1 and 6.")"
                ;;
        esac

        read -p "$(yellow "Do you want to return to the menu? (y/n): ")" return_to_menu
        return_to_menu=${return_to_menu:-Y}
        if [[ $return_to_menu =~ ^(n|N)$ ]]; then
            echo "$(green "Exiting...")"
            break
        fi
    done
}

s_ui() {
    while true; do
        clear
		echo "$(bblue "S-UI Menu")"
        echo
        echo "$(green "1. Install")"
        echo "$(green "2. Custom Install")"
        echo "$(green "3. Delete")"
        echo "$(red "0. Back to Main Menu")"
		echo

		read -p "$(yellow "Select an option: ")" s_ui_option
		case $s_ui_option in
            1)
                echo "Installing S-UI..."
                bash <(curl -Ls https://raw.githubusercontent.com/alireza0/s-ui/master/install.sh)

                # بررسی وضعیت نصب پس از اجرای دستور اول
                read -p "Is the S-UI installed correctly? (y/n): " answer
                answer=${answer:-Y}
                case $answer in
                    y|Y)
                        echo "S-UI installation confirmed. Returning to the menu..."
                        ;;
                    n|N)
                        echo "Re-running the installation..."
                        ;;
                    *)
                        echo "Invalid input. Please type y or n."
                        ;;
                esac
                ;;
            2)
                read -p "Enter a number for custom installation: " number
                echo "Performing custom installation with number $number..."
                bash <(curl -Ls https://raw.githubusercontent.com/alireza0/s-ui/master/install.sh) $number

                # بررسی وضعیت نصب پس از اجرای دستور دوم
                read -p "Is the S-UI installed correctly? (y/n): " answer
                answer=${answer:-Y}
                case $answer in
                    y|Y)
                        echo "S-UI installation confirmed. Returning to the menu..."
                        ;;
                    n|N)
                        echo "Re-running the installation..."
                        ;;
                    *)
                        echo "Invalid input. Please type y or n."
                        ;;
                esac
                ;;
            3)
                echo "Uninstalling S-UI..."
                s-ui uninstall

                # بررسی وضعیت حذف
                read -p "Was the S-UI uninstalled correctly? (y/n): " answer
                answer=${answer:-Y}
                case $answer in
                    y|Y)
                        echo "S-UI uninstallation confirmed. Returning to the menu..."
                        ;;
                    n|N)
                        echo "Please try uninstalling again."
                        ;;
                    *)
                        echo "Invalid input. Please type y or n."
                        ;;
                esac
                ;;
            0)
                echo "$(green "Returning to the main menu...")"
                break
                ;;
            *)
                echo "Invalid choice. Please select 1, 2, 3 or 0."
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
		answer=${answer:-Y}
        case $answer in
            y|Y)
				echo "$(green "Please visit http://$server_ip:8081/")"
				echo "$(green "User & Pass = sysadmin")"
				read -p "$(yellow "Press Enter to return to the menu...")"
				echo "$(green "Returning to the menu...")"
				;;
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
		clear
		echo "$(bblue "Sanaei X-UI Menu")"
        echo
        echo "$(green "1. Install")"
        echo "$(green "2. Custom Install")"
        echo "$(green "3. Delete")"
        echo "$(red "0. Back to Main Menu")"
		echo

		read -p "$(yellow "Select an option: ")" x_ui_3x_option
		case $x_ui_3x_option in
            1)
                echo "Installing x-ui 3x..."
                bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)

                # بررسی وضعیت نصب پس از اجرای دستور اول
                read -p "Is the x-ui 3x installed correctly? (y/n): " answer
                answer=${answer:-Y}
                case $answer in
                    y|Y)
                        echo "x-ui 3x installation confirmed. Returning to the menu..."
                        ;;
                    n|N)
                        echo "Re-running the installation..."
                        ;;
                    *)
                        echo "Invalid input. Please type y or n."
                        ;;
                esac
                ;;
            2)
                read -p "Enter a number for custom installation: " number
                echo "Performing custom installation with number $number..."
                bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh) $number

                # بررسی وضعیت نصب پس از اجرای دستور دوم
                read -p "Is the x-ui 3x installed correctly? (y/n): " answer
                answer=${answer:-Y}
                case $answer in
                    y|Y)
                        echo "x-ui 3x installation confirmed. Returning to the menu..."
                        ;;
                    n|N)
                        echo "Re-running the installation..."
                        ;;
                    *)
                        echo "Invalid input. Please type y or n."
                        ;;
                esac
                ;;
            3)
                echo "Uninstalling x-ui 3x..."
                x-ui uninstall

                # بررسی وضعیت حذف
                read -p "Was the x-ui 3x uninstalled correctly? (y/n): " answer
                answer=${answer:-Y}
                case $answer in
                    y|Y)
                        echo "x-ui 3x uninstallation confirmed. Returning to the menu..."
                        ;;
                    n|N)
                        echo "Please try uninstalling again."
                        ;;
                    *)
                        echo "Invalid input. Please type y or n."
                        ;;
                esac
                ;;
            0)
                echo "$(green "Returning to the main menu...")"
                break
                ;;
            *)
                echo "Invalid choice. Please select 1, 2, 3, or 0."
                ;;
        esac
    done
}


x_ui_alireza() {
    while true; do
        clear
		echo "$(bblue "Alireza X-UI Menu")"
        echo
        echo "$(green "1. Install")"
        echo "$(green "2. Custom Install")"
        echo "$(green "3. Delete")"
        echo "$(red "0. Back to Main Menu")"
		echo

		read -p "$(yellow "Select an option: ")" x_ui_alireza_option
		case $x_ui_alireza_option in
            1)
                echo "Installing x-ui alireza..."
                bash <(curl -Ls https://raw.githubusercontent.com/alireza0/x-ui/master/install.sh)

                # بررسی وضعیت نصب پس از اجرای دستور اول
                read -p "Is the x-ui alireza installed correctly? (y/n): " answer
                answer=${answer:-Y}
                case $answer in
                    y|Y)
                        echo "x-ui alireza installation confirmed. Returning to the menu..."
                        ;;
                    n|N)
                        echo "Re-running the installation..."
                        ;;
                    *)
                        echo "Invalid input. Please type y or n."
                        ;;
                esac
                ;;
            2)
                read -p "Enter a number for custom installation: " number
                echo "Performing custom installation with number $number..."
                bash <(curl -Ls https://raw.githubusercontent.com/alireza0/x-ui/master/install.sh) $number

                # بررسی وضعیت نصب پس از اجرای دستور دوم
                read -p "Is the x-ui alireza installed correctly? (y/n): " answer
                answer=${answer:-Y}
                case $answer in
                    y|Y)
                        echo "x-ui alireza installation confirmed. Returning to the menu..."
                        ;;
                    n|N)
                        echo "Re-running the installation..."
                        ;;
                    *)
                        echo "Invalid input. Please type y or n."
                        ;;
                esac
                ;;
            3)
                echo "Uninstalling x-ui alireza..."
                x-ui uninstall

                # بررسی وضعیت حذف
                read -p "Was the x-ui alireza uninstalled correctly? (y/n): " answer
                answer=${answer:-Y}
                case $answer in
                    y|Y)
                        echo "x-ui alireza uninstallation confirmed. Returning to the menu..."
                        ;;
                    n|N)
                        echo "Please try uninstalling again."
                        ;;
                    *)
                        echo "Invalid input. Please type y or n."
                        ;;
                esac
                ;;
            0)
                echo "$(green "Returning to the main menu...")"
                break
                ;;
            *)
                echo "Invalid choice. Please select 1, 2, 3 or 0."
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
		answer=${answer:-Y}
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
		answer=${answer:-Y}
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
		answer=${answer:-Y}
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
		answer=${answer:-Y}
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
		answer=${answer:-Y}
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

marzban_menu() {
    while true; do
        clear
        echo "$(bblue "Marzban Menu")"
        echo
        echo "$(green "1. Install Marzban")"
        echo "$(green "2. Add Admin")"
        echo "$(green "3. Delete Marzban")"
        echo "$(red "0. Back to Main Menu")"
        echo

        read -p "$(yellow "Select an option: ")" marzban_option
        case $marzban_option in
            1) install_marzban ;;
            2) add_admin ;;
            3) delete_marzban ;;
            0) break ;;
            *) echo "$(red "Invalid option. Please select a valid option.")" ;;
        esac
    done
}

install_marzban() {
    while true; do
        echo "Installing Marzban..."
        sudo bash -c "$(curl -sL https://github.com/Gozargah/Marzban-scripts/raw/master/marzban.sh)" @ install

        # بررسی وضعیت نصب
        read -p "$(yellow "Is the Marzban installed correctly? (y/n): ")" answer
		answer=${answer:-Y}
        case $answer in
            y|Y)
                echo "$(green "Marzban installation confirmed. Returning to the menu...")"
                break ;;
            n|N)
                echo "$(red "Re-running Marzban installation...")"
                ;;
            *)
                echo "$(red "Invalid input. Please type y or n.")"
                ;;
        esac
    done
}

add_admin() {
    echo "$(green "Add Admin...")"

    marzban cli admin create --sudo

    # دریافت IP سرور
    server_ip=$(hostname -I | awk '{print $1}')

    read -p "$(yellow "Was the Add Admin successful? (y/n): ")" answer
	answer=${answer:-Y}
    case $answer in
        y|Y)
            echo "$(green "Please visit http://$server_ip:8000/dashboard/")"
            read -p "$(yellow "Press Enter to return to the Add Admin menu...")"
            echo "$(green "Returning to the Add Admin menu...")"
            ;;
        n|N)
            echo "$(red "Re-running Add Admin...")"
            add_admin ;;
        *)
            echo "$(red "Invalid input. Please type y or n.")"
            add_admin ;;
    esac
}


delete_marzban() {
    while true; do
        echo "$(red "Uninstalling Marzban...")"
        
        marzban uninstall

        if [ $? -eq 0 ]; then
            echo "$(green "Marzban removed successfully.")"
        else
            echo "$(red "Failed to remove Marzban")"
        fi

        read -p "$(yellow "Was the removal successful? (y/n): ")" answer
		answer=${answer:-Y}
        case $answer in
            y|Y)
                echo "$(green "Returning to the Marzban menu...")"
                break ;;
            n|N)
                echo "$(red "Re-running removal process...")"
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
    while true; do
        read -p "$(yellow "Enter new SSH username: ")" username
        if id "$username" &>/dev/null; then
            echo "$(red "User '$username' already exists.")"
        else
            read -p "$(yellow "Enter full name for '$username': ")" fullname
            read -p "$(yellow "Enter password for '$username': ")" password
            # اضافه کردن کاربر جدید با شل nologin و نام کامل
            sudo adduser --shell /usr/sbin/nologin --gecos "$fullname" "$username"
            echo "$(green "User '$username' added successfully with nologin shell.")"

            # ذخیره نام کاربر و اطلاعات در فایل
            echo "$username:$fullname:$password" >> /root/SSH_User

            # درخواست برای بازگشت به منو یا اضافه کردن کاربر دیگر
            read -p "$(yellow "User '$username' added. Do you want to return to the menu? (y/n): ")" choice
            case $choice in
                y|Y) break ;;
                n|N) echo "$(green "Let's add another user.")" ;;
                *) echo "$(red "Invalid input. Please type y or n.")" ;;
            esac
        fi
    done
}

remove_ssh_user() {
    while true; do
        echo "$(green "Listing SSH users created with add_ssh_user:")"

        # چک کردن وجود فایل و لیست کردن کاربران
        if [ ! -f /root/SSH_User ] || [ ! -s /root/SSH_User ]; then
            echo "$(yellow "No custom SSH users found.")"
            read -p "$(yellow "Press Enter to return to the menu...")"
            break
        fi

        # استخراج نام کاربران از فایل
        users=$(awk -F: '{print $1}' /root/SSH_User)

        echo "0) Return to previous menu"
        i=1
        for user in $users; do
            echo "$i) $user"
            ((i++))
        done

        # انتخاب کاربر برای حذف یا بازگشت به منو
        read -p "$(yellow "Select a user to remove or '0' to return: ")" selection
        if [ "$selection" -eq 0 ]; then
            break
        elif [ "$selection" -ge 1 ] && [ "$selection" -lt "$i" ]; then
            username=$(echo "$users" | sed -n "${selection}p")
            # درخواست تایید حذف کاربر
            read -p "$(yellow "Do you want to remove user '$username'? (y/n): ")" choice
            case $choice in
                y|Y)
                    sudo deluser "$username"
                    sudo rm -rf /home/"$username"
                    echo "$(green "User '$username' removed successfully.")"
                    # حذف اطلاعات کاربر از فایل
                    sed -i "/^$username:/d" /root/SSH_User
                    ;;
                n|N)
                    echo "$(green "User '$username' was not removed.")"
                    ;;
                *)
                    echo "$(red "Invalid input. Please type y or n.")"
                    ;;
            esac
        else
            echo "$(red "Invalid selection. Please choose a valid option.")"
        fi
    done
}

list_ssh_users() {
    while true; do
        echo "$(green "Listing SSH users created with add_ssh_user:")"

        # چک کردن وجود فایل و لیست کردن کاربران
        if [ ! -f /root/SSH_User ] || [ ! -s /root/SSH_User ]; then
            echo "$(yellow "No custom SSH users found.")"
            read -p "$(yellow "Press Enter to return to the menu...")"
            break
        fi

        users=$(awk -F: '{print $1}' /root/SSH_User)
        echo "0) Return to previous menu"
        i=1
        for user in $users; do
            echo "$i) $user"
            ((i++))
        done

        # انتخاب کاربر برای مشاهده اطلاعات یا بازگشت به منو
        read -p "$(yellow "Select a user to view details or '0' to return: ")" selection
        if [ "$selection" -eq 0 ]; then
            break
        elif [ "$selection" -ge 1 ] && [ "$selection" -lt "$i" ]; then
            user_info=$(sed -n "${selection}p" /root/SSH_User)
            username=$(echo "$user_info" | cut -d: -f1)
            fullname=$(echo "$user_info" | cut -d: -f2)
            password=$(echo "$user_info" | cut -d: -f3)
            echo "$(green "Details for user '$username':")"
            echo "Full Name: $fullname"
            echo "Password: $password"
            read -p "$(yellow "Press Enter to return to the list...")"
        else
            echo "$(red "Invalid selection. Please choose a valid option.")"
        fi
    done
}

speedtest_menu() {
    while true; do
        clear
        echo "$(bblue "SpeedTest Menu")"
        echo
        echo "$(green "1. Install SpeedTest CLI")"
        echo "$(green "2. Run SpeedTest")"
        echo "$(green "3. Delete SpeedTest CLI")"
        echo "$(red "0. Back to Main Menu")"
        echo

        read -p "$(yellow "Select an option: ")" speedtest_option
        case $speedtest_option in
            1) install_speedtest ;;
            2) run_speedtest ;;
            3) delete_speedtest ;;
            0) break ;;
            *) echo "$(red "Invalid option. Please select a valid option.")" ;;
        esac
    done
}

install_speedtest() {
    while true; do
        echo "$(green "Installing Speedtest CLI...")"

        # اضافه کردن کلید GPG و مخزن Speedtest CLI
        curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash

        # بررسی موفقیت اضافه کردن مخزن
        if [ $? -eq 0 ]; then
            echo "$(green "Repository added successfully. Installing Speedtest CLI...")"
            
            # نصب Speedtest CLI
            sudo apt install speedtest -y

            # بررسی موفقیت نصب Speedtest CLI
            if [ $? -eq 0 ]; then
                echo "$(green "Speedtest CLI installed successfully.")"
            else
                echo "$(red "Failed to install Speedtest CLI.")"
            fi
        else
            echo "$(red "Failed to add repository.")"
        fi

        # بررسی وضعیت نصب
        read -p "$(yellow "Was the installation successful? (y/n): ")" answer
		answer=${answer:-Y}
        case $answer in
            y|Y)
                echo "$(green "Returning to the SpeedTest menu...")"
                break ;;
            n|N)
                echo "$(red "Reinstalling Speedtest CLI...")"
                ;;
            *)
                echo "$(red "Invalid input. Please type y or n.")"
                ;;
        esac
    done
}

run_speedtest() {
    echo "$(green "Running Speedtest...")"

    # اجرای Speedtest
    speedtest

    # بررسی وضعیت اجرای تست سرعت
    read -p "$(yellow "Was the Speedtest successful? (y/n): ")" answer
	answer=${answer:-Y}
    case $answer in
        y|Y)
            echo "$(green "Returning to the SpeedTest menu...")" ;;
        n|N)
            echo "$(red "Re-running Speedtest...")"
            run_speedtest ;;
        *)
            echo "$(red "Invalid input. Please type y or n.")" ;;
    esac
}

delete_speedtest() {
    while true; do
        echo "$(red "Removing Speedtest CLI...")"
        
        # حذف Speedtest CLI
        sudo apt remove --purge speedtest -y

        # بررسی موفقیت حذف Speedtest CLI
        if [ $? -eq 0 ]; then
            echo "$(green "Speedtest CLI removed successfully.")"
        else
            echo "$(red "Failed to remove Speedtest CLI.")"
        fi

        # بررسی وضعیت حذف
        read -p "$(yellow "Was the removal successful? (y/n): ")" answer
		answer=${answer:-Y}
        case $answer in
            y|Y)
                echo "$(green "Returning to the SpeedTest menu...")"
                break ;;
            n|N)
                echo "$(red "Re-running removal process...")"
                ;;
            *)
                echo "$(red "Invalid input. Please type y or n.")"
                ;;
        esac
    done
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
        4) s_ui ;;
        5) h_ui ;;
        6) x_ui_alireza ;;
        7) x_ui_3x ;;
		8) ezpz ;;
		9) hiddify ;;
		10) xpanel ;;
		11) ssh_vfarid ;;
		12) marzban_menu ;;
		13) mtproxy ;;
		14) add_ssh ;;
		15) speedtest_menu ;;
        0) exit_script ;;
        *) echo "$(red "Invalid option!")" ;;
    esac
done
