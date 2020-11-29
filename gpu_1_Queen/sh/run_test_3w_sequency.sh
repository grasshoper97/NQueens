#  串行使用 gpu 1 ， 运行10次，检测 3w
for i in {0..9}
do
	echo "loop $i for 3w"
	 ./gpucheck  ../300000.txt  1  0  
done


