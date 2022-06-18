#!/bin/sh
usage() { echo "Enter required arguments: $0 [-c <critical_threshold>] [-w <warning_threshold>] [-e <email>]" 1>&2; exit 1; }

while getopts ":c:w:e:" o; do
    case "${o}" in
        c)
            c=${OPTARG}
            #((c == 45 || c == 98)) || usage
            ;;
        w)
            w=${OPTARG}
            ;;

        e)
            e=${OPTARG}
            ;;

        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${c}" ] || [ -z "${w}" ] || [ -z "${e}" ]; then
    usage
fi

echo "c = ${c}"
echo "w = ${w}"
echo "e = ${e}"

TOTAL_MEMORY=$( free | grep Mem: | awk '{ print $2 }' )
echo $TOTAL_MEMORY
USED_MEMORY=$( free | grep Mem: | awk '{ print $3 }' )
echo $USED_MEMORY
PER_MEMORY=$( free | grep Mem: | awk '{ print ($3/$2)*100 }' )
echo $PER_MEMORY

if (($c > $w)); then
        if (($(echo "$w > $PER_MEMORY" |bc -l))); then
                echo "0, used memory is less than warning threshold"

        elif (($(echo "$w <= $PER_MEMORY" |bc -l) && $(echo "$c > $PER_MEMORY" |bc -l))); then
                echo "1, used memory greater than or equal to warning but less than the critical threshold"

        else
                echo "2, used memory is greater than or equal to threshold"
                echo "top 10 processes"
        fi

else
        echo "Critical Threshold must be greater than warning threshold"
fi
