// 2018.11.10   // very slow average 200s
// every thread check for a Queen. not a pair[]
// 2018.12.29 
//copy form CheckOne_Datafile_compare/gpu_1_Queen
// 2019.4.15 add TGPU structor, modify get_conflicts() ;
#include "Kernel.h"
#include <helper_functions.h>
#include <helper_cuda.h>
#include <timer.h>
//#define DEBUG 
#define BLOCK_SIZE 512 

typedef struct
{
    //Host-side input data
    unsigned *h_Data;
    //Partial sum for this GPU
    unsigned *h_Sum;

    //Device buffers
    unsigned *d_Data;
	unsigned *d_Sum;

    //Stream for asynchronous command execution
    cudaStream_t stream;

} TGPUplan;
//----------------------------Kernel----------------------------------------
__global__ void Ker_Warm(){
	// empty body, just warmup GPU;
	if(threadIdx.x == 0 )
		printf("GPU is OK!\n");
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


unsigned int get_conflicts(int * com, int N)
{

    //Solver config
    TGPUplan      plan[2];
	int GPU_N=0;
    //GPU reduction results
    printf("Starting simpleMultiGPU\n");
    checkCudaErrors(cudaGetDeviceCount(&GPU_N));

    printf("CUDA-capable device count: %i\n", GPU_N);

    printf("Generating input data...\n\n");

    //Create streams for issuing GPU command asynchronously and allocate memory (GPU and System page-locked)
	int i=0;
    for (i = 0; i < GPU_N; i++)
    {
        checkCudaErrors(cudaSetDevice(i));
        checkCudaErrors(cudaStreamCreate(&plan[i].stream));
        //Allocate memory
        checkCudaErrors(cudaMalloc((void **)&plan[i].d_Data, N  * sizeof(unsigned)));
        checkCudaErrors(cudaMalloc((void **)&plan[i].d_Sum,  1  * sizeof(unsigned)));
        checkCudaErrors(cudaMallocHost((void **)&plan[i].h_Data, N * sizeof(unsigned)));
        checkCudaErrors(cudaMallocHost((void **)&plan[i].h_Sum,  1 * sizeof(unsigned)));  // cudaMallocHost , not malloc()

		memcpy( plan[i].h_Data,  com, N * sizeof(unsigned));  // 普通内存数据转入页锁定内存；
    }

    //Start timing and compute on GPU(s)
    printf("Computing with %d GPUs...\n", GPU_N);
    StartTimer();

    //Copy data to GPU, launch the kernel and copy data back. All asynchronously
    for (i = 0; i < GPU_N; i++)
    {
        //Set device
        checkCudaErrors(cudaSetDevice(i));

        //Copy input data from CPU
        checkCudaErrors(cudaMemcpyAsync(plan[i].d_Data, plan[i].h_Data, N * sizeof(unsigned), cudaMemcpyHostToDevice, plan[i].stream));

        //Perform GPU computations
		Ker_Check_Combination<<<   ( N + BLOCK_SIZE-1)/BLOCK_SIZE  ,  BLOCK_SIZE , 0 , plan[i].stream >>>
			( plan[i].d_Data ,N  ,  plan[i].d_Sum) ;  
        getLastCudaError("reduceKernel() execution failed.\n");

        //Read back GPU results
        checkCudaErrors(cudaMemcpyAsync(plan[i].h_Sum, plan[i].d_Sum, 1 *sizeof(unsigned), cudaMemcpyDeviceToHost, plan[i].stream));
    }

    //Process GPU results
    for (i = 0; i < GPU_N; i++)
    {
        unsigned sum;

        //Set device
        checkCudaErrors(cudaSetDevice(i));

        //Wait for all operations to finish
        cudaStreamSynchronize(plan[i].stream);

        //Shut down this GPU
        checkCudaErrors(cudaFreeHost(plan[i].h_Data));
        checkCudaErrors(cudaFree(plan[i].d_Sum));
        checkCudaErrors(cudaFree(plan[i].d_Data));
        checkCudaErrors(cudaStreamDestroy(plan[i].stream));
    }


    printf("  GPU Processing time: %f (ms)\n\n", GetTimer());
	printf("%d  == %d \n ", plan[0].h_Sum[0],  plan[1].h_Sum[0]); 
	if( plan[0].h_Sum[0] ==  plan[1].h_Sum[0])
		printf("Check Pass");
	else
		printf("Check False");

	unsigned int conflicts = plan[0].h_Sum[0];


    // Cleanup and shutdown
    for (i = 0; i < GPU_N; i++)
    {
        checkCudaErrors(cudaSetDevice(i));
        checkCudaErrors(cudaFreeHost(plan[i].h_Sum));
    }

		printf("run OK!\n");
		return conflicts;
}
