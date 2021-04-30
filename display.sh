#!/usr/bin/env bash

# https://github.com/7aske/scripts
LCL_BIN="${LCL_BIN:-"$HOME/.local/bin/statusbar"}"

cmd=""
loop=0
sleep_time="1"
display_type="default"
prog="$(basename $0)"

_usage() {
	>&2 echo "usage: $prog -[cdlt] [/dev/ttyX]"
	>&2 echo "options:"
	>&2 echo "    -c <command>         override command"
	>&2 echo "    -d <default|network> display type"
	>&2 echo "    -l                   loop"
	>&2 echo "    -t <secs>            sleep seconds"
	exit 2
}

_display_default() {
	CPU="$($LCL_BIN/cpu)"
	TEMP="$($LCL_BIN/temp | cut -c 1-5)"
	MEM="$($LCL_BIN/memory)"
	printf "CPU: %4s %5sC\nMEM: %11s\n" "$CPU" "$TEMP" "$MEM"
}

_display_network() {
	CPU="$($LCL_BIN/cpu)"
	MEM="$($LCL_BIN/memory)"
	BAND="$($LCL_BIN/bandwidth -f "%5s %5s")"
	printf "H:%4s %9s\nN:%14s\n" "$CPU" "$MEM" "$BAND"
}

while getopts ":hlc:t:d:" ARG; do
	case $ARG in
		h) _usage ;;
		l) loop=1 ;;
		t) sleep_time="$OPTARG" ;;
		d) display_type="$OPTARG" ;;
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
		 case "$display_type" in
			 default|d) _display_default ;;
			 network|n) _display_network ;;
			 *) echo "Invalid type"
				 exit 2 ;;
		 esac | tee "$port"
	else
		eval $cmd | tee "$port"
	fi

	sleep "$sleep_time"

	if [ $loop -eq 0 ]; then
		exit 0
	fi
done
