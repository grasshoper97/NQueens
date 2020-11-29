file=result/10w_100w_us_outfor.txt
date>>$file
for N in `seq 100000 100000 1000000`
do
	for i in `seq 1 1 20`
	do
		./gpucheck  ../data_format1/$N.txt  1  0  1 >> $file
	done
done
