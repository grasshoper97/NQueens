for N in `seq 100 100 1000`
do
		./check ../data_format2_zero/$N.txt  10  40 > zero_100.txt
		./check ../data_format2_rand/$N.txt  10  40 > rand_100.txt
done
