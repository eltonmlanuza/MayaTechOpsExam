#!/bin/sh
usage() { echo "Enter required arguments: $0 [-c <45|90>] [-w <string>] [-e <email>]" 1>&2; exit 1; }

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

if (( $(echo "$c > $PER_MEMORY" |bc -l) )); then
        echo "Below Threshold"
else
        echo "Above Threshold"
fi