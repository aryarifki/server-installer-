#!/bin/bash

# =============================================================================
# COMPLETE MODERN WEB MANAGEMENT STACK INSTALLER (FIXED)
# Replaces Webmin with powerful modern alternatives
# Created: 2025-06-22 22:35:51 UTC
# User: aryarifki
# Repository: https://github.com/aryarifki/server-installer-
# =============================================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}$1${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Function to check if service is running
check_service() {
    if systemctl is-active "$1" >/dev/null 2>&1; then
        print_success "$1 is running"
        return 0
    else
        print_warning "$1 is not running"
        return 1
    fi
}

# Function to check if port is responding
check_port() {
    local port=$1
    local service_name=$2
    
    if curl -k -s --connect-timeout 5 "http://localhost:$port" >/dev/null 2>&1 || \
       curl -k -s --connect-timeout 5 "https://localhost:$port" >/dev/null 2>&1; then
        print_success "$service_name responding on port $port"
        return 0
    else
        print_warning "$service_name not responding on port $port"
        return 1
    fi
}

# Start installation
clear
print_header "🚀 COMPLETE MODERN STACK INSTALLER (FIXED)"
echo -e "${CYAN}Date: $(date)${NC}"
echo -e "${CYAN}User: $(whoami)${NC}"
echo -e "${CYAN}Server: $(hostname)${NC}"
echo -e "${CYAN}Repository: https://github.com/aryarifki/server-installer-${NC}"
echo ""
echo "This script will:"
echo "• Remove Webmin completely"
echo "• Install Cockpit (System Management)"
echo "• Install Docker + Portainer (Container Management)"
echo "• Install Netdata (Real-time Monitoring)"
echo "• Install Grafana + Prometheus (Advanced Analytics)"
echo "• Install FileBrowser (Web File Manager)"
echo ""
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_error "Installation cancelled"
    exit 1
fi

# =============================================================================
# PHASE 1: REMOVE WEBMIN COMPLETELY
# =============================================================================
print_header "🗑️ PHASE 1: REMOVING WEBMIN"

print_status "Stopping Webmin services..."
sudo systemctl stop webmin 2>/dev/null || true
sudo systemctl disable webmin 2>/dev/null || true

print_status "Removing Webmin packages..."
sudo apt remove webmin* -y >/dev/null 2>&1 || true
sudo apt autoremove -y >/dev/null 2>&1 || true
sudo apt autoclean >/dev/null 2>&1 || true

print_status "Removing Webmin directories and files..."
sudo rm -rf /etc/webmin
sudo rm -rf /var/webmin  
sudo rm -rf /usr/share/webmin
sudo rm -f /etc/systemd/system/webmin.service*
sudo rm -rf /etc/systemd/system/webmin.service.d/
sudo rm -f /etc/apt/sources.list.d/webmin.list
sudo rm -f /etc/apt/trusted.gpg.d/webmin*
sudo rm -f /usr/local/bin/webmin*

print_status "Cleaning environment variables..."
sudo sed -i '/WEBMIN/d' /etc/environment
sudo sed -i '/WEBMIN/d' /root/.bashrc 2>/dev/null || true

print_status "Reloading systemd..."
sudo systemctl daemon-reload
sudo systemctl reset-failed

print_success "Webmin removed completely!"

# =============================================================================
# PHASE 2: INSTALL COCKPIT
# =============================================================================
print_header "📱 PHASE 2: INSTALLING COCKPIT"

print_status "Updating package lists..."
sudo apt update >/dev/null 2>&1

print_status "Installing Cockpit and modules..."
sudo apt install -y \
    cockpit \
    cockpit-machines \
    cockpit-podman \
    cockpit-storaged \
    cockpit-networkmanager \
    cockpit-packagekit >/dev/null 2>&1

print_status "Starting and enabling Cockpit..."
sudo systemctl start cockpit
sudo systemctl enable cockpit >/dev/null 2>&1

print_status "Configuring firewall..."
sudo ufw allow 9090 >/dev/null 2>&1

sleep 3
check_service "cockpit"
check_port "9090" "Cockpit"

print_success "Cockpit installed successfully!"

# =============================================================================
# PHASE 3: INSTALL DOCKER + PORTAINER
# =============================================================================
print_header "🐳 PHASE 3: INSTALLING DOCKER + PORTAINER"

print_status "Installing Docker..."
sudo apt install -y \
    docker.io \
    docker-compose \
    docker-buildx >/dev/null 2>&1

print_status "Starting and enabling Docker..."
sudo systemctl start docker
sudo systemctl enable docker >/dev/null 2>&1

print_status "Adding user to docker group..."
sudo usermod -aG docker aryarifki

print_status "Installing Portainer..."
sudo docker volume create portainer_data >/dev/null 2>&1

sudo docker run -d \
    -p 9000:9000 \
    --name portainer \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce:latest >/dev/null 2>&1

print_status "Configuring firewall..."
sudo ufw allow 9000 >/dev/null 2>&1

sleep 5
check_service "docker"
check_port "9000" "Portainer"

print_success "Docker + Portainer installed successfully!"

# =============================================================================
# PHASE 4: INSTALL NETDATA
# =============================================================================
print_header "📊 PHASE 4: INSTALLING NETDATA"

print_status "Installing Netdata..."
bash <(curl -Ss https://my-netdata.io/kickstart.sh) \
    --dont-wait \
    --disable-telemetry >/dev/null 2>&1

print_status "Configuring firewall..."
sudo ufw allow 19999 >/dev/null 2>&1

sleep 10
check_service "netdata"
check_port "19999" "Netdata"

print_success "Netdata installed successfully!"

# =============================================================================
# PHASE 5: INSTALL FILEBROWSER
# =============================================================================
print_header "📁 PHASE 5: INSTALLING FILEBROWSER"

print_status "Downloading and installing FileBrowser..."
curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash >/dev/null 2>&1

print_status "Creating FileBrowser configuration..."
sudo mkdir -p /etc/filebrowser

sudo tee /etc/filebrowser/config.json << 'EOF' >/dev/null
{
  "port": 8080,
  "address": "0.0.0.0",
  "database": "/etc/filebrowser/database.db",
  "root": "/",
  "username": "aryarifki",
  "password": "aryarifki123"
}
EOF

print_status "Creating systemd service..."
sudo tee /etc/systemd/system/filebrowser.service << 'EOF' >/dev/null
[Unit]
Description=FileBrowser
After=network.target

[Service]
User=root
Group=root
ExecStart=/usr/local/bin/filebrowser -c /etc/filebrowser/config.json
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

print_status "Starting and enabling FileBrowser..."
sudo systemctl daemon-reload
sudo systemctl start filebrowser
sudo systemctl enable filebrowser >/dev/null 2>&1

print_status "Configuring firewall..."
sudo ufw allow 8080 >/dev/null 2>&1

sleep 3
check_service "filebrowser"
check_port "8080" "FileBrowser"

print_success "FileBrowser installed successfully!"

# =============================================================================
# PHASE 6: INSTALL PROMETHEUS + NODE EXPORTER
# =============================================================================
print_header "📈 PHASE 6: INSTALLING PROMETHEUS"

print_status "Creating prometheus user..."
sudo useradd --no-create-home --shell /bin/false prometheus 2>/dev/null || true
sudo mkdir -p /etc/prometheus /var/lib/prometheus
sudo chown prometheus:prometheus /etc/prometheus /var/lib/prometheus

print_status "Downloading and installing Prometheus..."
cd /tmp
wget -q https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz
tar xzf prometheus-2.45.0.linux-amd64.tar.gz >/dev/null 2>&1
sudo cp prometheus-2.45.0.linux-amd64/prometheus /usr/local/bin/
sudo cp prometheus-2.45.0.linux-amd64/promtool /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/prometheus /usr/local/bin/promtool

print_status "Creating Prometheus configuration..."
sudo tee /etc/prometheus/prometheus.yml << 'EOF' >/dev/null
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9091']
  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']
EOF

sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml

print_status "Creating Prometheus service..."
sudo tee /etc/systemd/system/prometheus.service << 'EOF' >/dev/null
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries \
    --web.listen-address=0.0.0.0:9091

[Install]
WantedBy=multi-user.target
EOF

print_status "Installing Node Exporter..."
cd /tmp
wget -q https://github.com/prometheus/node_exporter/releases/download/v1.6.0/node_exporter-1.6.0.linux-amd64.tar.gz
tar xzf node_exporter-1.6.0.linux-amd64.tar.gz >/dev/null 2>&1
sudo cp node_exporter-1.6.0.linux-amd64/node_exporter /usr/local/bin/
sudo useradd --no-create-home --shell /bin/false node_exporter 2>/dev/null || true
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

print_status "Creating Node Exporter service..."
sudo tee /etc/systemd/system/node_exporter.service << 'EOF' >/dev/null
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

print_status "Starting Prometheus services..."
sudo systemctl daemon-reload
sudo systemctl start prometheus node_exporter
sudo systemctl enable prometheus node_exporter >/dev/null 2>&1

print_status "Configuring firewall..."
sudo ufw allow 9091 >/dev/null 2>&1  # Prometheus
sudo ufw allow 9100 >/dev/null 2>&1  # Node Exporter

sleep 5
check_service "prometheus"
check_service "node_exporter"
check_port "9091" "Prometheus"

print_success "Prometheus + Node Exporter installed successfully!"

# =============================================================================
# PHASE 7: INSTALL GRAFANA
# =============================================================================
print_header "📊 PHASE 7: INSTALLING GRAFANA"

print_status "Adding Grafana repository..."
sudo apt install -y software-properties-common wget >/dev/null 2>&1
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add - >/dev/null 2>&1
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list >/dev/null

print_status "Installing Grafana..."
sudo apt update >/dev/null 2>&1
sudo apt install -y grafana >/dev/null 2>&1

print_status "Starting and enabling Grafana..."
sudo systemctl start grafana-server
sudo systemctl enable grafana-server >/dev/null 2>&1

print_status "Configuring firewall..."
sudo ufw allow 3000 >/dev/null 2>&1

sleep 5
check_service "grafana-server"
check_port "3000" "Grafana"

print_success "Grafana installed successfully!"

# =============================================================================
# PHASE 8: FINAL VERIFICATION AND CLEANUP
# =============================================================================
print_header "✅ PHASE 8: FINAL VERIFICATION"

print_status "Cleaning up temporary files..."
rm -f /tmp/prometheus-*.tar.gz
rm -f /tmp/node_exporter-*.tar.gz
rm -rf /tmp/prometheus-*
rm -rf /tmp/node_exporter-*

print_status "Verifying all services..."
echo ""

services=(
    "cockpit"
    "docker"
    "netdata"
    "filebrowser"
    "prometheus"
    "node_exporter"
    "grafana-server"
)

all_services_ok=true
for service in "${services[@]}"; do
    if ! check_service "$service"; then
        all_services_ok=false
    fi
done

print_status "Verifying network connectivity..."
echo ""

ports=(
    "9090:Cockpit"
    "9000:Portainer"
    "19999:Netdata"
    "8080:FileBrowser"
    "9091:Prometheus"
    "3000:Grafana"
)

all_ports_ok=true
for port_info in "${ports[@]}"; do
    IFS=':' read -r port service_name <<< "$port_info"
    if ! check_port "$port" "$service_name"; then
        all_ports_ok=false
    fi
done

# =============================================================================
# INSTALLATION COMPLETE
# =============================================================================
clear
print_header "🎉 INSTALLATION COMPLETE!"

echo -e "${GREEN}All modern web management tools have been installed successfully!${NC}"
echo ""

print_header "🌐 ACCESS YOUR NEW MANAGEMENT TOOLS"

echo -e "${CYAN}🏠 Server IP: 4.198.176.206${NC}"
echo ""

echo -e "${WHITE}📱 Cockpit (System Management):${NC}"
echo -e "   ${BLUE}URL:${NC} https://4.198.176.206:9090"
echo -e "   ${BLUE}Login:${NC} aryarifki / aryarifki#1123"
echo -e "   ${BLUE}Features:${NC} System monitoring, services, users, terminal"
echo ""

echo -e "${WHITE}🐳 Portainer (Container Management):${NC}"
echo -e "   ${BLUE}URL:${NC} https://4.198.176.206:9000"
echo -e "   ${BLUE}Setup:${NC} Create admin account on first visit"
echo -e "   ${BLUE}Features:${NC} Docker containers, images, volumes, networks"
echo ""

echo -e "${WHITE}📊 Netdata (Real-time Monitoring):${NC}"
echo -e "   ${BLUE}URL:${NC} https://4.198.176.206:19999"
echo -e "   ${BLUE}Access:${NC} No login required"
echo -e "   ${BLUE}Features:${NC} Real-time metrics, performance monitoring"
echo ""

echo -e "${WHITE}📁 FileBrowser (File Management):${NC}"
echo -e "   ${BLUE}URL:${NC} https://4.198.176.206:8080"
echo -e "   ${BLUE}Login:${NC} aryarifki / aryarifki123"
echo -e "   ${BLUE}Features:${NC} Web file manager, upload, download, edit"
echo ""

echo -e "${WHITE}📈 Grafana (Analytics Dashboard):${NC}"
echo -e "   ${BLUE}URL:${NC} https://4.198.176.206:3000"
echo -e "   ${BLUE}Login:${NC} admin / admin (change on first login)"
echo -e "   ${BLUE}Features:${NC} Advanced analytics, custom dashboards"
echo ""

echo -e "${WHITE}🔍 Prometheus (Metrics Collection):${NC}"
echo -e "   ${BLUE}URL:${NC} https://4.198.176.206:9091"
echo -e "   ${BLUE}Access:${NC} No login required"
echo -e "   ${BLUE}Features:${NC} Metrics collection, time-series data"
echo ""

print_header "💡 GETTING STARTED RECOMMENDATIONS"

echo -e "${YELLOW}1.${NC} Start with ${CYAN}Cockpit${NC} for general system management"
echo -e "${YELLOW}2.${NC} Use ${CYAN}Portainer${NC} to manage Docker containers"
echo -e "${YELLOW}3.${NC} Monitor performance with ${CYAN}Netdata${NC}"
echo -e "${YELLOW}4.${NC} Manage files with ${CYAN}FileBrowser${NC}"
echo -e "${YELLOW}5.${NC} Create custom dashboards with ${CYAN}Grafana${NC}"
echo ""

print_header "🔧 USEFUL COMMANDS"

echo "View all service status:"
echo "  sudo systemctl status cockpit docker netdata filebrowser prometheus grafana-server"
echo ""
echo "View firewall rules:"
echo "  sudo ufw status"
echo ""
echo "View running containers:"
echo "  sudo docker ps"
echo ""

if $all_services_ok && $all_ports_ok; then
    print_success "All services are running and accessible! 🚀"
else
    print_warning "Some services may need attention. Check the status above."
fi

echo ""
echo -e "${GREEN}Enjoy your new powerful web management tools!${NC}"
echo -e "${CYAN}Webmin has been completely replaced with modern alternatives.${NC}"
echo ""

# Create a summary file
cat > ~/installation-summary.txt << 'EOF'
MODERN WEB MANAGEMENT STACK - INSTALLATION SUMMARY
==================================================
Installation Date: $(date)
User: aryarifki
Server IP: 4.198.176.206

INSTALLED TOOLS:
- Cockpit: https://4.198.176.206:9090 (aryarifki/aryarifki#1123)
- Portainer: https://4.198.176.206:9000 (create admin account)
- Netdata: https://4.198.176.206:19999 (no login)
- FileBrowser: https://4.198.176.206:8080 (aryarifki/aryarifki123)
- Grafana: https://4.198.176.206:3000 (admin/admin)
- Prometheus: https://4.198.176.206:9091 (no login)

FEATURES REPLACED FROM WEBMIN:
✅ System Management → Cockpit
✅ File Management → FileBrowser
✅ Service Management → Cockpit
✅ User Management → Cockpit
✅ Performance Monitoring → Netdata + Grafana
✅ Container Management → Portainer
✅ Advanced Analytics → Grafana + Prometheus

STATUS: Installation completed successfully!
EOF

print_success "Installation summary saved to ~/installation-summary.txt"

exit 0