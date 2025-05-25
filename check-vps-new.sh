#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

clear
echo -e "\n${CYAN}${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║           ADVANCED SERVICE AVAILABILITY CHECK          ║${NC}"
echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}\n"

if [ "$(id -u)" != "0" ]; then
    echo -e "${YELLOW}[WARNING]${NC} This script works best with root privileges"
    echo -e "${YELLOW}[WARNING]${NC} Some checks may be limited without root access\n"
fi

print_title() {
    echo -e "\n${BOLD}${CYAN}===== $1 =====${NC}"
}

check_requirements() {
    echo -e "${BLUE}[INFO]${NC} Verifying required dependencies..."
    local missing_tools=()
    local missing_packages=()
    
    for tool in curl wget jq bc; do
        if ! command -v $tool &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if ! command -v ping &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            missing_packages+=("iputils-ping")
        elif command -v yum &> /dev/null || command -v dnf &> /dev/null; then
            missing_packages+=("iputils")
        fi
    fi
    
    if ! command -v ps &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            missing_packages+=("procps")
        elif command -v yum &> /dev/null || command -v dnf &> /dev/null; then
            missing_packages+=("procps-ng")
        fi
    fi
    
    if ! command -v host &> /dev/null || ! command -v dig &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            missing_packages+=("dnsutils")
        elif command -v yum &> /dev/null || command -v dnf &> /dev/null; then
            missing_packages+=("bind-utils")
        else
            echo -e "${RED}[ERROR]${NC} Could not detect package manager for DNS tools. Please install 'host' and 'dig' manually."
            exit 1
        fi
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        echo -e "${YELLOW}[SETUP]${NC} Installing missing tools: ${missing_tools[*]}"
        
        if command -v apt-get &> /dev/null; then
            apt-get update &> /dev/null
            apt-get install -y ${missing_tools[@]} &> /dev/null
        elif command -v yum &> /dev/null; then
            yum install -y ${missing_tools[@]} &> /dev/null
        elif command -v dnf &> /dev/null; then
            dnf install -y ${missing_tools[@]} &> /dev/null
        else
            echo -e "${RED}[ERROR]${NC} Could not detect package manager. Please install manually: ${missing_tools[*]}"
            exit 1
        fi
        
        for tool in "${missing_tools[@]}"; do
            if ! command -v $tool &> /dev/null; then
                echo -e "${RED}[ERROR]${NC} Failed to install $tool. Please install manually."
                exit 1
            fi
        done
    fi
    
    if [ ${#missing_packages[@]} -ne 0 ]; then
        echo -e "${YELLOW}[SETUP]${NC} Installing packages: ${missing_packages[*]}"
        
        if command -v apt-get &> /dev/null; then
            apt-get update &> /dev/null
            apt-get install -y ${missing_packages[@]} &> /dev/null
        elif command -v yum &> /dev/null; then
            yum install -y ${missing_packages[@]} &> /dev/null
        elif command -v dnf &> /dev/null; then
            dnf install -y ${missing_packages[@]} &> /dev/null
        fi
        
        if ! command -v ping &> /dev/null; then
            echo -e "${YELLOW}[WARNING]${NC} 'ping' command not available. Some network tests may be skipped."
        fi
        
        if ! command -v ps &> /dev/null; then
            echo -e "${YELLOW}[WARNING]${NC} 'ps' command not available. Some system checks may be limited."
        fi
        
        if ! command -v host &> /dev/null; then
            echo -e "${YELLOW}[WARNING]${NC} 'host' command not available. DNS resolution checks may be limited."
        fi
        
        if ! command -v dig &> /dev/null; then
            echo -e "${YELLOW}[WARNING]${NC} 'dig' command not available. DNS resolution checks may be limited."
        fi
    fi
    
    echo -e "${GREEN}[SUCCESS]${NC} Dependency check completed\n"
}

print_result() {
    local service=$1
    local status=$2
    local details=$3
    
    printf "%-25s" "$service"
    
    if [ "$status" == "success" ]; then
        echo -e ": ${GREEN}✓ ACCESSIBLE${NC} $details"
    elif [ "$status" == "partial" ]; then
        echo -e ": ${YELLOW}⚠ PARTIAL${NC} $details"
    else
        echo -e ": ${RED}✗ BLOCKED${NC} $details"
    fi
}

check_dns() {
    local domain=$1
    local dns_servers=("8.8.8.8" "1.1.1.1")
    local resolved=false
    
    for dns in "${dns_servers[@]}"; do
        if host "$domain" "$dns" &>/dev/null; then
            resolved=true
            break
        fi
    done
    
    echo "$resolved"
}

check_service() {
    local name=$1
    local url=$2
    local pattern=$3
    local special=$4
    local timeout=8
    
    echo -ne "${BLUE}[CHECKING]${NC} $name... "
    
    local domain=$(echo "$url" | sed -E 's|https?://||' | sed -E 's|/.*||')
    if [ "$(check_dns "$domain")" != "true" ]; then
        print_result "$name" "failed" "(DNS resolution failed)"
        return
    fi
    
    if [[ "$special" == "chatgpt" ]]; then
        local response=$(curl -s -I -m $timeout "https://chat.openai.com/" 2>&1)
        if [[ $? -eq 0 && ("$response" =~ (200|403|302|captcha) || "$response" =~ "cloudflare") ]]; then
            local api_test=$(curl -s -m $timeout "https://api.openai.com/v1/models" 2>&1)
            if [[ "$api_test" =~ "authentication" ]]; then
                print_result "$name" "success" "(API endpoint accessible)"
            else
                print_result "$name" "partial" "(Web access only)"
            fi
        else
            print_result "$name" "failed" ""
        fi
        return
    elif [[ "$special" == "netflix" ]]; then
        local response=$(curl -s -m $timeout "$url" 2>&1)
        if [[ $? -eq 0 && "$response" =~ "$pattern" ]]; then
            local region=$(curl -s -m $timeout "https://www.netflix.com/title/80018499" 2>&1 | grep -o "netflix.com/[a-z][a-z]/" | cut -d'/' -f2)
            if [[ ! -z "$region" ]]; then
                print_result "$name" "success" "(Region: ${region^^})"
            else
                print_result "$name" "success" ""
            fi
        else
            print_result "$name" "failed" ""
        fi
        return
    elif [[ "$special" == "spotify_premium" ]]; then
        local response=$(curl -s -m $timeout "$url" 2>&1)
        if [[ $? -eq 0 && "$response" =~ "$pattern" ]]; then
            local premium_response=$(curl -s -m $timeout "https://open.spotify.com/premium" 2>&1)
            if [[ "$premium_response" =~ "Spotify Premium" ]]; then
                print_result "$name" "success" "(Premium features may be available)"
            else
                print_result "$name" "success" ""
            fi
        else
            print_result "$name" "failed" ""
        fi
        return
    elif [[ "$special" == "spotify_register" ]]; then
        local response=$(curl -s -m $timeout "$url" 2>&1)
        if [[ $? -eq 0 && "$response" =~ "$pattern" ]]; then
            print_result "$name" "success" "(Registration page accessible)"
        else
            print_result "$name" "failed" ""
        fi
        return
    elif [[ "$special" == "youtube_premium" ]]; then
        local response=$(curl -s -m $timeout "$url" 2>&1)
        if [[ $? -eq 0 && "$response" =~ "$pattern" ]]; then
            local premium_response=$(curl -s -m $timeout "https://www.youtube.com/premium" 2>&1)
            if [[ "$premium_response" =~ "YouTube and YouTube Music ad-free" ]]; then
                print_result "$name" "success" "(Premium content available)"
            else
                print_result "$name" "success" ""
            fi
        else
            print_result "$name" "failed" ""
        fi
        return
    elif [[ "$special" == "instagram_music" ]]; then
        local response=$(curl -s -m $timeout "$url" 2>&1)
        if [[ $? -eq 0 && "$response" =~ "$pattern" ]]; then
            print_result "$name" "success" "(Music content likely accessible)"
        else
            print_result "$name" "failed" ""
        fi
        return
    elif [[ "$special" == "instagram_reels" ]]; then
        local response=$(curl -s -m $timeout "$url" 2>&1)
        if [[ $? -eq 0 && "$response" =~ "$pattern" ]]; then
            print_result "$name" "success" "(Reels content likely accessible)"
        else
            print_result "$name" "failed" ""
        fi
        return
    fi
    
    if [[ -z "$pattern" ]]; then
        local response=$(curl -s -I -m $timeout "$url" 2>&1)
        if [[ $? -eq 0 && "$response" =~ (200|302|301|307) ]]; then
            print_result "$name" "success" ""
        else
            local response_body=$(curl -s -L -m $timeout "$url" 2>&1)
            if [[ $? -eq 0 && ! "$response_body" =~ (blocked|unavailable|access denied|not available) ]]; then
                print_result "$name" "partial" "(Unusual response)"
            else
                print_result "$name" "failed" ""
            fi
        fi
    else
        local response=$(curl -s -L -m $timeout "$url" 2>&1)
        if [[ $? -eq 0 && "$response" =~ "$pattern" ]]; then
            print_result "$name" "success" ""
        else
            print_result "$name" "failed" ""
        fi
    fi
}

check_ip_geo_info() {
    print_title "🛰 IP & Geo Info"
    local ip_json=$(curl -s http://ip-api.com/json)
    echo "$ip_json" | jq -r '
      "IP Address           : \(.query)\n" +
      "ISP                  : \(.isp)\n" +
      "Organization         : \(.org)\n" +
      "AS Name              : \(.as)\n" +
      "Country              : \(.country)\n" +
      "Region               : \(.regionName)\n" +
      "City                 : \(.city)\n" +
      "Latitude             : \(.lat)\n" +
      "Longitude            : \(.lon)\n" +
      "Timezone             : \(.timezone)\n"'
    
    if [[ "$ip_json" =~ "hosting" || "$ip_json" =~ "datacenter" || "$(echo "$ip_json" | jq -r '.isp')" =~ (VPN|Proxy|Cloud|Host|Data) ]]; then
        echo -e "${YELLOW}[NOTICE]${NC} This appears to be a datacenter/VPN IP address"
    fi
}


check_internet_connectivity() {
    print_title "🌐 Internet Connectivity"
    curl -s --max-time 3 https://google.com >/dev/null && echo -e "${GREEN}✅ Internet is accessible${NC}" || echo -e "${RED}❌ No internet${NC}"
}

check_city_ping_status() {
    print_title "🚦 City Ping Status"
    declare -A cities=(
      [Tehran]=185.105.238.209
      [Shiraz]=185.24.253.139
      [Mashhad]=88.135.72.11
      [Esfahan]=194.5.50.94
      [Karaj]=193.8.95.39
      [Yazd]=85.185.161.202
    )
    printf "\n${BOLD}┌────────────────────┬────────────────────┬──────────────┬──────────────────────────────┐\n"
    printf "│ %-18s │ %-18s │ %-12s │ %-28s │\n" "City" "Status" "Ping (ms)" "ISP"
    printf "├────────────────────┼────────────────────┼──────────────┼──────────────────────────────┤\n"
    for city in "${!cities[@]}"; do
        ip=${cities[$city]}
        ping_time=$(ping -c 1 -W 1 "$ip" 2>/dev/null | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
        if [[ -n "$ping_time" ]]; then
            isp_info=$(curl -s http://ip-api.com/json/$ip | jq -r '.isp')
            printf "│ %-18s │ ${GREEN}%-18s${NC} │ %-12s │ %-28s │\n" "$city" "✅ Reachable" "$ping_time" "$isp_info"
        else
            printf "│ %-18s │ ${RED}%-18s${NC} │ %-12s │ %-28s │\n" "$city" "❌ Unreachable" "N/A" "N/A"
        fi
        sleep 0.5
    done
    printf "└────────────────────┴────────────────────┴──────────────┴──────────────────────────────┘\n"
}

check_server_uptime() {
    print_title "🕒 Server Uptime"
    local up_text=$(uptime -p | sed 's/up //')
    echo "$up_text"
    echo -n -e "${CYAN}Graphical Uptime: ${NC}"
    local blocks=$(( $(echo "$up_text" | wc -w) ))
    for ((i=0; i<blocks; i++)); do echo -n "🟩 "; done
    echo
}

test_network_performance() {
    echo -e "\n${CYAN}${BOLD}[ NETWORK PERFORMANCE TEST ]${NC}"
    
    echo -e "${BLUE}[INFO]${NC} Testing connection latency..."
    
    local targets=("google.com" "cloudflare.com" "amazon.com")
    local best_latency=1000
    
    for target in "${targets[@]}"; do
        if ping -c 3 -W 2 "$target" &>/dev/null; then
            local latency=$(ping -c 3 -W 2 "$target" 2>/dev/null | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
            if (( $(echo "$latency < $best_latency" | bc -l) )); then
                best_latency=$latency
            fi
            echo -e "  - Ping to $target: ${GREEN}$latency ms${NC}"
        else
            echo -e "  - Ping to $target: ${RED}Failed${NC}"
        fi
    done
    
    echo -e "${BLUE}[INFO]${NC} Testing download speed..."
    
    local test_successful=false
    
    local test_files=(
        "http://speedtest.ftp.otenet.gr/files/test1Mb.db"
        "http://speedtest.ftp.otenet.gr/files/test10Mb.db"
        "http://speedtest.tele2.net/1MB.zip"
    )
    
    for test_file in "${test_files[@]}"; do
        echo -e "  - Testing with $(basename "$test_file")..."
        local speed_result=$(wget --output-document=/dev/null "$test_file" 2>&1 | grep -o "[0-9.]* [KM]B/s")
        
        if [[ ! -z "$speed_result" ]]; then
            echo -e "  - Download speed: ${GREEN}$speed_result${NC}"
            test_successful=true
            break
        fi
    done
    
    if [ "$test_successful" = false ]; then
        echo -e "  - ${RED}Speed test failed. Connection may be limited.${NC}"
    fi
    
    echo -e "${BLUE}[INFO]${NC} Testing connection stability..."
    local packet_loss=$(ping -c 10 -q 1.1.1.1 2>/dev/null | grep "packet loss" | awk '{print $7}')
    
    if [[ ! -z "$packet_loss" ]]; then
        echo -e "  - Packet loss: ${packet_loss}"
        
        if [[ "$packet_loss" == "0%" ]]; then
            echo -e "  - Connection stability: ${GREEN}Excellent${NC}"
        elif [[ "$packet_loss" < "5%" ]]; then
            echo -e "  - Connection stability: ${GREEN}Good${NC}"
        elif [[ "$packet_loss" < "10%" ]]; then
            echo -e "  - Connection stability: ${YELLOW}Fair${NC}"
        else
            echo -e "  - Connection stability: ${RED}Poor${NC}"
        fi
    else
        echo -e "  - Connection stability: ${RED}Could not determine${NC}"
    fi
}

check_virtualization() {
    echo -e "\n${CYAN}${BOLD}[ SYSTEM ENVIRONMENT ]${NC}"
    
    local virt_check=$(systemd-detect-virt 2>/dev/null || echo "unknown")
    
    if [ "$virt_check" == "unknown" ]; then
        if [ -f /proc/cpuinfo ]; then
            if grep -q "hypervisor" /proc/cpuinfo; then
                virt_check="detected (CPU flags)"
            elif [ -d /proc/xen ]; then
                virt_check="xen"
            elif [ -f /proc/modules ] && grep -q "kvm" /proc/modules; then
                virt_check="kvm"
            elif [ -f /proc/modules ] && grep -q "vboxdrv" /proc/modules; then
                virt_check="virtualbox"
            elif [ -f /proc/modules ] && grep -q "vmware" /proc/modules; then
                virt_check="vmware"
            else
                virt_check="none detected"
            fi
        else
            virt_check="could not determine"
        fi
    fi
    
    echo -e "${BLUE}[INFO]${NC} Virtualization: $virt_check"
    
    echo -e "${BLUE}[INFO]${NC} CPU Information:"
    if [ -f /proc/cpuinfo ]; then
        local cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d ':' -f 2 | sed 's/^[ \t]*//')
        local cpu_cores=$(grep -c "processor" /proc/cpuinfo)
        echo -e "  - Model: $cpu_model"
        echo -e "  - Cores: $cpu_cores"
    else
        echo -e "  - Could not retrieve CPU information"
    fi
    
    echo -e "${BLUE}[INFO]${NC} Memory Information:"
    if [ -f /proc/meminfo ]; then
        local total_mem=$(grep "MemTotal" /proc/meminfo | awk '{print $2/1024}')
        local total_mem_rounded=$(printf "%.2f" $total_mem)
        echo -e "  - Total Memory: ${total_mem_rounded} MB"
    else
        echo -e "  - Could not retrieve memory information"
    fi
    
    echo -e "${BLUE}[INFO]${NC} Disk Information:"
    if command -v df &> /dev/null; then
        local disk_info=$(df -h / | tail -1)
        local total_disk=$(echo "$disk_info" | awk '{print $2}')
        local used_disk=$(echo "$disk_info" | awk '{print $3}')
        local avail_disk=$(echo "$disk_info" | awk '{print $4}')
        local usage_percent=$(echo "$disk_info" | awk '{print $5}')
        
        echo -e "  - Total: $total_disk"
        echo -e "  - Used: $used_disk ($usage_percent)"
        echo -e "  - Available: $avail_disk"
    else
        echo -e "  - Could not retrieve disk information"
    fi
}

check_streaming_services() {
    echo -e "\n${CYAN}${BOLD}[ STREAMING SERVICES AVAILABILITY ]${NC}"
    
    check_service "Netflix" "https://www.netflix.com" "Netflix" "netflix"
    check_service "YouTube" "https://www.youtube.com" "YouTube"
    check_service "YouTube Premium" "https://www.youtube.com/premium" "YouTube Premium" "youtube_premium"
    check_service "Spotify (Web)" "https://www.spotify.com" "Spotify"
    check_service "Spotify (Register)" "https://www.spotify.com/signup" "Sign up for free" "spotify_register"
    check_service "Spotify Premium" "https://www.spotify.com/premium" "Go Premium" "spotify_premium"
    check_service "Disney+" "https://www.disneyplus.com" "Disney+"
    check_service "Prime Video" "https://www.primevideo.com" "Prime Video"
    check_service "HBO Max" "https://www.hbomax.com" "HBO Max"
    check_service "Hulu" "https://www.hulu.com" "Hulu"
    check_service "Apple TV+" "https://tv.apple.com" "Apple TV+"
    check_service "Paramount+" "https://www.paramountplus.com" "Paramount+"
}

check_social_services() {
    echo -e "\n${CYAN}${BOLD}[ SOCIAL & COMMUNICATION SERVICES ]${NC}"
    
    check_service "Instagram" "https://www.instagram.com" "Instagram"
    check_service "Instagram Music" "https://www.instagram.com/explore/tags/instamusic/" "Music" "instagram_music"
    check_service "Instagram Reels" "https://www.instagram.com/reels/" "Reels" "instagram_reels"
    check_service "Facebook" "https://www.facebook.com" "Facebook"
    check_service "Twitter/X" "https://twitter.com" "Twitter"
    check_service "TikTok" "https://www.tiktok.com" "TikTok"
    check_service "LinkedIn" "https://www.linkedin.com" "LinkedIn"
    check_service "Reddit" "https://www.reddit.com" "Reddit"
    check_service "Telegram" "https://telegram.org" "Telegram"
    check_service "WhatsApp" "https://web.whatsapp.com" "WhatsApp"
    check_service "Discord" "https://discord.com" "Discord"
    check_service "Twitch" "https://www.twitch.tv" "Twitch"
}

check_productivity_services() {
    echo -e "\n${CYAN}${BOLD}[ PRODUCTIVITY & AI SERVICES ]${NC}"
    
    check_service "ChatGPT" "https://chat.openai.com" "" "chatgpt"
    check_service "GitHub" "https://github.com" "GitHub"
    check_service "Microsoft 365" "https://www.office.com" "Microsoft"
    check_service "Google Workspace" "https://workspace.google.com" "Google"
    check_service "Dropbox" "https://www.dropbox.com" "Dropbox"
    check_service "Slack" "https://slack.com" "Slack"
    check_service "Zoom" "https://zoom.us" "Zoom"
    check_service "Microsoft Teams" "https://teams.microsoft.com" "Teams"
}

main() {
    if [ -t 0 ]; then
        clear
    fi
    
    check_requirements
    
    echo -e "${BLUE}[INFO]${NC} Current system time: $(date)"
    echo -e "${BLUE}[INFO]${NC} Starting comprehensive service availability check\n"
    
    check_virtualization
    check_ip_geo_info
    test_network_performance

    check_internet_connectivity
    check_city_ping_status
    check_server_uptime

    check_streaming_services
    check_social_services
    check_productivity_services
    
    echo -e "\n${CYAN}${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║                           CHECK COMPLETED                        ║${NC}"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}\n"
}

main
