#!/bin/bash
for N in   `seq  1000 1000 9000  `
do
	echo "queen =${N}"
	ln -s /home/sx302/test/NQueen/cpu_min_conflict/gen_format2_random_1_line/$N.txt   $N.txt
done
ls -l

