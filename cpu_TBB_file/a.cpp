/* 原文链接：https://blog.csdn.net/yuxing55555/article/details/81019555 */
#include"tbb/tbb.h"
#include <stdio.h>
#include <numeric>
#include <thread>
#include <algorithm>
#include <string>
#include <fstream>
#include <cstdio>
#include <cstdlib>
#include <ctime>
#include <math.h>
#include <chrono>
#include <iostream>
#define MAX_ROW  1000
#define	ROWS_TO_READ 1  
using namespace tbb;
using namespace std;

// // 串行
// int SerialTask( int a[], int n ) {
	// int sum = 0;
	// for( int i=0; i!=n; ++i )
		// sum += SubTask(a, n, i);
	// return sum;
// }

class MyClass {
	int* m_NQArr;
	int  m_N;// array length
	public:
	int m_sum;
	// constructor()
	MyClass(int NQArr[] ,int N) :
		m_NQArr  ( NQArr ), 
		m_N  ( N ), 
		m_sum( 0 )
	{ }
	// constructor with parameters
	MyClass( MyClass& x, split ) : 
		m_NQArr  ( x.m_NQArr ), 
		m_N  ( x.m_N ), 
		m_sum( 0      ) 
	{ }
	// sub task
	int SubTask( int i){
		int conflict = 0;
		for (int j = i + 1; j < m_N; ++j)
		{
			if (m_NQArr[i] == m_NQArr[j] || abs(m_NQArr[i] - m_NQArr[j]) == j - i ) 
				conflict++;                 // 发现互相攻击的皇后对，conflict加一
		}
		return conflict ; 
	}
	// calculator
	void operator()( const blocked_range<int>& r ) {
		// int *a   = m_NQArr;
		// int n    = m_N;
		// int sum  = m_sum;
		int end = r.end();
		for( int i = r.begin(); i != end; ++i ) // 对 range内的 a[i] 求和
			m_sum += SubTask( i);
			// m_sum += SubTask( m_NQArr, n, i);
		// m_sum = sum;
	}
	// join
	void join( const MyClass& y ) 
	{
		m_sum += y.m_sum;
	}

};
//并行
int Task( const int a[], int n ) {
	MyClass my_class( (int*)a , (int) n);
	tbb::parallel_reduce( blocked_range<int>(0,n), my_class );
	return my_class.m_sum;
}

int main(int argc, const char *argv[]) 
{

	string filename;  		// 数据文件名
	int    loops;
	// int    thread_num ; 
	if(argc==3){
		filename     = argv[1];
		loops        = atoi(argv[2]);
		// printf("from file: %s  read %d rows. \n", filename, ROWS_TO_READ);
		cout << "from file: " << filename << " read " << ROWS_TO_READ \
			<< " lines, loops = "<< loops << endl;
	}                                              
	else{
		printf("usage:  check filename  loops( read 1 line, use adaptive theads number)\n"); 
		printf("e.g. :  check 4.txt 10 \n"); 
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
		// thread_num =  get_best_thread_num(N);
		// printf("adaptive thread num=%d\n", thread_num);
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
		 int conflict = Task(a[0], len_arr[0]);

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
