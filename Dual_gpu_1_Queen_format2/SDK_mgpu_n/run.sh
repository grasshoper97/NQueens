#!/bin/bash
outdir=output
mkdir $outdir
file=compare_100.txt
mv  ${outdir}/$file  ${outdir}/$file.bk
date >> ${outdir}/${file} 
for n in  `seq 100 100 1000` 
do
	echo " 1gpu data ${n} M"
	./mgpu  1  ${n}  >> ${outdir}/${file} 
	echo " 2gpu data ${n} M"
	./mgpu  2  ${n}  >> ${outdir}/${file} 
done
