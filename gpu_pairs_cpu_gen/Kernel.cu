/*
* 2018.12.3  
* add global vars d_pairs_i, d_pairs_j, pair_size 
* h_result/d_result/reaturn type change to unsigned int  
* 2018.12.4  assign d_result =0 use memcpy. not in Ker.
*/
#include "Kernel.h"
#define DEBUG 0
#define BLOCK_SIZE 512 

// global var;
int pairs_size=0;
int *d_pairs_i=0;
int *d_pairs_j=0;

//..................................................................
__global__ void Ker_Warm(){
	// empty body, just Ker_Warm GPU;
	if(threadIdx.x == 0 )
		printf("GPU is OK!\n");
}

__global__ void Ker_Check_Combination (
		int *d_combination,		// a combination to be checkeda, store in d_com[1~N], d_com[0] is unused, for caculate gradient esaily.
		int combination_size,	// length of combinations =queen number =N
		int *I, 				// pair X   , store in I[0 ~~ pairs_size-1]
		int *J,					// pari Y   , store in I[0 ~~ pairs_size-1]
		int pairs_size,			// pair number , =N*(N-1)/2
		unsigned int *d_result
		)
{
	const int tid = blockDim.x * blockIdx.x + threadIdx.x;   	// use shared mem,so must be in a Block, need not global thread No.
	//printf("block =%d, thread=%d, tid=%d\n",blockIdx.x, threadIdx.x ,tid);
	if(tid>=pairs_size)  // pairs_size = N*(N-1)/2
		return;


	// N*(N-1)/2 threads check pair
	int Xi=I[tid];   // tid in [0 ~~ pairs_size]
	int Xj=J[tid];   // I > J
	int Yi=d_combination[Xi];  // i,j in [1 ~~ N]
	int Yj=d_combination[Xj];
	if( Yi == Yj || Xi+Yi == Xj+Yj  ||  Yi -Xi == Yj - Xj) { //use +- instead of *,  can judge random sequence 
		//printf("-------->>> (%5d,%5d) (%5d,%5d) thread:%5d  \n ", Xj,Yj,Xi,Yi,tid);
		atomicAdd ((unsigned int *)&d_result[0],1);
		//printf("add 1: block =%d, thread=%d, tid=%d pair (%2d,%2d)\n",blockIdx.x, threadIdx.x ,tid, Xi, Xj);
	}


}// end of Kernel

//............................ cpu Interface......................................

void gen_pairs(int * h_pairs_i, int * h_pairs_j, int len, int n)
{
	int index=0; 
  //check every queen after current queen.
	for (int pi =0; pi <=n-2; pi++){         //generate check pairs   [ 1~N-1,   i+1~N ], store in h_pair[0~ len-1]
		for(int pj =pi+1 ; pj<=n-1 ; pj++){ 
			h_pairs_i[index]=pi; 
			h_pairs_j[index]=pj; 
			index++; 
		} 
	}//end  
	//if(index == len)
		//printf("index == len \n" );
}


// run only once, can be use multi times
void gen_transfer_pairs( int N)
{
	int *h_pairs_i=0; // after data trans to GPU, this memory is free.
	int *h_pairs_j=0;
	//N is combination_size;
	pairs_size=N*(N-1)/2;   //glabal vars
	h_pairs_i       =(int *)malloc(pairs_size         * sizeof(int));
	h_pairs_j       =(int *)malloc(pairs_size         * sizeof(int));
	if( h_pairs_i==NULL || h_pairs_j==NULL  )
	{
		printf("malloc h_pairs  error \n");
		exit(1);
	}
	// gen pairs[] in CPU
	gen_pairs(h_pairs_i, h_pairs_j, pairs_size, N);

	// alloc GPU mem
	cudaError_t cuda_err; 
	cuda_err = cudaSuccess;
	checkCudaErrors(cudaMalloc((void **)&d_pairs_i,     pairs_size       * sizeof(int)));
	checkCudaErrors(cudaMalloc((void **)&d_pairs_j,     pairs_size       * sizeof(int)));
	cuda_err = cudaGetLastError();    
	if (cuda_err != cudaSuccess) 
	{                      
		fprintf(stderr, "alloc d_pair[] error! (error code= %s)!\n", cudaGetErrorString(cuda_err));
		exit(EXIT_FAILURE);
	}  
	//else
		//fprintf(stderr, "alloc d_pair[] successed ! ( code= %s)!\n", cudaGetErrorString(cuda_err));
	
	//H to D
	checkCudaErrors(cudaMemcpy(d_pairs_i, h_pairs_i, pairs_size * sizeof(int), cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMemcpy(d_pairs_j, h_pairs_j, pairs_size * sizeof(int), cudaMemcpyHostToDevice));
	if (cuda_err != cudaSuccess) 
	{                      
		fprintf(stderr, "transfer  d_pair[] error! (error code= %s)!\n", cudaGetErrorString(cuda_err));
		exit(EXIT_FAILURE);
	}  
	//else
		//fprintf(stderr, "transfer d_pair[] successed ! ( code= %s)!\n", cudaGetErrorString(cuda_err));
	free(h_pairs_i);
	free(h_pairs_j);
}

void release_d_pairs()
{
	checkCudaErrors(cudaFree(d_pairs_i));
	checkCudaErrors(cudaFree(d_pairs_j));
}

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

	cuda_err = cudaSuccess;
	// allocate GPU mem
	checkCudaErrors(cudaMalloc((void **)&d_combination, combination_size * sizeof(int)));
	checkCudaErrors(cudaMalloc((void **)&d_result ,     1                * sizeof(unsigned int)));
	cuda_err = cudaGetLastError();    
	if (cuda_err != cudaSuccess) 
	{                      
		fprintf(stderr, "alloc d_combination error! (error code= %s)!\n", cudaGetErrorString(cuda_err));
		exit(EXIT_FAILURE);
	}  
	//combination  H->D	
	checkCudaErrors(cudaMemcpy(d_combination, h_combination, combination_size * sizeof(int), cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMemcpy(d_result		, h_result	   , 1				  * sizeof(unsigned int), cudaMemcpyHostToDevice));

	//set d_pairs[]
	gen_transfer_pairs( combination_size );

	//call Kernel<<< >>>
	Ker_Check_Combination<<<   (pairs_size + BLOCK_SIZE-1)/BLOCK_SIZE ,  BLOCK_SIZE  >>>
				(d_combination ,combination_size  ,d_pairs_i, d_pairs_j, pairs_size, d_result);  

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
	checkCudaErrors(cudaMemcpy(h_result, d_result, 1 * sizeof(unsigned int), cudaMemcpyDeviceToHost)); // wait for Kernel finished.
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
	release_d_pairs();

	return  conflicts;
}
