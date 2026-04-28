#!/bin/bash

###############################################################
# ThreatScore
# Author: Michael Pritsert
# GitHub: https://github.com/mishap2001
# LinkedIn: https://www.linkedin.com/in/michael-pritsert-8168bb38a
# License: MIT License
###############################################################

RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
MAGENTA='\e[35m'
CYAN='\e[36m'
BOLD='\e[1m'
ENDCOLOR='\e[0m'


echo -e "${GREEN}${BOLD}"
cat << "EOF"
 _______ _                    _     _____
|__   __| |                  | |   / ____|
   | |  | |__  _ __ ___  __ _| |_ | (___   ___ ___  _ __ ___
   | |  | '_ \| '__/ _ \/ _` | __| \___ \ / __/ _ \| '__/ _ \
   | |  | | | | | |  __/ (_| | |_  ____) | (_| (_) | | |  __/
   |_|  |_| |_|_|  \___|\__,_|\__||_____/ \___\___/|_|  \___|

EOF
echo -e "${ENDCOLOR}"

function APPS()
{
for app in curl jq ; do
if command -v "$app" >/dev/null; then
	echo -e "${GREEN}${BOLD}$app: installed ${ENDCOLOR}"
else
	echo -e "${RED}${BOLD}$app: NOT installed, installing now...${ENDCOLOR}"
	case "$app" in
		curl)
		sudo apt-get update && sudo apt-get install -y curl
		;;
	
		jq)
		sudo apt-get update && sudo apt-get install -y jq
		;;
	
	esac	
fi
done	
}

function CONF()
{
if [ ! -f .ThreatScore.conf ]; then
read -p "[*] Enter your VirusTotal API Key: " VT_API
read -p "[*] Enter your MalwareBazaar API Key: " MB_API
read -p "[*] Enter your OTX (AlienVault) API Key: " OTX_API
echo
echo -e "${CYAN}${BOLD}[*] Cloudflare credentials:${ENDCOLOR}"
read -p "    Account ID: " CF_ACCOUNT_ID
read -p "    API Token: " CF_TOKEN
echo
read -p "[*] Enter your urlscan.io API Key: " URLSCAN_API
read -p "[*] Enter your ThreatYeti API Key: " TY_API
read -p "[*] Enter your IPInfo API Key: " IPINFO_API
read -p "[*] Enter your AbuseIPDB API Key: " ABUSEIPDB_API
read -p "[*] Enter your Telegram Bot Token: " BOT_TOKEN
read -p "[*] Enter your Telegram Chat ID: " CHAT_ID
echo "BOT_TOKEN=$BOT_TOKEN" > .ThreatScore.conf
echo "CHAT_ID=$CHAT_ID" >> .ThreatScore.conf
echo "VT_API=\"$VT_API\"" >> .ThreatScore.conf
echo "MB_API=\"$MB_API\"" >> .ThreatScore.conf
echo "OTX_API=\"$OTX_API\"" >> .ThreatScore.conf
echo "CF_ACCOUNT_ID=\"$CF_ACCOUNT_ID\"" >> .ThreatScore.conf
echo "CF_TOKEN=\"$CF_TOKEN\"" >> .ThreatScore.conf
echo "URLSCAN_API=\"$URLSCAN_API\"" >> .ThreatScore.conf
echo "TY_API=\"$TY_API\"" >> .ThreatScore.conf
echo "IPINFO_API=\"$IPINFO_API\"" >> .ThreatScore.conf
echo "ABUSEIPDB_API=\"$ABUSEIPDB_API\"" >> .ThreatScore.conf

chmod 600 .ThreatScore.conf
echo -e "${GREEN}${BOLD}[+] API keys saved to .ThreatScore.conf${ENDCOLOR}"
fi

source .ThreatScore.conf

}

function MENU()
{
while true; do
echo
echo -e "${YELLOW}${BOLD}-------------------------------------------------------------${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}                       Scan Options${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}-------------------------------------------------------------${ENDCOLOR}"
echo
echo -e "${MAGENTA}${BOLD}[1]${ENDCOLOR} Check IP"
echo -e "${MAGENTA}${BOLD}[2]${ENDCOLOR} Check Domain"
echo -e "${MAGENTA}${BOLD}[3]${ENDCOLOR} Check URL"
echo -e "${MAGENTA}${BOLD}[4]${ENDCOLOR} Check Hash"
echo -e "${MAGENTA}${BOLD}[5]${ENDCOLOR} EXIT" 
echo
echo -ne "${BOLD}Choose an option to continue${ENDCOLOR}"
echo
printf "${YELLOW}${BOLD}Choice:${ENDCOLOR} "; read scan_choice
echo
case "$scan_choice" in
	1) IP ;;
	2) DOMAIN ;;
	3) URL ;;
	4) HASH ;;
	5) echo; echo -e "${RED}${BOLD}EXITING...${ENDCOLOR}"; sleep 0.5; exit ;;
	*) echo -e "${RED}${BOLD}Invalid input${ENDCOLOR}"
	   echo -e "${RED}${BOLD}Choose from the available options${ENDCOLOR}"
	   echo
	;;
esac
done		
}

function IP()
{
printf "${GREEN}${BOLD}Enter IP:${ENDCOLOR} "; read ip
if [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    ip_type="IPv4"
elif [[ "$ip" == *:* ]]; then
    ip_type="IPv6"
else
    echo -e "${RED}${BOLD}Invalid IP${ENDCOLOR}"
    return
fi

echo -e "${BOLD}IP Type:${ENDCOLOR} ${CYAN}$ip_type${ENDCOLOR}"
response_info=$(curl -s "https://api.ipinfo.io/lite/$ip?token=$IPINFO_API")
ip_in=$(echo "$response_info" | jq -r '.ip')
as_name=$(echo "$response_info" | jq -r '.as_name')
countrycode_in=$(echo "$response_info" | jq -r '.country_code')
country_in=$(echo "$response_info" | jq -r '.country')
continent_in=$(echo "$response_info" | jq -r '.continent')
continentcode_in=$(echo "$response_info" | jq -r '.continent_code')
echo
echo -e "${CYAN}${BOLD}========================${ENDCOLOR}"
echo -e "${CYAN}${BOLD}IPinfo Results:${ENDCOLOR}"
echo -e "${CYAN}${BOLD}========================${ENDCOLOR}"
echo -e "${BOLD}IP:${ENDCOLOR} $ip_in
${BOLD}Routing Domain:${ENDCOLOR} $as_name
${BOLD}Country:${ENDCOLOR} ${country_in}, $countrycode_in
${BOLD}Continent:${ENDCOLOR} ${continent_in}, $continentcode_in"  

echo
echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}     VirusTotal${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"
response_vt=$(curl -s -H "x-apikey: $VT_API" "https://www.virustotal.com/api/v3/ip_addresses/$ip")
ip_vt=$(echo "$response_vt" | jq -r '.data.id')
reputation=$(echo "$response_vt" | jq -r '.data.attributes.reputation')
vt_malicious=$(echo "$response_vt" | jq -r '.data.attributes.last_analysis_stats.malicious')
vt_suspicious=$(echo "$response_vt" | jq -r '.data.attributes.last_analysis_stats.suspicious')
vote_malicious=$(echo "$response_vt" | jq -r '.data.attributes.total_votes.malicious')
vote_harmless=$(echo "$response_vt" | jq -r '.data.attributes.total_votes.harmless')
asn=$(echo "$response_vt" | jq -r '.data.attributes.asn')
as_owner=$(echo "$response_vt" | jq -r '.data.attributes.as_owner')
country_vt=$(echo "$response_vt" | jq -r '.data.attributes.country')
network=$(echo "$response_vt" | jq -r '.data.attributes.network')
rdap_type=$(echo "$response_vt" | jq -r '.data.attributes.rdap.type')
rdap_country=$(echo "$response_vt" | jq -r '.data.attributes.rdap.country')

echo -e "${BOLD}IP:${ENDCOLOR} $ip_vt
${BOLD}VT malicious:${ENDCOLOR} ${RED}$vt_malicious${ENDCOLOR}
${BOLD}VT suspicious:${ENDCOLOR} ${YELLOW}$vt_suspicious${ENDCOLOR}
${BOLD}Reputation:${ENDCOLOR} ${MAGENTA}$reputation${ENDCOLOR}
${BOLD}Community votes:${ENDCOLOR} malicious=$vote_malicious harmless=$vote_harmless
${BOLD}ASN:${ENDCOLOR} $asn
${BOLD}Owner:${ENDCOLOR} $as_owner
${BOLD}Country:${ENDCOLOR} $country_vt
${BOLD}Network:${ENDCOLOR} $network
${BOLD}RDAP type:${ENDCOLOR} $rdap_type"

response_adb=$(curl -s \
  -G https://api.abuseipdb.com/api/v2/check \
  --data-urlencode "ipAddress=$ip" \
  --data-urlencode "maxAgeInDays=90" \
  -H "Key: $ABUSEIPDB_API" \
  -H "Accept: application/json")

ip_adb=$(echo "$response_adb" | jq -r '.data.ipAddress')
is_public=$(echo "$response_adb" | jq '.data.isPublic')
ip_version=$(echo "$response_adb" | jq '.data.ipVersion')
is_whitelisted=$(echo "$response_adb" | jq '.data.isWhitelisted')
abuse_score=$(echo "$response_adb" | jq '.data.abuseConfidenceScore')
country_adb=$(echo "$response_adb" | jq -r '.data.countryCode')
usage_type=$(echo "$response_adb" | jq -r '.data.usageType')
isp=$(echo "$response_adb" | jq -r '.data.isp')
domain=$(echo "$response_adb" | jq -r '.data.domain')
hostnames=$(echo "$response_adb" | jq -r '.data.hostnames | join(", ")')
is_tor=$(echo "$response_adb" | jq '.data.isTor')
total_reports=$(echo "$response_adb" | jq '.data.totalReports')
distinct_users=$(echo "$response_adb" | jq '.data.numDistinctUsers')
last_reported=$(echo "$response_adb" | jq -r '.data.lastReportedAt')
echo
echo -e "${CYAN}${BOLD}========================${ENDCOLOR}"
echo -e "${CYAN}${BOLD}AbuseIPDB Results:${ENDCOLOR}"
echo -e "${CYAN}${BOLD}========================${ENDCOLOR}"
echo -e "${BOLD}IP:${ENDCOLOR} $ip_adb"
echo -e "${BOLD}Is Public:${ENDCOLOR} $is_public"
echo -e "${BOLD}IP Version:${ENDCOLOR} $ip_version"
echo -e "${BOLD}Whitelisted:${ENDCOLOR} $is_whitelisted"
echo -e "${BOLD}Abuse Score:${ENDCOLOR} ${RED}$abuse_score${ENDCOLOR}"
echo -e "${BOLD}Country:${ENDCOLOR} $country_adb"
echo -e "${BOLD}Usage Type:${ENDCOLOR} $usage_type"
echo -e "${BOLD}ISP:${ENDCOLOR} $isp"
echo -e "${BOLD}Domain:${ENDCOLOR} $domain"
echo -e "${BOLD}Hostnames:${ENDCOLOR} $hostnames"
echo -e "${BOLD}Is TOR:${ENDCOLOR} ${MAGENTA}$is_tor${ENDCOLOR}"
echo -e "${BOLD}Total Reports:${ENDCOLOR} $total_reports"
echo -e "${BOLD}Distinct Users:${ENDCOLOR} $distinct_users"
echo -e "${BOLD}Last Reported:${ENDCOLOR} $last_reported"

echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}    OTX - AlienVault${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"

if [[ "$ip_type" == "IPv6" ]]; then
    OTX_TYPE="IPv6"
else
    OTX_TYPE="IPv4"
fi

RESP=$(curl -s "https://otx.alienvault.com/api/v1/indicators/$OTX_TYPE/$ip/general" \
  -H "X-OTX-API-KEY: $OTX_API")

IP_ADDR=$(printf '%s' "$RESP" | jq -r '.indicator // "N/A"')
PULSES=$(printf '%s' "$RESP" | jq -r '.pulse_info.count // 0')
REPUTATION=$(printf '%s' "$RESP" | jq -r '.reputation // 0')
ASN=$(printf '%s' "$RESP" | jq -r '.asn // "N/A"')
COUNTRY=$(printf '%s' "$RESP" | jq -r '.country_name // "N/A"')
CITY=$(printf '%s' "$RESP" | jq -r '.city // "N/A"')

TOP_TAGS=$(printf '%s' "$RESP" | jq -r '.pulse_info.pulses[].tags[]?' 2>/dev/null | tr '[:upper:]' '[:lower:]' | sort | uniq -c | sort -nr | head -10 | awk '{$1=$1; print}')
RECENT_PULSES=$(printf '%s' "$RESP" | jq -r '.pulse_info.pulses[]?.name' 2>/dev/null | head -10)

echo -e "${BOLD}IP:${ENDCOLOR} $IP_ADDR"
echo -e "${BOLD}Pulses:${ENDCOLOR} ${MAGENTA}$PULSES${ENDCOLOR}"
echo -e "${BOLD}Reputation:${ENDCOLOR} ${MAGENTA}$REPUTATION${ENDCOLOR}"
echo -e "${BOLD}ASN:${ENDCOLOR} $ASN"
echo -e "${BOLD}Location:${ENDCOLOR} $CITY, $COUNTRY"

if [ "$PULSES" -gt 0 ]; then
  echo -e "${BOLD}Suspicious:${ENDCOLOR} ${RED}${BOLD}YES${ENDCOLOR}"
else
  echo -e "${BOLD}Suspicious:${ENDCOLOR} ${GREEN}${BOLD}NO${ENDCOLOR}"
fi

echo -e "${BOLD}Top tags:${ENDCOLOR}"
[ -n "$TOP_TAGS" ] && echo "$TOP_TAGS" || echo "None"

echo -e "${BOLD}Recent pulse names:${ENDCOLOR}"
[ -n "$RECENT_PULSES" ] && echo "$RECENT_PULSES" || echo "None"

SCORE "IP"
MSG
}

function DOMAIN()
{
printf "${GREEN}${BOLD}Enter Domain:${ENDCOLOR} "; read domain
[[ "$domain" =~ ^[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]] || { echo -e "${RED}${BOLD}Invalid domain${ENDCOLOR}"; return; }

response_vt_domain=$(curl -s \
  -H "x-apikey: $VT_API" \
  "https://www.virustotal.com/api/v3/domains/$domain")

vt_malicious=$(echo "$response_vt_domain" | jq '.data.attributes.last_analysis_stats.malicious')
vt_suspicious=$(echo "$response_vt_domain" | jq '.data.attributes.last_analysis_stats.suspicious')
vt_harmless=$(echo "$response_vt_domain" | jq '.data.attributes.last_analysis_stats.harmless')
vt_undetected=$(echo "$response_vt_domain" | jq '.data.attributes.last_analysis_stats.undetected')
reputation=$(echo "$response_vt_domain" | jq '.data.attributes.reputation')
votes_malicious=$(echo "$response_vt_domain" | jq '.data.attributes.total_votes.malicious')
votes_harmless=$(echo "$response_vt_domain" | jq '.data.attributes.total_votes.harmless')
categories=$(echo "$response_vt_domain" | jq -r '.data.attributes.categories | to_entries[]? | .value' 2>/dev/null)
creation_date=$(echo "$response_vt_domain" | jq '.data.attributes.creation_date')
tld=$(echo "$response_vt_domain" | jq -r '.data.attributes.tld')
echo	
echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}     VirusTotal${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"
echo -e "${BOLD}Domain:${ENDCOLOR} $domain"
echo -e "${BOLD}VT malicious:${ENDCOLOR} ${RED}$vt_malicious${ENDCOLOR}"
echo -e "${BOLD}VT suspicious:${ENDCOLOR} ${YELLOW}$vt_suspicious${ENDCOLOR}"
echo -e "${BOLD}VT harmless:${ENDCOLOR} ${GREEN}$vt_harmless${ENDCOLOR}"
echo -e "${BOLD}VT undetected:${ENDCOLOR} ${CYAN}$vt_undetected${ENDCOLOR}"
echo -e "${BOLD}Reputation:${ENDCOLOR} ${MAGENTA}$reputation${ENDCOLOR}"
echo -e "${BOLD}Votes:${ENDCOLOR} malicious=$votes_malicious harmless=$votes_harmless"
echo -e "${BOLD}Categories:${ENDCOLOR} $categories"
echo -e "${BOLD}TLD:${ENDCOLOR} $tld"
echo -e "${BOLD}Creation date:${ENDCOLOR} $creation_date"
	
response_urlscan_domain=$(curl -s -G "https://urlscan.io/api/v1/search/" --data-urlencode "q=domain:$domain" -H "API-Key: $URLSCAN_API" | jq)
total=$(echo "$response_urlscan_domain" | jq '.total')
tag=$(echo "$response_urlscan_domain" | jq -r '.results[0].task.tags[0] // "none"')
last_scan=$(echo "$response_urlscan_domain" | jq -r '.results[0].task.time // "null"')
ip=$(echo "$response_urlscan_domain" | jq -r '.results[0].page.ip // "null"')
server=$(echo "$response_urlscan_domain" | jq -r '.results[0].page.server // "null"')
asnname=$(echo "$response_urlscan_domain" | jq -r '.results[0].page.asnname // "null"')
title=$(echo "$response_urlscan_domain" | jq -r '.results[0].page.title // "null"')
status=$(echo "$response_urlscan_domain" | jq -r '.results[0].page.status // "null"')	
echo
echo -e "${CYAN}${BOLD}========================${ENDCOLOR}"
echo -e "${CYAN}${BOLD}urlscan.io Results:${ENDCOLOR}"
echo -e "${CYAN}${BOLD}========================${ENDCOLOR}"
echo -e "${BOLD}Domain:${ENDCOLOR} $domain"
echo -e "${BOLD}Results Found:${ENDCOLOR} $total"
echo -e "${BOLD}Tag:${ENDCOLOR} $tag"
echo -e "${BOLD}Last Scan:${ENDCOLOR} $last_scan"
echo -e "${BOLD}IP:${ENDCOLOR} $ip"
echo -e "${BOLD}Server:${ENDCOLOR} $server"
echo -e "${BOLD}ASN:${ENDCOLOR} $asnname"
echo -e "${BOLD}Title:${ENDCOLOR} $title"
echo -e "${BOLD}Status:${ENDCOLOR} $status"

level=$(curl -s -X POST -H "Content-Type: application/json" \
-d "{\"hostname\":\"$domain\",\"license\":\"$TY_API\",\"version\":1,\"sections\":[\"popularity\"]}" \
https://api.alphamountain.ai/intelligence/hostname | jq -r '
    if (.summary.high_risk|length>0) then "high"
    elif (.summary.mid_risk|length>0) then "mid"
    elif (.summary.low_risk|length>0) then "low"
    else "none"
    end')
echo
echo -e "${CYAN}${BOLD}========================${ENDCOLOR}"
echo -e "${CYAN}${BOLD}ThreatYeti Results:${ENDCOLOR}"
echo -e "${CYAN}${BOLD}========================${ENDCOLOR}"
echo -e "${BOLD}Domain:${ENDCOLOR} $domain"
echo -e "${BOLD}Risk Level:${ENDCOLOR} ${MAGENTA}$level${ENDCOLOR}"

echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}    OTX - AlienVault${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"
RESP=$(curl -s "https://otx.alienvault.com/api/v1/indicators/domain/$domain/general" -H "X-OTX-API-KEY: $OTX_API")
DOMAIN=$(printf '%s' "$RESP" | jq -r '.indicator // "N/A"')
TYPE=$(printf '%s' "$RESP" | jq -r '.type // "N/A"')
PULSES=$(printf '%s' "$RESP" | jq -r '.pulse_info.count // 0')
SECTIONS=$(printf '%s' "$RESP" | jq -r '.sections // [] | join(", ")')
PULSE_NAMES=$(printf '%s' "$RESP" | jq -r '.pulse_info.pulses[]?.name' 2>/dev/null)
TAGS=$(printf '%s' "$RESP" | jq -r '.pulse_info.pulses[].tags[]?' 2>/dev/null | sort -u)
REFS=$(printf '%s' "$RESP" | jq -r '.pulse_info.references[]?' 2>/dev/null | sort -u)

echo -e "${BOLD}Domain:${ENDCOLOR} $DOMAIN"
echo -e "${BOLD}Type:${ENDCOLOR} $TYPE"
echo -e "${BOLD}Pulses:${ENDCOLOR} ${MAGENTA}$PULSES${ENDCOLOR}"
if [ "$PULSES" -gt 0 ]; then
  echo -e "${BOLD}Suspicious:${ENDCOLOR} ${RED}${BOLD}YES${ENDCOLOR}"
else
  echo -e "${BOLD}Suspicious:${ENDCOLOR} ${GREEN}${BOLD}NO${ENDCOLOR}"
fi
echo -e "${BOLD}Sections:${ENDCOLOR} $SECTIONS"

echo -e "${BOLD}Pulse names:${ENDCOLOR}"
[ -n "$PULSE_NAMES" ] && echo "$PULSE_NAMES"

echo -e "${BOLD}Tags:${ENDCOLOR}"
[ -n "$TAGS" ] && echo "$TAGS"

echo -e "${BOLD}References:${ENDCOLOR}"
[ -n "$REFS" ] && echo "$REFS"

SCORE "DOMAIN"
MSG
}

function URL()
{
printf "${GREEN}${BOLD}Enter URL:${ENDCOLOR} "; read url
[[ "$url" =~ ^https?:// ]] || { echo -e "${RED}${BOLD}Invalid URL${ENDCOLOR}"; return; }

URL="$url"
echo
echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}     VirusTotal${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"

SCAN_ID=$(curl -s -X POST "https://www.virustotal.com/api/v3/urls" \
  -H "x-apikey: $VT_API" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "url=$URL" | jq -r '.data.id')

while true; do
  RESP=$(curl -s "https://www.virustotal.com/api/v3/analyses/$SCAN_ID" \
    -H "x-apikey: $VT_API")

  STATUS=$(printf '%s' "$RESP" | jq -r '.data.attributes.status')

  [ "$STATUS" = "completed" ] && break
  sleep 2
done

vt_malicious=$(echo "$RESP" | jq '.data.attributes.stats.malicious')
vt_suspicious=$(echo "$RESP" | jq '.data.attributes.stats.suspicious')
vt_harmless=$(echo "$RESP" | jq '.data.attributes.stats.harmless')
vt_undetected=$(echo "$RESP" | jq '.data.attributes.stats.undetected')

echo -e "${BOLD}Malicious:${ENDCOLOR} ${RED}$vt_malicious${ENDCOLOR}"
echo -e "${BOLD}Suspicious:${ENDCOLOR} ${YELLOW}$vt_suspicious${ENDCOLOR}"
echo -e "${BOLD}Harmless:${ENDCOLOR} ${GREEN}$vt_harmless${ENDCOLOR}"
echo -e "${BOLD}Undetected:${ENDCOLOR} ${CYAN}$vt_undetected${ENDCOLOR}"

echo
echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}   Cloudflare Scan${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"

SCAN_ID=$(curl -s "https://api.cloudflare.com/client/v4/accounts/$CF_ACCOUNT_ID/urlscanner/v2/scan" \
  -H "Authorization: Bearer $CF_TOKEN" \
  -H "Content-Type: application/json" \
  --data "{\"url\":\"$url\",\"visibility\":\"public\"}" | jq -r '.uuid')

if [ -z "$SCAN_ID" ] || [ "$SCAN_ID" = "null" ]; then
  echo -e "${RED}${BOLD}Cloudflare scan failed (no ID)${ENDCOLOR}"
  return
fi

attempts=0

while true; do
  RESP=$(curl -s "https://api.cloudflare.com/client/v4/accounts/$CF_ACCOUNT_ID/urlscanner/v2/result/$SCAN_ID" \
    -H "Authorization: Bearer $CF_TOKEN")

  STATUS=$(echo "$RESP" | jq -r '.task.status' 2>/dev/null)

  [ "$STATUS" = "finished" ] && break

  ((attempts++))
  if ((attempts >= 15)); then
    echo -e "${RED}${BOLD}Cloudflare scan timeout${ENDCOLOR}"
    break
  fi

  sleep 2
done

DOMAIN=$(echo "$RESP" | jq -r '.page.domain // "N/A"')
IP=$(echo "$RESP" | jq -r '.page.ip // "N/A"')
COUNTRY=$(echo "$RESP" | jq -r '.page.country // "N/A"')
ASN=$(echo "$RESP" | jq -r '.page.asnname // "N/A"')
MALICIOUS=$(echo "$RESP" | jq -r 'if .verdicts.overall.malicious then "YES" else "NO" end')
REQUESTS=$(echo "$RESP" | jq -r '(.data.requests | length) // 0')
EXTERNAL=$(echo "$RESP" | jq -r '(.lists.linkDomains // []) | join(", ")')

echo -e "${BOLD}Domain:${ENDCOLOR} $DOMAIN"
echo -e "${BOLD}IP:${ENDCOLOR} $IP"
echo -e "${BOLD}Country:${ENDCOLOR} $COUNTRY"
echo -e "${BOLD}ASN:${ENDCOLOR} $ASN"

if [ "$MALICIOUS" = "YES" ]; then
  echo -e "${BOLD}Malicious:${ENDCOLOR} ${RED}${BOLD}YES${ENDCOLOR}"
else
  echo -e "${BOLD}Malicious:${ENDCOLOR} ${GREEN}${BOLD}NO${ENDCOLOR}"
fi

echo -e "${BOLD}Requests:${ENDCOLOR} $REQUESTS"
echo -e "${BOLD}External:${ENDCOLOR} $EXTERNAL"

echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}    OTX - AlienVault${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"
ENCODED_URL=$(jq -rn --arg x "$url" '$x|@uri')
RESP=$(curl -s "https://otx.alienvault.com/api/v1/indicators/url/$ENCODED_URL/general" \
  -H "X-OTX-API-KEY: $OTX_API")
URL_VALUE=$(echo "$RESP" | jq -r '.indicator // "N/A"')
PULSES=$(echo "$RESP" | jq -r '.pulse_info.count // 0')
TOP_TAGS=$(echo "$RESP" | jq -r '.pulse_info.pulses[].tags[]?' 2>/dev/null | tr '[:upper:]' '[:lower:]' | sort | uniq -c | sort -nr | head -10 | awk '{$1=$1; print}')
RECENT_PULSES=$(echo "$RESP" | jq -r '.pulse_info.pulses[]?.name' 2>/dev/null | head -10)
echo -e "${BOLD}URL:${ENDCOLOR} $URL_VALUE"
echo -e "${BOLD}Pulses:${ENDCOLOR} ${MAGENTA}$PULSES${ENDCOLOR}"

if [ "$PULSES" -gt 0 ]; then
  echo -e "${BOLD}Suspicious:${ENDCOLOR} ${RED}${BOLD}YES${ENDCOLOR}"
else
  echo -e "${BOLD}Suspicious:${ENDCOLOR} ${GREEN}${BOLD}NO${ENDCOLOR}"
fi

echo -e "${BOLD}Top tags:${ENDCOLOR}"
if [ -n "$TOP_TAGS" ]; then
  echo "$TOP_TAGS"
else
  echo "None"
fi

echo -e "${BOLD}Recent pulse names:${ENDCOLOR}"
if [ -n "$RECENT_PULSES" ]; then
  echo "$RECENT_PULSES"
else
  echo "None"
fi

vt_malicious=${vt_malicious:-0}
vt_suspicious=${vt_suspicious:-0}
abuse_score=${abuse_score:-0}
PULSES=${PULSES:-0}

SCORE "URL"
MSG
}

function HASH()
{
printf "${GREEN}${BOLD}Enter Hash (MD5/SHA-1/SHA-256):${ENDCOLOR} "; read hash
if [[ $hash =~ ^[a-fA-F0-9]{32}$ ]]; then
    hash_type="md5"
elif [[ $hash =~ ^[a-fA-F0-9]{40}$ ]]; then
    hash_type="sha1"
elif [[ $hash =~ ^[a-fA-F0-9]{64}$ ]]; then
    hash_type="sha256"
else
    echo -e "${RED}${BOLD}Unsupported hash type (only MD5 / SHA1 / SHA256 are supported)${ENDCOLOR}"
    return
fi
echo -e "${BOLD}Detected hash type:${ENDCOLOR} ${CYAN}$hash_type${ENDCOLOR}"

# VirusTotal

response_vt_file=$(curl -s \
-H "x-apikey: $VT_API" \
"https://www.virustotal.com/api/v3/files/$hash")

vt_malicious=$(echo "$response_vt_file" | jq '.data.attributes.last_analysis_stats.malicious')
vt_suspicious=$(echo "$response_vt_file" | jq '.data.attributes.last_analysis_stats.suspicious')
vt_harmless=$(echo "$response_vt_file" | jq '.data.attributes.last_analysis_stats.harmless')
vt_undetected=$(echo "$response_vt_file" | jq '.data.attributes.last_analysis_stats.undetected')

md5=$(echo "$response_vt_file" | jq -r '.data.attributes.md5')
sha1=$(echo "$response_vt_file" | jq -r '.data.attributes.sha1')
sha256=$(echo "$response_vt_file" | jq -r '.data.attributes.sha256')

type=$(echo "$response_vt_file" | jq -r '.data.attributes.type_description')
size=$(echo "$response_vt_file" | jq '.data.attributes.size')

threat_label=$(echo "$response_vt_file" | jq -r '.data.attributes.popular_threat_classification.suggested_threat_label')
threat_type=$(echo "$response_vt_file" | jq -r '.data.attributes.popular_threat_classification.popular_threat_category[0].value // "N/A"' 2>/dev/null)
tags=$(echo "$response_vt_file" | jq -r '[.data.attributes.tags[]?] | join(", ")')

echo
echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}     VirusTotal${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"
echo -e "${BOLD}Hash:${ENDCOLOR} $hash"
echo -e "${BOLD}Type:${ENDCOLOR} $type"
echo -e "${BOLD}Size:${ENDCOLOR} $size"
echo -e "${BOLD}MD5:${ENDCOLOR} $md5"
echo -e "${BOLD}SHA1:${ENDCOLOR} $sha1"
echo -e "${BOLD}SHA256:${ENDCOLOR} $sha256"
echo -e "${BOLD}VT malicious:${ENDCOLOR} ${RED}$vt_malicious${ENDCOLOR}"
echo -e "${BOLD}VT suspicious:${ENDCOLOR} ${YELLOW}$vt_suspicious${ENDCOLOR}"
echo -e "${BOLD}VT harmless:${ENDCOLOR} ${GREEN}$vt_harmless${ENDCOLOR}"
echo -e "${BOLD}VT undetected:${ENDCOLOR} ${CYAN}$vt_undetected${ENDCOLOR}"
echo -e "${BOLD}Threat:${ENDCOLOR} $threat_type"
echo -e "${BOLD}Family:${ENDCOLOR} $threat_label"
echo -e "${BOLD}Tags:${ENDCOLOR} ${tags:-N/A}"

# MalwareBazaar

response_mb=$(curl -s https://mb-api.abuse.ch/api/v1/ \
  -H "Auth-Key: $MB_API" \
  -d "query=get_info&hash=$hash")

mb_status=$(echo "$response_mb" | jq -r '.query_status')

mb_sha256=$(echo "$response_mb" | jq -r '.data[0].sha256_hash // "N/A"')
mb_sha1=$(echo "$response_mb" | jq -r '.data[0].sha1_hash // "N/A"')
mb_md5=$(echo "$response_mb" | jq -r '.data[0].md5_hash // "N/A"')

mb_file_name=$(echo "$response_mb" | jq -r '.data[0].file_name // "N/A"')
mb_file_type=$(echo "$response_mb" | jq -r '.data[0].file_type // "N/A"')
mb_size=$(echo "$response_mb" | jq -r '.data[0].file_size // "N/A"')

mb_signature=$(echo "$response_mb" | jq -r '.data[0].signature // "N/A"')
mb_tags=$(echo "$response_mb" | jq -r '[.data[0].tags[]?] | join(", ") // "N/A"')

mb_first_seen=$(echo "$response_mb" | jq -r '.data[0].first_seen // "N/A"')

mb_anyrun_verdict=$(echo "$response_mb" | jq -r '.data[0].vendor_intel["ANY.RUN"][0].verdict // "N/A"')
mb_triage_family=$(echo "$response_mb" | jq -r '.data[0].vendor_intel.Triage.malware_family // "N/A"')
mb_rl_status=$(echo "$response_mb" | jq -r '.data[0].vendor_intel.ReversingLabs.status // "N/A"')
mb_rl_name=$(echo "$response_mb" | jq -r '.data[0].vendor_intel.ReversingLabs.threat_name // "N/A"')
mb_fs_verdict=$(echo "$response_mb" | jq -r '.data[0].vendor_intel["FileScan-IO"].verdict // "N/A"')
mb_kaspersky_verdict=$(echo "$response_mb" | jq -r '.data[0].vendor_intel.Kaspersky.verdict // "N/A"')
mb_kaspersky_detection=$(echo "$response_mb" | jq -r '.data[0].vendor_intel.Kaspersky.detections[0] // "N/A"')

echo
echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}   MalwareBazaar${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"

if [ "$mb_status" = "ok" ]; then
  echo -e "${BOLD}Hash:${ENDCOLOR} $hash"
  echo -e "${BOLD}File name:${ENDCOLOR} $mb_file_name"
  echo -e "${BOLD}Type:${ENDCOLOR} $mb_file_type"
  echo -e "${BOLD}Size:${ENDCOLOR} $mb_size"
  echo -e "${BOLD}MD5:${ENDCOLOR} $mb_md5"
  echo -e "${BOLD}SHA1:${ENDCOLOR} $mb_sha1"
  echo -e "${BOLD}SHA256:${ENDCOLOR} $mb_sha256"
  echo -e "${BOLD}Signature:${ENDCOLOR} $mb_signature"
  echo -e "${BOLD}Tags:${ENDCOLOR} $mb_tags"
  echo -e "${BOLD}First seen:${ENDCOLOR} $mb_first_seen"
  echo -e "${BOLD}ANY.RUN verdict:${ENDCOLOR} $mb_anyrun_verdict"
  echo -e "${BOLD}Triage family:${ENDCOLOR} $mb_triage_family"
  echo -e "${BOLD}ReversingLabs:${ENDCOLOR} $mb_rl_status"
  echo -e "${BOLD}ReversingLabs threat:${ENDCOLOR} $mb_rl_name"
  echo -e "${BOLD}FileScan verdict:${ENDCOLOR} $mb_fs_verdict"
  echo -e "${BOLD}Kaspersky verdict:${ENDCOLOR} $mb_kaspersky_verdict"
  echo -e "${BOLD}Kaspersky detection:${ENDCOLOR} $mb_kaspersky_detection"
else
  echo -e "${RED}${BOLD}No results found${ENDCOLOR}"
fi

# OTX

response_otx=$(curl -s \
  -H "X-OTX-API-KEY: $OTX_API" \
  "https://otx.alienvault.com/api/v1/indicators/file/$hash/general")

pulse_count=$(echo "$response_otx" | jq -r '.pulse_info.count // 0')
indicator=$(echo "$response_otx" | jq -r '.indicator // "N/A"')
type=$(echo "$response_otx" | jq -r '.type // "N/A"')
type_title=$(echo "$response_otx" | jq -r '.type_title // "N/A"')

pulse_name=$(echo "$response_otx" | jq -r '.pulse_info.pulses[0].name // "N/A"')
pulse_desc=$(echo "$response_otx" | jq -r '.pulse_info.pulses[0].description // "N/A"')
pulse_created=$(echo "$response_otx" | jq -r '.pulse_info.pulses[0].created // "N/A"')
pulse_modified=$(echo "$response_otx" | jq -r '.pulse_info.pulses[0].modified // "N/A"')
pulse_author=$(echo "$response_otx" | jq -r '.pulse_info.pulses[0].author.username // "N/A"')
pulse_tags=$(echo "$response_otx" | jq -r '[.pulse_info.pulses[0].tags[]?] | join(", ") // "N/A"')
pulse_ref=$(echo "$response_otx" | jq -r '.pulse_info.references[0] // "N/A"')

echo
echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}    OTX - AlienVault${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}========================${ENDCOLOR}"
echo -e "${BOLD}Hash:${ENDCOLOR} $indicator"
echo -e "${BOLD}Type:${ENDCOLOR} $type"
echo -e "${BOLD}Type title:${ENDCOLOR} $type_title"
echo -e "${BOLD}Pulses:${ENDCOLOR} ${MAGENTA}$pulse_count${ENDCOLOR}"
echo -e "${BOLD}Pulse name:${ENDCOLOR} $pulse_name"
echo -e "${BOLD}Description:${ENDCOLOR} $pulse_desc"
echo -e "${BOLD}Author:${ENDCOLOR} $pulse_author"
echo -e "${BOLD}Tags:${ENDCOLOR} $pulse_tags"
echo -e "${BOLD}Reference:${ENDCOLOR} $pulse_ref"
echo -e "${BOLD}Created:${ENDCOLOR} $pulse_created"
echo -e "${BOLD}Modified:${ENDCOLOR} $pulse_modified"

SCORE "HASH"
MSG
}

function SCORE()
{
type="$1"
score=0

vt_malicious=$(echo "$vt_malicious" | tr -cd '0-9')
vt_suspicious=$(echo "$vt_suspicious" | tr -cd '0-9')
abuse_score=$(echo "$abuse_score" | tr -cd '0-9')
PULSES=$(echo "$PULSES" | tr -cd '0-9')

vt_malicious=${vt_malicious:-0}
vt_suspicious=${vt_suspicious:-0}
abuse_score=${abuse_score:-0}
PULSES=${PULSES:-0}

if ((vt_malicious >= 30)); then
    ((score += 50))
elif ((vt_malicious >= 10)); then
    ((score += 30))
elif ((vt_malicious > 0)); then
    ((score += 15))
fi

if ((vt_suspicious > 0)); then
    ((score += 10))
fi

if ((abuse_score >= 75)); then
    ((score += 30))
elif ((abuse_score >= 40)); then
     ((score += 20))
elif ((abuse_score > 0)); then
    ((score += 10))
fi

if ((PULSES >= 10)); then
    ((score += 25))
elif ((PULSES >= 3)); then
    ((score += 15))
elif ((PULSES > 0)); then
    ((score += 5))
fi

case "$level" in
    high) ((score += 25)) ;;
    mid)  ((score += 15)) ;;
    low)  ((score += 5)) ;;
esac

sources=0

((vt_malicious > 0)) && ((sources++))
((abuse_score > 0)) && ((sources++))
((PULSES > 0)) && ((sources++))
[[ "$level" == "high" || "$level" == "mid" ]] && ((sources++))

if ((sources >= 3)); then
    ((score += 15))
elif ((sources == 2)); then
    ((score += 5))
fi

((score > 100)) && score=100

if ((score >= 75)); then
    verdict="${RED}${BOLD}HIGHLY MALICIOUS${ENDCOLOR}"
elif ((score >= 45)); then
    verdict="${YELLOW}${BOLD}SUSPICIOUS${ENDCOLOR}"
elif ((score >= 20)); then
    verdict="${CYAN}${BOLD}LOW RISK${ENDCOLOR}"
else
    verdict="${GREEN}${BOLD}CLEAN / UNKNOWN${ENDCOLOR}"
fi

echo
echo -e "${YELLOW}${BOLD}=======================${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}     Threat Score${ENDCOLOR}"
echo -e "${YELLOW}${BOLD}=======================${ENDCOLOR}"
echo -e "${BOLD}Type:${ENDCOLOR} $type"
echo -e "${BOLD}Score:${ENDCOLOR} ${MAGENTA}${BOLD}$score / 100${ENDCOLOR}"
echo -e "${BOLD}Verdict:${ENDCOLOR} $verdict"
}

function MSG()
{
case "$scan_choice" in
    1) type="$ip_type"; obj="$ip" ;;
    2) type="Domain"; obj="$domain" ;;
    3) type="URL"; obj="$url" ;;
    4) type="Hash"; obj="$hash" ;;
esac

plain_verdict=$(echo "$verdict" | sed -E 's/\\e\[[0-9;]*m//g; s/\x1b\[[0-9;]*m//g')

if ((score >= 75)); then
    emoji="🔴"
elif ((score >= 45)); then
    emoji="🟠"
elif ((score >= 20)); then
    emoji="🟡"
else
    emoji="🟢"
fi

if ((score >= 75)); then
    risk="HIGH"
elif ((score >= 45)); then
    risk="MEDIUM"
elif ((score >= 20)); then
    risk="LOW"
else
    risk="NONE"
fi

msg="$emoji ThreatScanner Alert

Type: $type
Target: $obj

Score: $score / 100
Verdict: $plain_verdict

Indicators:
VT: M=${vt_malicious:-0} S=${vt_suspicious:-0}
AbuseIPDB: ${abuse_score:-N/A}
OTX: ${PULSES:-0} pulses

Risk: $risk

Time: $(date '+%Y-%m-%d %H:%M:%S')"

curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
    -d "chat_id=${CHAT_ID}" \
    --data-urlencode "text=${msg}" >/dev/null

echo
echo "Message was sent"
}

APPS
CONF
MENU
