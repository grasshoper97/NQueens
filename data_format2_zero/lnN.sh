#!/bin/bash
for N in   `seq  100 100 900  `
do
	echo "queen =${N}"
	ln -s /home/sx302/test/NQueen/cpu_min_conflict/min3_format2/format2_1_line_0_conflict/$N.txt  ./$N.txt
done
for N in   `seq  1000 1000 9000  `
do
	echo "queen =${N}"
	ln -s /home/sx302/test/NQueen/cpu_min_conflict/min3_format2/format2_1_line_0_conflict/$N.txt  ./$N.txt
done
for N in   `seq  10000 10000 90000  `
do
	echo "queen =${N}"
	ln -s /home/sx302/test/NQueen/cpu_min_conflict/min3_format2/format2_1_line_0_conflict/$N.txt  ./$N.txt
done
ls -l

