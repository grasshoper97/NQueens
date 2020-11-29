file=all2019.06.14.txt
date >> $file
for N in `seq 100 100 900`
do
	./gpu_pairs ../data_format2_rand/$N.txt  1   0  100 >> $file
done
for N in `seq 1000 1000 9000`
do
	./gpu_pairs ../data_format2_rand/$N.txt  1   0  100  >> $file
done
for N in `seq 10000 10000 90000`
do
	./gpu_pairs ../data_format2_rand/$N.txt  1   0  100 >> $file
done
for N in `seq 100000 100000 1000000`
do
	./gpu_pairs ../data_format2_rand/$N.txt  1   0  100  >> $file
done
grep AVER $file
