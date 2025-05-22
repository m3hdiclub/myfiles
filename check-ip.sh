
#!/bin/bash

RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
CYAN='\e[36m'
BOLD='\e[1m'
NC='\e[0m'

print_title() {
  echo -e "\n${BOLD}${CYAN}===== $1 =====${NC}"
}

print_title "🔍 Installing Dependencies"
for pkg in curl jq bc iputils-ping procps; do
  if ! dpkg -s "$pkg" &>/dev/null; then
    echo -e "Installing $pkg..."
    apt-get install -y "$pkg" &>/dev/null && echo -e "$pkg installed successfully" || echo -e "${RED}Failed to install $pkg${NC}"
  else
    echo -e "$pkg is already installed"
  fi
done

print_title "🛰 IP & Geo Info"
ip_json=$(curl -s http://ip-api.com/json)
echo "$ip_json" | jq -r '
  "IP Address       : \(.query)\n" +
  "ISP              : \(.isp)\n" +
  "Organization     : \(.org)\n" +
  "AS Name          : \(.as)\n" +
  "Country          : \(.country)\n" +
  "Region           : \(.regionName)\n" +
  "City             : \(.city)\n" +
  "Latitude         : \(.lat)\n" +
  "Longitude        : \(.lon)\n" +
  "Timezone         : \(.timezone)\n"'

print_title "🧭 Ping Test to Google"
ping -c 4 google.com

print_title "📊 Ping Graph (ms)"
ping_result=$(ping -c 4 google.com | grep time= | awk -F'time=' '{print $2}' | cut -d' ' -f1)
for ms in $ping_result; do
  index=$(( $(echo "$ms/2" | bc) ))
  char=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")
  graph_char=${char[$index]:-█}
  echo -e "$graph_char  ${ms} ms"
done

print_title "📥 Download Speed Test"
function test_speed() {
  url=$1
  tmpfile=$(mktemp)
  start=$(date +%s%3N)
  curl -s -o "$tmpfile" --max-time 10 "$url"
  end=$(date +%s%3N)
  rm "$tmpfile"
  bytes=10485760
  ms=$((end - start))
  echo "scale=2; $bytes * 8 / $ms / 1000" | bc
}
s1=$(test_speed "http://speed.hetzner.de/10MB.bin")
s2=$(test_speed "http://cachefly.cachefly.net/10mb.test")
s3=$(test_speed "http://mirror.nl.leaseweb.net/speedtest/10mb.bin")
avg=$(echo "scale=2; ($s1 + $s2 + $s3)/3" | bc)
if (( $(echo "$avg < 50" | bc -l) )); then
  color=$RED
elif (( $(echo "$avg < 200" | bc -l) )); then
  color=$YELLOW
else
  color=$GREEN
fi
echo -e "${BOLD}Average Download Speed: ${color}${avg} Mbps${NC}"
bar_length=$(printf "%.0f" $(echo "$avg/100" | bc -l))
bar=$(printf '█%.0s' $(seq 1 $bar_length))
echo -e "${BOLD}Speed Bar: ${color}${bar}${NC}"

print_title "🌐 Internet Connectivity"
curl -s --max-time 3 https://google.com >/dev/null && echo -e "${GREEN}✅ Internet is accessible${NC}" || echo -e "${RED}❌ No internet${NC}"

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

print_title "🕒 Server Uptime"
up_text=$(uptime -p | sed 's/up //')
echo "$up_text"
echo -n -e "${CYAN}Graphical Uptime: ${NC}"
blocks=$(( $(echo "$up_text" | wc -w) ))
for ((i=0; i<blocks; i++)); do echo -n "🟩 "; done
echo
