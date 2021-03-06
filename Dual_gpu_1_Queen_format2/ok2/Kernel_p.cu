// 2018.11.10   // very slow average 200s
// every thread check for a Queen. not a pair[]
// 2018.12.29 
//copy form CheckOne_Datafile_compare/gpu_1_Queen
#include "Kernel_p.h"
#define DEBUG 
#define BLOCK_SIZE 512 

//----------------------------Kernel----------------------------------------
__global__ void Ker_Warm(){
	// empty body, just warmup GPU;
	if(threadIdx.x == 0 )
		printf("GPU is OK!\n");
}

__global__ void Ker_Check_Combination3 (
		unsigned int *d_combination,			// 
		unsigned int combination_size,		// length of combinations =queen number =N
		unsigned int *d_result				// return conflicts count.
		)
{

	const int tid = blockDim.x * blockIdx.x + threadIdx.x;   	// use shared mem,so must be in a Block, need not global thread No.
	d_result[0] =0;
	if( tid == 0 ) {
		for(int i =0 ;i<combination_size ; i++){
			printf("%4d  ", d_combination[i]);
			d_result[0] += d_combination[i];
		}

		printf("\nsum = %8d \n ", d_result[0]);
	}
}

__global__ void Ker_Check_Combination (
		unsigned int *d_combination,			// 
		unsigned int combination_size,		// length of combinations =queen number =N
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
void  warmGPU()  // warm a single GPU
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
	fprintf(stderr, "Worm launch successed! ( code= %s)!\n", cudaGetErrorString(cuda_err));
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
void  warmGPU0_1()  // warm GPU 0 and 1 in diffirent streams// wrong??
{
	cudaError_t cuda_err; 
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	float cuda_time=0;
	cudaEventRecord(start, 0);

    cudaStream_t stream0;
    cudaStream_t stream1;

	checkCudaErrors(cudaSetDevice(0));
	checkCudaErrors(cudaStreamCreate(&stream0));
	Ker_Warm <<<1,1,0 , stream0>>>	();
	checkCudaErrors(cudaSetDevice(1));
	checkCudaErrors(cudaStreamCreate(&stream1));
	Ker_Warm <<<1,1,0 , stream1>>>	();

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
	fprintf(stderr, "Worm launch successed! ( code= %s)!\n", cudaGetErrorString(cuda_err));
	#endif
	}
	//checkCudaErrors(  cudaDeviceSynchronize()  );

	cudaEventRecord(stop, 0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&cuda_time, start, stop);
	#ifdef DEBUG
	printf("%-40s %f ms \n","warmup() run time=",cuda_time);
	#endif
	checkCudaErrors(cudaSetDevice(0));
	checkCudaErrors(cudaStreamDestroy(stream0));
	checkCudaErrors(cudaSetDevice(1));
	checkCudaErrors(cudaStreamDestroy(stream1));
}


unsigned int get_conflicts(unsigned int * combination, unsigned int combination_size)
{
	/* printf("\n----get_conflicts() begin! \n"); */
	/* unsigned int *h_combination0= 0; */
	/* unsigned int *h_combination1= 0; */

	unsigned int *h_combination= combination ; // 不是页锁定内存，是主程序直接传入的数组

	unsigned int *d_combination0= 0;
	unsigned int *d_combination1= 0;
	unsigned int * h_result0 = 0;
	unsigned int * h_result1 = 0;
	unsigned int * d_result0 = 0;
	unsigned int * d_result1 = 0;
	cudaError_t cuda_err; 
    cudaStream_t stream0;
    cudaStream_t stream1;

	//--------------cpu----------------------------------
    int  GPU_N;
    checkCudaErrors(cudaGetDeviceCount(&GPU_N));

	cuda_err = cudaSuccess;
	//---------------GPU0-----------------------------
	checkCudaErrors(cudaSetDevice(0));
	checkCudaErrors(cudaStreamCreate(&stream0));

	checkCudaErrors(cudaMalloc((void **)&d_combination0, combination_size * sizeof( unsigned int)));
	checkCudaErrors(cudaMalloc((void **)&d_result0 ,     1                * sizeof( unsigned int)));
	checkCudaErrors(cudaMallocHost((void **)&h_result0,  1 					   * sizeof(unsigned)));  // cudaMallocHost , not malloc()  
	/* memcpy( h_combination0,  combination , combination_size  * sizeof(unsigned));  */

	cuda_err = cudaGetLastError();    
	if (cuda_err != cudaSuccess) 
	{                      
		fprintf(stderr, "GPU 0 alloc d_combination error! (error code= %s)!\n", cudaGetErrorString(cuda_err));
		exit(EXIT_FAILURE);
	}  
	//---------------GPU1-----------------------------
	checkCudaErrors(cudaSetDevice(1));
	checkCudaErrors(cudaStreamCreate(&stream1));
	checkCudaErrors(cudaMalloc((void **)&d_combination1, combination_size * sizeof( unsigned int)));
	checkCudaErrors(cudaMalloc((void **)&d_result1 ,     1                * sizeof( unsigned int)));
	checkCudaErrors(cudaMallocHost((void **)&h_result1,  1 					   * sizeof(unsigned)));  // cudaMallocHost , not malloc()  
	/* memcpy( h_combination1,  combination , combination_size * sizeof(unsigned));  */

	cuda_err = cudaGetLastError();    
	if (cuda_err != cudaSuccess) 
	{                      
		fprintf(stderr, "GPU1  alloc d_combination error! (error code= %s)!\n", cudaGetErrorString(cuda_err));
		exit(EXIT_FAILURE);
	}  

// -----------------GPU0----------------------------------------------------------------------------
	checkCudaErrors(cudaSetDevice(0));
	checkCudaErrors(cudaMemcpyAsync(d_combination0, h_combination, combination_size * sizeof( unsigned int), cudaMemcpyHostToDevice, stream0));

	int GRID_SIZE  = ( combination_size + BLOCK_SIZE-1)/BLOCK_SIZE ;
	/* printf("gridsize = %d, blocksize =%d, queens = %d\n", GRID_SIZE, BLOCK_SIZE, combination_size ); */
	checkCudaErrors(cudaSetDevice(0));
	/* printf( "Switch to device : %d\n", getDevice()); */

	Ker_Check_Combination<<<   GRID_SIZE,  BLOCK_SIZE , 0, stream0 >>>
		(d_combination0 ,combination_size ,  d_result0);  

	getLastCudaError("Kernel() in divece 0 execution failed.\n");
	checkCudaErrors(cudaMemcpyAsync(h_result0, d_result0, 1 * sizeof(unsigned int), cudaMemcpyDeviceToHost,stream0));
// -----------------GPU1----------------------------------------------------------------------------
	checkCudaErrors(cudaSetDevice(1));
	checkCudaErrors(cudaMemcpyAsync(d_combination1, h_combination, combination_size * sizeof( unsigned int), cudaMemcpyHostToDevice, stream1));
	/* printf( "Switch to device : %d\n", getDevice()); */
	cuda_err= cudaSuccess;
	Ker_Check_Combination<<<   ( combination_size + BLOCK_SIZE-1)/BLOCK_SIZE  ,  BLOCK_SIZE , 0, stream1 >>>
		(d_combination1 ,combination_size ,  d_result1);  

	getLastCudaError("Kernel() in divece 1 execution failed.\n");
	checkCudaErrors(cudaMemcpyAsync(h_result1, d_result1, 1 * sizeof(unsigned int), cudaMemcpyDeviceToHost,stream1));
//------------------GPU0 同步-----------------------------------------------------------
	checkCudaErrors(cudaSetDevice(0));
	cudaStreamSynchronize(stream0);

//------------------GPU1 同步-----------------------------------------------------------
	checkCudaErrors(cudaSetDevice(1));
	cudaStreamSynchronize(stream1);

// ----------------------CPU ---------------------------------
	unsigned int conflicts =0 ;
	/* printf("%d\t%d\t  device0 == device1:%d\n", h_result0[0], h_result1[0],  h_result0[0]== h_result1[0]  ); */
	if( h_result0[0] = h_result1[0]) 
		conflicts = h_result1[0];
	//************************************************************************************************************

	//--------GPU0---------------------------
	checkCudaErrors(cudaSetDevice(0));
	checkCudaErrors( cudaFree(d_combination0) );
	checkCudaErrors( cudaFree(d_result0)      );
	/* checkCudaErrors(cudaFreeHost(h_combination0)); */
	checkCudaErrors(cudaFreeHost(h_result0)); 
	checkCudaErrors(cudaStreamDestroy(stream0));
	//--------GPU0---------------------------
	checkCudaErrors(cudaSetDevice(1));
	checkCudaErrors( cudaFree(d_combination1) );
	checkCudaErrors( cudaFree(d_result1)      );
	/* checkCudaErrors(cudaFreeHost(h_combination1)); */
	checkCudaErrors(cudaFreeHost(h_result1)); 
	checkCudaErrors(cudaStreamDestroy(stream1));

	/* printf(" get_conflicts()  run OK !\n"); */
	return  conflicts;

}
