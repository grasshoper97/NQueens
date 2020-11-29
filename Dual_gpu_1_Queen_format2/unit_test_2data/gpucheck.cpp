// 2019.05.16 
// put 2 version(use 1 and 2 GK110) get_conflicts() in Kernel_p.h/cu,  and unit test
#include "Kernel_p2.h"
#include <stdio.h>
#include <string.h>
#include <random>
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

	int   queen_num ;
	int   popu_num;
	if(argc==3){
		queen_num = atoi(argv[1]);
		popu_num = atoi(argv[2]);
		printf("queens = %d , popu_num = %d \n" ,queen_num, popu_num);
	}                                              
	else{
		printf("usage:  check   queen_num     popu_num");
		exit(0);
	}

	setDevice(0);
	warmGPU();
	printf( "Device in use =%d \n ", getDevice() );
	setDevice(1);
	warmGPU();
	printf( "Device in use =%d \n ", getDevice() );

	vector<vector<unsigned> > m_population;
	vector<unsigned >       m_conflicts_1;      // 不是适应度，直接放入冲突数量
	vector<unsigned >       m_conflicts_2;      

	m_population.clear();
	m_conflicts_1.resize       (popu_num, 0);
	m_conflicts_2.resize       (popu_num, 0);

	std::chrono::time_point<std::chrono::system_clock> c11_start, c11_end;
	int s, ms, us;

	vector<unsigned> tmp(queen_num, 0);  // init with N*0;
	for (int  i = 0; i < popu_num; ++i)  // 初始种群
	{
		for (unsigned  j = 0; j < queen_num; ++j)     // put [0.. N-1] in tmp[]
			tmp[j] = j;
		// shuffer it with time-based random seed:
		unsigned seed = chrono::system_clock::now ().time_since_epoch ().count ();
		shuffle (tmp.begin (), tmp.end (), default_random_engine (seed));
		// add tmp to popu_num
		m_population.push_back(tmp);
	}

	c11_start =std::chrono::system_clock::now();
	//single GPU get fitness
	for (size_t i = 0; i < m_conflicts_1.size(); ++i)  // 初始种群
		m_conflicts_1[i] = get_conflicts( &(m_population[i][0]) , queen_num   ); 

	c11_end = std::chrono::system_clock::now();
	s  = std::chrono::duration_cast<std::chrono::seconds>(c11_end-c11_start).count();
	ms = std::chrono::duration_cast<std::chrono::milliseconds>(c11_end-c11_start).count();
	us = std::chrono::duration_cast<std::chrono::microseconds>(c11_end-c11_start).count();
	printf("N= %6d  1GPU: %d s %d ms  %d us \t", queen_num, s, ms ,us);

	c11_start =std::chrono::system_clock::now();
	//double GPU get fitness
	if(m_conflicts_2.size() % 2 != 0){
		printf(" chronosome size is odd ; can't parallel!\n");                                                                                           
		exit(0);
	}
	for( int i =0; i < m_conflicts_2.size(); i+=2)
		get_conflicts( &(m_population[i][0]), &(m_population[i+1][0]), queen_num,  &(m_conflicts_2[i]) , &(m_conflicts_2[i+1]) );
	c11_end = std::chrono::system_clock::now();
	s = std::chrono::duration_cast<std::chrono::seconds>(c11_end-c11_start).count();
	ms = std::chrono::duration_cast<std::chrono::milliseconds>(c11_end-c11_start).count();
	us = std::chrono::duration_cast<std::chrono::microseconds>(c11_end-c11_start).count();
	printf("2GPU:  %d s  %d ms  %d us\n", s, ms ,us);


	int wrong_fit_count=0;
	int right_fit_count=0;
	float sum_con=0;
	for (size_t i = 0; i < popu_num ; ++i){  // 初始种群
		sum_con += m_conflicts_1[i];
		if(m_conflicts_1[i]  == m_conflicts_2[i])
			right_fit_count ++;
		else
			wrong_fit_count ++;
	}

	printf("right count = %d, wrong count = %d,  aver conflicts= %f\n ", right_fit_count, wrong_fit_count, 1.0*sum_con/popu_num);
}

