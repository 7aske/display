#!/usr/bin/env bash

LCL_BIN="${LCL_BIN:-"$HOME/.local/bin/statusbar"}"

cmd=""
loop=0

while getopts ":hlc:" ARG; do
	case $ARG in
		l) loop=1 ;;
		c) cmd="$OPTARG" ;;
		:) echo "error: -$OPTARG requires an argument"; exit 1 ;;
	esac
done

shift $((OPTIND-1))

if [ -c "$1" ]; then 
	stty -F "$1" 9600 -hupcl -icrnl
fi


while true; do
	if [ -z "$cmd" ]; then
		CPU="$($LCL_BIN/cpu)"
		TEMP="$($LCL_BIN/temp | cut -c 1-5)"
		MEM="$($LCL_BIN/memory)"
		DATA="$(printf "CPU:%4s %4sC\nMEM: %10s" $CPU $TEMP $MEM)"
	else
		DATA=`eval $cmd`
	fi

	echo -en "$DATA\n" | tee "$1"
	sleep 1
	if [ $loop -eq 0 ]; then
		exit 0
	fi
done
