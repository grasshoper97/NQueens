file=zero.outfor.txt
date >> $file
for N in `seq 100 100 900`
do
	for i in `seq 1 1 20`
	do
		./gpucheck ../data_format2_zero/$N.txt  1   0  1 |grep AVER >> $file
	done
done

for N in `seq 1000 1000 9000`
do
	for i in `seq 1 1 20`
	do
		./gpucheck ../data_format2_zero/$N.txt  1   0  1  |grep AVER >> $file
	done
done
for N in `seq 10000 10000 90000`
do
	for i in `seq 1 1 20`
	do
		./gpucheck ../data_format2_zero/$N.txt  1   0  1 |grep AVER >> $file
	done
done
cat $file
