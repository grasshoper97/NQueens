date >> result/10w_100w.txt
for N in `seq 100000 100000 1000000`
do
	./gpu_pairs ../data_format1/$N.txt  1  >> result/10w_100w.txt
done
