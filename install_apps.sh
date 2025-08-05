#!/bin/bash

# This script automates the installation of common applications on Ubuntu Desktop 24.04 LTS.
# It uses a combination of apt (package manager) and snap (universal packaging system).

# --- Configuration ---
# Set to 'true' if you want the script to automatically proceed without asking for confirmation
# for certain steps (e.g., adding repositories). Be cautious with this!
AUTO_CONFIRM=false

# --- Functions ---
# Function to check if a command exists
command_exists () {
    type "$1" &> /dev/null ;
}

# Function to prompt for confirmation
confirm_action() {
    if [ "$AUTO_CONFIRM" = true ]; then
        echo "Auto-confirming: $1"
        return 0 # Success
    else
        read -p "$1 (y/N)? " choice
        case "$choice" in
            y|Y ) return 0;;
            * ) return 1;;
        esac
    fi
}

# Function to display a section header
print_header() {
    echo ""
    echo "--- $1 ---"
    echo ""
}

# --- Script Start ---
echo "Starting Ubuntu Desktop 24.04 LTS Program Installation Script..."
echo "This script requires sudo privileges for many operations."
echo "You may be prompted for your password multiple times."

# Update package lists first
print_header "Updating System Package Lists"
sudo apt update -y || { echo "Failed to update package lists. Exiting."; exit 1; }
sudo apt upgrade -y || { echo "Failed to upgrade packages. Continuing..."; }

# --- Install VS Code ---
print_header "Installing Visual Studio Code"
# VS Code is easily installed via Snap, which keeps it updated automatically.
# The '--classic' flag is needed for applications that require broader system access.
if command_exists code; then
    echo "VS Code is already installed."
else
    if confirm_action "Install VS Code via Snap?"; then
        sudo snap install code --classic || echo "Failed to install VS Code."
    else
        echo "Skipping VS Code installation."
    fi
fi

# --- Install DBVisualizer ---
print_header "Installing DBVisualizer"
# DBVisualizer requires downloading a .deb package from their official website.
# You will need to check their website for the latest stable version download link.
# Go to: https://www.dbvis.com/download/
# Look for the "Linux (deb 64-bit)" download.
DBVIS_DOWNLOAD_URL="https://www.dbvis.com/download/dbvis_linux_13_0_6.deb" # <<< CHECK FOR LATEST VERSION HERE!
DBVIS_DEB_FILE="dbvis_linux_installer.deb"

echo "Please check https://www.dbvis.com/download/ for the latest stable version."
echo "The script is currently configured to download: $DBVIS_DOWNLOAD_URL"

if command_exists dbvis; then
    echo "DBVisualizer appears to be installed."
else
    if confirm_action "Download and install DBVisualizer?"; then
        wget -O "$DBVIS_DEB_FILE" "$DBVIS_DOWNLOAD_URL" && \
        sudo dpkg -i "$DBVIS_DEB_FILE" && \
        sudo apt --fix-broken install -y && \
        rm "$DBVIS_DEB_FILE" || echo "Failed to install DBVisualizer. Check the download URL and dependencies."
    else
        echo "Skipping DBVisualizer installation."
    fi
fi

# --- Install Zoom ---
print_header "Installing Zoom"
# Zoom also provides a .deb package. They often have a 'latest' URL.
# Go to: https://zoom.us/download
# Look for the "Linux" section and download the "Ubuntu" package.
ZOOM_DOWNLOAD_URL="https://zoom.us/client/latest/zoom_amd64.deb" # This URL usually points to the latest.
ZOOM_DEB_FILE="zoom_latest_amd64.deb"

echo "Downloading Zoom from: $ZOOM_DOWNLOAD_URL"

if command_exists zoom; then
    echo "Zoom is already installed."
else
    if confirm_action "Download and install Zoom?"; then
        wget -O "$ZOOM_DEB_FILE" "$ZOOM_DOWNLOAD_URL" && \
        sudo dpkg -i "$ZOOM_DEB_FILE" && \
        sudo apt --fix-broken install -y && \
        rm "$ZOOM_DEB_FILE" || echo "Failed to install Zoom. Check the download URL and dependencies."
    else
        echo "Skipping Zoom installation."
    fi
fi

# --- Install TickTick ---
print_header "Installing TickTick"
# TickTick is available as a Snap package.
if command_exists ticktick; then
    echo "TickTick is already installed."
else
    if confirm_action "Install TickTick via Snap?"; then
        sudo snap install ticktick || echo "Failed to install TickTick."
    else
        echo "Skipping TickTick installation."
    fi
fi

# --- Install Google Chrome ---
print_header "Installing Google Chrome"
# Chrome needs its official repository added to your system.
if command_exists google-chrome; then
    echo "Google Chrome is already installed."
else
    if confirm_action "Install Google Chrome?"; then
        echo "Adding Google Chrome repository..."
        wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg && \
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list > /dev/null && \
        sudo apt update -y && \
        sudo apt install google-chrome-stable -y || echo "Failed to install Google Chrome."
    else
        echo "Skipping Google Chrome installation."
    fi
fi

# --- Install Git ---
print_header "Installing Git"
# Git is usually in the default Ubuntu repositories.
if command_exists git; then
    echo "Git is already installed."
else
    if confirm_action "Install Git?"; then
        sudo apt install git -y || echo "Failed to install Git."
    else
        echo "Skipping Git installation."
    fi
fi

# --- Install GitHub CLI (gh) ---
print_header "Installing GitHub CLI (gh)"
if command_exists gh; then
    echo "GitHub CLI (gh) is already installed."
else
    if confirm_action "Install GitHub CLI (gh)?"; then
        echo "Adding GitHub CLI repository..."
        type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg && \
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
        sudo apt update -y && \
        sudo apt install gh -y || echo "Failed to install GitHub CLI (gh)."
    else
        echo "Skipping GitHub CLI (gh) installation."
    fi
fi

# --- Install Flameshot ---
print_header "Installing Flameshot"
# Flameshot is also usually in the default Ubuntu repositories.
if command_exists flameshot; then
    echo "Flameshot is already installed."
else
    if confirm_action "Install Flameshot?"; then
        sudo apt install flameshot -y || echo "Failed to install Flameshot."
    else
        echo "Skipping Flameshot installation."
    fi
fi

# --- Install Bitwarden ---
print_header "Installing Bitwarden"
# Bitwarden is available as a Snap package.
if command_exists bitwarden; then
    echo "Bitwarden is already installed."
else
    if confirm_action "Install Bitwarden via Snap?"; then
        sudo snap install bitwarden || echo "Failed to install Bitwarden."
    else
        echo "Skipping Bitwarden installation."
    fi
fi

# --- Install VirtualBox (Apt method for Noble - most reliable) ---
print_header "Installing VirtualBox"
if command_exists virtualbox; then
    echo "VirtualBox is already installed."
else
    if confirm_action "Install VirtualBox?"; then
        echo "Adding VirtualBox repository for Ubuntu 24.04 (Noble Numbat)..."
        
        # Install prerequisite packages
        sudo apt install -y curl wget gnupg2 lsb-release || { echo "Failed to install VirtualBox prerequisites."; exit 1; }

        # Import Oracle public keys
        wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo gpg --dearmor --output /usr/share/keyrings/oracle-virtualbox-2016.gpg || { echo "Failed to import VirtualBox 2016 GPG key."; exit 1; }
        wget -O- https://www.virtualbox.org/download/oracle_vbox.asc | sudo gpg --dearmor --output /usr/share/keyrings/oracle-virtualbox.gpg || { echo "Failed to import VirtualBox GPG key."; exit 1; }

        # Add VirtualBox repository for Noble
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] http://download.virtualbox.org/virtualbox/debian noble contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list > /dev/null && \
        
        sudo apt update -y && \
        
        # Attempt to install VirtualBox with its dependencies
        sudo apt install -y virtualbox-7.0 || {
            echo "Failed to install virtualbox-7.0. This might be a dependency issue."
            echo "Attempting to install a common missing dependency (libvpx8) from the main noble repository."
            # A common dependency problem is libvpx7, but the noble repo provides libvpx8 which is a good substitute.
            sudo apt install -y libvpx8 || echo "Failed to install libvpx8. Manual intervention required."
            
            # Now try installing VirtualBox again
            sudo apt install -y virtualbox-7.0 || echo "Failed to install VirtualBox even after fixing dependencies. Please check the log for details."
        }

        # Check if VirtualBox was installed before trying to add user
        if command_exists virtualbox; then
            # Add current user to vboxusers group
            echo "Adding your user to the 'vboxusers' group. You may need to log out and back in for changes to take effect."
            sudo usermod -aG vboxusers "$USER" || echo "Failed to add user to vboxusers group."
            
            # Ensure kernel modules are configured
            sudo /sbin/vboxconfig || echo "Failed to configure VirtualBox kernel modules. Manual intervention might be required."
        else
            echo "VirtualBox installation failed, skipping post-installation steps."
        fi
    else
        echo "Skipping VirtualBox installation."
    fi
fi

# --- Install Net-tools ---
print_header "Installing Net-tools"
if command_exists ifconfig; then # Check for a common net-tools command
    echo "Net-tools is already installed."
else
    if confirm_action "Install Net-tools?"; then
        sudo apt install net-tools -y || echo "Failed to install Net-tools."
    else
        echo "Skipping Net-tools installation."
    fi
fi

echo ""
echo "Installation script finished."
