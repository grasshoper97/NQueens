for N in `seq 400000 100000 1000000`
do
	nohup ./check  ../$N.txt  1  &
done
