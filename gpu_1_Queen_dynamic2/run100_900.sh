mkdir dir_$1
date >> dir_$1/100_900.txt
./$1 ../data_format1/100_900_step100.txt  9  |tee dir_$1/100_900.txt
