 /*
  * 2019.4.15 9:05 复制自 SDK simpleMultiGPU， 简化头文件，用来尝试双卡并行。
  * 2019.4.15 9:17 修改为整型数据
  */
// System includes
#include <stdio.h>
#include <assert.h>

// CUDA runtime
#include <cuda_runtime.h>

// helper functions and utilities to work with CUDA
#include <helper_functions.h>
#include <helper_cuda.h>
#include <timer.h>

#ifndef MAX
#define MAX(a,b) (a > b ? a : b)
#endif

//-------------------------------------------------------------------------------------------------------

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
//-------------------------------------------------------------------------------------------------------
typedef struct
{
    //Host-side input data
    int dataN;
    unsigned *h_Data;

    //Partial sum for this GPU
    unsigned *h_Sum;

    //Device buffers
    unsigned *d_Data;
	unsigned *d_Sum;

    //Stream for asynchronous command execution
    cudaStream_t stream;

} TGPUplan;
////////////////////////////////////////////////////////////////////////////////
// Data configuration
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// Program main
////////////////////////////////////////////////////////////////////////////////
int main(int argc, char **argv)
{
    //Solver config
    TGPUplan      plan[2];

    //GPU reduction results
    printf("Starting simpleMultiGPU\n");
    checkCudaErrors(cudaGetDeviceCount(&GPU_N));

    printf("CUDA-capable device count: %i\n", GPU_N);

    printf("Generating input data...\n\n");

    //Subdividing input data across GPUs
    //Get data sizes for each GPU
    for (i = 0; i < GPU_N; i++)
    {
        plan[i].dataN = DATA_N / GPU_N;//lean: data number for single GPU;
    }

    //Take into account "odd" data sizes
    for (i = 0; i < DATA_N % GPU_N; i++)
    {
        plan[i].dataN++;
    }

    //Assign data ranges to GPUs
    gpuBase = 0;

    for (i = 0; i < GPU_N; i++)
    {
        plan[i].h_Sum = h_SumGPU + i;  //= & hSumGPU[i];  lean: h_Sum is a pointer .  
        gpuBase += plan[i].dataN;
    }

    //Create streams for issuing GPU command asynchronously and allocate memory (GPU and System page-locked)
    for (i = 0; i < GPU_N; i++)
    {
        checkCudaErrors(cudaSetDevice(i));
        checkCudaErrors(cudaStreamCreate(&plan[i].stream));
        //Allocate memory
        checkCudaErrors(cudaMalloc((void **)&plan[i].d_Data, plan[i].dataN * sizeof(unsigned)));
        checkCudaErrors(cudaMalloc((void **)&plan[i].d_Sum, ACCUM_N * sizeof(unsigned)));
        checkCudaErrors(cudaMallocHost((void **)&plan[i].h_Data, plan[i].dataN * sizeof(unsigned)));

        for (j = 0; j < plan[i].dataN; j++)
        {
            plan[i].h_Data[j] = (unsigned)rand() / (unsigned)RAND_MAX;
        }
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
        checkCudaErrors(cudaMemcpyAsync(plan[i].d_Data, plan[i].h_Data, plan[i].dataN * sizeof(unsigned), cudaMemcpyHostToDevice, plan[i].stream));

        //Perform GPU computations
        reduceKernel<<<BLOCK_N, THREAD_N, 0, plan[i].stream>>>(plan[i].d_Sum, plan[i].d_Data, plan[i].dataN);
        getLastCudaError("reduceKernel() execution failed.\n");

        //Read back GPU results
        checkCudaErrors(cudaMemcpyAsync(plan[i].h_Sum_from_device, plan[i].d_Sum, ACCUM_N *sizeof(unsigned), cudaMemcpyDeviceToHost, plan[i].stream));
    }

    //Process GPU results
    for (i = 0; i < GPU_N; i++)
    {
        unsigned sum;

        //Set device
        checkCudaErrors(cudaSetDevice(i));

        //Wait for all operations to finish
        cudaStreamSynchronize(plan[i].stream);

        //Finalize GPU reduction for current subvector
        sum = 0;

        for (j = 0; j < ACCUM_N; j++)
        {
            sum += plan[i].h_Sum_from_device[j];
        }

        *(plan[i].h_Sum) = (unsigned)sum;

        //Shut down this GPU
        checkCudaErrors(cudaFreeHost(plan[i].h_Sum_from_device));
        checkCudaErrors(cudaFree(plan[i].d_Sum));
        checkCudaErrors(cudaFree(plan[i].d_Data));
        checkCudaErrors(cudaStreamDestroy(plan[i].stream));
    }

    sumGPU = 0;

    for (i = 0; i < GPU_N; i++)
    {
        sumGPU += h_SumGPU[i];
    }

    printf("  GPU Processing time: %f (ms)\n\n", GetTimer());

    // Compute on Host CPU
    printf("Computing with Host CPU...\n\n");

    sumCPU = 0;

    for (i = 0; i < GPU_N; i++)
    {
        for (j = 0; j < plan[i].dataN; j++)
        {
            sumCPU += plan[i].h_Data[j];
        }
    }

    // Compare GPU and CPU results
    printf("Comparing GPU and Host CPU results...\n");
    diff = fabs(sumCPU - sumGPU) / fabs(sumCPU);
    printf("  GPU sum: %f\n  CPU sum: %f\n", sumGPU, sumCPU);
    printf("  Relative difference: %E \n\n", diff);

    // Cleanup and shutdown
    for (i = 0; i < GPU_N; i++)
    {
        checkCudaErrors(cudaSetDevice(i));
        checkCudaErrors(cudaFreeHost(plan[i].h_Data));
    }

    exit((diff < 1e-5) ? EXIT_SUCCESS : EXIT_FAILURE);
}
