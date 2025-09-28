#!/bin/bash

# Script to automate installing Hyprland on Ubuntu 24.04 LTS Server
# Run as user with sudo privileges: chmod +x install_hyprland.sh && ./install_hyprland.sh
# Logs to ~/hyprland_install.log

LOGFILE="$HOME/hyprland_install.log"
echo "Hyprland Installation Script - Started at $(date)" | tee -a "$LOGFILE"

# Function to log and exit on error
check_error() {
    if [ $? -ne 0 ]; then
        echo "Error: $1" | tee -a "$LOGFILE"
        exit 1
    fi
}

# Post-Installation Setup
echo "Step 5: Updating system and installing firmware..." | tee -a "$LOGFILE"
sudo apt update 2>&1 | tee -a "$LOGFILE"
check_error "Failed to update package lists"
sudo apt upgrade -y 2>&1 | tee -a "$LOGFILE"
check_error "Failed to upgrade system"

# Install firmware for WiFi, graphics, etc.
sudo apt install -y linux-firmware 2>&1 | tee -a "$LOGFILE"
check_error "Failed to install linux-firmware"

# Install newer kernel for trackpad/suspend fixes
sudo apt install -y linux-generic-hwe-24.04 2>&1 | tee -a "$LOGFILE"
check_error "Failed to install HWE kernel"

# Install Hyprland Dependencies
echo "Step 6: Installing Hyprland dependencies..." | tee -a "$LOGFILE"
sudo apt install -y meson wget build-essential ninja-build cmake \
libcairo2-dev libcairo-dev libegl1-mesa-dev libgbm-dev libgles2-mesa-dev \
libglib2.0-dev libinput-dev libjpeg-dev libliftoff-dev libnm-dev \
libpango1.0-dev libpangocairo-1.0-0 libpixman-1-dev libseat-dev \
libsystemd-dev libudev-dev libvkfft-dev libvulkan-dev libwayland-dev \
libxcb1-dev libxcb-composite0-dev libxcb-cursor-dev libxcb-dri3-dev \
libxcb-errors-dev libxcb-ewmh-dev libxcb-icccm4-dev libxcb-present-dev \
libxcb-randr0-dev libxcb-render-util0-dev libxcb-res0-dev libxcb-xfixes0-dev \
libxcb-xinput-dev libxcb-xrm-dev libxkbcommon-dev libxkbcommon-x11-dev \
libxkbregistry-dev seatd vulkan-sdk wayland-protocols libdrm-dev \
libxdamage-dev libxext-dev libxfixes-dev libxxf86vm-dev libxrandr-dev \
libx11-dev libxtst-dev libxi-dev xwayland 2>&1 | tee -a "$LOGFILE"
check_error "Failed to install dependencies"

# Install SDDM for display manager
echo "Installing SDDM..." | tee -a "$LOGFILE"
sudo apt install -y sddm 2>&1 | tee -a "$LOGFILE"
check_error "Failed to install SDDM"

# Build and Install Hyprland
echo "Step 7: Building and installing Hyprland..." | tee -a "$LOGFILE"
mkdir -p ~/HyprSource && cd ~/HyprSource
check_error "Failed to create HyprSource directory"

# Clone Hyprland
git clone --recursive https://github.com/hyprwm/Hyprland.git 2>&1 | tee -a "$LOGFILE"
check_error "Failed to clone Hyprland"
cd Hyprland

# Build and install Hyprland
sudo make install 2>&1 | tee -a "$LOGFILE"
check_error "Failed to build and install Hyprland"

# Build and install xdg-desktop-portal-hyprland
cd ~/HyprSource
git clone https://github.com/hyprwm/xdg-desktop-portal-hyprland.git 2>&1 | tee -a "$LOGFILE"
check_error "Failed to clone xdg-desktop-portal-hyprland"
cd xdg-desktop-portal-hyprland
meson setup build 2>&1 | tee -a "$LOGFILE"
check_error "Failed to setup meson for xdg-desktop-portal-hyprland"
ninja -C build 2>&1 | tee -a "$LOGFILE"
check_error "Failed to build xdg-desktop-portal-hyprland"
sudo ninja -C build install 2>&1 | tee -a "$LOGFILE"
check_error "Failed to install xdg-desktop-portal-hyprland"

# Configure Hyprland
echo "Configuring Hyprland..." | tee -a "$LOGFILE"
mkdir -p ~/.config/hypr
cp /usr/share/hyprland/hyprland.conf ~/.config/hypr/hyprland.conf 2>&1 | tee -a "$LOGFILE"
check_error "Failed to copy Hyprland config"

# Add cursor size fix to config
echo "env = XCURSOR_SIZE,24" >> ~/.config/hypr/hyprland.conf 2>&1 | tee -a "$LOGFILE"
check_error "Failed to modify Hyprland config"

# Ensure Wayland environment variables
echo "Adding Wayland environment variables..." | tee -a "$LOGFILE"
sudo bash -c 'echo "QT_QPA_PLATFORM=wayland" >> /etc/environment' 2>&1 | tee -a "$LOGFILE"
check_error "Failed to set environment variables"

echo "Installation complete! Reboot with 'sudo reboot' and select Hyprland in SDDM." | tee -a "$LOGFILE"
echo "Check ~/hyprland_install.log for details if issues arise." | tee -a "$LOGFILE"
