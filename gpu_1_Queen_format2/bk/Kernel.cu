// 2018.11.10   // very slow average 200s
// every thread check for a Queen. not a pair[]
// 2018.12.29 
//copy form CheckOne_Datafile_compare/gpu_1_Queen
#include "Kernel.h"
//#define DEBUG 
#define BLOCK_SIZE 512 

//----------------------------Kernel----------------------------------------
__global__ void Ker_Warm(){
	// empty body, just warmup GPU;
	if(threadIdx.x == 0 )
		printf("GPU is OK!\n");
}

__global__ void Ker_Check_Combination (
		int *d_combination,			// 
		int combination_size,		// length of combinations =queen number =N
		unsigned int *d_result				// return conflicts count.
		)
{
	const int tid = blockDim.x * blockIdx.x + threadIdx.x;   	// use shared mem,so must be in a Block, need not global thread No.
	//printf("block =%d, thread=%d, tid=%d\n",blockIdx.x, threadIdx.x ,tid);
	if(tid >= combination_size)   
		return;
	if(tid==0)
		d_result[0]=0;


	int curX=tid;
	int curY=d_combination[tid];
	//check every queen after cur;
	for(int iX=tid+1 ; iX <= combination_size-1 ; iX++){
		int iY=d_combination[iX];
		if(iY == curY || iX+iY == curX+ curY  ||  iY -iX == curY - curX) { // not a	Permutations, it is random numbers. 
			//printf("-------->>> (%5d,%5d) (%5d,%5d) thread:%5d  \n ", curX,curY,iX,iY,tid);
			atomicAdd ((unsigned int *)&d_result[0],1);
			// break;   // get all conflicts
		}
	}

}// end of Kernel


//----------------------------CPU Interface----------------------------------------
void setDevice(int i)
{
	checkCudaErrors( cudaSetDevice( i )  );    
}
int  getDevice()
{
	int id=-1;
	checkCudaErrors( cudaGetDevice( &id )  );    
	return id;
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
	//checkCudaErrors(  cudaDeviceSynchronize()  );

	cudaEventRecord(stop, 0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&cuda_time, start, stop);
	#ifdef DEBUG
	printf("%-40s %f ms \n","warmup() run time=",cuda_time);
	#endif
}


unsigned int get_conflicts(int * combination, int combination_size)
{
	// 预热GPU
	//warmup<<<1, 1>>>();
	// Create input data
	int *h_combination = 0;  //store a number in [1~N]
	int *d_combination = 0;
	unsigned int * h_result = 0;
	unsigned int * d_result = 0;
	// timer 
	//std::chrono::time_point<std::chrono::system_clock> c11_start, c11_end;
	//cudaEvent_t start, stop;
	//cudaEventCreate(&start);
	//cudaEventCreate(&stop);
	//float cuda_time=0;
	//int cpu_time=0; 
	//cuda status var;
	cudaError_t cuda_err; 
	// Allocate CPU memory and initialize data.

	// init h_combination & timer.
	//c11_start =std::chrono::system_clock::now();
	//h_combination   =(int *)malloc(combination_size   * sizeof(int));  // need not allocate & free memory
	h_result        =(unsigned int *)malloc(	1                * sizeof(unsigned int));

	if(h_result==NULL )
	{
		printf("malloc h_result  error \ni");
		exit(1);
	}

	h_combination= combination;

	cuda_err = cudaSuccess;
	//cudaEventRecord(start, 0);
	// allocate GPU mem
	checkCudaErrors(cudaMalloc((void **)&d_combination, combination_size * sizeof(int)));
	checkCudaErrors(cudaMalloc((void **)&d_result ,     1                * sizeof(int)));
	cuda_err = cudaGetLastError();    
	if (cuda_err != cudaSuccess) 
	{                      
		fprintf(stderr, "alloc d_combination error! (error code= %s)!\n", cudaGetErrorString(cuda_err));
		exit(EXIT_FAILURE);
	}  
	//else
	//	fprintf(stderr, "alloc d_combination  successed ! ( code= %s)!\n", cudaGetErrorString(cuda_err));
	//cudaEventRecord(stop, 0);
	//cudaEventSynchronize(stop);
	//cudaEventElapsedTime(&cuda_time, start, stop);
	//if(DEBUG) printf("%-40s %f ms \n","GPU mem allocate  time=",cuda_time);
	//************************************************************************************************************


	//combination  H->D	
	//cudaEventRecord(start, 0);
	checkCudaErrors(cudaMemcpy(d_combination, h_combination, combination_size * sizeof(int), cudaMemcpyHostToDevice));
	//cudaEventRecord(stop, 0);
	//cudaEventSynchronize(stop);
	//cudaEventElapsedTime(&cuda_time, start, stop);
	//if(DEBUG) printf("%-40s %f ms \n","combination[] tranfer time =", cuda_time);

	// Execute  & timer
	//cudaEventRecord(start, 0);
	Ker_Check_Combination<<<   ( combination_size + BLOCK_SIZE-1)/BLOCK_SIZE  ,  BLOCK_SIZE  >>>
			(d_combination ,combination_size ,  d_result);  

	cuda_err= cudaSuccess;
	cuda_err = cudaGetLastError();    
	if (cuda_err != cudaSuccess) 
	{   
	#ifdef DEBUG
		fprintf(stderr, "Failed to launch (error code= %s)!\n", cudaGetErrorString(cuda_err));
	#endif
		exit(EXIT_FAILURE);
	}  
	else
	#ifdef DEBUG
			fprintf(stderr, "launch successed! ( code= %s)!\n", cudaGetErrorString(cuda_err));
	#endif

	//checkCudaErrors(cudaDeviceSynchronize());

	//cudaEventRecord(stop, 0);
	//cudaEventSynchronize(stop);
	//cudaEventElapsedTime(&cuda_time, start, stop);
	//if(DEBUG) printf("%-40s %f ms \n","CUDA Kernel run time=",cuda_time);


	// D->H  and timer	
	h_result[0]=0;
	//cudaEventRecord(start, 0);
	checkCudaErrors(cudaMemcpy(h_result, d_result, 1 * sizeof(unsigned int), cudaMemcpyDeviceToHost));
	cuda_err = cudaSuccess;
	cuda_err = cudaGetLastError();    
	if (cuda_err != cudaSuccess) 
	{                      
	#ifdef DEBUG
		fprintf(stderr, "D->H error! (error code= %s)!\n", cudaGetErrorString(cuda_err));
	#endif
		exit(EXIT_FAILURE);
	}  
	#ifdef DEBUG
	else
			fprintf(stderr, "D->H successed ! ( code= %s)!\n", cudaGetErrorString(cuda_err));
	#endif
	//cudaEventRecord(stop, 0);
	//cudaEventSynchronize(stop);
	//cudaEventElapsedTime(&cuda_time, start, stop);
	//if(DEBUG) printf("%-40s %f ms \n","CUDA D->H time =  ", cuda_time);

			//printf("testORI Kernel OK!  result= %d \n",h_result[0]);
	unsigned int conflicts = h_result[0];
	//************************************************************************************************************

	//free memory
	//cudaEventDestroy(start);
	//cudaEventDestroy(stop);
	// free(h_combination); //it is a pointer point to static array a[][], need not to free;
	free(h_result);
	checkCudaErrors( cudaFree(d_combination) );
	checkCudaErrors( cudaFree(d_result)      );
	checkCudaErrors( cudaDeviceSynchronize() );
	//checkCudaErrors(  cudaDeviceReset()     );
	return  conflicts;
}
