#!/bin/bash

ROOT_DIR="./filetree_rootdir"
DIRS_BASENAME="dir"
FILES_BASENAME="file"

declare -a LEVELS

LEVELS[0]=2
LEVELS[1]=3
LEVELS[2]=2

# $1 - count, $2 - current level, $3 - max level
function create_filetree
{
	for i in `seq 1 $1` ; do 
		if [ $2 -lt $3 ] ; then
			mkdir -pv ./$DIRS_BASENAME$i
			cd ./$DIRS_BASENAME$i
			create_filetree ${LEVELS[$2]} $(($2+1)) $3
			cd ..
		else
			touch $FILES_BASENAME$i
		fi
	done
}

function get_filename {
	if ! [[ $1 =~ ^[^/]+$ ]] ; then
		return 1
	fi
	return 0
}

function get_number {
	if ! [[ $1 =~ ^[0-9]+$ ]] ; then
		#echo "`basename $0:` invalid integer value '$1'." >&2
		#echo "Terminating..." >&2
		return 1
	fi
	return 0
}

while true ; do
	echo -e "\n1. set tree root directory: (\"$ROOT_DIR\")"
	echo "2. set directories basename (\"$DIRS_BASENAME\")"
	echo "3. set files basename: (\"$FILES_BASENAME\")"
	echo "4. set level 1 directories count (${LEVELS[0]})"
	echo "5. set level 2 directories count (${LEVELS[1]})"
	echo "6. set level 3 files count (${LEVELS[2]})"
	echo "7. create tree"
	echo "8. exit"
	echo -en "\nEnter your choice: "

	read DECISION

	case "$DECISION" in
		1) echo -n "Enter root dir: " ; read ROOT_DIR ;;
		2)
			echo -n "Enter directories basename (no slashes): " ; read VAR
			get_filename $VAR
			if [ $? -gt 0 ] ; then
				echo "Invalid input" ; echo "Press Enter" ; read
				continue
			fi
			DIRS_BASENAME=$VAR
		;;
		3)
			echo -n "Enter files basename (no slashes): " ; read VAR
			get_filename $VAR
			if [ $? -gt 0 ] ; then
				echo "Invalid input" ; echo "Press Enter" ; read
				continue
			fi
			FILES_BASENAME=$VAR
		;;
		[4-6])
			INDEX=$(($DECISION - 4))
			echo -n "Enter level $INDEX size: " ; read VAR
			get_number $VAR
			if [ $? -gt 0 ] ; then
				echo "Invalid input" ; echo "Press Enter" ; read
				continue
			fi
			LEVELS[$INDEX]=$VAR
		;;
		7)
			mkdir -pv $ROOT_DIR
			cd $ROOT_DIR
			create_filetree ${LEVELS[0]} 1 ${#LEVELS[@]}
		;;
		8) exit 0 ;;
		"" | *)
			echo Invalid input ; echo Press Enter ; read
		;;
	esac
done

