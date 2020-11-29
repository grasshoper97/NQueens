date >> result/all_us.txt
for N in `seq 100 100 900`
do
		./gpucheck  ../data_format1/$N.txt  1  1  10 >> result/all_us.txt
done
for N in `seq 1000 1000 9000`
do
		./gpucheck  ../data_format1/$N.txt  1  1  10 >> result/all_us.txt
done
for N in `seq 10000 10000 90000`
do
		./gpucheck  ../data_format1/$N.txt  1  1  10 >> result/all_us.txt
done
for N in `seq 100000 100000 1000000`
do
		./gpucheck  ../data_format1/$N.txt  1  1  10 >> result/all_us.txt
done
