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

# 6. Detect and launch the panel entry point
# Do not assume the repository contains ./hvm.py. Find a known startup file
# in the repository (including one or two levels of subdirectories).
echo ""
echo -e "${C4}================================================================================${NC}"
echo -e " ${C3}✅ INSTALLATION FINISHED BY EVILSAAD${NC}"
echo -e " ${C6}🔎 Looking for the HVM Panel startup file...${NC}"
echo -e "${C4}================================================================================${NC}"
echo ""

ENTRYPOINT=""
for candidate in hvm.py app.py main.py panel.py run.py server.py; do
    found="$(find . -maxdepth 3 -type f -name "$candidate" -not -path './venv/*' -print -quit)"
    if [ -n "$found" ]; then
        ENTRYPOINT="$found"
        break
    fi
done

if [ -n "$ENTRYPOINT" ]; then
    echo -e "${C3}Starting panel using: ${ENTRYPOINT}${NC}"
    echo -e "${WHITE}🌐 Default panel port (if configured by the app):${NC} ${C2}5000${NC}"
    exec ./venv/bin/python3 "$ENTRYPOINT"
else
    echo -e "${C1}✖ Could not find a supported Python startup file.${NC}"
    echo -e "${C2}The installer no longer assumes that hvm.py exists.${NC}"
    echo -e "${C2}Repository files (first 80):${NC}"
    find . -maxdepth 3 -type f -not -path './.git/*' -not -path './venv/*' | sort | head -80
    echo ""
    echo -e "${C1}Installation completed, but the panel was not started.${NC}"
    echo -e "${C2}Check the repository README for its actual startup command.${NC}"
    exit 1
fi
