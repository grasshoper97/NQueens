date >> result/10w_100w_us.txt
for N in `seq 100000 100000 1000000`
do
		./gpucheck  ../data_format1/$N.txt  1  1  10 >> result/10w_100w_us.txt
done
