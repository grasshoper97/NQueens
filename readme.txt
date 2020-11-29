 data_format1 :文件格式为  N值  “Queen”  解的排列
 data_format2 :文件格式为  N值  “Queen” Conflicts值  "Conflicts" 解的排列， 目前存放的文件都是仅有1行；

//----------------------------------------------------------------------------------------------------
cpu_mthread_tbb  	2019. 06. 10  使用TBB框架加速
效果很差，和单 CPU 性能几乎一样，甚至更差。

cpu_TBB_arr  ( 复制自~/testTBB/3_NQ_)
使用 parallel_reduce(), 获得极大的加速比
数据是一个全冲突数组

cpu_TBB_file  
真正使用了 rand 文件获得的数据

cpu_Thread/
使用类似 GPU block 分配任务的方式向 40 个线程分配自己负责的皇后。获得比 java Fork-Join 相似的加速比

cpu_Thread_recursion/
cpu_Thread_recursion_test/
在线程中递归创建线程，实现二分法（模仿java Fork-Join） 当N值较大（达到10000），线程数量会超过 100000( 每个皇后要一个线程，
一个父线程对两个线程合并结果) 会 core dump，而且core 文件很大，会占满整个磁盘，造成死机。 需要重启，然后删除 core。
做该实验时，要先 limit 0, 禁止 core 文件，避免死机。


//------------------------------v1 利用fork-join 框架并行----------------------------------------------------------------------
v1-v1.5 都存在循环调用300次后Java虚拟机出现内存耗尽出现异常。

纯java 读取文件，并计算冲突数
java_v1				 2019.06.23
Java Fork_join framework, 100w时得到 29倍加速比（40 cores）

C++ 调用 Java 类
java_v1.1_jni		2019.09.09
把 java 代码封装入 class 文件。 用 C++ 调用java，理论上效率和纯java相同。

java_v1.2_jni	2019.09.12
多次(10)调用 class 文件，模拟 GA 中频繁计算适应的的情况
1.第二次调用，创建虚拟机会失败
2.两次调用之间插入 sleep(5) 。 失败
解决办法： 整个过程分为 Init ， 调用函数，  releaseJVM  三个函数。  init、release在main中只用一次， 计算函数多次调用

java_v1.3_jni	2019.09.13
更改变量名


java_v1.4_jni	2019.09.13
封装到类中，放入 m_JVM.cpp  m_JVM.h  两个文件里， 编译出问题！
解决办法： makefile 里 调整动态库和头文件参数的顺序【？？？原因、原理待研究】

java_v1.4.1_jni	2019.09.13
类生成对象使用 new， 在堆里完成，用delete删除；
【重现异常！】// 运行到304 次循环，出现 jmv 内存耗尽，无法启动新线程异常！

java_v1.5_jni	2019.09.14
用向量当参数，替代int 数组
添加GA.h GA.cpp 完全模拟m_JVM 对象创建和指针传递过程。 
【重现异常！】// 运行到304 次循环，出现 jmv 内存耗尽，无法启动新线程异常！
结论： 指针传递没问题， 问题是 jvm 调用到 300 次后，会异常，返回的结果全是 0 。 猜猜是java虚拟机中内存耗尽，具体要再研究。

//------------------------------Java v2 手工调用线程----------------------------------------------------------------------
v2中使用精度为 ns 的函数来计时
v2
	第一步：每个线程负责一个 queen， 所以线程数量庞大, queen[N] 多线程并行计算到中间数组 result[N]中；
	第二部：result[N]串行到 sum 中
v2.1
	第二部也手工串行化：
	result[N] 到 sub_sum[CORES], 再串行到 sum中。
v2.2
	线程池技术，大大减少线程数量
v2.3s 
	把计算过程封装到一个静态方法里, 第二部分串行求和
v2.3p
	把计算过程封装到一个静态方法里，第二部分40个线程并行求和。性能没有提升，反而略微下降（100w个数据任务量太小了 ）
//------------------------------Java v3 --------------------------------------------------------------------
java_v3_jni_array
	线程池技术，串行最后求和，构造全冲突数组，并计算结果。验证通过
java_v3_jni_file
	线程池技术，串行最后求和，读取文件中随机数组内容

Hu_java 
	java_v3_jni 的算法，但是性能极差，原因？还是数组和向量吗？:wqa


cpu:
从指定文件中读取指定的行，放入动态生成的数组中，调用双重循环计算冲突个数，然后释放数组；

cpu_format2:
使用第二种格式

gpu_1_queen:
取数据过程和cpu版一样，计算冲突个数调用了 Kernel.h  Kernel.cu封装的 get_conflicts() GPU版函数。
2018.12.21  增加main() 参数，指定 gpu 设备
2019.04.05 add replication parameters to caculate average:
usage : gpucheck  file  lines  device  deplication

gpu_1_queen_format2:
读取第二种格式来检查冲突数量
2019.04.05 add replication parameters to caculate average:
usage : gpucheck  file  lines  device  deplication


gpu_pair_cpu_gen
更细粒度的GPU并行，pair数组由 CPU 产生， 传输到 GPU

gpu_pair_gpu_gen
为了避免传输，pair[]数组由 GPU本次用循环生成， 但是效果比较差，性能反而下降。


2019.4 15 
Dual_gpu_1_Queen_format2
直接定义两个流，不用 simpleMultiGPU 结构体，实现双GPU并行。
ok
ok2
cannot
