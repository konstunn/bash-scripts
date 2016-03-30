#!/bin/bash

function ask_check_process_name {
	read -ep "Enter process name: " VAR
	eval $1=$VAR
}

function ask_check_timespan {
	read -p "Enter from time: " VAR
	# TODO think about the format (or several formats)
	# dd.mm.yyyy hh:mm
	$TIME_FORMAT="\([0-9]{2}\)\.\1\.\1{2}\([\t ]+\)\1:\1\2$"
	if [[ $VAR =~ $TIME_FORMAT ]] ; then
		echo -n ""	
	else
		echo -n ""	
	fi
}

function print_main_menu {
	echo "1. set process name"
	echo "2. set time span"
	echo "3. run"
	echo "4. exit"
}

# main
while true ; do
	echo ""
	print_main_menu	
	echo ""
	read -p "Enter your choice: " CHOICE

	case "$CHOICE" in 
		1)	echo "not implemented" ;;
		2)	echo "not implemented" ;;
		4)	exit 0 ;;
	esac

	clear
done
