file=all
# step 1.  need run once.
# for ((threads = 1; threads <= 60 ; threads +=1 ))
# do
	# dir=rand_thread_$threads
	# echo " ============ $dir ==========="
	# # 抽取出37行AVER数据,对应 37 个 问题规模
	# cat $dir/all.txt | grep AVER | tee $dir/tmp.txt
# done

# step 2
# 100-100w,  37 lines
f_us=us.txt
f_ms=ms.txt
mv two_dim.txt two_dim.bk
for ((line = 1; line <= 37 ; line++ ))  
do
	# N of queens
	sed -n "${line}p"  rand_thread_10/tmp.txt | awk '{printf("%d\t", $2) }' >> $f_ms
	sed -n "${line}p"  rand_thread_10/tmp.txt | awk '{printf("%d\t", $2) }' >> $f_us
	echo " ============ $line ==========="
	# 每次循环增加一行，有 60 列
	for ((threads = 1; threads <= 60 ; threads +=1 ))
	do
		dir=rand_thread_$threads
		# sed -n "${line}p"  $dir/tmp.txt | tee one_dim.txt
		sed -n "${line}p"  $dir/tmp.txt | awk '{printf("%f\t", $3) }' >>  $f_ms
		sed -n "${line}p"  $dir/tmp.txt | awk '{printf("%f\t", $4) }' >>  $f_us
	done
	# awk '{printf("\n" ) }' >>two_dim.txt
	echo "" >> $f_ms
	echo "" >> $f_us
done
