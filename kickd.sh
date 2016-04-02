#!/bin/bash

function print_help {
	echo -e "\nUsage:\n `basename $0` [options]"
	echo -e "\nOptions:		\
		\n --menu | -m		\
		\n --process | -p	<process_name> \
		\n --help | -h \n"
		# TODO may be it would better to operate with pid 
		# instead of process name ?
}

if [ $# -eq 0 ] ; then 
	TEXT_MENU=1
fi

# parse command line arguments
OPTS=+h,t:,m
LONG_OPTS="help,menu,track:"

ARGS=`getopt -o $OPTS --long $LONG_OPTS \
     -n $(basename $0) -- "$@"`

# if getopt returned error, claim and exit
if [ $? -ne 0 ] ; then
	echo "`basename $0`: specify '--help' or '-h' option for help." >&2
	echo "`basename $0`: terminating..." >&2
	exit 1
fi

eval set -- "$ARGS"

while true ; do
	case "$1" in 
		--menu | -m)
			TEXT_MENU=1 ; shift 
		;;
		--process | -p)
			KICK_NOW=1;	PROCESS="$2" ; shift 2
		;;
		--help | -h)	print_help; exit 0 ;;
		--)				shift ; break ;;
	esac
done

# claim if extra arguments and exit
if [ $# -gt 0 ] ; then
	echo "`basename $0`: extra arguments \"$@\"" >&2
	echo "`basename $0`: specify '--help' or '-h' option for help." >&2
	echo "`basename $0`: terminating..." >&2
	exit 1
fi

# search command "$1" in $PATH and in ./
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

# TODO adopt
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

# TODO adopt
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

function list_cron_jobs {
	# FIXME complete adoption from alarm.sh
	crontab -l | grep -A 1 "^# kick.sh" \
		| awk -F' |\t' \
			'BEGIN { print "process name\tjob state\ttimeout"; i=0 }
			/^# kick.sh/ { printf "%s\t",$3; i++ }
			/^#?\t[0-9]/ { 
				if ($1 == "#") printf "%s\t","off"
				else printf "%s\t","on"
				printf "%s:%s\t%s\t",$3,$2,$6;
			}
			END { if (i == 0) print "\nNo alarms." }'
}

# $1 - name, 
# $2 - time (hh:mm), 
# $3 - crontab day of week
# $4 - path to track 
function add_cron_job {
	HOURS=$(echo $2 | awk -F':' '{print $1}')
	MINUTES=$(echo $2 | awk -F':' '{print $2}')

	DOW=$3 # crontab day of week 

	TRACK="$4"

	# TODO adopt
	crontab -l \
		| sed -e \ 
		# TODO (crontab -l ; echo "" ) | crontab -
		"\$a\# $JOB_HEADER $1\n
		\t$MINUTES\t$HOURS\t\*\t\*\t$DOW\t$SELF_PATH -t \"$TRACK\"\n" \
		| crontab -

	if [ $? -eq 0 ] ; then
		echo -e "\nJob was added"
	fi
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

if [ $TEXT_MENU -eq 1 ] ; then

	# if crontab does not exist
	crontab -l > /dev/null		
	if [ $? -gt 0 ] ; then
		# create one
		echo -e "\n" | crontab - 
		# FIXME if crontab already exists
		# and is absolutely empty "" then add job function fails 
	else 
		# backup crontab
		echo -n ""
		mkdir -p ./crontab.bkp
		crontab -l > ./crontab.bkp/`date +%H%M%S-%d-%m-%Y`.crontab.bkp
	fi

	while true ; do
		echo ""
		echo "1. list jobs"
		echo "2. add job"
		echo "3. delete job"
		echo "4. set job"
		echo "5. enable/disable job"
		echo "6. exit"
		echo ""
		read -p "Enter your choice: " CHOICE
		
		echo ""
		case "$CHOICE" in
			1) list_cron_jobs
			;;
			2)
			;;
			6)	exit 0 ;;
		esac
		echo ""
		read -p "Press Enter..."
		clear
	done
fi

if [ $KICK_NOW -eq 0 ] ; then exit 0; fi

# kick now
# TODO complete
