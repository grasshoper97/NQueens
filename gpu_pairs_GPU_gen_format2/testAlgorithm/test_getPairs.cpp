#include<stdio.h>

  void getPairs(
	int N, 						// Queen number;
	long long int tid, 	// position in pairs[];
	int *Xi, 					// return i;
	int *Xj)					// return j;
{
	int PairNumOfCurRound=N-1;
	for(int i =0 ; i <= N-2; i ++ ){ // N-1 round totally , 
		unsigned long long int sub_tid = tid - PairNumOfCurRound;
		if(sub_tid <= 0){
			//printf("\033[1;40;32m  (%d,%lld)\n  \033[0m",i, i+tid );
			*Xi=i;
			*Xj=i+tid;
			break;
		}
		PairNumOfCurRound--;
		tid=sub_tid;
	}
	
}

  void getPairs_2(
	int N, 						// Queen number;
	long long int tid, 	// position in pairs[];
	int *Xi, 					// return i;
	int *Xj)					// return j;
{
	int PairNumOfCurRound=N-1;
	int begin =0;
	for(int i =0 ; i <= N-2; i ++ ){ // N-1 round totally , 
		tid -= PairNumOfCurRound;
		if(tid <= 0){
			//printf("\033[1;40;32m  (%d,%lld)\n  \033[0m",i, i+tid );
			*Xi=i;
			*Xj=i+tid+ PairNumOfCurRound;
			break;
		}
		PairNumOfCurRound--;
		begin++;
	}
}

void getPairs_3(
	int N, 						// Queen number;
	long long int tid, 	// position in pairs[];
	int *Xi, 					// return i;
	int *Xj)					// return j;
{

	int iRound=N-1;
	for(int i =0 ; i <= N-2; i ++ ){ // N-1 round totally , 
		if(tid - iRound<= 0){
			//printf("\033[1;40;32m  (%d,%lld)\n  \033[0m",i, i+tid );
			*Xi=i;
			*Xj=i+tid;
			break;
		}
		tid -= iRound;
		iRound--;
	}
}
// tid : 0~ N(N-1)/2-1
void getPairs_4(
	int N, 						// Queen number;
	long long int tid, 	// position in pairs[];
	int *Xi, 					// return i;
	int *Xj)					// return j;
{

	int NumofRound = N-1;
	for(int iRound =0 ; iRound < N-1; iRound ++ ){ // N-1 round totally , 
		if(tid - NumofRound< 0){
			*Xi=iRound;
			*Xj= tid +1 +iRound;
			break;
		}
		tid -= NumofRound;
		NumofRound--;
	}
}
 int main()
{
	int N=8;
	int Xi=0, Xj=0;
	int Xi2=0, Xj2=0;
	int Xi3=0, Xj3=0;
	int Xi4=0, Xj4=0;
	for(int tid=1 ;tid<=28 ;tid++){
		getPairs(N,tid, &Xi,&Xj);
		getPairs_2(N,tid, &Xi2,&Xj2);
		getPairs_3(N,tid, &Xi3,&Xj3);
		printf("{%2d}  [%2d, %2d][%2d,%2d][%2d,%2d]\n",tid, Xi,Xj,Xi2,Xj2, Xi3,Xj3 );
	}
	for(int tid=0 ;tid<28 ;tid++){
		getPairs_4(N,tid, &Xi4,&Xj4);
		printf("[%2d,%2d]  ", Xi4,Xj4);
	}


}
