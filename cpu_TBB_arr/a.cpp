/* 原文链接：https://blog.csdn.net/yuxing55555/article/details/81019555 */
#include"tbb/tbb.h"
#include <math.h>
#include <chrono>
#include <iostream>
using namespace tbb;
using namespace std;

int Foo(int * a, int n, int i){
	int conflict = 0;
	for (int j = i + 1; j < n; ++j)
	{
		if (a[i] == a[j] || abs(a[i] - a[j]) == abs(j - i) ) 
			conflict++;                 // 发现互相攻击的皇后对，conflict加一
	}
	return conflict ; 
}
// 串行
int SerialSumFoo( int a[], int n ) {
	int sum = 0;
	for( int i=0; i!=n; ++i )
		sum += Foo(a, n, i);
	return sum;
}

class SumFoo {
	int* my_a;
	int  my_n;// array length
	public:
	int my_sum;
	// constructor()
	SumFoo(int a[] ,int n) :
		my_a  ( a ), 
		my_n  ( n ), 
		my_sum( 0 )
	{ }
	// constructor with parameters
	SumFoo( SumFoo& x, split ) : 
		my_a  ( x.my_a ), 
		my_n  ( x.my_n ), 
		my_sum( 0      ) 
	{ }
	// calculator
	void operator()( const blocked_range<int>& r ) {
		int *a   = my_a;
		int n    = my_n;
		// int sum  = my_sum;
		int end = r.end();
		for( int i = r.begin(); i != end; ++i ) // 对 range内的 a[i] 求和
			my_sum += Foo(a, n, i);
		// my_sum = sum;
	}
	// join
	void join( const SumFoo& y ) 
	{
		my_sum += y.my_sum;
	}

};
//并行
int ParallelSumFoo( const int a[], int n ) {
	SumFoo sf( (int*)a , (int) n);
	parallel_reduce( blocked_range<int>(0,n), sf );
	return sf.my_sum;
}

int main(int argc, char *argv[])
{
	int N;
	int loop;
	if( argc == 3 ){
		N = atoi(argv[1]);	
		loop = atoi(argv[2]);	
	}
	else{ // has no extra parameters
		printf("2 extra parameters needed!\n");
		printf("./a.out  100 5\n" );
		return 0;
	}
	int *arr = new int[N];
	for(int i=0; i<N; i++){
		arr[i] = i;
	}
	// int N = 10;
	// int arr[10] = {0,1,2,3,4,5,6,7,8,9};


	// cout << "seri  :" <<  SerialSumFoo(arr,N)  << endl;
	// cout << "-----------------"<< endl;
	//
	std::chrono::time_point<std::chrono::system_clock> c11_start, c11_end;
	int time_ms=0,  time_us = 0;
	float sum_ms=0,  sum_us = 0;
	int con =0 ;
	//-------------------------------------------
	printf("%10s\t%10s\t%10s\t%10s\n", "  N  ", "loop", "time(ms)", "time(us)" );
	for(int i=0; i < loop; i++){

		c11_start =std::chrono::system_clock::now();

		con = ParallelSumFoo(arr,N); 

		c11_end = std::chrono::system_clock::now();
		time_ms = std::chrono::duration_cast<std::chrono::milliseconds>(c11_end-c11_start).count();
		time_us = std::chrono::duration_cast<std::chrono::microseconds>(c11_end-c11_start).count();

		sum_ms 	+= time_ms ;
		sum_us 	+= time_us ;

		printf("%10d\t%10d\t%10d\t%10d\n", N, i, time_ms, time_us  )  ;

	}// end of for 
	//-------------------------------------------
	printf("%10s\t%10s\t%10s\t%10s\n", "   N   " , "average", "  ms "     , " us" );
	printf("%10d\t%10s\t%10f\t%10f\n", 	   N     ,   "AVER" , sum_ms/loop , sum_us/loop );


	cout << "para  :" << con << endl; 
	delete [] arr;

}
