/*
 * 2019.12.31
 * 1.使用 Thread 多线程， 修改makefile 加 -lpthread
 * 2.rows_to_read 修改为常量
 * 3.增加 loops 测试次数，求平均运行时间
 */
#include <stdio.h>
#include <thread>
#include <algorithm>
#include <string>
#include <fstream>
#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <ctime>
#include <chrono>
#define MAX_ROW  1000
#define	ROWS_TO_READ 1  
using namespace std;

int  max_depth = 0;
// int thread_func(int *arr, int N, int start, int end, int thres, int & sum)// 像普通函数一样用引用地址会报错
int thread_func(int start, int end, int *sum, int depth)
{
		int my_dep = depth +1 ;
		if (my_dep > max_depth)
			max_depth = my_dep; 
		//判断任务是否足够小
		if( end - start < 1 )
		{
			*sum += start ;
			printf("[%5d] = %5d ]\n", start, *sum);
		}
		else // 还需要继续分解
		{
			//如果大于阈值，就再进行任务拆分
			int middle 	= (start + end)/2;
			//执行子任务
			std::thread t1, t2;
			int left 	= 0; 
			int right	= 0;
			t1 = thread( thread_func,  start,    middle,   &left , my_dep);
			t2 = thread( thread_func,  middle+1, end,      &right, my_dep);
			//等待子任务执行完，并得到执行结果
			t1.join();
			t2.join();
			*sum = left+ right;
			printf("----------------------------[( %5d  -  %5d ) = %5d ]\n", start,end,  *sum);
		}
		return *sum;
}


int main(int argc, const char *argv[]) 
{

	int N = 0;
	if(argc==2){
		N= atoi(argv[1]);
		cout << "N = " << N << endl;
	}                                              
	else{
		printf("usage:  check N \n"); 
		printf("e.g. :  check 10\n"); 
		exit(0);
    }
		int result= 0;
		std::thread t = thread ( thread_func, 1, N , &result  ,  1);
		t.join();
		printf("\n=======================================================================\n");
		printf(" result= %d , max_dep = %d \n", result, max_depth);


}
