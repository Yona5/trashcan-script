#! /bin/bash

name="Yonas Tilahun Temesgen"
student_id="S1719046"
echo -e "\n "
echo "Name: $name"
echo "Student ID: $student_id"
echo "Script: monitor.sh"
echo "================================"
echo -e "\n "

inotify=$(which inotifywait)

install_inotify(){
	sudo apt-get install inotify-tools 
}

if [[ ! $inotify = "/usr/bin/inotifywait" ]]; then

	read -p "monitor.sh needs inotifywait to run. Would you like to install it? (Y/N): " confirm 
		case "$confirm" in 
			n | N) exit 0;;
			y | Y) install_inotify;;
			*) echo "invalid args";;
		esac
fi 

monitor(){
	inotifywait -m --timefmt '%H:%M:%S' --format '%T %w %e ' -e delete -e create -e modify -e move $HOME/.trashCan 
}
monitor
