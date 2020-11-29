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
#define MAX_ROW  1000
using namespace std;

// 使用全局变量
JavaVMOption 	m_options[2];
JNIEnv *		m_env;
JavaVM *		m_jvm;
JavaVMInitArgs 	m_vm_args;
long 			m_status;
jclass 			m_clazz;
jmethodID 		m_funcID;
jint 			m_return_int;
jobject 		m_obj;
/*
*	input: array, array_sizei=queen_num
*/
int get_conflicts_fork_join(int *arr,  int N)
{
	jintArray jarr = m_env->NewIntArray( N );						// C++ 数组转 Java数组
	m_env->SetIntArrayRegion(jarr, 0, N , arr);
	m_return_int = m_env->CallIntMethod(  m_obj,  m_funcID,  jarr,  N , 2); 
	// std::cout << m_return_int << std::endl;
	return m_return_int;
}
// init()
int init_jvm()
{
	m_options[0].optionString =  (char*)"-Djava.compiler=NONE";
	m_options[1].optionString =  (char*)"-Djava.class.path=.";
	cout<<m_options[1].optionString<<endl;
	//m_options[2].optionString = "-verbose:jni"; 用于跟踪运行时的信息
	m_vm_args.version 	= JNI_VERSION_1_8; // JDK版本号
	m_vm_args.nOptions 	= 2;
	m_vm_args.options 	= m_options;
	m_vm_args.ignoreUnrecognized = JNI_TRUE;
	m_status = JNI_CreateJavaVM(&m_jvm, (void**)&m_env, &m_vm_args);  //构造虚拟机 m_env

	if(m_status != JNI_ERR){
		printf("[OK 1] create java m_jvm success\n");
		m_clazz = m_env->FindClass("Caculator");  // 在这里查找java类
		if(m_clazz !=0){
			printf("[OK 2] find java class success\n");
			m_obj =m_env-> AllocObject( m_clazz);     // 用无参数的构造方法，构造 Caculator 对象
			if( m_obj !=0 )
			{
				printf( "[OK 3] create java obj ok\n" );
				/*
				 * public int get_conflicts(int[], int, int);
				 *     descriptor: ([III)I
				 */
				m_funcID = m_env->GetMethodID( m_clazz  , "get_conflicts", "([III)I"); //获取方法
				if(m_funcID !=0)
					printf( "[OK 4] find Func ok\n" );
				else{// func false
					printf( "[ERR 4] find Func error\n" );
					return -4;
				}
			}else{ // obj false
				printf( "[ERR 3] create java obj failed\n" );
				return -3;
			}
		}else{//class false
			printf("[ERR 2] FindClass failed\n");
			return -2;  //class error
		}
	}else{//m_jvm false;
		printf("[ERR 1]create java m_jvm fail\n");
		return -1;	// m_jvm error;
	}
	return 0; // means m_jvm/class/func OK!
}

void release_jvm()
{
	if(m_status != JNI_ERR)
		m_jvm->DestroyJavaVM();
	printf( "[OK 5] Java VM destory.\n");
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

	init_jvm();

	for(int i=0 ;i<rows_already_read; i++){
		//printf("a[%3d].length=%d\n",i,  len[i]);
		//showArr(a[i], len[i]);
		c11_start =std::chrono::system_clock::now();
		
		int m_conflicts; 
		for(int k =0; k< 10 ; k++) {
			m_conflicts = get_conflicts_fork_join(a[i], len[i]);
			printf("k=%d ok  con=%d \n", k, m_conflicts);
			// sleep(3);
		}


		c11_end = std::chrono::system_clock::now();
		milli_seconds = std::chrono::duration_cast<std::chrono::milliseconds>(c11_end-c11_start).count();
		micro_seconds = std::chrono::duration_cast<std::chrono::microseconds>(c11_end-c11_start).count();
		printf(	"\e[1;31;40m %10d\t%10d\t%10d\t%10d\t%10d\t\n\e[0m", len[i], conflicts[i],m_conflicts, milli_seconds, micro_seconds);
	}
	release_jvm();
	// release memory
	for(int i=0 ;i<rows_already_read; i++){
		delete [] a[i];   // release Dim 2
	}
	delete [] a; // release Dim 1
	delete [] len;
	delete [] conflicts;

}
