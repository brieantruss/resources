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

# --- Install Python 3.12 ---
print_header "Installing Python 3.12"
if command_exists python3.12; then
    echo "Python 3.12 is already installed."
else
    if confirm_action "Install Python 3.12?"; then
        sudo apt install python3.12 -y || echo "Failed to install Python 3.12."
    else
        echo "Skipping Python 3.12 installation."
    fi
fi

# --- Install Python VENV ---
# Add VENV package for Python 3.12 environments
print_header "Installing Python 3.12 VENV"
if dpkg -l | grep -q python3.12-venv; then
    echo "Python 3.12 VENV is already installed."
else
    if confirm_action "Install Python 3.12 VENV?"; then
        sudo apt install python3.12-venv -y || echo "Failed to install Python 3.12 VENV."
    else
        echo "Skipping Python 3.12 VENV installation."
    fi
fi

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

# --- Git Global Configuration ---
print_header "Git Global Configuration"
if command_exists git; then
    if confirm_action "Set global Git user email (btruss@moduloinsights.com) and name (Briean Truss)?"; then
        echo "Setting global user.email..."
        git config --global user.email "btruss@moduloinsights.com" || echo "Failed to set user.email."
        echo "Setting global user.name..."
        git config --global user.name "Briean Truss" || echo "Failed to set user.name."
    else
        echo "Skipping Git global configuration."
    fi
else
    echo "Git is not installed, skipping global configuration."
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

# ---------------------------------------------------------------------
# --- Configure SSH, GitHub CLI, and Clone Reference Repo ---
# ---------------------------------------------------------------------
print_header "Configuring SSH, GitHub CLI, and Cloning Reference Repo"

# 1. Install and Enable OpenSSH Server
if ! command_exists sshd; then
    if confirm_action "Install and enable OpenSSH Server?"; then
        echo "Installing openssh-server..."
        sudo apt install openssh-server -y || echo "Failed to install openssh-server."
        echo "Enabling and starting SSH service..."
        sudo systemctl enable --now ssh || echo "Failed to enable/start ssh service."
    else
        echo "Skipping OpenSSH Server installation."
    fi
fi

# 2. Configure GitHub CLI (gh) for SSH
# NOTE: gh command existence is checked in the previous section.
if command_exists gh; then
    if confirm_action "Configure GitHub CLI (gh) to use SSH protocol?"; then
        echo "Starting gh auth login process. Please follow the prompts (select SSH as protocol)."
        gh auth login # Requires user interaction
        
        # Set Git protocol to SSH for GitHub
        if [ $? -eq 0 ]; then
            echo "Setting git_protocol to ssh for github.com."
            gh config set -h github.com git_protocol ssh || echo "Failed to set gh git_protocol."
        else
            echo "GitHub CLI login failed or was cancelled, skipping protocol configuration."
        fi
    else
        echo "Skipping GitHub CLI SSH configuration."
    fi
else
    echo "GitHub CLI (gh) is not installed, skipping configuration."
fi

# 3. Clone Reference Documentation
REFERENCE_REPO="https://github.com/btruss13/reference"
REFERENCE_DIR="$HOME/reference"

if [ -d "$REFERENCE_DIR" ]; then
    echo "Reference repository already exists at $REFERENCE_DIR."
else
    if confirm_action "Clone reference repository ($REFERENCE_REPO) to $REFERENCE_DIR?"; then
        # Ensure we are in the home directory before cloning
        (cd "$HOME" && git clone "$REFERENCE_REPO" || echo "Failed to clone reference repository.")
    else
        echo "Skipping reference repository clone."
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

# --- Install Slack ---
print_header "Installing Slack"
# Slack is available as a Snap package.
if command_exists slack; then
    echo "Slack is already installed."
else
    if confirm_action "Install Slack via Snap?"; then
        # The official Slack app requires the '--classic' confinement
        sudo snap install slack --classic || echo "Failed to install Slack."
    else
        echo "Skipping Slack installation."
    fi
fi

# ---------------------------------------------------------------------
# --- Install QEMU/KVM with Virt-Manager (Replacing VirtualBox) ---
# ---------------------------------------------------------------------
print_header "Installing QEMU/KVM and Virt-Manager"
if command_exists virt-manager; then
    echo "Virt-Manager and QEMU/KVM appear to be installed."
else
    if confirm_action "Install QEMU/KVM and Virt-Manager (recommended virtualization stack)?"; then
        echo "Installing qemu-kvm, libvirt-daemon-system, and virt-manager..."
        
        # Install the main packages
        sudo apt install -y qemu-kvm libvirt-daemon-system virt-manager bridge-utils || { 
            echo "Failed to install core KVM packages. Exiting KVM installation section."
            exit 1
        }

        # Check for KVM installation success before proceeding
        if command_exists virt-manager; then
            echo "KVM packages installed successfully."

            # Start and enable the libvirt service
            echo "Enabling and starting libvirt service..."
            sudo systemctl enable --now libvirtd || echo "Failed to enable and start libvirtd service."

            # Add current user to the 'libvirt' group
            echo "Adding your user to the 'libvirt' group for non-root management. ⚠️ You MUST **log out and log back in** for this change to take effect."
            sudo usermod -aG libvirt "$USER" || echo "Failed to add user to libvirt group."
            
            # Verify KVM support (optional but helpful)
            if grep -E 'vmx|svm' /proc/cpuinfo &> /dev/null; then
                echo "KVM hardware virtualization support (VMX/SVM) is available on your CPU."
            else
                echo "⚠️ KVM hardware virtualization support (VMX/SVM) may be disabled or unavailable. Check your BIOS settings."
            fi

            # Check if user is in the group (will only work immediately after 'usermod -aG' if current shell is in the group list)
            if groups "$USER" | grep -q libvirt; then
                echo "User '$USER' is now a member of the 'libvirt' group (requires re-login)."
            fi

        else
            echo "Virt-Manager installation failed, skipping post-installation steps."
        fi
    else
        echo "Skipping QEMU/KVM and Virt-Manager installation."
    fi
fi

# --- LibreOffice Management ---
print_header "LibreOffice Management"

# 1. Remove pre-installed (older) LibreOffice packages
if confirm_action "Remove pre-installed LibreOffice packages to install the latest version?"; then
    echo "Removing default LibreOffice packages..."
    sudo apt remove --purge libreoffice* -y || echo "Failed to purge existing LibreOffice packages."
else
    echo "Skipping removal of default LibreOffice packages."
fi

# 2. Add PPA and install the latest LibreOffice
if confirm_action "Add LibreOffice PPA and install the latest stable version?"; then
    echo "Adding LibreOffice PPA..."
    sudo add-apt-repository ppa:libreoffice/ppa -y || echo "Failed to add LibreOffice PPA."
    
    echo "Updating package list and installing latest LibreOffice..."
    sudo apt update -y && sudo apt install libreoffice -y || echo "Failed to install the latest LibreOffice."
else
    echo "Skipping installation of the latest LibreOffice."
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
echo "----------------------------------------------------------------------"
echo "⚠️ IMPORTANT POST-INSTALLATION STEPS:"
echo "* If you installed **QEMU/KVM**, you **MUST log out and log back in**"
echo "  for the user group changes (libvirt) to take effect."
echo "* If you configured **GitHub CLI (gh)**, you will need to complete the"
echo "  authentication process (Web browser/SSH) when prompted during the run."
echo "* Your Git global user configuration is set: **Briean Truss <btruss@moduloinsights.com>**"
echo "----------------------------------------------------------------------"