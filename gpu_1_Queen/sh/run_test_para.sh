for i in {0..1}
do
	# 顺序调用
	#./gpucheck  ../300000.txt  1  0 
	# 后台完全并行，使用同一个 gpu 0， 结果任务会混合到一起，
	#nohup ./gpucheck  ../300000.txt  1  0  &
	# 后台完全并行，使用两个不同 gpu 0 1;
	 nohup ./gpucheck  ../300000.txt  1  ${i}  &

done

# 三个进程使用同一个GPU，造成每个任务都要2000ms完成， 本来 1w，2w， 3w  需要 300、600、1100 ms. 说明任务互相干扰了。
