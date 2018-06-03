#!/bin/bash
##################################################################################
##################################################################################
###### SCRIPT TO FLASH A TYTERA MD380/MD390 WITH THE EXPERIMENTAL SOFTWARE  ######
######               FROM  TRAVISGODSPEED - KK4VCZ                          ######
###### 	  LOCATED AT https://github.com/travisgoodspeed/md380tools.git	    ######
###### 		REVISION 03-06-2018   - Written by PA0ESH     	            ######
###### 	   	You may copy, modify or change this script as you like	    ######
####### Requires: whiptail						    ######
##################################################################################
##################################################################################
#

directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
script_rev="3.0"
script_date="28-11-2016"
script_ver_file="version-md380.txt"
script_file="flash-md380.sh"
pi_user_own=$(whoami)
pi_user="MD380 Experimental firmware - Current Linux user: ${pi_user_own} - Working dir :${directory} - Rev: ${script_rev} - dated: ${script_date}"
M_title="MD380-tools installer - ${script_rev} - Dated: ${script_date}"


declare -a jessie=('gcc-arm-none-eabi' 'binutils-arm-none-eabi' 'libnewlib-arm-none-eabi' 'libusb-1.0-0' 'python-usb' 'python-pip' 'unzip' 'make' 'curl' 'git')
declare -a xenial=('gcc-arm-none-eabi' 'binutils-arm-none-eabi' 'libnewlib-arm-none-eabi' 'libusb-1.0-0-dev' 'python-usb' 'python-pip' 'curl' 'git')
declare -a stretch=('gcc-arm-none-eabi' 'binutils-arm-none-eabi' 'libnewlib-arm-none-eabi' 'libusb-1.0-0-dev' 'python-usb' 'make' 'curl' 'git')


function test_jessie {
clear
apt-get update
echo "Installation of pre requisite  packages for Ubuntu distro: $distro"
for item in ${jessie[*]}
do
    check_package $item
done
pip install pyusb -U # update PyUSB to 1.0
}

function test_xenal {
clear
apt-get update
echo "Installation of pre requisite  packages for linux distro: $distro"
for item in ${xenial[*]}
do
    check_package $item
done

}
function test_stretch {
clear
apt-get update
echo "updating the package for Debianb distro: $distro"
for item in ${stretch[*]}
do
    check_package $item
done

}

#Check first of all if user is root

function check_package {
#pack_name="git"
pack_name=$1
ss1=$(dpkg-query -W -f='${Status} \n'  $pack_name)
rep1==$(echo $ss1 | tr '[:upper:]' '[:lower:]' | sed 's/ //g')

rep2="=installokinstalled"
#
#echo "---------------------------------------------"
if [ "$rep1" != "${rep2}" ] 
		then
 		echo "Installing package $pack_name"
		echo "---------------------------------------------"
		apt-get -y install $pack_name
else
	 echo " ${pack_name} already installed."		
fi

}

function check_distro {
result=$(dpkg --status tzdata|grep Provides|cut -f2 -d'-')
distro=$(echo $result | tr '[:upper:]' '[:lower:]' | sed 's/ //g')

if [ ${distro} == "jessie" ]; then
	whiptail --backtitle "${pi_user}" --title "Linux Debian - ${distro} for Raspberry" --msgbox "Testing availability or installing the pre-requisite packages\n\
	required for this distro : ${distro}\n\
This may take some time, so please be patient and watch out for errors." 12 60
	test_jessie
elif  [ ${distro} == "xenial" ]; then
	whiptail --backtitle "${pi_user}" --title "Linux Ubuntu - ${distro}" --msgbox "Testing availability or installing the pre-requisite packages\n\
This may take some time, so please be patient and watch out for errors." 12 60
	test_xenal
elif  [ ${distro} == "stretch" ]; then
	whiptail --backtitle "${pi_user}" --title "Linux Debian - ${distro}" --msgbox "Testing availability or installing the pre-requisite packages\n\
This may take some time, so please be patient and watch out for errors." 12 60
	test_stretch
	
else
	whiptail --backtitle "${pi_user} - not suitable" --title "Linux distro - ${distro}" --msgbox "The OS on this machine is not (yet) suitable for the MD380/390 tools..." 12 60
exit 1
fi
sleep 2
}


function MD380-tools_install {
clear
check_distro
echo "Installing the MD380 python toolkit"
echo -e "\t${YelRed} This may take a while ${Reset}"
if [ ! -d $directory/md380tools ] ; then
#echo "Directory does not exist"
			whiptail --backtitle "${pi_user}" --title "$M_title" --msgbox "Now the source code is being downloaded and compiled.\nThis may take some time, so relax.\nHit OK to continue." 12 60
			git clone https://github.com/travisgoodspeed/md380tools
			if [ ! -f /etc/udev/rules.d/99-md380.rules ]
			then
				cp $directory/md380tools/99-md380.rules  /etc/udev/rules.d
			fi
			#cd $directory/md380tools
			make clean
			make all			
else
#echo "Directory exists"
			whiptail --backtitle "${pi_user}" --title "$M_title" --msgbox "Now the source code is being updated and compiled.\nThis may take some time, so relax.\nHit OK to continue." 12 60
			cd $directory/md380tools
			git pull
			if [ ! -f /etc/udev/rules.d/99-md380.rules ]
				then
				cp $directory/md380tools/99-md380.rules  /etc/udev/rules.d
			fi

			cd $directory/md380tools
			make clean
			make all
fi

#echo -e "${Green} Installation or updating git repository md380tools completed ${Reset}"
return
}

#functions to flash the md380/390 with user data
function do_flash_db-eu {
# routine to flash the software only
if [ ! -d $directory/md380tools ] ; then
	whiptail --backtitle "${pi_user}" --title "$M_title" --msgbox " You have to install the tools first \n Choose the 6th option from the main menu\n Hit OK to continue." 8 78
else
	whiptail --backtitle "${pi_user}" --title "$M_title" --msgbox " Please switch on the MD380/390 in normal mode. \n The red light should NOT be flashing\nThen hit OK to continue.\nThis proces may take some time ! Be patient!" 16 78
	cd $directory/md380tools

	clear
	git pull
	make clean
	##### turn on radio in DFU mode to begin firmware update with USB cable ######
	make updatedb_eur flashdb
	whiptail --backtitle "${pi_user}" --title "$M_title" --msgbox "The MD380 has been loaded with the DMR user database according to EU privacy laws \nYour own codeplug remains unchanged." 8 78
fi
}

function do_flash_db-row {
# routine to flash the software only
if [ ! -d $directory/md380tools ] ; then
	whiptail --backtitle "${pi_user}" --title "$M_title" --msgbox " You have to install the tools first \n Choose the 6th option from the main menu\n Hit OK to continue." 8 78
else
	whiptail --backtitle "${pi_user}" --title "$M_title" --msgbox " Please switch on the MD380/390 in normal mode. \n The red light should NOT be flashing.\nThen hit OK to continue.\nThis process may take some time. Be Patient!" 16 78
	cd $directory/md380tools

	clear
	git pull
	make clean
	##### turn on radio in DFU mode to begin firmware update with USB cable ######
	make updatedb flashdb
	whiptail --backtitle "${pi_user}" --title "$M_title" --msgbox "The MD380 has been loaded with the DMR user database without EU privacy laws. \nYour own codeplug remains unchanged.\n Hit OK to continue." 8 78
fi
}

#functions to flash the experimental firmware - eith with or without GPS
function do_flash_sw-no-gps {
# routine to flash the software only
clear
if [ ! -d $directory/md380tools ] ; then
	whiptail --backtitle "${pi_user}" --title "$M_title" --msgbox " You have to install the tools first \n This will be done now\n Hit OK to continue." 12 78
	MD380-tools_install
else
	whiptail --backtitle "${pi_user}" --title "$M_title" --msgbox " Please switch on the MD380/390 in DFU mode. \n Press the PTT button and the button above together,\n and switch on the MD380/390.\n The red light should be flashing\n Then hit OK to continue." 12 78
	cd $directory/md380tools
	git pull
	##### turn on radio in DFU mode to begin firmware update with USB cable ######
	clear
	make clean
	make flash

	whiptail --backtitle "${pi_user}" --title "$M_title" --msgbox "The MD380 has been loaded with the new experimental software\nYour codeplug remains unchanged\nSwitch off the MD380 now to exit the DFU mode.\n Hit OK to continue." 8 78
fi
}

function do_flash_sw-yes-gps {
clear
# routine to flash the software only
if [ ! -d $directory/md380tools ] ; then
	whiptail --backtitle "${pi_user}" --title "$M_title" --msgbox " You have to install the tools first \n This will be done now\n Hit OK to continue." 12 78
	MD380-tools_install
else
	whiptail --backtitle "${pi_user}" --title "$M_title" --msgbox " Please switch on the MD380/390 in DFU mode. \n Press the PTT button and the button above together,\n and switch on the MD380/390.\n The red light should be flashing\n Then hit OK to continue." 12 78
	cd $directory/md380tools
	git pull
	##### turn on radio in DFU mode to begin firmware update with USB cable ######
	clear
	make flash_S13

	whiptail --backtitle "${pi_user}" --title "$M_title" --msgbox "The MD380 has been loaded with the new experimental software\nYour codeplug remains unchanged\nSwitch off the MD380 now to exit the DFU mode.\n Hit OK to continue." 8 78
fi
}


function check_update_script {
rm -rf ${script_ver_file}
wget -N  http://www.pa0esh.nl/svn/md380/$script_ver_file >> /dev/null
#sudo chmod +x $script_ver_file
#sudo sed -i -e 's/\r$//' $script_ver_file
read -d $'\x04' name < "$script_ver_file" 
new_date=$name
if [ "$new_date" == "$script_date" ] 
then
		whiptail --backtitle "${pi_user}" --title "$M_title" --msgbox "No new script available\nThe current is dated: $new_date  - Rev: $script_rev." 8 78
		sudo rm -rf "$script_ver_file"
else
        if (whiptail --backtitle "${pi_user}" --title "$M_title" --yes-button "Update" --no-button "No, Thanks"  --yesno " There is an update of this script available for download.\n Current version dated: $script_date \n New version    : $new_date" 10 60) then
    	echo "You choose to update the script. It will restart it after the download is completed -  $?."
    	#sudo chmod -x $script_ver_file
    	sudo rm -rf $script_file
        sudo wget -N  http://www.pa0esh.nl/svn/md380/$script_file >> /dev/null
		sudo chmod +x *.sh
		sed -i -e 's/\r$//' $script_file
		sync
		sudo ./$script_file
		fi
fi
}



function about_info {


info="The patched firmware is known to work on the following devices:\n \
\n \
The D-Version (NoGPS) for radios without GPS\n \


Tytera/TYT MD380\n \
Tytera/TYT MD390\n \
Retevis RT3\n \
\n \
The S-Version (GPS) for radios with GPS\n \
Tytera/TYT MD380\n \
Tytera/TYT MD390\n \
Retevis RT8\n \
Both types of vocoder (old and new vocoder radios) are supported.\n\
\n \
The DMR MARC user's database required a 16 MByte SPI Flash memory chip.\nIn some VHF Radios is only an 1 MByte SPI Flash installed."


whiptail --backtitle "${pi_user}" --title "$M_title"  --msgbox "${info}"  24 80

}


function special_menu {
    sstatus="0"
    while [ "$sstatus" -eq 0 ]  
    do
        choice=$(whiptail --backtitle "${pi_user}" --title "$M_title" --menu "\nMake a choice" 16 78 5 \
        "make clean" "Clean up everything." \
        "make flashD03" "Flash original FW for MD380 with new vocoder." \
        "make flashD02" "Start backing up the first application." \
        "make dist" "Create a windows installation package" \
        "spiflashid " "To check the type / size of SPI-Flash." 3>&2 2>&1 1>&3) 
         
        # Change to lower case and remove spaces.
        option=$(echo $choice | tr '[:upper:]' '[:lower:]' | sed 's/ //g')
        case "${option}" in
            makeclean) 
            clear
            cd $directory/md380tools
            git pull
            make clean
            cd $directory
			whiptail --backtitle "${pi_user}" --title "$M_title"  --msgbox "Cleaning has been completed"  24 78        
            ;;
            makeflashd03)
               clear
            git pull
            cd $directory/md380tools
            make flash_original_D03
            cd $directory
               info1="A windows installer has been created\n \
				You can find ut in the directory"
			whiptail --backtitle "${pi_user}" --title "$M_title"  --msgbox "${info1}"  24 78        
            ;;
            makeflashd02)
                git pull
			    clear
                cd $directory/md380tools
                make flash_original_D02
                cd $directory
			whiptail --backtitle "${pi_user}" --title "$M_title"  --msgbox "MD380 been flashed with original oldest FW."  24 78        
            ;;
            makedist)
	            git pull            
                clear
                cd $directory/md380tools
                rm -rf *.bin
                rmdir --ignore-fail-on-non-empty /home/pi/md380tools/dist/*
                make dist
                cd $directory
          	info1="A windows installer has been created\n \
 You can find it in the directory $directory/md380tools/dist as a zipfile. \
 Copy this zip file to your windows c, unpack it and run the installer called upgrade.exe. \
 Then select the appropriate firmware (bin file)"
			whiptail --backtitle "${pi_user}" --title "$M_title"  --msgbox "${info1}"  16 78        
            ;;
            spiflashid)
                clear
                cd $directory/md380tools
                md380-tool spiflashid 
                cd $directory
                
            ;;
            *) whiptail --backtitle "${pi_user}" --title "$M_title"  --msgbox "You cancelled or have finished the specials menu." 8 78
                sstatus=1
            ;;
        esac
        special=$sstatus
    done

}

# main part of the script

clear
#routine to check that user is root, and if not change to root with consent of user
#
if [[ $EUID -ne 0 ]]; then
	whiptail --backtitle "${pi_user}" --title "$M_title" --yesno " You are not logged in as root.\n This script only works with user root.\n Would you like to change to root now?\n\n If yes, the script will restart as root. !" 10 60 2
	if [ $? -eq 0 ]; then # yes
		sync
		sudo ./$script_file
	else
	clear
	echo "you stopped the script because you did not want to run it as root"
	exit 1
	fi
fi	


whiptail --backtitle "${pi_user}" --title "$M_title" --yesno "This script installs Travis Goodspeed, KK4VCZ MD380 tools on\n\
a Raspberry  or Ubuntu machine. Source code at https://github.com/travisgoodspeed/md380tools.git \n\
The script has been tested on the folowing distro;s: Ubuntu stretch, Debian Jessie (Raspberry) en Debian Xenal.\n\
Use this tool at your own risk !!! \n  \nMake sure the MD380/390 is connected with the programming cable to an USB port of the machine, but NOT switched on!" --yes-button "Continue" --no-button "Abort" 16 80
exitstatus=$?
if [ $exitstatus = 0 ]; then
	sleep 0
else
	echo -e "${YelRed} Installation aborted. ${Reset}"
    exit
fi

whiptail --backtitle "${pi_user}" --title "$M_title" --yesno --defaultno "You accept the risks of something going wrong when using this tool ?\nYou know how to put the MD380 in DFU mode?\nAre you ready to start with the MD380 toolbox ?" 16 60

exitstatus=$?

if [ $exitstatus = 0 ]; then
    status="0"
    while [ "$status" -eq 0 ]
    do
        choice=$(whiptail --backtitle "${pi_user}" --title "$M_title" --menu "Make a choice" 22 78 14 \
		"Check script" "Check for a new version of this script" \
		"Linux Update" "Update the Operating System on this machine" \
		"MD380-tools" "MD380 tools 1st time installation." \
		"MD380-SW-NO-GPS" "flash software MD380 No GPS" \
		"MD380-SW-YES-GPS" "flash software MD380 with GPS" \
		"MD380-DB-EU" "flash user database EU privacy law" \
	    "MD380-DB-ROW" "flash user database ROW privacylaw" \
	    "Specials" "For the expierenced user. Be carefull" \
		"About" "info on flashing MD380/MD390"  \
		"MD380-ORG" "info on flashing original firmware"  3>&2 2>&1 1>&3)

        # Change to lower case and remove spaces.
        option=$(echo $choice | tr '[:upper:]' '[:lower:]' | sed 's/ //g')
        case "${option}" in
            checkscript)
            #whiptail --backtitle "${pi_user}" --title "$M_title" --msgbox "See if there is a new script available" 8 60			
			check_update_script
			;;
            linuxupdate)
        	clear
        	if (whiptail --backtitle "${pi_user}" --title "$M_title" --yesno "The script will now update the operating system on this machine ?\n\Would you like to reboot afterwards and login again?" 20 60 2) then
    			apt-get update && apt-get -y dist-upgrade && reboot
			else
    			apt-get update && apt-get -y dist-upgrade
			fi
            ;;
            md380-tools)
            MD380-tools_install
            whiptail --backtitle "${pi_user}" --title "$M_title" --msgbox "MD380 tools have either been installed for 1st time or were updated" 12 60
            ;;
            md380-sw-no-gps)
            do_flash_sw-no-gps
            ;;
            md380-sw-yes-gps)
            do_flash_sw-yes-gps
            ;;
           md380-db-eu)
            do_flash_db-eu
            ;;
           md380-db-row)
            #do_flash_db-row
                whiptail --backtitle "${pi_user}" --title "$M_title" --msgbox "Flashing MD380 user database according to ROW privacy law's no longer possible\nAs per 28.11.2016, DMR-MARC no longer provides privavcy sensitive data\nPlease carry out the EU option." 12 60
            ;;
           specials)
            special_menu
            ;;
 			md380-org)
                whiptail --backtitle "${pi_user}" --title "$M_title" --msgbox "Flashing MD380 with original firmware should be done using the suppliers tools." 8 60
            ;;
 			about)
                about_info
            ;;
            *)  whiptail --backtitle "${pi_user}" --title "$M_title"  --msgbox "You have cancelled the MD380-tool utility ." 8 60
                status=1
                break
                exit
            ;;
        esac
        exitstatus1=$status1
    done
else
	rm -rf $directory/tmp.file >> /dev/null
	whiptail --backtitle "${pi_user}" --title "$M_title"  --msgbox "You have cancelled the MD380-tool utility ." 8 60
	status=1
	
    exit
fi
