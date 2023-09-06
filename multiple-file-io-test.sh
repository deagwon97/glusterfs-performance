#!/bin/bash


test_io() {
    local vol=$1            # the path of test workspace in the volume
    local bs=$2             # block size nk, nM, nG ..
    local parallel_count=$3 # the number of parallel processes
    local copy_count=$4     # the number of copy input blocks

    # create io test workspace
    mkdir -p $vol
    # delete files in $vol
    rm -rf $vol/testfile*
    # delete old log files
    rm -rf ./log/log*

    # test io performance in parallel
    pids=()
    local i=1
    for (( i=1; i<=$parallel_count; i++ ))
    do
        rm -rf $vol/testfile$i
        dd if=/dev/zero of=$vol/testfile$i bs=$bs count=$copy_count  2>> ./log/log$i &
        pids+=($!)
    done

    # delete files in $vol
    rm -rf $vol/testfile*

    # waiting for pids
    for pid in ${pids[@]}
    do
        wait $pid
    done
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

    avg_bandwith=$(echo $sum_bandwith $length | awk '{printf "%4.3f\n",$1/$2}')
    avg_mb_bandwith=$(echo $avg_bandwith ${unit_map["MB/s"]} | awk '{printf "%4.3f\n",$1/$2}')

    echo "($avg_bandwith, $avg_mb_bandwith)"
}

echo_result(){
    local vol=$1
    local bs=$2
    local parallel_count=$3
    local copy_count=$4
    local avg_bandwith=$5
    local avg_mb_bandwith=$6
    echo "vol=$vol, bs=$bs, parallel_count=$parallel_count, copy_count=$copy_count, $avg_bandwith Bytes/s,  $avg_mb_bandwith MB/s"
}


test_single_bs(){
    local vol=$1
    local bs=$2
    local parallel_count=$3
    local copy_count=$4

    test_io $vol $bs $parallel_count $copy_count

    local bw_list=`calculate_io_bandwidth_average`
    local avg_bandwith=${bw_list[0]}
    local avg_mb_bandwith=${bw_list[1]}

    echo_result $vol $bs $parallel_count $copy_count $avg_bandwith $avg_mb_bandwith
}


test_multiple_bs(){
    local vol=$1
    local parallel_count=$2
    
    # test 1kBytes ~ 1MBytes
    local bs_k=1
    while [ $bs_k -le 1024 ]
    do 
        test_single_bs $vol ${bs_k}k $parallel_count 1 
        bs_k=$(($bs_k*2)) 
    done 
    # test 1MBytes ~ 512MBytes
    local bs_M=1
    while [ $bs_M -le 512 ]
    do 
        test_single_bs $vol ${bs_M}M $parallel_count 1 
        bs_M=$((bs_M*2))
    done 
}

vol=$1
parallel_count=$2
test_multiple_bs $vol $parallel_count