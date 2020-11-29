#ifndef M_JVM_H

#include <jni.h> 
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
	jlong 			m_return_long;
	jobject 		m_obj;
	long get_conflicts_java(int *arr,  int N);
	// init()
	int init_jvm();
	void release_jvm();
}; // end of Class m_JVM

#endif
