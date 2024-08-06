add_ssh_user() {
    while true; do
        read -p "$(yellow "Enter new SSH username: ")" username
        if id "$username" &>/dev/null; then
            echo "$(red "User '$username' already exists.")"
        else
            # اضافه کردن کاربر جدید با شل nologin
            sudo adduser --shell /usr/sbin/nologin "$username"
            echo "$(green "User '$username' added successfully with nologin shell.")"

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
