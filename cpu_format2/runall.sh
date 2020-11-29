out=out.txt
#100
for N in `seq 100 100 900`
do
	./check ../data_format2_rand/$N.txt  1  |grep "TIME" >>$out
done

#1k
for N in `seq 1000 1000 9000`
do
	./check ../data_format2_rand/$N.txt  1  |grep "TIME" >>$out
done

#1w
for N in `seq 10000 10000 90000`
do
	./check ../data_format2_rand/$N.txt  1  |grep "TIME" >>$out
done

#10w
for N in `seq 100000 100000 1000000`
do
	./check ../data_format2_rand/$N.txt  1 |grep "TIME" >>$out
done
