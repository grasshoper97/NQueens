2019. 4. 15 
test_multi_GPU/ 借鉴 simpleMultiGPU 的结构体，实现NQ的并行。

# 一个数组两个GPU处理两次；
cannot/
	无法并行,原因：h_combinaion, h_result 用 malloc()分配，不是页锁定内存

ok/
	h_combination 0/1, h_result 0/1  都用cudaMallocHost，页锁定内存

ok2/
	h_combination 直接使用参数数组，而非页锁定内存，经实验，数据传输和 kernel 也能并行。 , h_result 0/1 用cudaMallocHost，
# 同时传入两个数组	

2data
	仅仅用setDevice()切换GPU来并行不成功，修改get_conflicts（）同时传入两个数组，用传地址来返回两个结果，通过 setDevice()和流，以及页锁定内存，才能同时利用两个GPU
	Kernel_p.*  源文件
	/home/sx302/test/NQueen/Hu_Neng_Fa/DualGPU_multiStream_1.1  -->>

unit_test_2data
	对比逐个计算适应度和每次两个计算适应度的性能差别。结论：对N>5000， 双GPU才有优势。
	Kernel_p2.*  源文件
	/home/sx302/test/NQueen/Hu_Neng_Fa/DualGPU_multiStream_1.05  -->>

SDK_mgpu_n	
把SDK 多GPU例子参数化，并加入注释。
