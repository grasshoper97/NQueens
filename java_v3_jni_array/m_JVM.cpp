#include "m_JVM.h"
#include <unistd.h> 
#include <stdio.h>
#include <chrono>
#include <iostream>
using namespace std;
/*
 *	input: array, array_sizei=queen_num
 */
long m_JVM::get_conflicts_java(int *arr,  int N)
{
	jintArray jarr = m_env->NewIntArray( N );						// C++ 数组转 Java数组
	m_env->SetIntArrayRegion(jarr, 0, N , arr);
	// m_return_long = m_env->CallIntMethod(  m_obj,  m_funcID,  jarr,  N , 2); 
	m_return_long =    m_env->CallStaticLongMethod( m_clazz, m_funcID, jarr, N, 40); 
	// std::cout << m_return_int << std::endl;
	return m_return_long;
}
// init()
int m_JVM::init_jvm()
{
	m_options[0].optionString =  (char*)"-Djava.compiler=NONE";
	m_options[1].optionString =  (char*)"-Djava.class.path=.";
	cout<<m_options[1].optionString<<endl;
	//m_options[2].optionString = "-verbose:jni"; 用于跟踪运行时的信息
	m_vm_args.version 	= JNI_VERSION_1_8; // JDK版本号
	m_vm_args.nOptions 	= 2;
	m_vm_args.options 	= m_options;
	m_vm_args.ignoreUnrecognized = JNI_TRUE;
	m_status = JNI_CreateJavaVM( &m_jvm, (void**)&m_env, &m_vm_args);  //构造虚拟机 m_env

	if(m_status != JNI_ERR){
		printf("[OK 1] create java m_jvm success\n");
		m_clazz = m_env->FindClass("Caculator");  // 在这里查找java类
		if(m_clazz !=0){
			printf("[OK 2] find java class success\n");
				/*
				 * public int get_conflicts(int[], int, int);
				 *     descriptor: ([III)I
				 */
			m_funcID = m_env->GetStaticMethodID( m_clazz, "caculate", "([III)J");
			// m_funcID = m_env->GetMethodID( m_clazz  , "get_conflicts", "([III)I"); //获取方法
			if(m_funcID !=0)
				printf( "[OK 3] find Func ok\n" );
			else{// func false
				printf( "[ERR 3] find Func error\n" );
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

void m_JVM::release_jvm()
{
	if(m_status != JNI_ERR)
		m_jvm->DestroyJavaVM();
	printf( "[OK 4] Java VM destory.\n");
}
