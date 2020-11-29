file=all
dir=out
mkdir $dir
# clear file
date > $dir/$file.txt
for N in `seq 100 100 900`
do
	echo $N
	./a.out  $N  10  >> $dir/$file.txt
done
for N in `seq 1000 1000 9000`
do
	echo $N
	./a.out  $N  10  >> $dir/$file.txt
done
for N in `seq 10000 10000 90000`
do
	echo $N
	./a.out  $N  5  >> $dir/$file.txt
done
for N in `seq 100000 100000 1000000`
do
	echo $N
	./a.out  $N  3 >> $dir/$file.txt
done
