#!/bin/bash

ROOT_DIR=`pwd`/filetree_rootdir
DIRS_BASENAME=dir
FILES_BASENAME=file

function print_help
{
	echo -e "\nUsage:\n `basename $0` [options] <level1-breadth> [level2-breadth]..."
	echo -e "\nOptions: \
		\n --root-dir		<root-directory-path>	(Default: \"./`basename $ROOT_DIR`)\" \
		\n --dirs-basename	<directories basename>	(Default: \"$DIRS_BASENAME\") \
		\n --files-basename	<files basename>	(Default: \"$FILES_BASENAME\")\n"		
}

ARGS=`getopt -o '+h' --long 'help,root-dir:,dirs-basename:,files-basename:' \
     -n $(basename $0) -- "$@"`

if [ $? != 0 ] ; then 
	echo "Terminating..." >&2 # TODO print help ?
	exit 1
fi

eval set -- "$ARGS"

while true ; do
	case "$1" in
		--root-dir)			ROOT_DIR=$2 ; shift 2 ;;
		--dirs-basename)	DIRS_BASENAME=$2 ; shift 2 ;;
		--files-basename)	FILES_BASENAME=$2 ; shift 2 ;;
		--help | -h)		print_help; exit 0 ;;
		--)					shift ; break ;;
	esac
done

# $1 - count, $2 - current level, $3 - max level
function create_filetree
{
	for i in `seq 1 $1` ; do 
		if [ $2 -lt $3 ] ; then
			mkdir -pv ./$DIRS_BASENAME$i
			cd ./$DIRS_BASENAME$i
			create_filetree ${ARGS[$2]} $(($2+1)) $3
			cd ..
		else
			touch $FILES_BASENAME$i
		fi
	done
}

if [[ $# == 0 ]] ; then
	echo "`basename $0`: at least level 1 breadth required" >&2
	print_help
	echo "Terminating..." >&2
	exit 1
fi

ARGS=("$@") 

# check if values are numeric
for arg in "${ARGS[@]}" ; do 
	if ! [[ $arg =~ ^[0-9]+$ ]] ; then
		echo "`basename $0:` invalid integer value '$arg'." >&2
		echo "Terminating..." >&2
		exit 1
	fi
done

if [ -x $ROOT_DIR ] ; then 
	rm -rf $ROOT_DIR ; 
fi

mkdir -pv $ROOT_DIR
cd $ROOT_DIR

create_filetree ${ARGS[0]} 1 $#
