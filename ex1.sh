#!/bin/bash

# a function for displaying a help on using the script
print_usage() {
    echo "usage: $0 [options] -- [files]"          # $0 is name of script
    echo "options:"
    echo " -s : The individual file sizes and the total size are displayed"
    echo " -S : Only the total size are displayed"
    echo " --help : Show detailed help"
    echo " --usage : Show usage information"
}

# the function for displaying more detailed help
print_help() {

    echo "This script outputs the size of files specified as arguments."
    echo "If no options are provided, the script outputs the size of each file followed by its name."
    echo
    print_usage
    echo " -- : Separates option from file names"
}

ind_size=true
total_size=false
exit_code=0
files=()
parse_options=true

while [[ $# -gt 0 ]]; do
    if [[ "$parse_options" == true ]]; then
        case "$1" in
            -s) 
                total_size=true ;;

            -S)
                ind_size=false
                total_size=true ;;

            --help)
                print_help
                exit 0 ;;

            --usage)
                print_usage
                exit 0 ;;

            --)
                parse_options=false
                ;;

            -*)
                echo "Error: Unsupported option $1" >&2
                exit 2
                ;;
            *)
                files+=("$1")
                ;;
        esac
    else
        files+=("$1")
    fi
    shift
done


if [[ ${#files[@]} -eq 0 ]]; then
    echo "Error: No files provided" >&2 
    print_usage
fi

SUM_of_the_sizes=0
#---------------------------------------------------------------------------------------
 
for file in "${files[@]}"; do
    if [[ -e "$file" ]]; then
        file_size=$(stat -c %s -- "$file")
        #SUM_of_the_sizes=$((SUM_of_the_sizes + file_size))
        if [[ $? -ne 0 ]]; then
            echo "Error: File '$file' doesn't exist." >&2
            exit_code=1
        else
            SUM_of_the_sizes=$((SUM_of_the_sizes + file_size))
            if [[ "$ind_size" == true ]]; then
                echo "$file_size $file"
            fi
        fi
    else
        echo "Error: file '$file' does't exist."
        exit_code=1
    fi
done


if [[ $total_size == true ]]; then
    echo "The sum of the sizes of all files: $SUM_of_the_sizes"
fi

exit $exit_code
