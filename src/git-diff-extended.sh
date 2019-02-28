#!/bin/bash

# formatting
NONE='\033[00m'
BOLD='\033[1m'
PURPLE='\033[01;35m'
RED='\033[01;31m'


function show-help() {
    echo "Method requires 2 input parameters. This 2 strings are compared to each other. If string is a valid path to a file, the content of the file will be compared."
    echo
    echo "Usaage"
    echo "------"
    echo -e "diff ${BOLD}--system-diff${NONE} [OPTIONS] file1|string1 file2|string2"
    echo "where -x -y -z stand for options supported by system diff"
    
    echo "Examples"
    echo "------"
    echo "diff string1 string2"
    echo "diff string1 file2"
    echo "diff file1 string2"
    echo "diff file1 file2"
    echo
    echo
    echo "This diff implementation uses git-diff in combination with diff-highlighting. If you for whatever reason prefer the old system diff implementation"
    echo -e "you can easily fall back by using ${BOLD}--system-diff${NONE} parameter."
    echo
    echo "Examples"
    echo "------"
    echo -e "diff ${BOLD}--system-diff${NONE} [OPTIONS] file1|string1 file2|string2"
    echo 
}



# cleanup
rm -f /tmp/extended-diff-?.auto-generated

# the qualifier determines if we ahe a file or string as input
#
# LEFT    FILE     1
# RIGHT   FILE     2
# LEFT    STRIMG   4
# RIGHT   STRING   8
#
input_qualifier=0

# counts up to 2, is increased for each filestring that has to be compared
compare_variable_counter=0

# incremented through each cycle in the loop
loop_counter=0

# determines whether or not the new or the default diff functionality should be executed
use_default_diff=false

# final filenames to be compared
left_side_file="/tmp/extended-diff-1.auto-generated"
right_side_file="/tmp/extended-diff-2.auto-generated"


if [ "$#" -lt 2 ];
then
    echo -e "${RED}Invalid number of input parameters provided - at least 2 required!!${NONE}"
    echo
    show-help
    exit -1
fi


# check, whether or not fallback to system diff
for arg in "$@"; do
#   echo "arg($loop_counter): $arg"

    if [[ "$arg" == "--system-diff" ]]
    then
        # fallback to default system diff tool
        use_default_diff=true
    fi
done


# echo $use_default_diff
# perform the actal diff
if [[ "$use_default_diff" == "true" ]]
then
    echo "RUNNING SYSTEM DIFF"
    SYSTEM_DIFF_EXE=`which diff`
    RAW_PARAMETER_LIST="$@"
    PARAMETER_LIST=`echo $RAW_PARAMETER_LIST | sed s/--system-diff//`
    $SYSTEM_DIFF_EXE $PARAMETER_LIST
else
    OPTIONS=""
    for arg in "$@"; do
        loop_counter=$[$loop_counter+1]
        if [[ $arg == -* ]]
        then
            OPTIONS="$OPTIONS $arg"
        else
            compare_variable_counter=$[$compare_variable_counter+1]
        fi

        if [[ "$OPTIONS" == "" ]]
        then
            OPTIONS="--no-index"
        fi

        if [ "$compare_variable_counter" -gt 2 ];
        then
            echo -e "${RED}Invalid number of input parameters provided - 2 files/strings can be compared at max!${NONE}"
            echo
            show-help
            exit -1
        fi

        if [ -e "$arg" ]
        then
            #echo arg refers to a file (set qualifier to 1/2 for left/right file)
            input_qualifier=$((input_qualifier+$compare_variable_counter))

            if [ "$compare_variable_counter" -eq 1 ];
            then
                left_side_file=$arg
            else
                right_side_file=$arg
            fi
        else
            #echo arg refers to a string (set qualifier to 4/8 for left/right string)
            input_qualifier=$((input_qualifier+$compare_variable_counter*4))
            # dump string to diff file
            echo $arg>/tmp/extended-diff-$compare_variable_counter.auto-generated
        fi
    done


    COMMAND="git diff $OPTIONS -- $left_side_file $right_side_file"
#   echo $COMMAND
    $COMMAND
    if [ "$?" -eq 0 ];
    then
        case "$input_qualifier" in
        3)  declare -i char_count=$(cat $left_side_file | wc -m)
            declare -i line_count=$(cat $left_side_file | wc -l)
            echo -e "${PURPLE}Files are identical, each of them having ${line_count} lines and consisting of ${char_count} characters at all."
        ;;
        6)  echo -e "${PURPLE}Left side string is identical to right side file content"
        ;;
        9)  echo -e "${PURPLE}Left side file content is identical to right side string"
        ;;
        12) echo -e "${PURPLE}Strings are identical"
        ;;
        *) echo -e "${RED}Something went wrong! Got invalid input_qualifier: '${input_qualifier}'"
        exit -1
        ;;
        esac
    else
        echo -e "${RED}Differences detected!"
        exit 1
    fi
fi

