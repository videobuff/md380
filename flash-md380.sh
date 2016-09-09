#!/bin/bash
##################################################################################
##################################################################################
###### SCRIPT TO FLASH A TYTERA MD380 WITH THE EXPERIMENTAL SOFTWARE        ######
###### 				FROM  TRAVISGODSPEED - KK4VCZ							######
###### 	LOCATED AT https://github.com/travisgoodspeed/md380tools.git		######
###### 					   REVISION 29-08-2016   - Written by PA0ESH     	######
###### 	   You may copy, modify or change this script as you like		    ######
##################################################################################
##################################################################################
#
#
# Requires: whiptail
# 29th August 2016 - PA0ESH
# Color Codes
Reset='\e[0m'
Red='\e[31m'
Green='\e[30;42m' # Black/Green
Yellow='\e[33m'
YelRed='\e[31;43m' #Red/Yellow
Blue='\e[34m'
White='\e[37m'
BluW='\e[37;44m'


function check_jessie {
rm -rf tmp.file >/dev/null
lsb_release -a >tmp.file

result=$(grep -c jessie tmp.file)

if [ $result >0 ] 
then
			whiptail --backtitle "MD380 DMR EXPERIMENTAL SOFTWARE ${pi_user}" --title "MD380 Basic installation - ver 1.10 dd: 06092016" --msgbox "This Raspberry runs Debian Jessie so you may continue" 8 60

else
			whiptail --backtitle "MD380 DMR EXPERIMENTAL SOFTWARE ${pi_user}" --title "MD380 Basic installation - ver 1.10 dd: 06092016" --msgbox "This Raspberry does NOT run Debian Jessie.\nUse a fresh formatted sd card with the latest Debian Jessie (www.raspberry.org).\n The programme will stop now." 8 60
			break
			exit
fi
}

pause(){
   read -p "Press any key to continue"
}


function do_flash_sw {
# routine to flash the software only
if [ ! -d /home/pi/md380tools ] ; then
	whiptail --backtitle "MD380 DMR EXPERIMENTAL SOFTWARE ${pi_user}" --title "MD380-tools Basic installation - ver 1.10 dd: 06092016" --msgbox " You have to install the tools first \n Choose the 2nd option from the main menu\n Hit OK to continue." 12 78
else
	whiptail --backtitle "MD380 DMR EXPERIMENTAL SOFTWARE ${pi_user}" --title "MD380-tools Basic installation - ver 1.10 dd: 06092016" --msgbox " Please switch on the MD380 in DFU mode. \n Press the PTT button and the button above together,\n and switch on the MD380.\n The red light should be flashing\n Then hit OK to continue." 12 78
	cd /home/pi/md380tools
	git pull
	##### turn on radio in DFU mode to begin firmware update with USB cable ######
	clear
	sudo make all flash
	
	whiptail --backtitle "MD380 DMR EXPERIMENTAL SOFTWARE ${pi_user}" --title "MD380-tools Basic installation - ver 1.10 dd: 06092016" --msgbox "The MD380 has been loaded with the new experimental software\nYour codeplug remains unchanged\nSwitch off the MD380 now to exit the DFU mode.\n Hit OK to continue." 8 78
fi
}

function do_flash_db {
# routine to flash the software only
if [ ! -d /home/pi/md380tools ] ; then
	whiptail --backtitle "MD380 DMR EXPERIMENTAL SOFTWARE ${pi_user}" --title "MD380-tools Basic installation - ver 1.10 dd: 06092016" --msgbox " You have to install the tools first \n Choose the 2nd option from the main menu\n Hit OK to continue." 8 78
else
	whiptail --backtitle "MD380 DMR EXPERIMENTAL SOFTWARE ${pi_user}" --title "MD380-tools Basic installation - ver 1.10 dd: 06092016" --msgbox " Please switch on the MD380 in normal mode. \n The red light should NOT be flashing\nThen hit OK to continue." 8 78
	cd /home/pi/md380tools
	
	clear
	git pull
	sudo make clean
	##### turn on radio in DFU mode to begin firmware update with USB cable ######
	sudo make flashdb
	whiptail --backtitle "MD380 DMR EXPERIMENTAL SOFTWARE ${pi_user}" --title "MD380-tools Basic installation - ver 1.10 dd: 06092016" --msgbox "The MD380 has been loaded with the complete DMR user database\nYour own codeplug remains unchanged.\n Hit OK to continue." 8 78
fi
}

function do_flash_original {
# routine to flash the software only
if [ ! -d /home/pi/md380tools ] ; then
	whiptail --backtitle "MD380 DMR EXPERIMENTAL SOFTWARE ${pi_user}" --title "MD380-tools Basic installation - ver 1.10 dd: 06092016" --msgbox " You have to install the tools first \n Choose the 2nd option from the main menu\n Hit OK to continue." 8 78
else
	whiptail --backtitle "MD380 DMR EXPERIMENTAL SOFTWARE ${pi_user}" --title "MD380-tools Basic installation - ver 1.10 dd: 06092016" --msgbox " Please switch on the MD380 in DFU mode. \n Press the PTT button and the button above together,\n and switch on the MD380.\n The red light should be flashing\n Then hit OK to continue." 12 78
	cd /home/pi/md380tools
	clear
	git pull
	sudo make clean
	##### turn on radio in DFU mode to begin firmware update with USB cable ######
	make flash_d02.032
	whiptail --backtitle "MD380 DMR EXPERIMENTAL SOFTWARE ${pi_user}" --title "MD380-tools Basic installation - ver 1.10 dd: 06092016" --msgbox "The MD380 has been loaded with the original firmware version d02.32\nYour own codeplug remains unchanged.\n Hit OK to continue." 8 78
fi
}


function raspiupdate {
clear
echo "running Raspberry update & upgrade"
echo -e "\t \e[030;42m Updating Debian Jessie package List... \t ${Reset}"
echo -e "\t${YelRed} This may take a while ${Reset}"
sudo apt-get update
echo -e "\t \e[030;42m Upgrading Debian Jessie package List... \t ${Reset}"
echo -e "\t${YelRed} This may take even longer ${Reset}"
# dpkg -P --force-all nfs-common > /dev/null
sudo apt-get -y dist-upgrade
clear
	whiptail --backtitle "MD380 DMR EXPERIMENTAL SOFTWARE ${pi_user}" --title "MD380-tools Basic installation - ver 1.10 dd: 06092016" --msgbox "The Raspberry will now reboot\n Hit OK to continue." 8 78
sudo reboot
return
}

function MD380-tools_install {
clear
echo "Installing the MD380 python toolkit"
echo -e "\t${YelRed} This may take a while ${Reset}"
cd /home/pi
if [ ! -d /home/pi/md380tools ] ; then
#echo "Directory does not exist"
			whiptail --backtitle "MD380 DMR EXPERIMENTAL SOFTWARE ${pi_user}" --title "MD380 Basic installation - ver 1.10 dd: 06092016" --msgbox " This may take some time, so relax.\n Hit OK to continue." 8 45
			git clone https://github.com/travisgoodspeed/md380tools			
			if [ ! -f /etc/udev/rules.d/99-md380.rules ]
			then
				cp /home/pi/md380tools/99-md380.rules  /etc/udev/rules.d
			fi
			cd /home/pi/md380tools
			make clean
			make all
else
#echo "Directory exists"
			whiptail --backtitle "MD380 DMR EXPERIMENTAL SOFTWARE ${pi_user}" --title "MD380 Basic installation - ver 1.10 dd: 06092016" --msgbox " This may take some time, so relax.\n Hit OK to continue." 8 45
			cd /home/pi/md380tools
			git pull
			if [ ! -f /etc/udev/rules.d/99-md380.rules ]
				then
				cp /home/pi/md380tools/99-md380.rules  /etc/udev/rules.d
			fi

			cd /home/pi/md380tools
			make clean
			make all
fi	
#echo -e "${Green} Installation or updating git repository md380tools completed ${Reset}"
return
}

do_root() {
whiptail --backtitle "MD380 DMR EXPERIMENTAL SOFTWARE ${pi_user}" --title "MD380 Basic installation - ver 1.10 dd: 06092016" --yesno " You are not logged in as root.\n This utility only works with the user root.\n Would you like to change to root now?\n\n If yes, the script will restart as root. !" 20 60 2
if [ $? -eq 0 ]; then # yes
	sync
	sudo /home/pi/flash-md380.sh
fi
exit 0
}


do_finish() {
whiptail --backtitle "MD380 DMR EXPERIMENTAL SOFTWARE ${pi_user}" --title "MD380 Basic installation - ver 1.10 dd: 06092016" --yesno "Would you like to reboot the Raspberry PI now?" 20 60 2
if [ $? -eq 0 ]; then # yes
	sync
	sudo reboot
fi
exit 0
}

pause(){
   read -p "Press any key to continue"
}

pi_user=$(whoami)
pi_user=" - CURRENT USER: ${pi_user}"

whiptail --backtitle "MD380 DMR EXPERIMENTAL SOFTWARE ${pi_user}" --title "MD380 Basic installation - ver 1.10 dd: 06092016" --yesno "This script installs Travis Goodspeed, KK4VCZ MD380 tools on a Raspberry \n\
Source code at https://github.com/travisgoodspeed/md380tools.git \n\
Use this tool at your own risk  \n  \nMake sure the MD380 is connected with the programming cable to the Raspberry, but NOT switched on!" --yes-button "Continue" --no-button "Abort" 12 80
exitstatus=$?
if [ $exitstatus = 0 ]; then
	sleep 0 
else
	echo -e "${YelRed} Installation aborted. ${Reset}"
    exit
fi

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
clear && do_root
     exit
fi


function update_raspberry {
clear
echo "Updating the packages list....."
sudo apt-get update
sudo -y apt-get upgrade
sudo -y apt-get dist-upgrade

}


function pre_package {
clear
echo "testing if pre-requisite packages are installed"

result=$(dpkg-query -W -f='${Status} \n'  git)
if [ "$result" != "install ok installed " ]
then
	clear
	echo "installing git software required to obtain the source code."
    sudo apt-get -y install git
fi

result=$(dpkg-query -W -f='${Status} \n'  whiptail)
if [ "$result" != "install ok installed " ]
then
	clear
	echo "installing whiptail package"
    sudo apt-get -y install whiptail
fi

result=$(dpkg-query -W -f='${Status} \n'  gcc-arm-none-eabi)
if [ "$result" != "install ok installed " ]
then
	clear
	echo "installing gcc-arm-none-eabi package"
    sudo apt-get -y install gcc-arm-none-eabi
fi

result=$(dpkg-query -W -f='${Status} \n'  gcc-arm-none-eabi)
if [ "$result" != "install ok installed " ]
then
	clear
	echo "installing gcc-arm-none-eabi package."
    sudo apt-get -y install gcc-arm-none-eabi
fi

result=$(dpkg-query -W -f='${Status} \n'  binutils-arm-none-eabi)
if [ "$result" != "install ok installed " ]
then
	clear
	echo "installing binutils-arm-none-eabi package."
    sudo apt-get -y install binutils-arm-none-eabi
fi

result=$(dpkg-query -W -f='${Status} \n'  libusb-1.0-0)
if [ "$result" != "install ok installed " ]
then
	clear
	echo "installing libusb-1.0-0 package."
    sudo apt-get -y install libusb-1.0-0
fi


result=$(dpkg-query -W -f='${Status} \n'  libnewlib-arm-none-eabi)
if [ "$result" != "install ok installed " ]
then
	clear
	echo "installing libnewlib-arm-none-eabi package."
    sudo apt-get -y install libnewlib-arm-none-eabi
fi


result=$(dpkg-query -W -f='${Status} \n'  python-usb)
if [ "$result" != "install ok installed " ]
then
	clear
	echo "installing git software required to obtain the source code."
    sudo apt-get -y install python-usb
fi

pip install pyusb -U

clear

}

whiptail --backtitle "MD380 DMR EXPERIMENTAL SOFTWARE ${pi_user}" --title "MD380 Basic installation - ver 1.10 dd: 06092016" --yesno --defaultno "You accept the risks of something going wrong when using this tool ?\nYou know how to put the MD380 in DFU mode?\nAre you ready to start with the MD380 toolbox ?" 16 60
 
exitstatus=$?
if [ $exitstatus = 0 ]; then
    status="0"
    while [ "$status" -eq 0 ]  
    do
        choice=$(whiptail --backtitle "MD380 DMR EXPERIMENTAL SOFTWARE ${pi_user}" --title "MD380 Basic installation - ver 1.10 dd: 06092016" --menu "Make a choice" 22 80 10 \
		"Raspberry OS Check" "test for correct OS system (Jessie)" \
		"Pre-requisite check" "Test if pre-requisite packages are installed" \
		"RPI update/upgrade" "Bring Raspberry OS to the latest updates" \
		"RPI reboot" "Reboot the Raspberry" \
		"Update firmware RPI" "Update Rspberry's firmware" \
		"MD380-tools" "Update tools or 1ste time installation" \
		"MD380-SW" "flash software" \
		"MD380-DB" "flash user database" \
		"MD380-ORG" "info on flashing original firmware"  3>&2 2>&1 1>&3) 
         
        # Change to lower case and remove spaces.
        option=$(echo $choice | tr '[:upper:]' '[:lower:]' | sed 's/ //g')
        case "${option}" in
            updatefirmwarerpi)
        	clear
        	whiptail --backtitle "MD380 DMR EXPERIMENTAL SOFTWARE ${pi_user}" --title "MD380 Basic installation - ver 1.10 dd: 06092016" --yesno "Would you like to flash the Raspberry PI (not the MD380 !!!) with new firmware ?" 20 60 2
			if [ $? -eq 0 ]; then # yese
			clear
	   		rpi-update
	   		fi
            ;;
            rpireboot)
            do_finish
            ;;
          raspberryoscheck)
            check_jessie
            ;;
            pre-requisitecheck)
            pre_package
            whiptail --backtitle "MD380 DMR EXPERIMENTAL SOFTWARE ${pi_user}" --title "MD380 Basic installation - ver 1.10 dd: 06092016" --msgbox "All pre-requiste packags are installed and up-to-date" 8 60
            ;;  
            rpiupdate/upgrade)
            clear
            apt-get update
            clear
            apt-get -y upgrade
            clear
            apt-get -y dist-upgrade
            sudo apt-get clean
            clear
            apt-get -y rpipugrade
            ;;         
            md380-tools)
            MD380-tools_install
                whiptail --backtitle "MD380 DMR EXPERIMENTAL SOFTWARE ${pi_user}" --title "MD380 Basic installation - ver 1.10 dd: 06092016" --msgbox "MD380 tools installed or updated" 8 60
            ;;           
            md380-sw)
            do_flash_sw
                whiptail --backtitle "MD380 DMR EXPERIMENTAL SOFTWARE ${pi_user}" --title "MD380 Basic installation - ver 1.10 dd: 06092016" --msgbox "Flashing MD380 software completed" 8 60
            ;;
           md380-db)
            do_flash_db
                whiptail --backtitle "MD380 DMR EXPERIMENTAL SOFTWARE ${pi_user}" --title "MD380 Basic installation - ver 1.10 dd: 06092016" --msgbox "Flashing MD380 user database completed" 8 60
            ;;
 			md380-org)
                whiptail --backtitle "MD380 DMR EXPERIMENTAL SOFTWARE ${pi_user}" --title "MD380 Basic installation - ver 1.10 dd: 06092016" --msgbox "Flashing MD380 with original firmware should be done using the suppliers tools." 8 60
            ;;
            *)  whiptail --backtitle "MD380 DMR EXPERIMENTAL SOFTWARE ${pi_user}" --title "MD380 Basic installation - ver 1.10 dd: 06092016"  --msgbox "You have cancelled the MD380-tool utility ." 8 60
                status=1
                exit
            ;;
        esac
        exitstatus1=$status1
    done
else
	rm -rf /home/pi/tmp.file > /dev/null
	whiptail --backtitle "MD380 DMR EXPERIMENTAL SOFTWARE ${pi_user}" --title "MD380 Basic installation - ver 1.10 dd: 06092016"  --msgbox "You have cancelled the MD380-tool utility ." 8 60
    exit
fi
