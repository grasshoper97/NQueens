#!/bin/bash
# 64k  		128k  		256k   		512k	1M		2M		4M
# 65536 	131072		262144		524288  1048576 2097152	4194304
iter=2097152
popu=800
outdir=popu_${popu}_iter_${iter}
mkdir $outdir

for n in `seq 2000 1000 3000`
do
	echo "GPU check Queens  =${n}"
	date >> ${outdir}/${n}.txt
	./a.out ${n}  $popu  ${iter}  10 0  >>  ${outdir}/${n}.txt 
done

