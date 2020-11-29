/*
* 2018.12.3  
* add global vars d_pairs_i, d_pairs_j, pair_size 
* h_result/d_result/reaturn type change to unsigned int  
* 20:00
* generate pairs[] form cpu to GPU.
*/
#include "Kernel.h"
#define DEBUG 1
#define BLOCK_SIZE 512 


//..................................................................
__global__ void Ker_Warm(){
	// empty body, just Ker_Warm GPU;
	if(threadIdx.x == 0 )
		printf("GPU is OK!\n");
}

	
// tid : 1~ N(N-1)/2
__device__ void getPairs(
	int N, 						// Queen number;
	int pos, 	// position in pairs[];
	int *Xi, 					// return i;
	int *Xj)					// return j;
{

	int iRound=N-1;
	for(int i =0 ; i < N-1; i ++ ){ // N-1 round totally , 
		if(pos - iRound<= 0){
			//printf("\033[1;40;32m  (%d,%lld)\n  \033[0m",i, i+pos );
			*Xi=i;
			*Xj=i+pos;
			break;
		}
		pos -= iRound;
		iRound--;
	}
}

// tid : 0~ N(N-1)/2-1
__device__ void getPairs_4(
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

__global__ void Ker_Check_Combination (
		int *d_combination,		// a combination to be checkeda, store in d_com[1~N], d_com[0] is unused, for caculate gradient esaily.
		int combination_size,	// length of combinations =queen number =N
		unsigned long long int pairs_size,			// pair number , =N*(N-1)/2
		unsigned int *d_result
		)
{
	const int tid = blockDim.x * blockIdx.x + threadIdx.x;   	// tid is int , max is 2^31-1, K80 max thread number.
	//printf("block =%d, thread=%d, tid=%d\n",blockIdx.x, threadIdx.x ,tid);
	if(tid>=pairs_size)  // pairs_size = N*(N-1)/2.   tid in [0.. pairs_sizea] , tid +1 in [1.. pairs_size]
		return;


	// N*(N-1)/2 threads check pair
	int Xi;
	int Xj;
	/* getPairs( combination_size, tid+1, &Xi, &Xj);  // getPairs use [1.. pairs_size], tid start at 0. so tid+1 as no. */
	getPairs_4( combination_size, tid, &Xi, &Xj);  // getPairs use [1.. pairs_size], tid start at 0. so tid+1 as no.

	int Yi = d_combination[Xi];  // i,j in [1 ~~ N]
	int Yj = d_combination[Xj];
	if( Yi == Yj || Xi+Yi == Xj+Yj  ||  Yi -Xi == Yj - Xj) { //use +- instead of *,  can judge random sequence 
		//printf("-------->>> (%5d,%5d) (%5d,%5d) thread:%5d  \n ", Xj,Yj,Xi,Yi,tid);
		atomicAdd ((unsigned int *)&d_result[0],1);
		//printf("add 1: block =%d, thread=%d, tid=%d pair (%2d,%2d)\n",blockIdx.x, threadIdx.x ,tid, Xi, Xj);
	}


}// end of Kernel

//............................ cpu Interface......................................


void  warmGPU() 
{
	cudaError_t cuda_err; 
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	float cuda_time=0;

	cudaEventRecord(start, 0);
		Ker_Warm <<<1,1>>>	();

	cuda_err= cudaSuccess;
	cuda_err = cudaGetLastError();    
	if (cuda_err != cudaSuccess) 
	{   
		fprintf(stderr, "Failed to launch (error code= %s)!\n", cudaGetErrorString(cuda_err));
		exit(EXIT_FAILURE);
	}  
	else
	{	
	#ifdef DEBUG
	fprintf(stderr, "launch successed! ( code= %s)!\n", cudaGetErrorString(cuda_err));
	#endif
	}
	checkCudaErrors(cudaDeviceSynchronize());

	cudaEventRecord(stop, 0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&cuda_time, start, stop);
	#ifdef DEBUG
	printf("%-40s %f ms \n","Ker_Warm() run time=",cuda_time);
	#endif
}

unsigned int get_conflicts(int * combination, int combination_size)
{
	int *h_combination = 0;  //store a number in [1~N]
	int *d_combination = 0;
	unsigned int *h_result= 0;
	unsigned int *d_result= 0;  // for automic opration
	cudaError_t cuda_err; 
	h_result        =(unsigned int *)malloc(	1                * sizeof(unsigned int));

	if(  h_result==NULL )
	{
		printf("malloc h_result  error \ni");
		exit(1);
	}
	h_result[0]=0;
	h_combination= combination;
	int pairs_size= combination_size * ( combination_size -1) /2;

	cuda_err = cudaSuccess;
	// allocate GPU mem
	checkCudaErrors(cudaMalloc((void **)&d_combination, combination_size * sizeof(int)));  // if bigger than 4G, GPU memory alloc false;
	checkCudaErrors(cudaMalloc((void **)&d_result ,     1                * sizeof(unsigned int)));
	cuda_err = cudaGetLastError();    
	if (cuda_err != cudaSuccess) 
	{                      
		fprintf(stderr, "alloc d_combination error! (error code= %s)!\n", cudaGetErrorString(cuda_err));
		printf( "alloc d_combination error! (error code= %s)!\n", cudaGetErrorString(cuda_err));
		exit(EXIT_FAILURE);
	}  
	//combination  H->D	
	checkCudaErrors(cudaMemcpy(d_combination, h_combination , combination_size * sizeof(int), cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMemcpy(d_result		, h_result		, 1 			   * sizeof(unsigned int), cudaMemcpyHostToDevice)); 


	//call Kernel<<< >>>
	Ker_Check_Combination<<<   (pairs_size + BLOCK_SIZE-1)/BLOCK_SIZE ,  BLOCK_SIZE  >>>
				(d_combination ,combination_size  , pairs_size, d_result);  

	cuda_err= cudaSuccess;
	cuda_err = cudaGetLastError();    
	if (cuda_err != cudaSuccess) 
	{   
		if(DEBUG) fprintf(stderr, "Failed to launch (error code= %s)!\n", cudaGetErrorString(cuda_err));
		exit(EXIT_FAILURE);
	}  
	else
		if(DEBUG) fprintf(stderr, "launch successed! ( code= %s)!\n", cudaGetErrorString(cuda_err));


	// D->H  and timer	
	//cudaEventRecord(start, 0);
	checkCudaErrors(cudaMemcpy(h_result, d_result, 1 * sizeof(int), cudaMemcpyDeviceToHost)); // wait for Kernel finished.
	cuda_err = cudaSuccess;
	cuda_err = cudaGetLastError();    
	if (cuda_err != cudaSuccess) 
	{                      
		if(DEBUG) fprintf(stderr, "D->H error! (error code= %s)!\n", cudaGetErrorString(cuda_err));
		exit(EXIT_FAILURE);
	}  
	else
		if(DEBUG) fprintf(stderr, "D->H successed ! ( code= %s)!\n", cudaGetErrorString(cuda_err));
	unsigned int conflicts = h_result[0];
	//************************************************************************************************************

	//free memory
	free(h_result);
	checkCudaErrors(cudaFree(d_combination));
	checkCudaErrors(cudaFree(d_result));

	return  conflicts;
}
