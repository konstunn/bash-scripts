#!/bin/bash

function dbg_echo {
	if [ $DEBUG -eq 1 ] ; then
		echo $1
	fi
}

function find_command {
	eval COMMAND=\$$1
	VAR=`which $COMMAND`

	if [ $VAR ] ; then
		dbg_echo "command found."
		eval $1=$VAR
	else
		dbg_echo "command not found, try ./"
		if [ ! -x ./$COMMAND ] ; then
			dbg_echo "command not found anywhere."
			return 1
		fi
		eval $1=./$COMMAND
	fi
	return 0
}

function track_n_kick {
	while true ; do
		pgrep `basename $1` > /dev/null

		if [ $? -gt 0 ] ; then
			dbg_echo "process not found"

			if [ -x $1 ] ; then
				dbg_echo "kicking up.."
				$1 &
				dbg_echo "kicked up."
			else 
				dbg_echo "executable file \"$1\" lost. terminating.."
				return 1
			fi
		else
			dbg_echo "process alive"
		fi

		sleep $2

	done
}


function ask_check_sleep_timeout {
	read -p "Enter sleep timeout: " VAR
	if [[ $VAR =~ ^[0-9]+[smhd]?$ ]] ; then
		eval $1=$VAR
	else
		echo "\"$VAR\" is not valid integer value"
	fi
}

function ask_check_process_name {
	read -ep "Enter process name: " VAR
	find_command VAR
	if [ $? -eq 0 ] ; then 
		eval $1=$VAR
	else
		echo "\"$VAR\" command not found anywhere"
	fi
}

# TODO handle command-line arguments

function print_set_daemon_menu {
	echo "1. set process name ($PROCESS_NAME)" 
	echo "2. set timeout ($SLEEP_TIMEOUT)"
	echo "3. toggle debug messages ($DEBUG)"
	echo "4. start daemon"
	echo "5. exit"
}

PROCESS_NAME="./dummy.sh"
DEBUG=1
SLEEP_TIMEOUT=3

function set_cron_jobs {
	echo -n ""
}

function set_daemon {
	while true ; do
		echo ""
		print_set_daemon_menu
		echo ""
		read -p "Enter your choice: " CHOICE
		case "$CHOICE" in
			1)	ask_check_process_name PROCESS_NAME ;;	
			2)	ask_check_sleep_timeout SLEEP_TIMEOUT ;;
			3)	if [ $DEBUG -eq 0 ] ; then DEBUG=1; else DEBUG=0; fi ;;
			4)  track_n_kick $PROCESS_NAME $SLEEP_TIMEOUT ;; # TODO fork
			5)	return 0 ;;
		esac
		echo ""
		read -p "Press Enter..."
		clear
	done
}

function print_main_menu {
	echo "1. set daemon"
	echo "2. set cron jobs"
	echo "3. exit"
} 

# main
while true ; do
	echo ""
	print_main_menu	
	echo ""
	read -p "Enter your choice: " CHOICE

	case "$CHOICE" in 
		1)	set_daemon ;;
		2)	echo "not implemented" ;;
		3)	exit 0 ;;
	esac

	clear
done

