dir=zero
file=all_ms
thres=2
mkdir $dir
date >> $dir/$file.txt
for N in `seq 100 100 900`
do
		echo $N
		java CountTask  ../data_format2_rand/$N.txt  100  $thres >> $dir/$file.txt
done
for N in `seq 1000 1000 9000`
do
		echo $N
		java CountTask  ../data_format2_rand/$N.txt  100  $thres >> $dir/$file.txt
done
for N in `seq 10000 10000 90000`
do
		echo $N
		java CountTask  ../data_format2_rand/$N.txt  50  $thres >> $dir/$file.txt
done
for N in `seq 100000 100000 1000000`
do
		echo $N
		java CountTask  ../data_format2_rand/$N.txt  10 $thres >> $dir/$file.txt
done
