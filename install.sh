#!/bin/bash

# ==============================================================================
# Title: Hvm Panel v5 - Ultimate Rainbow Edition
# Developer: EVILSAAD
# ==============================================================================

# Color Definitions
C1='\033[0;31m' # Red
C2='\033[0;33m' # Yellow
C3='\033[0;32m' # Green
C4='\033[0;36m' # Cyan
C5='\033[0;34m' # Blue
C6='\033[0;35m' # Magenta
WHITE='\033[1;37m'
NC='\033[0m' # No Color

clear

# --- Rainbow Header Logic ---
print_rainbow() {
    local lines=(
        "################################################################################"
        " ███████╗██╗   ██╗██╗██╗      ███████╗ █████╗  █████╗ ██████╗"
        " ██╔════╝██║   ██║██║██║      ██╔════╝██╔══██╗██╔══██╗██╔══██╗"
        " █████╗  ██║   ██║██║██║      ███████╗███████║███████║██║  ██║"
        " ██╔══╝  ╚██╗ ██╔╝██║██║      ╚════██║██╔══██║██╔══██║██║  ██║"
        " ███████╗ ╚████╔╝ ██║███████╗ ███████║██║  ██║██║  ██║██████╔╝"
        " ╚══════╝  ╚═══╝  ╚═╝╚══════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝"
        "                      VERSION 5.0 - ULTIMATE                    "
        "                   --- MADE BY EVILSAAD ---                    "
        "################################################################################"
    )
    local colors=($C1 $C2 $C3 $C4 $C5 $C6)
    for i in "${!lines[@]}"; do
        echo -e "${colors[$i % ${#colors[@]}]}${lines[$i]}${NC}"
    done
}

print_rainbow
echo ""

# --- Main Menu ---
while true; do
    echo -e "${C4}==================== MAIN MENU ====================${NC}"
    echo -e " ${C3}1) HVM PANEL INSTALL${NC}"
    echo -e " ${C1}2) Exit${NC}"
    echo -e "${C4}===================================================${NC}"
    read -r -p "Select an option [1-2]: " choice

    case "$choice" in
        1)
            echo -e "${C3}Starting HVM Panel installation...${NC}"
            break
            ;;
        2)
            echo -e "${C2}Exiting installer. Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${C1}Invalid option. Please select 1 or 2.${NC}"
            ;;
    esac
done

echo ""

# 1. Update System and install required tools
echo -e "${C3}--> [1/6] Updating system and installing prerequisites...${NC}"
if ! apt update || ! apt upgrade -y; then
    echo -e "${C1}✖ System update failed.${NC}"
    exit 1
fi
if ! apt install python3 python3-pip python3-venv unzip git snapd bridge-utils uidmap lxc-utils -y; then
    echo -e "${C1}✖ Required package installation failed.${NC}"
    exit 1
fi

# 2. Clone HVM repository and enter its directory
echo -e "${C4}--> [2/6] Cloning HVM repository...${NC}"
if [ -d "hvm/.git" ]; then
    echo -e "${C2}⚠ hvm repository already exists; using existing checkout.${NC}"
elif [ -e "hvm" ]; then
    echo -e "${C1}✖ A 'hvm' path already exists but is not a Git repository. Rename or remove it first.${NC}"
    exit 1
else
    if ! git clone https://github.com/evilsaad0-hash/hvm.git; then
        echo -e "${C1}✖ Git clone failed.${NC}"
        exit 1
    fi
fi
cd hvm || exit 1

# 3. LXD Setup
echo -e "${C5}--> [3/6] Setting up LXD Virtualization...${NC}"
snap install lxd
usermod -aG lxd "${SUDO_USER:-$USER}"

# 4. Network Init
echo -e "${C6}--> [4/6] Configuring Network Bridge...${NC}"
lxd init --auto

# 5. Virtual environment and dependencies
echo -e "${C2}--> [5/6] Preparing Python environment...${NC}"
if [ ! -d "venv" ]; then
    python3 -m venv venv || exit 1
fi
./venv/bin/pip install --upgrade pip || exit 1
if [ -f "requirements.txt" ]; then
    ./venv/bin/pip install -r requirements.txt || exit 1
else
    echo -e "${C2}⚠ Warning: requirements.txt missing!${NC}"
fi

# 6. Final Launch (Port 5000)
echo ""
echo -e "${C4}================================================================================${NC}"
echo -e " ${C3}✅ INSTALLATION FINISHED BY EVILSAAD${NC}"
echo -e " ${WHITE}🌐 PORT:${NC} ${C2}5000${NC}"
echo -e " ${C6}🚀 STARTING HVM-V5 PANEL NOW...${NC}"
echo -e "${C4}================================================================================${NC}"
echo ""

# Run the panel
# Note: Ensure hvm.py is configured to listen on port 5000
./venv/bin/python3 hvm.py
