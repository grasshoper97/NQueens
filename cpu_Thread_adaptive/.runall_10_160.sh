file=all
for ((threads = 1; threads <= 9 ; threads ++ ))
do
	dir=rand_thread_$threads
	mkdir $dir
	# clear file
	date > $dir/$file.txt
	for N in `seq 100 100 900`
	do
		echo $N
		./check  ../data_format2_rand/$N.txt  100  $threads >> $dir/$file.txt
	done
	for N in `seq 1000 1000 9000`
	do
		echo $N
		./check  ../data_format2_rand/$N.txt  100  $threads >> $dir/$file.txt
	done
	for N in `seq 10000 10000 90000`
	do
		echo $N
		./check  ../data_format2_rand/$N.txt  50  $threads >> $dir/$file.txt
	done
	for N in `seq 100000 100000 1000000`
	do
		echo $N
		./check  ../data_format2_rand/$N.txt  10 $threads >> $dir/$file.txt
	done
done
