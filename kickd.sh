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
		dbg_echo "command found in PATH."
		eval $1=$VAR
	else
		dbg_echo "command not found in PATH. try ./"
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

	done 2> /dev/null # beware when $ bash -x $0
}

PROCESS_NAME="./dummy.sh"
DEBUG=1
TIMEOUT=3

while true ; do
	echo -e "\n1. set process name (\"$PROCESS_NAME\")"
	echo "2. set timeout ($TIMEOUT)"
	echo "3. toggle output debug messages ($DEBUG)"
	echo "4. start"
	echo ""
	read -p "Enter your choice: " CHOICE

	case "$CHOICE" in 
		1) 
			read -ep "Enter process name: " VAR
			find_command VAR
			if [ $? -eq 0 ] ; then 
				PROCESS_NAME=$VAR
			else
				dbg_echo "\"$VAR\" command is not found anywhere"
			fi
		;;
		2)
			read -p "Enter timeout: " VAR
			if [[ $VAR =~ ^[0-9]+[smhd]?$ ]] ; then
				TIMEOUT=$VAR
			else
				dbg_echo "\"$VAR\" is not valid integer value"
			fi
		;;
		3) if [ $DEBUG -eq 0 ] ; then DEBUG=1; else DEBUG=0; fi ;;
		4)
			track_n_kick $PROCESS_NAME $TIMEOUT
		;;
	esac
done

