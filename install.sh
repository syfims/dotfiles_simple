#!/bin/bash

# Dark Setup Script
# Actions:
# 1. Configure Passwordless Sudo
# 2. Optimize Network (Cloudflare DNS, Disable Wi-Fi Power Save)
# 3. Install System Packages & Hyprland
# 4. Set Fish as Default Shell
# 5. Link Dotfiles

# Colors
PURPLE='\e[38;2;138;43;226m'
DARK='\e[38;2;105;105;105m'
RESET='\e[0m'

echo -e "${PURPLE}=== D A R K  S E T U P ===${RESET}"


REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_CONFIG_DIR="$REPO_DIR/.config"
TARGET_CONFIG_DIR="$HOME/.config"

# Dependencies
PACKAGES="aria2 blueman ffmpeg fish kitty mpv neovim pavucontrol playerctl python3 thunar unzip waybar wf-recorder wl-clipboard wofi yt-dlp zen-browser zip"
HYPR_PACKAGES="hyprland hyprpaper hyprsunset"
FONTS="noto-fonts-emoji ttf-fira-code ttf-nerd-fonts-symbols"

echo -e "${PURPLE}Starting setup...${RESET}"

# Check pacman
if ! command -v pacman &> /dev/null; then
    echo -e "${DARK}Error: pacman not found. This script requires an Arch Linux-based system.${RESET}"
    exit 1
fi

# Sudo
echo -e "${PURPLE}Configuring passwordless sudo for user '$USER' நான${RESET}"
echo -e "${DARK}You may be asked for your password one last time to apply this change.${RESET}"
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee "/etc/sudoers.d/00-$USER-nopasswd" > /dev/null
sudo chmod 440 "/etc/sudoers.d/00-$USER-nopasswd"
echo -e "${DARK}Passwordless sudo configured.${RESET}"

# Network
echo -e "${PURPLE}Optimizing Network...${RESET}"

echo -e "${DARK}Setting DNS to Cloudflare (1.1.1.1)...${RESET}"
sudo chattr -i /etc/resolv.conf 2>/dev/null
echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf > /dev/null
echo "nameserver 1.0.0.1" | sudo tee -a /etc/resolv.conf > /dev/null
sudo chattr +i /etc/resolv.conf
echo -e "${DARK}DNS locked to 1.1.1.1 / 1.0.0.1${RESET}"

echo -e "${DARK}Disabling Wi-Fi Power Save to improve speed/latency...${RESET}"
if [ -d "/etc/NetworkManager/conf.d" ]; then
    printf "[connection]\nwifi.powersave = 2\n" | sudo tee /etc/NetworkManager/conf.d/default-wifi-powersave-on.conf > /dev/null
    echo -e "${DARK}Wi-Fi power save disabled via NetworkManager.${RESET}"
else
    echo -e "${DARK}NetworkManager config directory not found. Skipping Wi-Fi optimization.${RESET}"
fi


# Install
echo -e "${PURPLE}Installing dependencies...${RESET}"
sudo pacman -Sy --needed --noconfirm $PACKAGES $HYPR_PACKAGES $FONTS

# Shell
echo -e "${PURPLE}Changing default shell to fish...${RESET}"
if command -v fish &> /dev/null; then
    # Verifica se o shell já é o fish antes de tentar mudar
    if [ "$SHELL" != "$(which fish)" ]; then
        sudo chsh -s "$(which fish)" "$USER"
        echo -e "${DARK}Default shell changed to fish.${RESET}"
    else
        echo -e "${DARK}Shell is already fish.${RESET}"
    fi
else
    echo -e "${DARK}Fish not found. Skipping shell change.${RESET}"
fi

# Config
echo -e "${PURPLE}Linking configurations to $TARGET_CONFIG_DIR...${RESET}"
mkdir -p "$TARGET_CONFIG_DIR"

if [ -d "$REPO_CONFIG_DIR" ]; then
    for item in "$REPO_CONFIG_DIR"/*;
    do
        item_name=$(basename "$item")
        TARGET="$TARGET_CONFIG_DIR/$item_name"

        # Remove symlink quebrado ou existente
        if [ -L "$TARGET" ]; then
            rm "$TARGET"
        fi
        
        cp -r "$item" "$TARGET"
        echo -e "${DARK}Copied $item_name${RESET}"
    done
else
    echo -e "${DARK}Config directory $REPO_CONFIG_DIR not found.${RESET}"
fi

# User Directories
echo -e "${PURPLE}Creating user directories...${RESET}"
mkdir -p "$HOME/0/"{documents,videos,music,downloads,pictures}
echo -e "${DARK}User directories created under $HOME/0/.${RESET}"

# VS Code Workspace Generation
echo -e "${PURPLE}Generating VS Code workspace...${RESET}"
python3 -c "
import os
import json

home = os.path.expanduser('~')
repo_config = '$REPO_CONFIG_DIR'
target_config = '$TARGET_CONFIG_DIR'
workspace_file = os.path.join(home, '0', 'documents', '.config.code-workspace')

folders = []
if os.path.exists(repo_config):
    # Get all subdirectories in the repo's config folder
    config_items = [d for d in os.listdir(repo_config) if os.path.isdir(os.path.join(repo_config, d))]
    # Sort for consistency
    config_items.sort()
    
    for item in config_items:
        # Map them to their destination in ~/.config
        full_path = os.path.join(target_config, item)
        folders.append({'path': full_path})

data = {
    'folders': folders,
    'settings': {}
}

try:
    with open(workspace_file, 'w') as f:
        json.dump(data, f, indent=4)
    print(f'Workspace file created at: {workspace_file}')
except Exception as e:
    print(f'Error creating workspace file: {e}')
"


# Python Global Venv
echo -e "${PURPLE}Setting up Global Python Venv...${RESET}"
VENV_DIR="$HOME/0/.venv"
python -m venv "$VENV_DIR"
"$VENV_DIR/bin/pip" install --upgrade pip
"$VENV_DIR/bin/pip" install yt-dlp python-telegram-bot telethon pyrogram pylast PyYAML requests beautifulsoup4
echo -e "${DARK}Python global venv created at $VENV_DIR with required packages.${RESET}"

# Fish Venv Helper
echo -e "${PURPLE}Setting up 'venventer' command for fish shell...${RESET}"
FISH_FUNCTIONS_DIR="$HOME/.config/fish/functions"
mkdir -p "$FISH_FUNCTIONS_DIR"
cat << EOF > "$FISH_FUNCTIONS_DIR/venventer.fish"
function venventer
    if test -f "$HOME/0/.venv/bin/activate.fish"
        source "$HOME/0/.venv/bin/activate.fish"
    else if test -f "$HOME/0/.venv/bin/activate"
        source "$HOME/0/.venv/bin/activate"
    else
        echo "Error: Python venv activation script not found in $HOME/0/.venv"
    end
end
EOF
echo -e "${DARK}'venventer' command created. Restart fish shell to use.${RESET}"

# Services
echo -e "${PURPLE}Enabling Services...${RESET}"
sudo systemctl enable --now bluetooth
echo -e "${DARK}Bluetooth service enabled and started.${RESET}"

# AUR Helper (yay)
echo -e "${PURPLE}Installing yay (AUR Helper)...${RESET}"
if ! command -v yay &> /dev/null; then
    cd "$HOME"
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd "$HOME"
    rm -rf yay
    echo -e "${DARK}yay installed successfully.${RESET}"
else
    echo -e "${DARK}yay is already installed.${RESET}"
fi

# AUR Packages
echo -e "${PURPLE}Installing AUR packages...${RESET}"
yay -S --noconfirm antigravity spotify gallery-dl
echo -e "${DARK}AUR packages installed.${RESET}"

# Cleanup
echo -e "${PURPLE}Performing system cleanup...${RESET}"
echo -e "${DARK}Clearing pacman cache...${RESET}"
sudo pacman -Scc --noconfirm
echo -e "${DARK}Removing unused dependencies...${RESET}"
sudo pacman -Rns $(pacman -Qtdq) --noconfirm 2>/dev/null || true # Suppress errors if no unused deps
echo -e "${DARK}Trimming journal logs (older than 1 week)...${RESET}"
sudo journalctl --vacuum-time=1w
echo -e "${DARK}Cleanup complete.${RESET}"

echo -e "${PURPLE}Setup complete! Please restart your session or reload your window manager.${RESET}"
