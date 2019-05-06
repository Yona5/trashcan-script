#! /bin/bash

name="Yonas Tilahun Temesgen"
student_id="S1719046"
echo -e "\n "
echo "Name: $name" 
echo "Student ID: $student_id"
echo "Script: safeDel.sh"
echo "================================"
echo -e "\n "

trap trap_ctrl_c SIGINT

trap_ctrl_c(){
	local counter=0
	for i in $HOME/.trashCan/*; do
		counter=$((counter + 1))
	done
	echo -e "\r\nThe trashcan has $counter regular files"
	echo -e "\r\nYou hit Ctrl-C."
	exit 130
}


if [[ ! -d $HOME/.trashCan ]]; then
	mkdir $HOME/.trashCan
fi

delete_file(){
	for f in "$@"; do
		if [[ -d "$f" ]]; then
			echo "Please enter file name/s"
		elif [[ ! -e "$f" ]]; then
			echo "$f doesn't exist."
		elif [[ -f "$f" ]]; then
			mv $f $HOME/.trashCan
			echo "$f moved to trash can"
		fi
	done		
}


list_file(){
	for f in $HOME/.trashCan/*; do
		local file_name=$(basename $f | cut -f 1 -d '.')
		local f_name=$(basename $f)
		local file_extension="${f_name##*.}"
		local file_size=$(stat -c %s "$f")
		echo $file_name $file_size $file_extension
	done
}

recover_file(){
	local file_exist=false
	local current_directory=$(pwd)
	if [[ -z $OPTARG ]]; then
		read -p "Type the name of file you'd like to recover: " answer
		if [[ -e "$HOME/.trashCan/$answer" ]]; then
			mv $HOME/.trashCan/$answer $current_directory
			echo "$answer moved to $current_directory"
		else 
			echo "$answer doesn't exist in trash can"
		fi

	else
		for f in $HOME/.trashCan/*; do
			if [[ $OPTARG = $f ]]; then	
				mv $OPTARG $current_directory
				file_exist=true 
				local f_name=$(basename $OPTARG)
				echo "$f_name moved to $current_directory"
			fi
		done

		if [[ "$file_exist" = false ]]; then
			echo "$OPTARG doesn't exist."
		fi
	fi
}


clear_trash(){
	for f in $HOME/.trashCan/*; do
		rm "$f"
		echo "$f is removed"
	done
}

confirm(){

	read -p "Are you sure you want to clear the trash can? (Y/N): " confirm 
	case "$confirm" in 
		n | N) ;;
		y | Y) clear_trash;;
		*) echo "invalid argument";;
	esac
}

show_total_size(){
	du -h -b -c $HOME/.trashCan/*
}

check_total_size(){
	local total=0
	for f in $HOME/.trashCan/*; do
		local size=$(du -sb $f | cut -f1)
		total=$((size + total))
	done

	if (($total > 1024)); then
		echo "-------------------------------"
		echo "The trash can has exceeded 1kb"
		echo "-------------------------------"
		echo -e "\n "
	fi
}
check_total_size

monitor(){
	./monitor.sh
}

kill_monitor(){
	killall monitor.sh
}

USAGE="USAGE: $0 [-lr:dtmk]
OPTIONS
       -l     lists all files in the trashcan directory

       -r file
	      restores the the file moved to trashcan to the working directory

       -d     erases the files from the trashcan completely

       -t     shows the total size of the trashcan directory in bytes

       -m     monitors monitors activities like creation, deletion, and  modi-
	      fication of files in the trash can

       -k     kills the current monitor script
"

while getopts :lr:dtmk args #options
do
  case $args in
     l) list_file;;
     r) recover_file "$OPTARG";;
     d) confirm;; 
     t) show_total_size;; 
     m) monitor;; 
     k) kill_monitor;;     
     :) echo "data missing, option -$OPTARG";;
    \?) echo "$USAGE";;
  esac
done

((pos = OPTIND - 1))
shift $pos

PS3='option> '

if (( $# == 0 ))
then if (( $OPTIND == 1 )) 
 then select menu_list in list recover delete total monitor kill exit
      do case $menu_list in
         "list") list_file;;
         "recover") recover_file "$OPTARG";;
         "delete") confirm;;
         "total") show_total_size;;
         "monitor") monitor;;
         "kill") kill_monitor;;
         "exit") exit 0;;
         *) echo "unknown option";;
         esac
      done
 fi
else delete_file $@
fi







