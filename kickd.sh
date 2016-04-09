#!/bin/bash

# TODO may be it would better to operate with pid 
# instead of process name ?
function print_help {
	echo -e "\nUsage:\n `basename $0` [options]"
	echo -e "\nOptions:		\
		\n --menu | -m		\
		\n --process | -p	<process_name> \
		\n --help | -h \n"
}

# robust way to get path to itself
SELF_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"/"$(basename $0)"

# if no arguments, show text menu
if [ $# -eq 0 ] ; then 
	TEXT_MENU=1
fi

# parse command line arguments
OPTS=+h,k:,m
LONG_OPTS="help,menu,kick:"

ARGS=`getopt -o $OPTS --long $LONG_OPTS \
     -n $(basename $0) -- "$@"`

# if getopt returned error, claim and exit
if [ $? -ne 0 ] ; then
	echo "`basename $0`: specify '--help' or '-h' option for help." >&2
	echo "`basename $0`: terminating..." >&2
	exit 1
fi

eval set -- "$ARGS"

# parse command line arguments
while true ; do
	case "$1" in 
		--menu | -m)
			TEXT_MENU=1 ; shift 
		;;
		--kick| -k)
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
		echo "command found."
		eval $1=$VAR
		return 0
	else
		echo "command not found, trying to find in ./"
		if [ ! -x ./$COMMAND ] ; then
			echo "command not found anywhere."
			return 1
		fi
		eval $1=./$COMMAND
	fi
	return 0
}

# $1 - process name
function track_n_kick {
		pgrep `basename $1` > /dev/null

		if [ $? -gt 0 ] ; then
			echo "process not found"

			if [ -x $1 ] ; then
				echo "kicking up.."
				$1 &
				echo "kicked up."
			else 
				# TODO log that
				echo "executable file \"$1\" lost. terminating.."
				return 1
			fi
		else
			echo "process alive"
		fi
}

# TODO adopt
# $1 - timeout variable name   
function ask_check_minutes {
	read -p "Enter kick munutes: " DOW

	REGEX=""
	
	# validate
	if ! [[ $DOW =~ ^(([0-5][0-9])|(\2-\2(/\2)?))(,\1)*$ ]] 
	then
		echo "Invalid input '$DOW'"
		return 1
	else
		eval $1=$VAR
	fi
}

function ask_check_process_name {
	read -ep "Enter process name: " VAR
	find_command VAR
	if [ $? -eq 0 ] ; then 
		eval $1=$VAR
	else
		echo "\"$VAR\" command not found anywhere"
		return 1
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
# $4 - process name
function add_cron_job {
	HOURS=$(echo $2 | awk -F':' '{print $1}')
	MINUTES=$(echo $2 | awk -F':' '{print $2}')

	DOW=$3 # crontab day of week 

	PROCESS="$4"

	(crontab -l 
	echo -e "# $JOB_HEADER $1\n
		\t$MINUTES\t$HOURS\t*\t*\t$DOW\t$SELF_PATH -k \"$PROCESS\"\n") \
	| crontab -

	if [ $? -eq 0 ] ; then
		echo -e "\nJob was added"
	else
		echo -e "\nFailed to add job."
	fi
}

if [ $TEXT_MENU -eq 1 ] ; then

	# if crontab does not exist
	crontab -l > /dev/null		
	if [ $? -gt 0 ] ; then
		# create one
		echo -n "" | crontab - 
	else 
		# backup crontab
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
				ask_check_process_name PROCESS
				if [ $? -gt 0 ] ; then break ; fi
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
