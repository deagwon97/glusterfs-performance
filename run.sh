#!/bin/bash

parallel_count=100
echo test parallel file io performance
echo set parallel count to $parallel_count

./multiple-file-io-test.sh /root/gluster/dt8 $parallel_count >> multiple-d8.log 
./multiple-file-io-test.sh /root/gluster/dt2dp4rd1 $parallel_count >> multiple-dt2dp4rd1.log 
./multiple-file-io-test.sh /root/gluster/dt2dp4rd1 $parallel_count >> multiple-dt2dp4rd1.log 
./multiple-file-io-test.sh /root/gluster/dp8rd2 $parallel_count >> multiple-dp8rd2.log 
./multiple-file-io-test.sh /root/gluster/dt4rp2 $parallel_count >> multiple-dt4rp2.log 
./multiple-file-io-test.sh /root/home/nfs $parallel_count >> multiple-nfs.log 

parallel_count=1
echo test single file io performance
echo set parallel count to $parallel_count

./multiple-file-io-test.sh /root/gluster/dt8 $parallel_count >> single-dt8.log 
./multiple-file-io-test.sh /root/gluster/dt2dp4rd1 $parallel_count >> single-dt2dp4rd1.log 
./multiple-file-io-test.sh /root/gluster/dt2dp4rd1 $parallel_count >> single-dt2dp4rd1.log 
./multiple-file-io-test.sh /root/gluster/dp8rd2 $parallel_count >> single-dp8rd2.log 
./multiple-file-io-test.sh /root/gluster/dt4rp2 $parallel_count >> single-dt4rp2.log 
./multiple-file-io-test.sh /root/nfs/nfs $parallel_count >> single-nfs.log 

echo 'create report.csv'
./report_logs > ./report.csv
