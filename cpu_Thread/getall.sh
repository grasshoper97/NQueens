file=all
# for threads in 10 30 50 60 70 80 
for ((threads = 90; threads <= 160 ; threads +=10 ))
do
	dir=rand_thread_$threads
	echo " ============ $dir ==========="
	cat $dir/all.txt | grep AVER | tee $dir/tmp.txt
done
