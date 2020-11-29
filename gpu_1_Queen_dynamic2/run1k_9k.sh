mkdir dir_$1
date >> dir_$1/1k_9k.txt
./$1 ../data_format1/1k_9k_step1k.txt  9  |tee dir_$1/1k_9k.txt
