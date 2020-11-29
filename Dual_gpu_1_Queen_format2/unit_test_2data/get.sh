#!/bin/bash
if [ $# -eq 0 ];
then
    echo "./get.sh  dir"
    exit
fi

dir=`pwd`
cd $1
pwd
for n in `seq 1000 1000 10000`
do
	#echo "$n"
	#cat $n.txt |grep -E "GPU"
	#tail -n 3  $n.txt |grep -E "GPU" | awk '{print $2,$4,$6,$9,$11,$13}'
	tail -n 3  $n.txt |grep -E "GPU" | awk '{print $2, $4,$6,$8,$11,$13,$15}'
done
cd $dir 

