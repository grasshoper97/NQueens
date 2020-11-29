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

	string 	filename;  		// 数据文件名
	int 	MAX_ROW =100;   // 最多可以读入有100行数据的文件
	int    	rows_to_read;   // 希望读入的行数, 完成读取后，=rows_already_read
	int  	loop;
	if(argc>=4){
		filename=argv[1];
		rows_to_read =atoi(argv[2]);
		loop =atoi(argv[3]);
		printf("from file: %s  read %d rows %d loops \n", filename.c_str(), rows_to_read  , loop);
	}                                              
	else{
		printf("usage:  check filename rowNumber\n"); 
		printf("e.g. :  check 4.txt 10\n"); 
		exit(0);
    }
	//利用ifstream类的构造函数创建一个文件输入流对象
	int ** a =new int*[MAX_ROW]; 	 // Dim 2
	int * len=new int[MAX_ROW]; 	 // Dim 1
	int * conflicts=new int[MAX_ROW]; 	 // Dim 1
	int rows_already_read=0;

	
	ifstream fin( filename );   // open argv[1]   

	if ( ! fin)
	{
		cout << "文件不能打开" <<endl;
		exit(0);
	}
	int N ;
	string s_Queen, s_conflicts;
	for(int i=0; i<rows_to_read; i++){
		rows_already_read++;
		fin >> len[i];  N = len[i];
		fin >> s_Queen; //just for string "Queen"
		fin >> conflicts[i];
		fin >> s_conflicts; //just for string "conflicts"
		a[i]=new int[N];
		for(int k=0; k<N ; k++)
			fin >> a[i][k];
	}
	fin.close();  // 关闭文件输入流      


	m_JVM*  m_jvm = new m_JVM();
	m_jvm->init_jvm();

	std::chrono::time_point<std::chrono::system_clock> c11_start, c11_end;
	int milli_seconds=0,  micro_seconds = 0;

	for(int i=0 ;i<rows_already_read; i++){
		//printf("a[%3d].length=%d\n",i,  len[i]);
		//showArr(a[i], len[i]);
		c11_start =std::chrono::system_clock::now();
		
		long m_conflicts; 

		// int queen[8] = {0,1,2,3,4,5,6,7};
		// int queen[8] = {0, 4, 7, 5, 2, 6, 1, 3};
		 // int queen[1000];
		 // for(int i = 0; i< 1000; i++)
			 // queen[i]= i;

		for(int k =0; k< loop ; k++) { // 运行到304 次循环，出现 jmv 内存耗尽，无法启动新线程异常！

			m_conflicts = m_jvm->get_conflicts_java(a[i], len[i]);
			 // m_conflicts = m_jvm->get_conflicts_java( queen , 1000 );

//			printf("k=%d ok  con=%ld \n", k, m_conflicts);
			// sleep(3);
		}


		c11_end = std::chrono::system_clock::now();
		milli_seconds = std::chrono::duration_cast<std::chrono::milliseconds>(c11_end-c11_start).count();
		micro_seconds = std::chrono::duration_cast<std::chrono::microseconds>(c11_end-c11_start).count();
		printf("AVER %10s\t%10s\t%10s%10s\n","Queen","conflicts","time(us)","time(ms)");
		printf("%10s%10s\t%10s\t%10s%10s\n","----","-----","---------","--------","--------");
		printf(	"aver %10d\t%10d\t%10ld\t%10f\t%10f\n",
				len[i], conflicts[i],  m_conflicts, 
				1.0 * micro_seconds/ loop, 
				1.0 * milli_seconds/ loop );
	}

	m_jvm->release_jvm();
	delete m_jvm ;

	// release memory
	for(int i=0 ;i<rows_already_read; i++){
		delete [] a[i];   // release Dim 2
	}
	delete [] a; // release Dim 1
	delete [] len;
	delete [] conflicts;

}
