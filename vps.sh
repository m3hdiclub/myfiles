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
			clear
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
				clear
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
        # Display the UFW menu using whiptail
        ufw_option=$(whiptail --title "UFW Menu" \
            --menu "Select an option:" 20 60 10 \
            "1" "Install UFW" \
            "2" "Add Port" \
            "3" "Enable UFW" \
            "4" "Disable UFW" \
            "5" "Delete Port" \
            "6" "Status" \
            "0" "Back to Main Menu" 3>&1 1>&2 2>&3)

        # Check the exit status of whiptail to determine user choice
        if [ $? -eq 0 ]; then
            case $ufw_option in
                1)
                    echo "$(green "Installing UFW...")"
                    clear
                    sudo apt install ufw -y
                    if [ $? -eq 0 ]; then
                        whiptail --title "Success" --msgbox "UFW installed successfully." 8 45
                    else
                        whiptail --title "Error" --msgbox "Failed to install UFW." 8 45
                    fi
                    ;;
                2)
                    while true; do
                        port=$(whiptail --inputbox "Enter the port you want to allow:" 8 45 3>&1 1>&2 2>&3)
                        if sudo ufw status | grep -q "$port.*ALLOW"; then
                            whiptail --title "Warning" --msgbox "Port $port is already allowed." 8 45
                        else
                            clear
                            sudo ufw allow "$port"
                            if [ $? -eq 0 ]; then
                                whiptail --title "Success" --msgbox "Port $port has been allowed successfully." 8 45
                            else
                                whiptail --title "Error" --msgbox "Failed to allow port $port." 8 45
                            fi
                        fi
                        add_another=$(whiptail --yesno "Do you want to add another port?" 8 45 3>&1 1>&2 2>&3)
                        if [ $? -eq 1 ]; then
                            break
                        fi
                    done
                    ;;
                3)
                    echo "$(green "Enabling UFW...")"
                    clear
                    sudo ufw enable
                    if [ $? -eq 0 ]; then
                        whiptail --title "Success" --msgbox "UFW has been enabled successfully." 8 45
                    else
                        whiptail --title "Error" --msgbox "Failed to enable UFW." 8 45
                    fi
                    ;;
                4)
                    echo "$(green "Disabling UFW...")"
                    clear
                    sudo ufw disable
                    if [ $? -eq 0 ]; then
                        whiptail --title "Success" --msgbox "UFW has been disabled successfully." 8 45
                    else
                        whiptail --title "Error" --msgbox "Failed to disable UFW." 8 45
                    fi
                    ;;
                5)
                    while true; do
                        # Store the UFW status in a temporary file
                        ufw_status_file=$(mktemp)
                        sudo ufw status numbered > "$ufw_status_file"
                        
                        # Display the full UFW status with scrolling support
                        whiptail --title "UFW Status" --textbox "$ufw_status_file" 25 80

                        # Ask for the rule number to delete
                        rule_number=$(whiptail --inputbox "Enter the number of the rule you want to delete:" 8 45 3>&1 1>&2 2>&3)
                        if [ -n "$rule_number" ]; then
                            sudo ufw delete "$rule_number"
                            if [ $? -eq 0 ]; then
                                whiptail --title "Success" --msgbox "Rule number $rule_number has been deleted successfully." 8 45
                            else
                                whiptail --title "Error" --msgbox "Failed to delete rule number $rule_number." 8 45
                            fi
                        else
                            whiptail --title "Error" --msgbox "Invalid rule number." 8 45
                        fi

                        delete_another=$(whiptail --yesno "Do you want to delete another rule?" 8 45 3>&1 1>&2 2>&3)
                        if [ $? -eq 1 ]; then
                            break
                        fi

                        # Remove the temporary file
                        rm "$ufw_status_file"
                    done
                    ;;
                6)
                    echo "$(green "status...")"
                    clear
                    ufw_status=$(sudo ufw status)
                    whiptail --title "UFW Status" --msgbox "$ufw_status" 20 70
                    ;;
                0)
                    echo "$(green "Returning to the main menu...")"
                    break
                    ;;
                *)
                    whiptail --title "Invalid Option" --msgbox "Please select a valid option." 8 45
                    ;;
            esac
        else
            # Exit if the user cancels the menu
            break
        fi
    done
}

s_ui() {
    while true; do
        # Use whiptail to display the S-UI menu
        s_ui_option=$(whiptail --title "S-UI Menu" \
            --menu "Select an option:" 15 60 4 \
            "1" "Install" \
            "2" "Custom Install" \
            "3" "Delete" \
            "0" "Back to Main Menu" 3>&1 1>&2 2>&3)

        # Check the exit status of whiptail to determine user choice
        if [ $? -eq 0 ]; then
            case $s_ui_option in
                1)
                    whiptail --title "Installation" --msgbox "Installing S-UI..." 8 45
					clear
                    bash <(curl -Ls https://raw.githubusercontent.com/alireza0/s-ui/master/install.sh)

                    # Check the installation status after running the first command
                    install_status=$(whiptail --title "Installation Status" --yesno "Is the S-UI installed correctly?" 8 60 3>&1 1>&2 2>&3)
                    if [ $? -eq 0 ]; then
                        whiptail --title "Installation Confirmed" --msgbox "S-UI installation confirmed. Returning to the menu..." 8 60
                    else
                        whiptail --title "Reinstall" --msgbox "Re-running the installation..." 8 60
                    fi
                    ;;
                2)
                    number=$(whiptail --inputbox "Enter a number for custom installation:" 8 60 3>&1 1>&2 2>&3)
					clear
                    whiptail --title "Custom Installation" --msgbox "Performing custom installation with number $number..." 8 60
                    bash <(curl -Ls https://raw.githubusercontent.com/alireza0/s-ui/master/install.sh) $number

                    # Check the installation status after running the second command
                    custom_install_status=$(whiptail --title "Installation Status" --yesno "Is the S-UI installed correctly?" 8 60 3>&1 1>&2 2>&3)
                    if [ $? -eq 0 ]; then
                        whiptail --title "Installation Confirmed" --msgbox "S-UI installation confirmed. Returning to the menu..." 8 60
                    else
                        whiptail --title "Reinstall" --msgbox "Re-running the installation..." 8 60
                    fi
                    ;;
                3)
                    whiptail --title "Uninstallation" --msgbox "Uninstalling S-UI..." 8 45
					clear
                    s-ui uninstall

                    # Check the uninstallation status
                    uninstall_status=$(whiptail --title "Uninstallation Status" --yesno "Was the S-UI uninstalled correctly?" 8 60 3>&1 1>&2 2>&3)
                    if [ $? -eq 0 ]; then
                        whiptail --title "Uninstallation Confirmed" --msgbox "S-UI uninstallation confirmed. Returning to the menu..." 8 60
                    else
                        whiptail --title "Try Again" --msgbox "Please try uninstalling again." 8 60
                    fi
                    ;;
                0)
                    whiptail --title "Return to Main Menu" 8 60
                    break
                    ;;
                *)
                    whiptail --title "Invalid Option" --msgbox "Please select a valid option." 8 45
                    ;;
            esac
        else
            # Exit if the user cancels the menu
            break
        fi
    done
}


h_ui() {
    while true; do
        echo "Installing H-UI..."
		clear
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
        # Use whiptail to display the Sanaei X-UI menu
        x_ui_3x_option=$(whiptail --title "Sanaei X-UI Menu" \
            --menu "Select an option:" 15 60 4 \
            "1" "Install" \
            "2" "Custom Install" \
            "3" "Delete" \
            "0" "Back to Main Menu" 3>&1 1>&2 2>&3)

        # Check the exit status of whiptail to determine user choice
        if [ $? -eq 0 ]; then
            case $x_ui_3x_option in
                1)
                    whiptail --title "Installation" --msgbox "Installing x-ui 3x..." 8 45
                    clear
					bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)

                    # Check the installation status after running the first command
                    install_status=$(whiptail --title "Installation Status" --yesno "Is the x-ui 3x installed correctly?" 8 60 3>&1 1>&2 2>&3)
                    if [ $? -eq 0 ]; then
                        whiptail --title "Installation Confirmed" --msgbox "x-ui 3x installation confirmed. Returning to the menu..." 8 60
                    else
                        whiptail --title "Reinstall" --msgbox "Re-running the installation..." 8 60
                    fi
                    ;;
                2)
                    number=$(whiptail --inputbox "Enter a number for custom installation:" 8 60 3>&1 1>&2 2>&3)
                    whiptail --title "Custom Installation" --msgbox "Performing custom installation with number $number..." 8 60
                    clear
					bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh) $number

                    # Check the installation status after running the second command
                    custom_install_status=$(whiptail --title "Installation Status" --yesno "Is the x-ui 3x installed correctly?" 8 60 3>&1 1>&2 2>&3)
                    if [ $? -eq 0 ]; then
                        whiptail --title "Installation Confirmed" --msgbox "x-ui 3x installation confirmed. Returning to the menu..." 8 60
                    else
                        whiptail --title "Reinstall" --msgbox "Re-running the installation..." 8 60
                    fi
                    ;;
                3)
                    whiptail --title "Uninstallation" --msgbox "Uninstalling x-ui 3x..." 8 45
                    clear
					x-ui uninstall

                    # Check the uninstallation status
                    uninstall_status=$(whiptail --title "Uninstallation Status" --yesno "Was the x-ui 3x uninstalled correctly?" 8 60 3>&1 1>&2 2>&3)
                    if [ $? -eq 0 ]; then
                        whiptail --title "Uninstallation Confirmed" --msgbox "x-ui 3x uninstallation confirmed. Returning to the menu..." 8 60
                    else
                        whiptail --title "Try Again" --msgbox "Please try uninstalling again." 8 60
                    fi
                    ;;
                0)
                    whiptail --title "Return to Main Menu" 8 60
                    break
                    ;;
                *)
                    whiptail --title "Invalid Option" --msgbox "Please select a valid option." 8 45
                    ;;
            esac
        else
            # Exit if the user cancels the menu
            break
        fi
    done
}

x_ui_alireza() {
    while true; do
        # Use whiptail to display the Alireza X-UI menu
        x_ui_alireza_option=$(whiptail --title "Alireza X-UI Menu" \
            --menu "Select an option:" 15 60 4 \
            "1" "Install" \
            "2" "Custom Install" \
            "3" "Delete" \
            "0" "Back to Main Menu" 3>&1 1>&2 2>&3)

        # Check the exit status of whiptail to determine user choice
        if [ $? -eq 0 ]; then
            case $x_ui_alireza_option in
                1)
                    whiptail --title "Installation" --msgbox "Installing x-ui alireza..." 8 45
                    clear
					bash <(curl -Ls https://raw.githubusercontent.com/alireza0/x-ui/master/install.sh)

                    # Check the installation status after running the first command
                    install_status=$(whiptail --title "Installation Status" --yesno "Is the x-ui alireza installed correctly?" 8 60 3>&1 1>&2 2>&3)
                    if [ $? -eq 0 ]; then
                        whiptail --title "Installation Confirmed" --msgbox "x-ui alireza installation confirmed. Returning to the menu..." 8 60
                    else
                        whiptail --title "Reinstall" --msgbox "Re-running the installation..." 8 60
                    fi
                    ;;
                2)
                    number=$(whiptail --inputbox "Enter a number for custom installation:" 8 60 3>&1 1>&2 2>&3)
                    whiptail --title "Custom Installation" --msgbox "Performing custom installation with number $number..." 8 60
                    clear
					bash <(curl -Ls https://raw.githubusercontent.com/alireza0/x-ui/master/install.sh) $number

                    # Check the installation status after running the second command
                    custom_install_status=$(whiptail --title "Installation Status" --yesno "Is the x-ui alireza installed correctly?" 8 60 3>&1 1>&2 2>&3)
                    if [ $? -eq 0 ]; then
                        whiptail --title "Installation Confirmed" --msgbox "x-ui alireza installation confirmed. Returning to the menu..." 8 60
                    else
                        whiptail --title "Reinstall" --msgbox "Re-running the installation..." 8 60
                    fi
                    ;;
                3)
                    whiptail --title "Uninstallation" --msgbox "Uninstalling x-ui alireza..." 8 45
                    clear
					x-ui uninstall

                    # Check the uninstallation status
                    uninstall_status=$(whiptail --title "Uninstallation Status" --yesno "Was the x-ui alireza uninstalled correctly?" 8 60 3>&1 1>&2 2>&3)
                    if [ $? -eq 0 ]; then
                        whiptail --title "Uninstallation Confirmed" --msgbox "x-ui alireza uninstallation confirmed. Returning to the menu..." 8 60
                    else
                        whiptail --title "Try Again" --msgbox "Please try uninstalling again." 8 60
                    fi
                    ;;
                0)
                    whiptail --title "Return to Main Menu" 8 60
                    break
                    ;;
                *)
                    whiptail --title "Invalid Option" --msgbox "Please select a valid option." 8 45
                    ;;
            esac
        else
            # Exit if the user cancels the menu
            break
        fi
    done
}

ezpz() {
    while true; do
        echo "Installing reality-ezpz..."
		clear
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
		clear
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
		clear
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
		clear
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
		clear
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
        # Use whiptail to display the Marzban menu
        marzban_option=$(whiptail --title "Marzban Menu" \
            --menu "Select an option:" 15 60 4 \
            "1" "Install Marzban" \
            "2" "Add Admin" \
            "3" "Delete Marzban" \
            "0" "Back to Main Menu" 3>&1 1>&2 2>&3)

        # Check the exit status of whiptail to determine user choice
        if [ $? -eq 0 ]; then
            case $marzban_option in
                1) install_marzban ;;
                2) add_admin ;;
                3) delete_marzban ;;
                0) break ;;
                *) whiptail --title "Invalid Option" --msgbox "Invalid option. Please select a valid option." 8 60 ;;
            esac
        else
            # Exit if the user cancels the menu
            break
        fi
    done
}

install_marzban() {
    while true; do
        whiptail --title "Installing Marzban" --msgbox "Installing Marzban..." 8 45
        clear
		sudo bash -c "$(curl -sL https://github.com/Gozargah/Marzban-scripts/raw/master/marzban.sh)" @ install

        # Check installation status
        install_status=$(whiptail --title "Installation Status" --yesno "Is the Marzban installed correctly?" 8 60 3>&1 1>&2 2>&3)
        if [ $? -eq 0 ]; then
            whiptail --title "Installation Confirmed" --msgbox "Marzban installation confirmed. Returning to the menu..." 8 60
            break
        else
            whiptail --title "Reinstall" --msgbox "Re-running Marzban installation..." 8 60
        fi
    done
}

add_admin() {
    whiptail --title "Add Admin" --msgbox "Adding Admin..." 8 45
	clear
    marzban cli admin create --sudo

    # Get server IP
    server_ip=$(hostname -I | awk '{print $1}')

    admin_status=$(whiptail --title "Add Admin Status" --yesno "Was the Add Admin successful?" 8 60 3>&1 1>&2 2>&3)
    if [ $? -eq 0 ]; then
        whiptail --title "Admin Added" --msgbox "Please visit http://$server_ip:8000/dashboard/" 8 60
        whiptail --title "Return to Menu" --msgbox "Returning to the Add Admin menu..." 8 60
    else
        whiptail --title "Re-add Admin" --msgbox "Re-running Add Admin..." 8 60
        add_admin
    fi
}

delete_marzban() {
    while true; do
        whiptail --title "Uninstalling Marzban" --msgbox "Uninstalling Marzban..." 8 60
        clear
        marzban uninstall

        if [ $? -eq 0 ]; then
            whiptail --title "Uninstallation Successful" --msgbox "Marzban removed successfully." 8 60
        else
            whiptail --title "Uninstallation Failed" --msgbox "Failed to remove Marzban." 8 60
        fi

        uninstall_status=$(whiptail --title "Removal Status" --yesno "Was the removal successful?" 8 60 3>&1 1>&2 2>&3)
        if [ $? -eq 0 ]; then
            whiptail --title "Return to Menu" --msgbox "Returning to the Marzban menu..." 8 60
            break
        else
            whiptail --title "Re-run Removal" --msgbox "Re-running removal process..." 8 60
        fi
    done
}


add_ssh() {
    while true; do
        option=$(whiptail --title "SSH User Management" \
            --menu "Select an option:" 15 60 4 \
            "1" "Add SSH User" \
            "2" "Remove SSH User" \
            "3" "List SSH Users" \
            "0" "Back to Main Menu" 3>&1 1>&2 2>&3)

        if [ $? -eq 0 ]; then
            case $option in
                1) add_ssh_user ;;
                2) remove_ssh_user ;;
                3) list_ssh_users ;;
                0) break ;;
                *) whiptail --title "Invalid Option" --msgbox "Invalid option. Please try again." 8 60 ;;
            esac
        else
            break
        fi
    done
}


add_ssh_user() {
    while true; do
        username=$(whiptail --inputbox "Enter new SSH username:" 8 45 3>&1 1>&2 2>&3)
        if id "$username" &>/dev/null; then
            whiptail --title "User Exists" --msgbox "User '$username' already exists." 8 60
        else
            fullname=$(whiptail --inputbox "Enter full name for '$username':" 8 45 3>&1 1>&2 2>&3)
            password=$(whiptail --passwordbox "Enter password for '$username':" 8 45 3>&1 1>&2 2>&3)
            sudo adduser --shell /usr/sbin/nologin --gecos "$fullname" "$username"
            whiptail --title "User Added" --msgbox "User '$username' added successfully with nologin shell." 8 60

            # Save user details
            echo "$username:$fullname:$password" >> /root/SSH_User

            # Ask if user wants to return to menu
            choice=$(whiptail --yesno "User '$username' added. Do you want to return to the menu?" 8 60 3>&1 1>&2 2>&3)
            if [ $? -eq 0 ]; then
                break
            else
                whiptail --title "Add Another User" --msgbox "Let's add another user." 8 60
            fi
        fi
    done
}


remove_ssh_user() {
    while true; do
        if [ ! -f /root/SSH_User ] || [ ! -s /root/SSH_User ]; then
            whiptail --title "No Users Found" --msgbox "No custom SSH users found." 8 60
            break
        fi

        users=$(awk -F: '{print $1}' /root/SSH_User)
        options="0 Return to Previous Menu"
        i=1
        for user in $users; do
            options="$options $i $user"
            ((i++))
        done

        selection=$(whiptail --title "Select User to Remove" --menu "Select a user to remove or '0' to return:" 15 60 10 $options 3>&1 1>&2 2>&3)
        if [ $? -eq 0 ]; then
            if [ "$selection" -eq 0 ]; then
                break
            elif [ "$selection" -ge 1 ] && [ "$selection" -lt "$i" ]; then
                username=$(echo "$users" | sed -n "${selection}p")
                choice=$(whiptail --yesno "Do you want to remove user '$username'?" 8 60 3>&1 1>&2 2>&3)
                if [ $? -eq 0 ]; then
                    sudo deluser "$username"
                    sudo rm -rf /home/"$username"
                    whiptail --title "User Removed" --msgbox "User '$username' removed successfully." 8 60
                    # Remove user details from file
                    sed -i "/^$username:/d" /root/SSH_User
                else
                    whiptail --title "User Not Removed" --msgbox "User '$username' was not removed." 8 60
                fi
            else
                whiptail --title "Invalid Selection" --msgbox "Invalid selection. Please choose a valid option." 8 60
            fi
        else
            break
        fi
    done
}


list_ssh_users() {
    while true; do
        if [ ! -f /root/SSH_User ] || [ ! -s /root/SSH_User ]; then
            whiptail --title "No Users Found" --msgbox "No custom SSH users found." 8 60
            break
        fi

        users=$(awk -F: '{print $1}' /root/SSH_User)
        options="0 Return to Previous Menu"
        i=1
        for user in $users; do
            options="$options $i $user"
            ((i++))
        done

        selection=$(whiptail --title "Select User to View Details" --menu "Select a user to view details or '0' to return:" 15 60 10 $options 3>&1 1>&2 2>&3)
        if [ $? -eq 0 ]; then
            if [ "$selection" -eq 0 ]; then
                break
            elif [ "$selection" -ge 1 ] && [ "$selection" -lt "$i" ]; then
                user_info=$(sed -n "${selection}p" /root/SSH_User)
                username=$(echo "$user_info" | cut -d: -f1)
                fullname=$(echo "$user_info" | cut -d: -f2)
                password=$(echo "$user_info" | cut -d: -f3)
                whiptail --title "User Details" --msgbox "Details for user '$username':\n\nFull Name: $fullname\nPassword: $password" 12 45
            else
                whiptail --title "Invalid Selection" --msgbox "Invalid selection. Please choose a valid option." 8 60
            fi
        else
            break
        fi
    done
}


speedtest_menu() {
    while true; do
        option=$(whiptail --title "SpeedTest Menu" \
            --menu "Select an option:" 15 60 4 \
            "1" "Install SpeedTest CLI" \
            "2" "Run SpeedTest" \
            "3" "Delete SpeedTest CLI" \
            "0" "Back to Main Menu" 3>&1 1>&2 2>&3)

        if [ $? -eq 0 ]; then
            case $option in
                1) install_speedtest ;;
                2) run_speedtest ;;
                3) delete_speedtest ;;
                0) break ;;
                *) whiptail --title "Invalid Option" --msgbox "Invalid option. Please select a valid option." 8 60 ;;
            esac
        else
            break
        fi
    done
}


install_speedtest() {
    while true; do
        whiptail --title "Installing Speedtest CLI" --msgbox "Installing Speedtest CLI..." 8 45

        # Add GPG key and Speedtest repository
        clear
		curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash

        if [ $? -eq 0 ]; then
            whiptail --title "Repository Added" --msgbox "Repository added successfully. Installing Speedtest CLI..." 8 60
            sudo apt install speedtest -y

            if [ $? -eq 0 ]; then
                whiptail --title "Installation Successful" --msgbox "Speedtest CLI installed successfully." 8 60
            else
                whiptail --title "Installation Failed" --msgbox "Failed to install Speedtest CLI." 8 60
            fi
        else
            whiptail --title "Repository Addition Failed" --msgbox "Failed to add repository." 8 60
        fi

        # Check installation status
        answer=$(whiptail --yesno "Was the installation successful?" 8 60 3>&1 1>&2 2>&3)
        if [ $? -eq 0 ]; then
            whiptail --title "Returning to Menu" --msgbox "Returning to the SpeedTest menu..." 8 60
            break
        else
            whiptail --title "Reinstall" --msgbox "Reinstalling Speedtest CLI..." 8 60
        fi
    done
}


run_speedtest() {
    whiptail --title "Running Speedtest" --msgbox "Running Speedtest..." 8 45
    clear
	speedtest

    # Check test status
    answer=$(whiptail --yesno "Was the Speedtest successful?" 8 60 3>&1 1>&2 2>&3)
    if [ $? -eq 0 ]; then
        whiptail --title "Returning to Menu" --msgbox "Returning to the SpeedTest menu..." 8 60
    else
        whiptail --title "Re-run Speedtest" --msgbox "Re-running Speedtest..." 8 60
        run_speedtest
    fi
}


delete_speedtest() {
    while true; do
        whiptail --title "Removing Speedtest CLI" --msgbox "Removing Speedtest CLI..." 8 60
        clear
        sudo apt remove --purge speedtest -y

        if [ $? -eq 0 ]; then
            whiptail --title "Removal Successful" --msgbox "Speedtest CLI removed successfully." 8 60
        else
            whiptail --title "Removal Failed" --msgbox "Failed to remove Speedtest CLI." 8 60
        fi

        # Check removal status
        answer=$(whiptail --yesno "Was the removal successful?" 8 60 3>&1 1>&2 2>&3)
        if [ $? -eq 0 ]; then
            whiptail --title "Returning to Menu" --msgbox "Returning to the SpeedTest menu..." 8 60
            break
        else
            whiptail --title "Re-run Removal" --msgbox "Re-running removal process..." 8 60
        fi
    done
}



exit_script() {
    echo "Exiting..."
    exit 0
}

menu() {
    while true; do
        # نمایش منو با استفاده از whiptail
        choice=$(whiptail --backtitle "MEHDI CLUB" \
            --title "Choose Your Operation" \
            --menu "Please choose one of the following options:" 25 60 17 \
            "1" "UPDATE" \
            "2" "Change SSH Port" \
            "3" "Firewall" \
            "4" "S-UI" \
            "5" "H-UI" \
            "6" "X-UI [alireza]" \
            "7" "X-UI [3x]" \
            "8" "reality-ezpz" \
            "9" "Hiddify" \
            "10" "XPanel" \
            "11" "SSH [vfarid]" \
            "12" "Marzban" \
            "13" "MTProxy" \
            "14" "Add SSH" \
            "15" "SpeedTest" \
            "0" "Exit" 3>&1 1>&2 2>&3)

        # بررسی نتیجه فرمان whiptail
        if [ $? -eq 0 ]; then
            # بررسی انتخاب کاربر
            case $choice in
                1)
                    update
                    ;;
                2)
                    change_ssh_port
                    ;;
                3)
                    ufw
                    ;;
                4)
                    s_ui
                    ;;
                5)
                    h_ui
                    ;;
                6)
                    x_ui_alireza
                    ;;
                7)
                    x_ui_3x
                    ;;
                8)
                    ezpz
                    ;;
                9)
                    hiddify
                    ;;
                10)
                    xpanel
                    ;;
                11)
                    ssh_vfarid
                    ;;
                12)
                    marzban_menu
                    ;;
                13)
                    mtproxy
                    ;;
                14)
                    add_ssh
                    ;;
                15)
                    speedtest_menu
                    ;;
                0)
                    exit_script
                    ;;
                *)
                    whiptail --title "Invalid Option" --msgbox "Please select a valid option." 8 60
                    ;;
            esac
        else
            exit 1
        fi
    done
}

# اجرای تابع منو
menu
