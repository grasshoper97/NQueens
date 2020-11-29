file=all_adaptive
	# clear file
	date > $file.txt
	for N in `seq 100 100 900`
	do
		echo $N
		./check  ../data_format2_rand/$N.txt  10   >> $file.txt
	done
	for N in `seq 1000 1000 9000`
	do
		echo $N
		./check  ../data_format2_rand/$N.txt  10   >> $file.txt
	done
	for N in `seq 10000 10000 90000`
	do
		echo $N
		./check  ../data_format2_rand/$N.txt  5  >> $file.txt
	done
	for N in `seq 100000 100000 1000000`
	do
		echo $N
		./check  ../data_format2_rand/$N.txt  3  >> $file.txt
	done
