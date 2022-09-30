#!/usr/bin/env bash
#################################################

# Author : Salar Muhammadi
# DevSecOps
# Blanck Arch Auto Installation
# CS50x Harvard University

#################################################

# Initial Configuraion

declare -r -l myHostName='blanckarch'; # Hostname @Required
declare -r -l myLocalDomain='lo'; # Top-Domain @Optional
declare -r PassWord='pa$$w0rD'; # Root Password @Required
declare -r userName='blanck'; # Sudoer User name @Required
declare -r userPass='password'; # User Password @Required

#################################################

# Auto Check for UEFI or BIOS bootloader

declare -i bootMode;
if ls /sys/firmware/efi/efivars > /dev/null 2>&1; then bootMode=1; else bootMode=0; fi; # BIOS By Default # UEFI if Found

#################################################
# Choose Disk Address

#################################################
# Config Partition Disk

declare -r diskMapAddr='/dev/sda'; # Partition Addr @Required
declare -r swapSize='+8G'; # Swap size @Default
declare -r bootSize='+1G'; # Boot Partition @Default
declare -r rootSize=' '; # Default to Reminder Size @Default

#################################################
# Start Installation Process

# Global commands

loadkeys us; # Set Keyboard Keys

# Set and Sync TimeDate
timedatectl set-ntp true;
timedatectl status;

#################################################

# Upgrade Keyring
pacman -Sy archlinux-keyring --noconfirm;

#################################################

# Partition Disk
# BIOS
[[ $bootMode == 0 ]] && ( (
    echo o # Create a new empty DOS partition table
    echo n # New Partition
    echo p # Primary partition
    echo 1 # Partition number
    echo   # Default First Sector
    echo "$swapSize" # Swap Partiton Size
    echo   #
    echo t # Change Partition Type
    echo swap #Swap Type
    echo   #
    echo n # New Partition
    echo p # Primary Partition
    echo 2 # Second Partition
    echo   # Default First Sector
    echo "$rootSize" # Root Partitio Size
    echo   #
    echo t # Change Partition Type
    echo 2 # Second Partition
    echo linux # Linux Root Type
    echo   #
    echo p # Print Partition Table
    echo w # Write Partition Table
    ) | fdisk "$diskMapAddr" );
# UEFI @
[[ $bootMode == 1 ]] && ( (
    echo   #
    echo g # Create a new empty GPT partition table
    echo n # New Partition
    echo 1 # Default Partition Number ( 1 )
    echo   # Default First Sector
    echo "$swapSize" # Swap Partition Size
    echo   #
    echo t # Change Partition Type
    echo swap # Swap Type
    echo   #
    echo n # New Partition
    echo 2 # Default Partition Number ( 2 )
    echo   # Default First Sector
    echo "$bootSize" #
    echo   #
    echo t # Change Partition Type
    echo 2 # Default Partition Number ( 2 )
    echo uefi # UEFI Type
    echo   #
    echo n # New Partition
    echo 3 # Default Partition Number ( 3 )
    echo   # Default First Sector
    echo "$rootSize" # ROOT Partition Size
    echo   #
    echo t # Change Partition Type
    echo 3 # Default Partition Number ( 3 )
    echo linux # Linux Root Type
    echo   #
    echo p # Print Partition Table
    echo w # Write Partition Table
) | fdisk "$diskMapAddr" );

#################################################

# Format Partition Drives

mkswap ${diskMapAddr}1
[[ $bootMode == 1 ]] && mkfs.fat -F32 ${diskMapAddr}2;
[[ $bootMode == 1 ]] && mkfs.ext4 ${diskMapAddr}3;
[[ $bootMode == 0 ]] && mkfs.ext4 ${diskMapAddr}2;

#################################################

# Mount Drives
swapon ${diskMapAddr}1;
[[ $bootMode == 0 ]] && mount ${diskMapAddr}2 /mnt;
[[ $bootMode == 1 ]] && mount ${diskMapAddr}3 /mnt;

#################################################

# Install Base Root
pacstrap /mnt base linux linux-firmware nano;

#################################################

# Bind FileSystem
genfstab -U /mnt >> /mnt/etc/fstab;

#################################################

# Mount EFI Drive
[[ $bootMode == 1 ]] && mkdir /mnt/efi;
[[ $bootMode == 1 ]] && mount ${diskMapAddr}2 /mnt/efi;

#################################################
# Generate Arch Configrator
(
    echo '#!/usr/bin/env bash';
    echo '# Auther : Blanckth';
    echo '# New Arch Configurator';
    echo '# Set TimeDate Options';
    echo 'timedatectl set-timezone Asia/Tehran;';
    echo 'timedatectl set-ntp true;';
    echo 'timedatectl status;';
    echo 'hwclock --systohc;';
    echo '# Set Locale Options';
    echo 'localectl set-locale LANG=en_US.UTF-8;';
    echo '#Comment OUT';
    echo 'sed -e "/en_US.UTF-8/s/^#*/#/g" -i /etc/locale.gen;';
    echo '# UnComment';
    echo 'sed -e "/en_US.UTF-8/s/^#*//" -i /etc/locale.gen;';
    echo '# Commit Changes';
    echo 'locale-gen;';
    echo '# Set Keymap';
    echo 'echo "KEYMAP=us" > /etc/vconsole.conf;';
    echo '# Set Hostname';
    echo "echo '$myHostName' > /etc/hostname;";
    echo '# Set DNS Config';
    echo 'echo -e "127.0.0.1\tlocalhost" > /etc/hosts;';
    echo 'echo -e "::1\t\tlocalhost" >> /etc/hosts;';
    echo -n 'echo -e "127.0.1.1\t'; echo -n "$myHostName.$myLocalDomain"; echo -n '\t'; echo -n "$myHostName"; echo '" >> /etc/hosts;';
    echo '#################################################';
    echo '# Install Essentials And Usefull Packages ( Comment-out the Optional Packages If you mind )';
    echo 'pacman -Sy archlinux-keyring --noconfirm; # Require';
    echo 'pacman -Sy xorg --noconfirm --needed; # Require';
    echo 'pacman -S intel-ucode --noconfirm --needed; # Require OR';
    echo '# pacman -S amd-ucode --noconfirm --needed; # OR Require';
    echo 'pacman -S networkmanager network-manager-applet nm-connection-editor --noconfirm --needed; # Require';
    echo '# pacman -S networkmanager-openconnect networkmanager-openvpn networkmanager-pptp networkmanager-vpnc networkmanager-l2tp --noconfirm --needed; # Optional';
    echo 'pacman -S gnome gdm gpm --noconfirm --needed; # Required';
    echo '# pacman -S gnome-extra --noconfirm --needed; # Optional';
    echo '# pacman -S xfce4 xfce4-goodies --noconfirm --needed; # Optional';
    echo 'pacman -S grub --noconfirm --needed; # Required';
    [[ $bootMode == 1 ]] && echo 'pacman -S efibootmgr --needed --noconfirm; # Required';
    echo 'pacman -S sudo --noconfirm --needed; # Required';
    echo 'pacman -S alsa-utils pulseaudio pulseaudio-alsa pavucontrol --noconfirm --needed; # Required';
    echo 'pacman -S reflector sof-firmware --noconfirm --needed; # Required';
    echo 'pacman -S usbmuxd usbutils --noconfirm --needed; # Required';
    echo 'pacman -S wireless-regdb wireless_tools wpa_supplicant --noconfirm --needed; # Required';
    echo 'pacman -S dnsmasq mtools bind-tools texinfo iproute2 dhcpcd dhclient man-db man-pages --noconfirm --needed; # Required';
    echo '# pacman -S dialog bc python nmap net-tools ntfs-3g screen --noconfirm --needed; # Optional';
    echo '# pacman -S tcpdump testdisk tmux --noconfirm --needed; # Optional';
    echo '# pacman -S vlc uget remmina putty gufw ufw libreoffice wireshark-qt vscode firefox arduino audacious rkhunter xf86-input-synaptics --needed; # Optional';
    echo '#################################################';
    [[ $bootMode == 0 ]] && echo '# Configue Grub Bootloader BIOS mode';
    [[ $bootMode == 0 ]] && echo "grub-install ${diskMapAddr};";
    [[ $bootMode == 1 ]] && echo '# Configue Grub Bootloader UEFI mode';
    [[ $bootMode == 1 ]] && echo 'grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/efi;';
    echo '# Grub Global Configs';
    echo 'grub-mkconfig -o /boot/grub/grub.cfg;';
    echo '#################################################';
    echo '# Enables Services';
    echo 'systemctl enable gdm;';
    echo 'systemctl enable NetworkManager;';
    echo '#################################################';
    echo '# Set Root password';
    echo '( ';
    echo "    echo '$PassWord' ";
    echo "    echo '$PassWord' ";
    echo ') | passwd';
    echo '#################################################';
    echo '# Create new Sudoer USER';
    echo '# Uncomment wheel as Sudoer';
    echo "sed -e '/%wheel ALL=(ALL:ALL) ALL/s/^#*//' -i /etc/sudoers;";
    echo '# ADD New USER';
    echo "useradd -m -G wheel -s /bin/bash '$userName'"
    echo '# Set User password';
    echo '( ';
    echo "    echo '$userPass' ";
    echo "    echo '$userPass' ";
    echo ') | passwd blanck';
    echo '#################################################';
    echo '# EXIT';
    echo 'exit';
    echo '#################################################';
) > ArchConf.sh;

#################################################

# Move Arch Configurator
chmod 777 ArchConf.sh;
mv ArchConf.sh /mnt;

#################################################

# Change to new root And Run Baked Script
arch-chroot /mnt ./ArchConf.sh;

#################################################

# Reboot
reboot -f