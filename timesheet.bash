#!/bin/bash
#
# Pomodoro timesheet script
#
# Remigijus Jarmalavičius <remigijus@jarmalavicius.lt>
# (c) 2013-2014

filename=$(dirname $0)"/.time-reports/`date '+%Y-%m'`.arff"

cat $filename | awk -F, '
{
    if ($2 == "'$1'") {
        data[$1][NR] = $4;
    }
}
END{
    for (date in data) {
        tmp_date = date;
        gsub("\"", "", tmp_date);
        print tmp_date;
        for (x in data[date]) {
            tmp_desc = data[date][x];
            gsub("\"", "", tmp_desc);
            print "  " tmp_desc;
        }
        print ""
    }
}
'
