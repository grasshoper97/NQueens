#include <stdio.h>
#include<chrono>
#include<iostream>
using namespace std;
#define jend (N-1)
int main(int argc, char** argv){
	int N;
	unsigned long long int x;
	int show_flag;
	if(argc>=4){
		N=atoi( argv[1] );
		x=atoll( argv[2] );
		show_flag=atoi( argv[3] );
		printf("N\t\tx\t\tflag\n");
		printf("%d\t\t%lld\t\t%d\n", N,x,show_flag);
	}
	else{ 
		printf("need N , x, show_flag \n");
		printf("e.g. a.out 10 40 1\n");
		exit(0);
	}

	//----------------out put all pairs------------------------
	if(show_flag==1){  // flag==1  , show all pairs.
		int count=0;
		for(int i =0 ; i <= N-2; i ++ ){ // N-1 round totally
			for(int j = i+1 ; j<=jend; j++)
				printf(" \033[1;40;31m %3d\033[0m(%2d,%2d) ",++count, i,j );
			printf("\n" );
		}
	}
	//----------------get x-th pair ------------------------
	printf("N=%2d, x=%lld\n ",N,x );
	int PairNumOfCurRound=N-1;
	for(int i =0 ; i <= N-2; i ++ ){ // N-1 round totally , 
		unsigned long long int subx=x-PairNumOfCurRound;
		if(subx <= 0){
			printf("\033[1;40;32m  (%d,%lld)\n  \033[0m",i, i+x );
			break;
		}
		PairNumOfCurRound--;
		x=subx;
	}
}
