#!/bin/bash


test_io() {

    local vol=$1
    local bs=$2
    local separately_count=$3

    # pids=()
    commands=()

    mkdir -p $vol

    rm -rf $vol/testfile*
    rm -rf ./log/log*

    PIPE=my_sync_pipe
    mkfifo $PIPE
    
    local i=1
    for (( i=1; i<=$separately_count; i++ ))
    do
        (
            read -r < $PIPE
            dd if=/dev/zero of=$vol/testfile$i bs=$bs count=1  2>> ./log/log$i
        ) &
    done

    for i in $(seq 1 $NUM_PROCESSES); do
        echo "Go" > $PIPE
    done

    wait
    rm $PIPE
    
    rm -rf $vol/testfile*
    return 0
}


calculate_io_bandwidth_average(){
    declare -A unit_map
    unit_map=(
    ["GB/s"]=$((1024 * 1024 * 1024))
    ["MB/s"]=$((1024 * 1024))
    ["kB/s"]=$((1024))
    )
    report=(`cat ./log/log* | grep copied | awk '{ print $8":"$9}'`)
    length=${#report[@]}
    sum_bandwith=0
    for line in ${report[@]}
    do
    value=`echo $line | awk -F":" '{print $1}'`
    unit=`echo $line | awk  -F":" '{print $2}'`
    
    bandwithd=$(echo $value ${unit_map[$unit]} | awk '{printf "%4.3f\n",$1*$2}')
    sum_bandwith="$( bc <<<"$sum_bandwith + $bandwithd" )"
    done

    avg_bandwidth=$(echo $sum_bandwith $length | awk '{printf "%4.3f\n",$1/$2}')
    sum_mb_bandwidth=$(echo $sum_bandwith ${unit_map["MB/s"]} | awk '{printf "%4.3f\n",$1/$2}')
    avg_mb_bandwidth=$(echo $avg_bandwidth ${unit_map["MB/s"]} | awk '{printf "%4.3f\n",$1/$2}')

    echo "$avg_bandwidth $avg_mb_bandwidth $sum_mb_bandwidth"
}

echo_result(){
    local vol=$1
    local bs=$2
    local separately_count=$3
    local avg_bandwidth=$4
    local avg_mb_bandwidth=$5
    local sum_mb_bandwidth=$6
    echo "vol=$vol, bs=$bs, separately_count=$separately_count, $avg_bandwidth Bytes/s, $avg_mb_bandwidth MB/s, $sum_mb_bandwidth MB/s"
}


test_single_bs(){
    local vol=$1
    local bs=$2
    local separately_count=$3

    test_io $vol $bs $separately_count
    local bw_list=`calculate_io_bandwidth_average`

    local avg_bandwidth=`echo $bw_list | awk -F" " '{print $1}'`
    local avg_mb_bandwidth=`echo $bw_list | awk  -F" " '{print $2}'`
    local sum_mb_bandwidth=`echo $bw_list | awk  -F" " '{print $3}'`

    echo_result $vol $bs $separately_count $avg_bandwidth $avg_mb_bandwidth $sum_mb_bandwidth
}


test_multiple_bs(){
    local vol=$1
    local separately_count=$2
    local i=1
    
     i=1; while [ $i -le 512 ]
        do 
            test_single_bs $vol ${i}k $separately_count
            i=$(($i*2)) 
        done 
     i=1; while [ $i -le 512 ]
         do 
             test_single_bs $vol ${i}M $separately_count
             i=$((i*2))
         done 
}


vol=$1
separately_count=$2
test_multiple_bs $vol $separately_count