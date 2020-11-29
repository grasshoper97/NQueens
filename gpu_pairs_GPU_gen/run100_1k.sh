file=100_1k.txt
rm $file
for i in `seq 1 1 10`
do
./gpu_pairs ../data_format1/100_900_step100.txt  9  >>$file
./gpu_pairs  ../data_format1/1k_9k_step1k.txt  1  >>  $file
done
