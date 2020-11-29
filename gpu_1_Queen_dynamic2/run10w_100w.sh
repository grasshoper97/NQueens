mkdir dir_$1
date >> dir_$1/10w_100w.txt
for N in `seq 100000 100000 1000000`
do
	./$1 ../data_format1/$N.txt  1  >> dir_$1/10w_100w.txt
done
