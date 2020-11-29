// 2018.12.3 add color output
// 2019.04.05  usage   
//"usage:  check filename row_to_be_read  device_id  replicate_of_line
// 2019.04.12  modify kernel.cu , use divice 0 and device 1 simulatiously.
#include "Kernel_p.h"
#include <stdio.h>
#include <string.h>
#include <string>
#include <fstream>
#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <ctime>
#include <chrono>
#define MAX_ROW  1000
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
	int    rows_to_read;   // 希望读入的行数, 完成读取后，=rows_already_read
	int    device;
	int    replication;
	if(argc==5){
		filename	 = argv[1];
		rows_to_read = atoi(argv[2]);
		device 	 	 = atoi(argv[3]);
		replication	 = atoi(argv[4]);
		printf("from file: %s  read %d rows. use Device 0 and 1 \n", filename.c_str() , rows_to_read );
	}                                              
	else{
		printf("usage:  check filename row_to_be_read  device_id  replicate_of_line\n"); 
		printf("e.g. :  check 4.txt 5  0 10\n"); 
		exit(0);
    }
	//利用ifstream类的构造函数创建一个文件输入流对象
	unsigned int ** a =new unsigned int*[MAX_ROW]; 	 // Dim 2
	unsigned int * len=new  unsigned int[MAX_ROW]; 	 // Dim 1
	unsigned int * conflicts=new unsigned int[MAX_ROW]; 	 // Dim 1
	int rows_already_read=0;

	std::chrono::time_point<std::chrono::system_clock> c11_start, c11_end;
	int milli_seconds=0, micro_seconds=0;  
	
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
		fin >> s_Queen; //just for seperate N and combination in txt file.
		fin >> conflicts[i];
		fin >> s_conflicts; //just for string "conflicts"
		a[i]=new unsigned int[N];
		for(int k=0; k<N ; k++)
			fin >> a[i][k];
	}
	fin.close();  // 关闭文件输入流      


	setDevice(0);
	warmGPU();
	printf( "Device in use =%d \n ", getDevice() );
	setDevice(1);
	warmGPU();
	printf( "Device in use =%d \n ", getDevice() );
	//warmGPU0_1(); // warm gpu 0 and 1 in diffirent stream;

	printf("\e[1;31;40m%10s\t%10s\t%10s\t%10s\n\e[0m","Queen","conflicts","time(ms)","time(us)");
	printf("%10s\t%10s\t%10s\n","-----","---------","--------");
	for(int i=0 ;i<rows_already_read; i++){
		//printf("a[%3d].length=%d\n",i,  len[i]);
		//showArr(a[i], len[i]);
		float sum_milli= 0 , sum_micro = 0;
		float  sum_conflicts = 0;
		for(int t =0; t<replication; t++){

			unsigned int * tmp = new unsigned int[ len[i]];
			memcpy(tmp, a[i], len[i]*sizeof(int) ); // to avoid auto optimaize by sys.
			// for(int x = 0; x<len[i]; x++)
				// tmp[x] = a[i][x];

			c11_start =std::chrono::system_clock::now();

			unsigned int   m_conflicts = get_conflicts( tmp, len[i]);

			c11_end = std::chrono::system_clock::now();
	
			delete []tmp;
			milli_seconds = std::chrono::duration_cast<std::chrono::milliseconds>(c11_end-c11_start).count();
			micro_seconds = std::chrono::duration_cast<std::chrono::microseconds>(c11_end-c11_start).count();
			printf(	"\e[1;31;40m[%2d]  %10d\t%10d\t%10d\t%10d\e[0m", t, len[i], m_conflicts, milli_seconds,micro_seconds);
			if(m_conflicts ==  conflicts[i] ) 
				printf("\tcpu == GPU0/1, Check Pass!\n");
			else
				printf("\tcpu != GPU0/1, Check False!\n");
			sum_milli += milli_seconds ;
			sum_micro += micro_seconds ;
			sum_conflicts = sum_conflicts + m_conflicts ;
		}
		printf(	"\e[1;31;40mAVER  %10d\t%10.2f\t%10.2f\t%10.2f\t\n\e[0m",len[i], sum_conflicts/replication , sum_milli/replication, sum_micro/replication);

	}
	// release memory
	for(int i=0 ;i<rows_already_read; i++){
		delete [] a[i];   // release Dim 2
	}
	delete [] a; // 
	delete [] len;
	delete [] conflicts;
}
