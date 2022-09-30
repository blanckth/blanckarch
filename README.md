# BlanckArch Linux Automatic Installation Script
#### Video Demo:  <URL HERE>
### Description:
  > ### Author : `Salar Muhammadi`

```BASH
git clone https://github.com/blanckth/blanckarch.git && cd blanckarch && chmod 777 ./blanckarch.sh
```
#### Config and Save

```BASH
nano ./blanckarch.sh
```
#### Execute
```BASH
./blanckarch.sh
```

#### This project is a functional script to automate the installation process of arch linux OS

##### I am a fan of arch linux and always have fun with installation process and configuration But in most case it is anoying to write all the commands every time i want to install it for virtualization So i decide to code some Bash script to Automate all the process and execute the installation by some configuration and just One Enter!
##### It can handles some multi situation modes like UEFI/BIOS dynamically by the way it is the script Version 1.0 and i don't update it to keep it simple for this course.
##### For more details , it begin with some variables to set some static configurations like username and password , hostname and etc. after that it will check the system bootloader mode to choose EFI/BIOS Configuration, so there will be some variables again for setting the Partitioning Disks. Thats all the configuration it needed and after that it do all the process automatically, ofcourse it needs some advanced skills to config other Optional configurations but for now it is enough for simple installtion.
##### It set some date times and begins to sync some keyrings, after that the script will Create new partiotion tables then it will Format and Mount them on the right drive.
##### So now the process of installation of the base in new system will begin, after the system installed sucsessfully it will write the Filesystem and mount EFI if needed on the current mode. Now our new system is ready to chroot and start the command and configuration from within, in this case we must chroot into new system root and do other script but we need automation yeah!
##### So we baked second script with existing config info and write the new one; Now we can move the shell into chroot and execute that script fro within the new system root terminal.
##### The Auto Script will Config all most needed Essential Settings and then install most needed packages by OS to work for normal user, it also have some Optional package that we can uncomment and have them alongside the way and also they are all usefull.
##### after the downloading and install and upgrade the setup packages the script will config remaining configurations and setups. thats it! New Operation system is ready to use and script will reboot the machine . Enjoy!
