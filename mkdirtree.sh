#!/bin/bash

function 200files
{
	for k in `seq 1 200`;
	do
		touch $1/$k
	done
}

cd $1

for i in `seq 1 50`;
do
	mkdir -pv $i

	for j in `seq 1 100`;
	do
		mkdir -p $i/$j
		200files "$i/$j"
	done

done
