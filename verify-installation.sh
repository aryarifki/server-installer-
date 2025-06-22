#!/bin/bash

# =============================================================================
# INSTALLATION VERIFICATION SCRIPT
# =============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

print_header() {
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}$1${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

clear
print_header "🔍 MODERN STACK VERIFICATION"
echo -e "${CYAN}Date: $(date)${NC}"
echo -e "${CYAN}User: $(whoami)${NC}"
echo -e "${CYAN}Server: $(hostname)${NC}"
echo ""

# Service status check
print_header "📊 SERVICE STATUS CHECK"
services=(
    "cockpit:Cockpit System Management"
    "docker:Docker Container Engine"
    "netdata:Netdata Real-time Monitoring"
    "filebrowser:FileBrowser File Management"
    "prometheus:Prometheus Metrics Collection"
    "node_exporter:Node Exporter System Metrics"
    "grafana-server:Grafana Analytics Platform"
)

for service_info in "${services[@]}"; do
    IFS=':' read -r service description <<< "$service_info"
    
    if systemctl is-active "$service" >/dev/null 2>&1; then
        echo -e "${GREEN}✅${NC} ${description}"
    else
        echo -e "${RED}❌${NC} ${description}"
    fi
done

# Network connectivity check
echo ""
print_header "🌐 NETWORK CONNECTIVITY CHECK"
ports=(
    "9090:Cockpit"
    "9000:Portainer"
    "19999:Netdata"
    "8080:FileBrowser"
    "9091:Prometheus"
    "9100:Node Exporter"
    "3000:Grafana"
)

for port_info in "${ports[@]}"; do
    IFS=':' read -r port service_name <<< "$port_info"
    
    if curl -k -s --connect-timeout 5 "http://localhost:$port" >/dev/null 2>&1 || \
       curl -k -s --connect-timeout 5 "https://localhost:$port" >/dev/null 2>&1; then
        echo -e "${GREEN}✅${NC} Port $port ($service_name) responding"
    else
        echo -e "${RED}❌${NC} Port $port ($service_name) not responding"
    fi
done

echo ""
print_header "🌐 ACCESS INFORMATION"
echo -e "${CYAN}Server IP: 4.198.176.206${NC}"
echo ""
echo -e "${WHITE}Your Management Tools:${NC}"
echo "📱 Cockpit:     https://4.198.176.206:9090"
echo "🐳 Portainer:   https://4.198.176.206:9000"
echo "📊 Netdata:     https://4.198.176.206:19999"
echo "📁 FileBrowser: https://4.198.176.206:8080"
echo "📈 Grafana:     https://4.198.176.206:3000"
echo "🔍 Prometheus:  https://4.198.176.206:9091"

echo ""
print_header "✅ VERIFICATION COMPLETE"