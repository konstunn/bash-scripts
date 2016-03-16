#!/bin/bash

while true ; do

	dd if=/dev/zero of=/dev/null bs=1024 count=1 &> /dev/null

	sleep 1

done
