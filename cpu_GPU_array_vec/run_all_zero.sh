file=all_zero.2019.04.05.txt
date >> $file
for N in `seq 100 100 900`
do
	./gpucheck ../data_format2_zero/$N.txt  1   0  100 >> $file
done
for N in `seq 1000 1000 9000`
do
	./gpucheck ../data_format2_zero/$N.txt  1   0  100  >> $file
done
for N in `seq 10000 10000 90000`
do
	./gpucheck ../data_format2_zero/$N.txt  1   0  100  >> $file
done
grep AVER $file
