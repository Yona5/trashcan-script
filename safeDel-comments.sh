#! /bin/bash

name="Yonas Tilahun Temesgen"
student_id="S1719046"
echo -e "\n "
echo "Name: $name"
echo "Student ID: $student_id"
echo "Script: safeDel-comments.sh"
echo "================================"
echo -e "\n "

# calls the trap_ctrl_c function when 
# ctrl + c signal is detected
trap trap_ctrl_c SIGINT

# the function that gets called when ctrl + c signal
# is detected 
# it also counts the number of regular files in 
# the trashcan
trap_ctrl_c(){
	local counter=0
	for i in $HOME/.trashCan/*; do
		counter=$((counter + 1))
	done
	echo -e "\r\nThe trashcan has $counter regular files"
	echo -e "\r\nYou hit Ctrl-C."
	exit 130
}

# this piece of code checks if there is trashcan directory
# and creates one if it does not exist
if [[ ! -d $HOME/.trashCan ]]; then
	mkdir $HOME/.trashCan
fi

# this function moves file/s to the trash can directory 
# when safeDel.sh is followed by file name/s 
delete_file(){
	for f in "$@"; do
		# checks if the argument is a directory
		if [[ -d "$f" ]]; then
			echo "Please enter file name/s"
		# checks if the argument exists 
		elif [[ ! -e "$f" ]]; then
			echo "$f does not exist."
		# checks if the argument is a file and move 
		# it to the trash can directory 
		elif [[ -f "$f" ]]; then
			mv $f $HOME/.trashCan
			echo "$f moved to trash can"
		fi
	done		
}

# lists files in the trash with their name, file size, and file extension 
list_file(){
	# loops through the trashcan directory
	for f in $HOME/.trashCan/*; do
		# assigns just the file name with no extension to a variable
		local file_name=$(basename $f | cut -f 1 -d '.')

		# assigns the file name with its extension to a variable
		local f_name=$(basename $f)

		# assigns the extension of the file name to a variable
		local file_extension="${f_name##*.}"
		
		# assigns the size of the current file to a variable
		local file_size=$(stat -c %s "$f")
		
		echo $file_name $file_size $file_extension
	done
}

# restores file to the working directory from the trash can
recover_file(){
	local file_exist=false
	local current_directory=$(pwd)
	
	# determines whether the function is called from the menu or directly from the the command line
	# if it is from the menu, it asks the user to input the name of the file after they choose the 
	# number corresponding to this function
	if [[ -z $OPTARG ]]; then
		read -p "Type the name of file you'd like to recover: " answer
		if [[ -e "$HOME/.trashCan/$answer" ]]; then
			mv $HOME/.trashCan/$answer $current_directory
			echo "$answer moved to $current_directory"
		else 
			echo "$answer doesn't exist in trash can"
		fi
	# if the user provides the option followed by the file name,
	# this piece of code takes the argument and restores the file (if it exists)
	# from the trash can to the working directory
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

# erases all files in the trash can
clear_trash(){
	# loops through the trash can
	for f in $HOME/.trashCan/*; do
		rm "$f"
		echo "$f is removed"
	done
}

# asks for confirmation before calling the function that deletes the files
# in the trash can
confirm(){
	# if the user confirms, clear_trash function gets called
	read -p "Are you sure you want to clear the trash can? (Y/N): " confirm 
	case "$confirm" in 
		n | N) ;;
		y | Y) clear_trash;;
		*) echo "invalid argument";;
	esac
}

# shows the total size of the trash can using du(data usage)
show_total_size(){
	du -h -b -c $HOME/.trashCan/*
}

# warns the user when the trash can exceedes 1kb
check_total_size(){
	# adds individual file size to total
	local total=0
	for f in $HOME/.trashCan/*; do
		local size=$(du -sb $f | cut -f1)
		total=$((size + total))
	done
	# checks if total is greater that 1kb
	if (($total > 1024)); then
		echo "-------------------------------"
		echo "The trash can has exceeded 1kb"
		echo "-------------------------------"
		echo -e "\n "
	fi
}
check_total_size

# starts the monitor script
monitor(){
	./monitor.sh
}

# kills the monitor script
kill_monitor(){
	killall inotifywait
}

# shows how to use the script
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







