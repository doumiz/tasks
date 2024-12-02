#!/bin/bash

usage="userhome [-f file] [login]"
login="$USER"
output=""
grep_code=0
is_empty=1

if [ "$1" == "-h" -o "$1" == "-help" -o "$1" == "-usage" -o "$1" == "--help" -o "$1" == "--usage" ]; then
    echo $usage;
    exit 0;
fi

if [ ! "$1" == "" ]; then
    login="$1"
fi

path="/etc/passwd"

if [ "$1" == "-f" ]; then
    path="$2"
    login="$3"
fi

if [ ! -f "$path" ]; then
    echo "File was not founded" >&2;
    exit 2;
fi

output=$(grep "^$login:" "$path")
grep_code=$?

if [ $grep_code -eq 1 ]; then
    echo "User was not founded" >&2;
    exit 1;
fi

echo "$output" | cut -d':' -f 6

exit 0
