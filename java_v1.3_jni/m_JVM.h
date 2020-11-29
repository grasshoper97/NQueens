#ifndef M_JVM_H

#include <jni.h> 
#include <unistd.h> 
#include <stdio.h>
#include <chrono>
#include <iostream>
using namespace std;
class m_JVM
{
	public :
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
	m_status = JNI_CreateJavaVM( &m_jvm, (void**)&m_env, &m_vm_args);  //构造虚拟机 m_env

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
}; // end of Class m_JVM

#endif
