mkdir dir_$1
date >> dir_$1/4_100.txt
./$1 ../data_format1/4_100_step1.txt  97  |tee dir_$1/4_100.txt
