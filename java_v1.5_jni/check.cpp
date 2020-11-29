// #include "m_JVM.h" // 加上此行后出现 m_JVM 重复定义错误
#include "GA.h"

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

	std::chrono::time_point<std::chrono::system_clock> c11_start, c11_end;
	int milli_seconds=0,  micro_seconds = 0;

	printf("%10s\t%10s\t%10s%10s\n","Queen","conflicts","time(ms)","time(us)");                                                                          
	printf("%10s\t%10s\t%10s%10s\n","-----","---------","--------","--------");

	m_JVM*  m_jvm = new m_JVM();
	m_jvm->init_jvm();

	GA queen( 100, m_jvm);

	queen.run();

	m_jvm->release_jvm();
	delete m_jvm ;

}
