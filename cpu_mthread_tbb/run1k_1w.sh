#!/bin/bash

txtdir=txt_mthread_
# population=1000
echo $txtdir
mkdir  $txtdir

for n in `seq 1000 1000 10000`
do
	echo "Queens  =${n}"
	date >> ./$txtdir/${n}.txt
	./check ../data_format2_rand/$n.txt  1 20  >> ./$txtdir/${n}.txt 
done

