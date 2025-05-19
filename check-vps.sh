#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "\n${CYAN}${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║                  ADVANCED SERVICE AVAILABILITY CHECK           ║${NC}"
echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}\n"

if [ "$(id -u)" != "0" ]; then
    echo -e "${YELLOW}[WARNING]${NC} This script works best with root privileges"
    echo -e "${YELLOW}[WARNING]${NC} Some checks may be limited without root access\n"
fi

check_requirements() {
    echo -e "${BLUE}[INFO]${NC} Verifying required dependencies..."
    local missing_tools=()
    
    for tool in curl wget jq host dig; do
        if ! command -v $tool &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        echo -e "${YELLOW}[SETUP]${NC} Installing missing dependencies: ${missing_tools[*]}"
        
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
    
    echo -e "${GREEN}[SUCCESS]${NC} All dependencies are available\n"
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
    elif [[ "$special" == "spotify" ]]; then
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
    elif [[ "$special" == "youtube" ]]; then
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

check_ip_info() {
    echo -e "\n${CYAN}${BOLD}[ IP GEOLOCATION & NETWORK INFO ]${NC}"
    
    local services=(
        "https://ipinfo.io"
        "https://ifconfig.co/json"
        "https://api.ipify.org?format=json"
    )
    
    local ip_info=""
    
    for service in "${services[@]}"; do
        ip_info=$(curl -s "$service")
        if [[ $? -eq 0 && ! -z "$ip_info" && "$ip_info" =~ "ip" ]]; then
            break
        fi
    done
    
    if [[ ! -z "$ip_info" ]]; then
        local ip=$(echo "$ip_info" | jq -r '.ip // "Unknown"')
        local country=$(echo "$ip_info" | jq -r '.country // .country_code // "Unknown"')
        local region=$(echo "$ip_info" | jq -r '.region // .region_name // "Unknown"')
        local city=$(echo "$ip_info" | jq -r '.city // "Unknown"')
        local isp=$(echo "$ip_info" | jq -r '.org // .asn_org // "Unknown"')
        local asn=$(echo "$ip_info" | jq -r '.asn // "Unknown"')
        local timezone=$(echo "$ip_info" | jq -r '.timezone // "Unknown"')
        
        echo -e "${BLUE}[INFO]${NC} Current IP address: ${BOLD}$ip${NC}"
        echo -e "${BLUE}[INFO]${NC} Geographic location: $city, $region, $country"
        echo -e "${BLUE}[INFO]${NC} Network provider: $isp $asn"
        echo -e "${BLUE}[INFO]${NC} Timezone: $timezone"
        
        if [[ "$ip_info" =~ "hosting" || "$ip_info" =~ "datacenter" || "$isp" =~ (VPN|Proxy|Cloud|Host|Data) ]]; then
            echo -e "${YELLOW}[NOTICE]${NC} This appears to be a datacenter/VPN IP address"
        fi
    else
        echo -e "${RED}[ERROR]${NC} Could not retrieve IP information"
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
    check_service "YouTube" "https://www.youtube.com" "YouTube" "youtube"
    check_service "YouTube Premium" "https://www.youtube.com/premium" "YouTube Premium"
    check_service "Spotify" "https://open.spotify.com" "Spotify" "spotify"
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
    check_ip_info
    test_network_performance
    check_streaming_services
    check_social_services
    check_productivity_services
    
    echo -e "\n${CYAN}${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║                       CHECK COMPLETED                          ║${NC}"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}\n"
}

main
