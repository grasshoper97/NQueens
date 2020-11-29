mkdir dir_$1
date >> dir_$1/1w_9w.txt
./$1 ../data_format1/1w_9w_step1w.txt  9  |tee dir_$1/1w_9w.txt
