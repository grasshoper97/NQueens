#include "m_JVM.h"
#include <jni.h> 
#include <unistd.h> 
#include <stdio.h>
#include <algorithm>
#include <string>
#include <fstream>
#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <ctime>
#include <chrono>

using namespace std;
void showArr(int * a, int N)
{
	for(int i=0; i< N; i++)
		printf("%3d ", a[i]);
	printf("\n ");
}

int main(int argc, const char *argv[]) 
{
	int N;
	int loop;
	if(argc>=3){
		N 	 = atoi( argv[1] );
		loop = atoi( argv[2] );
		printf("N=%d,  loop=%d\n", N, loop);
	}                                              
	else{
		printf("usage:  check N  loop\n"); 
		printf("e.g. :  check 100  5\n"); 
		exit(0);
    }

	std::chrono::time_point<std::chrono::system_clock> c11_start, c11_end;
	int milli_seconds=0,  micro_seconds = 0;
	

	m_JVM*  m_jvm = new m_JVM();
	m_jvm->init_jvm();

	int *queen = new int[N];
	for(int i = 0; i< N; i++)
		queen[i]= i;

	long sum = (long) N*(N-1)/2 ;

	for(int i=0 ;i<loop;  i++){
		c11_start =std::chrono::system_clock::now();
		long m_conflicts; 

		// m_conflicts = m_jvm->get_conflicts_java(a[i], len[i]);
		m_conflicts = m_jvm->get_conflicts_java( queen , N );

		printf("[%d] %d  sum= %ld ,  con=%ld \n", i ,  m_conflicts == sum,  sum , m_conflicts);


		c11_end = std::chrono::system_clock::now();
		milli_seconds = std::chrono::duration_cast<std::chrono::milliseconds>(c11_end-c11_start).count();
		micro_seconds = std::chrono::duration_cast<std::chrono::microseconds>(c11_end-c11_start).count();
		printf(	"\e[1;31;40m %10ld\t%10d\t%10d\t\n\e[0m",m_conflicts, milli_seconds, micro_seconds);
	}

	m_jvm->release_jvm();
	delete m_jvm ;

	// release memory
	delete [] queen; // release Dim 1

}
