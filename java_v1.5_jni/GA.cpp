#include "GA.h"
#include <vector>
using namespace std;
GA::GA(int n , m_JVM * a)
{
	N = n;
	jvm = a;
}
void GA::run()
{
	for(int k = 0 ;k< 1000; k++)
	{
		vector < int > b ;
		for(int i =0 ; i<N  ; i++)
			b.push_back(i);
		int x = func( &(b[0]));
		printf("k=%d,  x=%d\n", k, x);
	}
}
int  GA::func (int * arr)
{
	return   jvm->get_conflicts_fork_join( arr , N );  
}

