#!/bin/bash
outdir=output
mkdir $outdir
file=compare1_2.txt
rm ${outdir}/$file
date >> ${outdir}/${file} 
for n in  `seq 10 10 100` 
do
	echo " 1gpu data ${n} M"
	./mgpu  1  ${n}  >> ${outdir}/${file} 
	echo " 2gpu data ${n} M"
	./mgpu  2  ${n}  >> ${outdir}/${file} 
done
