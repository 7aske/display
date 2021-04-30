#!/usr/bin/env bash

LCL_BIN="${LCL_BIN:-"$HOME/.local/bin/statusbar"}"

cmd=""
loop=0
sleep_time="1"

while getopts ":hlc:t:" ARG; do
	case $ARG in
		l) loop=1 ;;
		t) sleep_time="$OPTARG" ;;
		c) cmd="$OPTARG" ;;
		:) echo "error: -$OPTARG requires an argument"; exit 1 ;;
	esac
done

shift $((OPTIND-1))

port="/dev/ttyUSB0"

if [ -n "$1" ]; then 
	port="$1"
fi

if [ -c "$port" ]; then 
	stty -F "$port" 9600 -hupcl -icrnl
fi


while true; do
	if [ -z "$cmd" ]; then
		CPU="$($LCL_BIN/cpu)"
		MEM="$($LCL_BIN/memory)"
		BAND="$($LCL_BIN/bandwidth -f "%5s %5s")"

		DATA="$(printf "H:%4s %9s\nN:%14s" "$CPU" "$MEM" "$BAND")"
	else
		DATA=`eval $cmd`
	fi

	echo -en "$DATA\n" | tee "$port"
	sleep "$sleep_time"
	if [ $loop -eq 0 ]; then
		exit 0
	fi
done
