#40w-100w
for N in `seq 400000 100000 1000000`
do
./check  ../data_format2_rand/$N.txt 1 3
done
