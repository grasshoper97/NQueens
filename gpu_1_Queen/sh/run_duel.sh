nohup ./gpucheck   ../100000.txt  1  0  &
nohup ./gpucheck2  ../100000.txt  1  1  &
# 三个进程使用同一个GPU，造成每个任务都要2000ms完成， 本来 1w，2w， 3w  需要 300、600、1100 ms. 说明任务互相干扰了。
