#include <iostream>                // std::cout
#include <thread>                // std::thread
#include <mutex>                // std::mutex, std::unique_lock
#include <condition_variable>    // std::condition_variable
#include <stdio.h>
#include <string>
#include <fstream>
#include <cstdio>
#include <cstdlib>
#include <ctime>
#include <chrono>
#define MAX_ROW  1000
#define MAX_THREADS 100
using namespace std;

std::mutex mtx; // 全局互斥锁.
std::condition_variable cv; // 全局条件变量.
bool ready = false; // 全局标志位.

/*
*	input: array, array_sizei=queen_num
*/
int get_conflicts_cpu(int *a,  int N)
{
	int conflict = 0;
	for (int i = 0; i < N; ++i)
	{
		for (int j = i + 1; j < N; ++j)
		{
			if (a[i] == a[j] || abs(a[i] - a[j]) == j - i) //lean: a[] may has same num.
				conflict++;                 // 发现互相攻击的皇后对，conflict加一
		}
	}
	//printf("[%d]queen, conflict=%d   ", N, conflict);
	return conflict; 
}

void go()
{
	std::unique_lock <std::mutex> lck(mtx);
	ready = true; // 设置全局标志位为 true.
	cv.notify_all(); // 唤醒所有线程.
}

/*
 * 要求N必须是 cores的整倍数, 每个线程工作是全部工作的 1/cores 
 */
void  one_thread(int *a,  int N, int tid, int cores, int *result) 
{
	std::unique_lock <std::mutex> lck(mtx);
	while (!ready) // 如果标志位不为 true, 则等待...
		cv.wait(lck); // 当前线程被阻塞, 当主调函数把全局标志位变为 true 之后,统一开始执行
	// 线程被唤醒, 继续往下执行

	for (int i = tid; i < N; i+=cores)
	{
		for (int j = i + 1; j < N; ++j)
		{
			if (a[i] == a[j] || abs(a[i] - a[j]) == j - i) //lean: a[] may has same num.
				(*result) ++;                 // 发现互相攻击的皇后对，conflict加一
		}
	}
	//printf("[%d]queen, conflict=%d   ", N, conflict);
	// cout<<"tid= " << tid<<" thread_id "<< std::this_thread::get_id() << ",  result = "<< *result <<endl;
}
int get_conflicts_thread(int *a,  int N, int cores)
{
	int * result_core_i = new int[cores]; // array[] 保存每个线程的结果； 
	
	// for(int i =0; i<cores ;i++){
	 // std::thread t1( inc, &num1, 100);
	// }
	// int conflict = 0;
	// for(int i =0; i<cores ;i++){
	// }
	std::thread threads[MAX_THREADS]; //new 来产生线程数组失败，这里用静态大小数组
	// void  one_thread(int *a,  int N, int tid, int cores, int *result) 
	for (int i = 0; i < cores ; ++i){
		result_core_i[i]=0;
		threads[i] = std::thread( one_thread, a , N , i, cores, &(result_core_i[i] ) );
	}

	std::cout << cores<< " threads ready to race... "<< endl;
	go(); // go!

	/*
	 * for (auto & th:threads)
	 *     th.join();
	 */
	//等待全部线程结束
	for (int i = 0; i < cores ; ++i)
		threads[i].join();

	// 汇总每个线程的结果。
	int conflicts = 0;
	for(int i =0; i<cores ;i++){
		conflicts += result_core_i[i];
	}

	delete [] result_core_i;
	return conflicts;
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
	int    rows_to_read;   // 希望读入的行数, 完成读取后，=rows_already_read
	int cores;
	if(argc==4){
		filename=argv[1];
		rows_to_read =atoi(argv[2]);
		cores =atoi(argv[3]);
		printf("from file: %s  read %d rows.use %d cores \n", filename.data(), rows_to_read, cores);
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
	int elapsed_seconds;  
	
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
		a[i]=new int[N];
		for(int k=0; k<N ; k++)
			fin >> a[i][k];
	}
	fin.close();  // 关闭文件输入流      

	printf("%10s\t%10s\t%10s\t%10s\n","Type","Queen","conflicts","time(ms)");
	printf("%10s\t%10s\t%10s\t%10s\n","-----","-----","---------","--------");
	for(int i=0 ;i<rows_already_read; i++){
		//printf("a[%3d].length=%d\n",i,  len[i]);
		//showArr(a[i], len[i]);
		c11_start =std::chrono::system_clock::now();
		int conflicts = get_conflicts_cpu(a[i], len[i]);
		c11_end = std::chrono::system_clock::now();
		elapsed_seconds = std::chrono::duration_cast<std::chrono::milliseconds>(c11_end-c11_start).count();
		printf("%10s\t%10d\t%10d\t%10d\n","SingleCPU",len[i], conflicts, elapsed_seconds);

		c11_start =std::chrono::system_clock::now();
		conflicts = get_conflicts_thread(a[i], len[i], cores);
		c11_end = std::chrono::system_clock::now();
		elapsed_seconds = std::chrono::duration_cast<std::chrono::milliseconds>(c11_end-c11_start).count();
		printf("%10s\t%10d\t%10d\t%10d\n","MulThread",len[i], conflicts, elapsed_seconds);
	}
	// release memory
	for(int i=0 ;i<rows_already_read; i++){
		delete [] a[i];   // release Dim 2
	}
	delete [] a; // release Dim 1
	delete [] len;
	delete [] conflicts;

}
