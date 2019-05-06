#! /bin/bash

name="Yonas Tilahun Temesgen"
student_id="S1719046"
echo -e "\n "
echo "Name: $name"
echo "Student ID: $student_id"
echo "Script: monitor-comments.sh"
echo "================================"
echo -e "\n "

# assigns the location of inotifywait to a varaible
inotify=$(which inotifywait)

# a funtion that installs inotify-tools if it's not installed

# inotify-tools is a C library and a set of command-line programs
# for Linux providing a simple interface to inotify(is a Linux kernel 
# subsystem that acts to extend filesystems to notice changes to the filesystem).
# These programs can be used to monitor and act upon filesystem events
install_inotify(){
	sudo apt-get install inotify-tools 
}

# checks if inotifywait is installed
# if it's not installed, it calls the function defined above that installs inotifywait
# after getting user's approval
if [[ ! $inotify = "/usr/bin/inotifywait" ]]; then
	# asks for user's permision to download inotifywait
	read -p "monitor.sh needs inotifywait to run. Would you like to install it? (Y/N): " confirm 
		case "$confirm" in 
			n | N) exit 0;;
			y | Y) install_inotify;;
			*) echo "invalid args";;
		esac
fi 

# this function detects changes (deletion, creation, and modification of files) 
# in the trash can directory 
# -m keeps monitoring the directory
# --timefmt formats how time is displayed
# -e listens for particular events
# --format specifies what information should get displayed
#the program constantly displays information in the terminal when listed events get invoked

#the user has to open another terminal and run safeDel.sh to see the changes in the current terminal
monitor(){
	inotifywait -m --timefmt '%H:%M:%S' --format '%T %w %e ' -e delete -e create -e modify -e move $HOME/.trashCan 

}
monitor
