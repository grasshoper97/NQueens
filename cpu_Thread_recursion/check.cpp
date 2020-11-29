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

// int thread_func(int *arr, int N, int start, int end, int thres, int & sum)// 像普通函数一样用引用地址会报错, 原因不明，网上有相关的同样错误；
int thread_func(int *arr, int N, int start, int end, int thres, int *sum)
{
		//判断任务是否足够小
		if( end - start < thres )
		{
			// *sum = 0;
			//如果小于阈值，就进行运算
			for(int i=start; i<=end; i++)
				for(int j = i+1; j<N ; j++)  // 用到N，判断到达结尾
					if ( arr[i] == arr [j] || abs( arr [j] - arr [i] )==j-i)
						(*sum) ++;
						// *sum ++; // 结果要么是0 ，要么是随即数，原因是运行符优先级错误；
			// printf("[%d has %d conflicts]\n", start, *sum);
		}
		else // 还需要继续分解
		{
			//如果大于阈值，就再进行任务拆分
			int middle 	= (start + end)/2;
			//执行子任务
			std::thread t1, t2;
			int left 	= 0; 
			int right	= 0;
			t1 = thread( thread_func, arr, N, start,    middle, thres,  &left );
			t2 = thread( thread_func, arr, N, middle+1, end,    thres,  &right);
			//等待子任务执行完，并得到执行结果
			t1.join();
			t2.join();
			*sum = left+ right;
			// printf("-----[( %d  -  %d ) has %d conflicts]\n", start,end,  *sum);
		}
		return *sum;
	}

void showArr(int * a, int N)
{
	for(int i=0; i< N; i++)
		printf("%3d ", a[i]);
	printf("\n ");
}

int main(int argc, const char *argv[]) 
{

	string filename;  		// 数据文件名
	int    loops;
	int    threshold;
	if(argc==4){
		filename     = argv[1];
		loops        = atoi(argv[2]);
		threshold	 = atoi(argv[3]);
		// printf("from file: %s  read %d rows. \n", filename, ROWS_TO_READ);
		cout << "from file: " << filename << " read " << ROWS_TO_READ << " lines, use "
			<< threshold <<" threshold, loops = "<< loops << endl;
	}                                              
	else{
		printf("usage:  check filename threshold loops\n"); 
		printf("e.g. :  check 4.txt 2 10\n"); 
		exit(0);
    }
	//利用ifstream类的构造函数创建一个文件输入流对象
	int ** a =new int*[MAX_ROW]; 	 // Dim 2
	int * len_arr=new int[MAX_ROW]; 	 // Dim 1
	int * conflicts_arr=new int[MAX_ROW]; 	 // Dim 1
	int rows_already_read=0;

	std::chrono::time_point<std::chrono::system_clock> c11_start, c11_end;
	int milli_seconds=0,  micro_seconds = 0;
	
	ifstream fin( filename );   // open argv[1]   

	if ( ! fin)
	{
		cout << "文件不能打开" <<endl;
		exit(0);
	}
	string s_Queen, s_conflicts;
	for(int i=0; i<ROWS_TO_READ; i++){
		rows_already_read++;
		int N ;
		fin >> len_arr[i];  N = len_arr[i];
		fin >> s_Queen; //just for string "Queen"
		fin >> conflicts_arr[i];
		fin >> s_conflicts; //just for string "conflicts_arr"
		a[i]=new int[N];
		for(int k=0; k<N ; k++)
			fin >> a[i][k];
	}
	fin.close();  // 关闭文件输入流      

	printf("%10s\t%10s\t%10s%10s\n","Queen","conflicts_arr","time(ms)","time(us)");                                                                          
	printf("%10s\t%10s\t%10s%10s\n","-----","---------","--------","--------");
	float sum_ms = 0;
	float sum_us = 0;
	for(int lo=0 ; lo < loops ; lo++){
		//printf("a[%3d].length=%d\n",i,  len_arr[i]);
		//showArr(a[i], len_arr[i]);
		c11_start =std::chrono::system_clock::now();

		// int conflict = get_conflicts_cpu(a[0], len_arr[0]);
		// int conflict = get_conflicts_Thread(a[0], len_arr[0], thread_num );
		int conflict = 0;
		std::thread t = thread ( thread_func, a[0], len_arr[0], 0, len_arr[0]-1, threshold , &conflict);
		t.join();

		c11_end = std::chrono::system_clock::now();
		milli_seconds = std::chrono::duration_cast<std::chrono::milliseconds>(c11_end-c11_start).count();
		micro_seconds = std::chrono::duration_cast<std::chrono::microseconds>(c11_end-c11_start).count();
		printf(	"\e[1;31;40m %10d\t%10d\t%10d\t%10d\t\n\e[0m", len_arr[0], conflict, milli_seconds, micro_seconds);
		if( conflicts_arr[0] != conflict )
			printf(" %d != %d  =======================    ERROR================================\n", conflicts_arr[0] , conflict  );
		sum_ms += milli_seconds;
		sum_us += micro_seconds;
	}
	printf(	"AVER  %10d\t%10f\t%10f\n", len_arr[0], sum_ms/loops, sum_us/loops);


	// release memory
	for(int i=0 ;i<rows_already_read; i++){
		delete [] a[i];   // release Dim 2
	}
	delete [] a; // release Dim 1
	delete [] len_arr;
	delete [] conflicts_arr;

}
