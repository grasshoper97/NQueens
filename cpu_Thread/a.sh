for ((threads = 10; threads <= 160 ; threads +=10 ))
do
	dir=rand_thread_$threads
	# sed -n "${line}p"  $dir/tmp.txt | tee one_dim.txt
	wc -l $dir/tmp.txt

	cat  $dir/tmp.txt
	
done
