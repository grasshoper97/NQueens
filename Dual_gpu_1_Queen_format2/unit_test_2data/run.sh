#!/bin/bash
popu=200
outdir=popu_${popu}
mkdir $outdir

for n in `seq 1000 1000 10000`
do
	echo "GPU check Queens  =${n}"
	date >> ${outdir}/${n}.txt
	./gpucheck ${n}  $popu   >>  ${outdir}/${n}.txt 
done

