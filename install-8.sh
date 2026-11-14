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
echo -e "${C3}--> [1/7] Updating system and installing prerequisites...${NC}"
if ! apt update || ! apt upgrade -y; then
    echo -e "${C1}✖ System update failed.${NC}"
    exit 1
fi
if ! apt install python3 python3-pip python3-venv unzip git snapd bridge-utils uidmap lxc-utils -y; then
    echo -e "${C1}✖ Required package installation failed.${NC}"
    exit 1
fi

# 2. Clone HVM repository and enter its directory
echo -e "${C4}--> [2/7] Cloning HVM repository...${NC}"
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
echo -e "${C5}--> [3/7] Setting up LXD Virtualization...${NC}"
snap install lxd
usermod -aG lxd "${SUDO_USER:-$USER}"

# 4. Network Init
echo -e "${C6}--> [4/7] Configuring Network Bridge...${NC}"
lxd init --auto

# 5. Extract HVM Panel files
# Supports either an archive named Hvm-v5.zip or Hvm-v5.
echo -e "${C2}--> [5/7] Extracting HVM Panel files...${NC}"
if [ -f "Hvm-v5.zip" ]; then
    unzip -o "Hvm-v5.zip" || { echo -e "${C1}✖ Failed to extract Hvm-v5.zip.${NC}"; exit 1; }
elif [ -f "Hvm-v5" ]; then
    unzip -o "Hvm-v5" || { echo -e "${C1}✖ Failed to extract Hvm-v5.${NC}"; exit 1; }
else
    echo -e "${C1}✖ Hvm-v5 archive not found inside $(pwd).${NC}"
    echo -e "${C2}Upload Hvm-v5.zip into the cloned hvm directory and run the installer again.${NC}"
    exit 1
fi

# 6. Enter the extracted HVM directory
echo -e "${C4}--> [6/7] Entering HVM directory...${NC}"
if [ -d "HVM" ]; then
    cd HVM || exit 1
elif [ -d "hvm" ]; then
    cd hvm || exit 1
else
    echo -e "${C1}✖ Extracted HVM directory was not found.${NC}"
    echo -e "${C2}Directories available:${NC}"
    find . -maxdepth 2 -type d -not -path './.git*' -not -path './venv*' -print
    exit 1
fi

# 7. Create Python environment, install dependencies, and launch
echo -e "${C2}--> [7/7] Setting up Python environment and starting HVM Panel...${NC}"
python3 -m venv venv || { echo -e "${C1}✖ Could not create Python virtual environment.${NC}"; exit 1; }
source venv/bin/activate || exit 1
pip install --upgrade pip || { echo -e "${C1}✖ pip upgrade failed.${NC}"; exit 1; }
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt || { echo -e "${C1}✖ Requirements installation failed.${NC}"; exit 1; }
else
    echo -e "${C1}✖ requirements.txt not found in $(pwd).${NC}"
    exit 1
fi

if [ ! -f "hvm.py" ]; then
    echo -e "${C1}✖ hvm.py not found in $(pwd).${NC}"
    echo -e "${C2}Files in current directory:${NC}"
    ls -la
    exit 1
fi

echo -e "${C3}✅ Installation completed. Starting HVM Panel...${NC}"
python hvm.py
