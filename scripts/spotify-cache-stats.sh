#!/bin/bash

CACHEDIR=/var/lib/squeezeboxserver/cache/spotifycache/Storage 

cd $CACHEDIR

clear;
while true; do 
	tput eo
	tput cup 0 0  
	echo "Cache Size:      $(du -sh .)"
 	echo "Directory Count: $(ls -1 | grep -v index.dat | wc -l) " 
	tput el
	echo "" 

	OPENFILES=$(sudo lsof +D $CACHEDIR | grep 'file$' | cut -d'/' -f8-)
	for FILE in $OPENFILES; do 
		SIZE=$(stat -c %s $CACHEDIR/$FILE)
		CTIME=$(stat -c %x $CACHEDIR/$FILE)	
		printf "File: %s %9s, Time: $CTIME\n" $FILE $SIZE 
	done
	tput el
	echo ""
	for DIR in $(ls -1tr | grep -v index.dat | tail -n 10); do 
		printf "%2s: %s,    " $DIR $(du -sh $DIR | cut -f1) 
	done 

	echo ""; 

	tput el
	for I in {1..5}; do 
		sleep 1; 
		echo -n "."; 
	done 
	tput el1
done
