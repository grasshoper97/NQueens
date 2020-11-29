#奇葩的bug：
#如果 把  ${JMV_FLAG} 不是放在最末尾，而是放在 ${CFLAGS} 后面，则会出现 
# ---------------JNI_CreateJavaVM’未定义的引用-------------------
#  的编译错误，无法通过。简单的换个位置，就可以顺利编译成功了。
#
#

CC = g++
CFLAGS = -std=c++11 -g 
JVM_FLAG = -ljvm -L/usr/local/jdk1.8.0_161/jre/lib/amd64/server -L/usr/bin/java   -I/usr/local/jdk1.8.0_161/include  -I/usr/local/jdk1.8.0_161/include/linux

check : check.o  m_JVM.o GA.o
	${CC} ${CFLAGS}   check.o m_JVM.o  GA.o  -o check  ${JVM_FLAG}

m_JVM.o : m_JVM.cpp  m_JVM.h
	${CC} ${CFLAGS}  -c m_JVM.cpp -o m_JVM.o ${JVM_FLAG}

check.o : check.cpp m_JVM.h  GA.h
	${CC} ${CFLAGS}  -c check.cpp -o check.o 

GA.o:  GA.cpp GA.h
	${CC} ${CFLAGS}  -c GA.cpp -o GA.o 

clean:
	rm -rf *.o
	rm -rf check
