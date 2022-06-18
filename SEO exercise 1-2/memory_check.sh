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

# echo "c = ${c}"
# echo "w = ${w}"
# echo "e = ${e}"

TOTAL_MEMORY=$( free | grep Mem: | awk '{ print $2 }' )
echo "Total Memory: $TOTAL_MEMORY"
USED_MEMORY=$( free | grep Mem: | awk '{ print $3 }' )
echo "Used Memory: $USED_MEMORY"
PER_MEMORY=$( free | grep Mem: | awk '{ print ($3/$2)*100 }' )
echo "Memory Usage; $PER_MEMORY %"
DATE_SUBJ=$(date '+%Y%m%d %H:%M')
SUBJECT="$DATE_SUBJ memory check - critical"
MESSAGE="/tmp/Mail.out"
TO=${e}

if (($c > $w)); then
        if (($(echo "$w > $PER_MEMORY" |bc -l))); then
                echo "Used memory is less than warning threshold"
                exit 0

        elif (($(echo "$w <= $PER_MEMORY" |bc -l) && $(echo "$c > $PER_MEMORY" |bc -l))); then
                echo "Used memory greater than or equal to warning but less than the critical threshold"
                exit 1
        else
                echo "Used memory is greater than or equal to threshold"
                echo "$(ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -11)"
                echo "Used memory is greater than or equal to threshold" >> $MESSAGE
                echo "$(ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -11)" >> $MESSAGE
				mail -s "$SUBJECT" "$TO" < $MESSAGE
                echo "email sent"
                rm /tmp/Mail.out
                exit 2
        fi

else
        echo "Critical Threshold must be greater than warning threshold"
fi