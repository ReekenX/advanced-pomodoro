#!/bin/bash
#
# Pomodoro script - 25 minutes work without any interruptions!
#
# Remigijus Jarmalavičius <remigijus@jarmalavicius.lt>
# (c) 2013-2014

filename=$(dirname $0)"/.time-reports/`date '+%Y-%m'`.arff"
date=`date '+%Y-%m-%d'`

if [ -z "$2" ]
then
    counter=0
else
    counter=$2
fi

pomodoro_limit=25
if [ "$1" == "rest" ]
then
    pomodoro_limit=5
fi

while [ 1 ]
do
    limit=$pomodoro_limit
    summary="Podoro session"
    client=$(echo $1 | awk -F, '{print $1}')
    project=$(echo $1 | awk -F, '{print $2}')
    task=$(echo $1 | awk -F, '{print $3}')
    startmessage="Concentrate on $project!"
    endmessage="Done with $project! Ready for a new one?"
    notify-send -u low -i /usr/share/icons/gnome/22x22/actions/appointment-new.png -t 3000 "$summary" "$startmessage"
    echo

    while [ $counter != $limit ]
    do
        clear
        echo "Concentrate on $1 for last $(($pomodoro_limit-$counter)) minutes!"
        echo
        if [ -e  "$filename" ]
        then
            echo "Today:"
            echo
            cat "$filename" | grep "$date" | awk -F, '{print $2}' | sort | uniq -c | \
                awk '{print "\t"+$1/2.0" h. "$2}' | \
                sed 's/^/\t/'
            echo
            echo "For a complete log see: $filename"
        fi
        echo
        echo -en "Progress:   "
        echo -en "┇"
        for i in $(seq 1 $counter)
        do
            echo -n "✖"
        done
        for i in $(seq 1 $(($limit-$counter)))
        do
            echo -n "·"
        done
        echo -n "┇   $counter out of $limit"
        echo
        sleep 60
        let "counter = $counter + 1"
    done

    if [ ! -f "$filename" ]
    then
        echo "@RELATION timesheet" >> "$filename"
        echo "@ATTRIBUTE date date \"yyyy-MM-dd\"" >> "$filename"
        echo "@ATTRIBUTE client string" >> "$filename"
        echo "@ATTRIBUTE project string" >> "$filename"
        echo "@ATTRIBUTE work string" >> "$filename"
        echo >> "$filename"
        echo "@DATA" >> "$filename"
    fi

    clients=$(cat $filename | awk -F, '{if (NR > 7) {print $2}}' | sort | uniq | xargs echo | sed 's/ /,/g')
    sed "s/@ATTRIBUTE client.*/@ATTRIBUTE client {$clients}/" -i "$filename"

    projects=$(cat $filename | awk -F, '{if (NR > 7) {print $3}}' | sort | uniq | xargs echo | sed 's/ /,/g')
    sed "s/@ATTRIBUTE project.*/@ATTRIBUTE project {$projects}/" -i "$filename"

    let "counter = 0"
    echo
    notify-send -u normal -i /usr/share/icons/gnome/22x22/actions/appointment-new.png "$summary" "$endmessage"
    echo "\"$date\",$client,$project,\"$task\"" >> "$filename"
    beep
done
