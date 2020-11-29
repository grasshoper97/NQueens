#ifndef GA_H

#include "m_JVM.h"
class GA
{
	m_JVM * jvm;
	int N;
	public:
	GA(int n , m_JVM * a);
	void run();
	int func (int * arr);
};

#endif
