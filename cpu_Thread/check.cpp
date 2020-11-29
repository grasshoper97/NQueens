/*
 * 2019.12.31
 * 1.使用 Thread 多线程， 修改makefile 加 -lpthread
 * 2.rows_to_read 修改为常量
 * 3.增加 loops 测试次数，求平均运行时间
 */
#include <stdio.h>
#include <numeric>
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

/*
 * 线程函数
 */
void* thread_func( int *a, int N, int thr_idx , int thr_num, int* b)
{
	b[ thr_idx ] = 0; // 线程计数器清零（可以优化掉）
	int tmp = 0;
	int loops = ( N + thr_num -1 ) / thr_num;
	for (int b = 0 ; b < loops ; b++){
		int i = thr_num * b + thr_idx ; // 如果 i 越界，j必定也越界，退出循环，不访问a[[
		for (int j = i + 1; j < N; ++j)
		{
			if (a[i] == a[j] || abs(a[i] - a[j]) == j - i) //lean: a[] may has same num.
				// b[ thr_idx ] ++;                 // 发现互相攻击的皇后对，线程自己的计数器+1；
				tmp ++;
		}//j
	}//b

	b[ thr_idx ] = tmp ;
	return 0 ;
}
/*
 * 多线程版的求冲突函数
 */
int get_conflicts_Thread(int *a,  int N,  int num )
{
	std::thread *thr_arr = new std::thread[ num ];
	int * b = new int[num]; // 每个线程对应一个计数器
	for(int i=0; i< num ;i++) {
		thr_arr[i]= thread( thread_func, a, N, i ,num ,b);
	}
	// 等待每个线程结束
	for(int i=0; i< num ;i++) 
		thr_arr[i].join();

	// for(int i=0; i< num ;i++) 
		// sum += b[i];  // 每个线程的冲突数求和
	// 从 b[0] 到 b[num-1] 求和
	// int sum = accumulate(b,  b + num, 0)；
	int sum = accumulate( b, b + num, 0); 

	delete [] thr_arr;
	delete [] b;

	return sum; 
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
	int    thread_num ; 
	if(argc==4){
		filename     = argv[1];
		loops        = atoi(argv[2]);
		thread_num   = atoi(argv[3]);
		// printf("from file: %s  read %d rows. \n", filename, ROWS_TO_READ);
		cout << "from file: " << filename << " read " << ROWS_TO_READ << " lines, use "
			<< thread_num <<" threads, loops = "<< loops << endl;
	}                                              
	else{
		printf("usage:  check filename threads loops\n"); 
		printf("e.g. :  check 4.txt 10\n"); 
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
	int N ;
	string s_Queen, s_conflicts;
	for(int i=0; i<ROWS_TO_READ; i++){
		rows_already_read++;
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
		int conflict = get_conflicts_Thread(a[0], len_arr[0], thread_num );

		c11_end = std::chrono::system_clock::now();
		milli_seconds = std::chrono::duration_cast<std::chrono::milliseconds>(c11_end-c11_start).count();
		micro_seconds = std::chrono::duration_cast<std::chrono::microseconds>(c11_end-c11_start).count();
		printf(	"\e[1;31;40m %10d\t%10d\t%10d\t%10d\t\n\e[0m", len_arr[0], conflict, milli_seconds, micro_seconds);
		if( conflicts_arr[0] != conflict )
			printf("======================================================ERROR================================\n");
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
