#!/bin/bash
# 某些配置事先知道不可能求出解，因此没有做，没有对应的数据文件，用 N 来表示
for n in `seq 2000 1000 10000`
do
	if [ ! -f ./popu_400_iter_262144/${n}.txt ];then
		echo -e "N\tN\tN\tN" |awk -v OFS='\t' 'BEGIN{ ORS="\t" } {print $3, $4}' 
	else
		tail  ./popu_400_iter_262144/${n}.txt       |grep "average"|awk -v OFS='\t' 'BEGIN{ ORS="\t" } {print $3, $4}' 
	fi

	if [ ! -f ./popu_400_iter_524288/${n}.txt ];then
		echo -e "N\tN\tN\tN" |awk -v OFS='\t' 'BEGIN{ ORS="\t" } {print $3, $4}' 
	else
		tail  ./popu_400_iter_524288/${n}.txt       |grep "average"|awk -v OFS='\t' 'BEGIN{ ORS="\t" } {print $3, $4}' 
	fi
	
	if [ ! -f ./popu_800_iter_524288/${n}.txt ];then
		echo -e "N\tN\tN\tN" |awk -v OFS='\t' 'BEGIN{ ORS="\t" } {print $3, $4}' 
	else
		tail  ./popu_800_iter_524288/${n}.txt       |grep "average"|awk -v OFS='\t' 'BEGIN{ ORS="\t" } {print $3, $4}' 
	fi

	if [ ! -f ./popu_800_iter_2097152/${n}.txt ];then
		echo -e "N\tN\tN\tN" |awk -v OFS='\t' 'BEGIN{ ORS="\n" } {print $3, $4}' 
	else
		tail  ./popu_800_iter_2097152/${n}.txt       |grep "average"|awk -v OFS='\t' 'BEGIN{ ORS="\n" } {print $3, $4}' 
	fi
done

