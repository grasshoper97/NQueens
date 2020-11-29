file=N_10w_thres_1_1_100.txt
date >> $file
p
for thres in `seq 2 1 100`
do
	echo $thres
	java CountTask  ../data_format2_rand/100000.txt  1  $thres  >>  $file
done
