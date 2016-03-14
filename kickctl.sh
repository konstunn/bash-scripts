#!/bin/bash

COMMAND=`which $1`

if [ $COMMAND ] ; then 
	echo command found in PATH.
	COMMAND=$1
else
	echo command not found in PATH. try ./
	if [ ! -x ./$1 ] ; then echo command not found ; exit 1 ; fi
	COMMAND=./$1
fi

while true ; do

	PID=`pgrep $1`

	if [ $? -gt 0 ] 
	then
		echo process not found

		if [ -x $COMMAND ] ; then
			$COMMAND &
		else 
			echo executable lost ; exit 1
		fi
	else
		echo process found
	fi

	sleep $2

done 2> /dev/null
