N=10000
for i in `seq 1 1 100`
do
	./gpucheck ../data_format2_rand/$N.txt  1   0  1 
done
