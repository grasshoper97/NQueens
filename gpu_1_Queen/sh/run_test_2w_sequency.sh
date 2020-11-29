#  串行使用 gpu 0 ， 运行10次，检测 1w
for i in {0..9}
do
	echo "loop $i for 2w"
	 ./gpucheck  ../200000.txt  1  1  
done


