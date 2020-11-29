#1h - 9h
for N in `seq 100 100 900`
do
	java Caculator $N
done
#1k - 9k
for N in `seq 1000 1000 9000`
do
	java Caculator $N
done
#1w-9w
for N in `seq 10000 10000 90000`
do
	java Caculator $N
done
#10w-100w
for N in `seq 100000 100000 1000000`
do
	java Caculator $N
done
