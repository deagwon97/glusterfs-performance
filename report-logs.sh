#!/bin/bash

report_logs(){
    local log_file_list=`ls | grep ".log"`
    local length=`echo $log_file_list | wc -w`

    echo 'logfile, volume_type, bs, bandwidth[Bytes/s]'
    for filename in $log_file_list
    do
        cat $filename | awk -F" |/|,|bs=" -v filename="$filename" '{gsub("\\(","",$0); print  filename", "$4", "$7", "$13}'
    done
}
report_logs