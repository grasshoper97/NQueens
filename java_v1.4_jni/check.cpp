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

	string filename;  		// 数据文件名
	int MAX_ROW =100;   // 最多可以读入有100行数据的文件
	int    rows_to_read;   // 希望读入的行数, 完成读取后，=rows_already_read
	if(argc>=3){
		filename=argv[1];
		rows_to_read =atoi(argv[2]);
		printf("from file: %s  read %d rows. \n", filename.c_str(), rows_to_read);
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

	printf("%10s\t%10s\t%10s%10s\n","Queen","conflicts","time(ms)","time(us)");                                                                          
	printf("%10s\t%10s\t%10s%10s\n","-----","---------","--------","--------");

	m_JVM m_jvm;
	m_jvm.init_jvm();

	for(int i=0 ;i<rows_already_read; i++){
		//printf("a[%3d].length=%d\n",i,  len[i]);
		//showArr(a[i], len[i]);
		c11_start =std::chrono::system_clock::now();
		
		int m_conflicts; 
		for(int k =0; k< 10 ; k++) {

			m_conflicts = m_jvm.get_conflicts_fork_join(a[i], len[i]);

			printf("k=%d ok  con=%d \n", k, m_conflicts);
			// sleep(3);
		}


		c11_end = std::chrono::system_clock::now();
		milli_seconds = std::chrono::duration_cast<std::chrono::milliseconds>(c11_end-c11_start).count();
		micro_seconds = std::chrono::duration_cast<std::chrono::microseconds>(c11_end-c11_start).count();
		printf(	"\e[1;31;40m %10d\t%10d\t%10d\t%10d\t%10d\t\n\e[0m", len[i], conflicts[i],m_conflicts, milli_seconds, micro_seconds);
	}

	m_jvm.release_jvm();

	// release memory
	for(int i=0 ;i<rows_already_read; i++){
		delete [] a[i];   // release Dim 2
	}
	delete [] a; // release Dim 1
	delete [] len;
	delete [] conflicts;

}
