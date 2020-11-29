 /*
  * 2019.4.15 复制自 SDK simpleMultiGPU， 简化头文件，用来尝试双卡并行。
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


typedef struct
{
    //Host-side input data
    int dataN;
    float *h_Data;
    //Partial sum for this GPU
    float *h_Sum;

    //Device buffers
    float *d_Data,*d_Sum;

    //Reduction copied back from GPU
    float *h_Sum_from_device;

    //Stream for asynchronous command execution
    cudaStream_t stream;

} TGPUplan;
////////////////////////////////////////////////////////////////////////////////
// Data configuration
////////////////////////////////////////////////////////////////////////////////
const int MAX_GPU_COUNT = 32;
//const int DATA_N        = 1048576 * 32; // 32M
/* const int DATA_N        = 1048576 * 512; // 32M */

////////////////////////////////////////////////////////////////////////////////
// Simple reduction kernel.
// Refer to the 'reduction' CUDA Sample describing
// reduction optimization strategies
////////////////////////////////////////////////////////////////////////////////
__global__ static void reduceKernel(float *d_Result, float *d_Input, int N)
{
    const int     tid = blockIdx.x * blockDim.x + threadIdx.x;
    const int threadN = gridDim.x * blockDim.x; //lean: thread number total;
    float sum = 0;

    for (int pos = tid; pos < N; pos += threadN)
        sum += d_Input[pos];

    d_Result[tid] = sum;
}

////////////////////////////////////////////////////////////////////////////////
// Program main
////////////////////////////////////////////////////////////////////////////////
int main(int argc, char **argv)
{
    TGPUplan      plan[MAX_GPU_COUNT]; //对应每个GPU的结构体
    float     h_SumGPU[MAX_GPU_COUNT];//每个GPU的部分和

    float 	sumGPU;	//多个GPU累计的总和
    double 	sumCPU;	// CPU计算的总和
	double	diff;	//二者误差

	int gpuBase; // 数据指针 
    int i, j;

    const int  BLOCK_N = 32;  // Kernle 块数量
    const int THREAD_N = 256; // 每个块的线程数量
    const int  ACCUM_N = BLOCK_N * THREAD_N; // 每个Kernel 中的线程数量

    printf("Starting simpleMultiGPU\n");
	//获取GPU个数，可以是两块显卡，或者一块显卡上两个GPU核心；
    /* checkCudaErrors(cudaGetDeviceCount(&GPU_N)); */
    /* printf("CUDA-capable device count: %i\n", GPU_N); */
	int GPU_N;  // GPU 个数
	int DATA_N = 1048576 ; // 1024*1024； 1M

	if(argc==3){
		GPU_N = atoi(argv[1]);	
		DATA_N = DATA_N * atoi(argv[2]);  // main参数以兆为单位
	}
	else{ // has no extra parameters
		printf("2 extra parameters needed!\n");
		printf("./mgpu gpu_num  data_num(M)\n");
		return 0;
	}
    printf("Generating input data...\n\n");
    //Subdividing input data across GPUs
    //Get data sizes for each GPU
    for (i = 0; i < GPU_N; i++)
    {
        plan[i].dataN = DATA_N / GPU_N;//lean: data number for single GPU;
    }// plan[0~31], GPU_N = 2,只使用plan数组中的前两个。

    //Take into account "odd" data sizes
    for (i = 0; i < DATA_N % GPU_N; i++)
    {
        plan[i].dataN++; //不能整除的情况，余数从0到GPU_N,分配给前几个GPU
    }

    //Assign data ranges to GPUs
    /* gpuBase = 0; */

    for (i = 0; i < GPU_N; i++)
    {
        plan[i].h_Sum = h_SumGPU + i;  //= & hSumGPU[i];  lean: h_Sum is a pointer .  
        /* gpuBase += plan[i].dataN; */
    }

    //Create streams for issuing GPU command asynchronously and allocate memory (GPU and System page-locked)
    for (i = 0; i < GPU_N; i++)
    {
        checkCudaErrors(cudaSetDevice(i)); // 先选设备
        checkCudaErrors(cudaStreamCreate(&plan[i].stream));
        //Allocate memory
        checkCudaErrors(cudaMalloc((void **)&plan[i].d_Data, plan[i].dataN * sizeof(float)));
        checkCudaErrors(cudaMalloc((void **)&plan[i].d_Sum, ACCUM_N * sizeof(float)));
        checkCudaErrors(cudaMallocHost((void **)&plan[i].h_Sum_from_device, ACCUM_N * sizeof(float)));
        checkCudaErrors(cudaMallocHost((void **)&plan[i].h_Data, plan[i].dataN * sizeof(float)));

        for (j = 0; j < plan[i].dataN; j++)
        {
            plan[i].h_Data[j] = (float)rand() / (float)RAND_MAX; // 填入dataN个随机数据(注意，每个plan[i].dataN可能不一样大，因为余数)
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
        checkCudaErrors(cudaMemcpyAsync(plan[i].d_Data, plan[i].h_Data, plan[i].dataN * sizeof(float), cudaMemcpyHostToDevice, plan[i].stream));

        //Perform GPU computations
        reduceKernel<<<BLOCK_N, THREAD_N, 0, plan[i].stream>>>(plan[i].d_Sum, plan[i].d_Data, plan[i].dataN);
        getLastCudaError("reduceKernel() execution failed.\n");

        //Read back GPU results
        checkCudaErrors(cudaMemcpyAsync(plan[i].h_Sum_from_device, plan[i].d_Sum, ACCUM_N *sizeof(float), cudaMemcpyDeviceToHost, plan[i].stream));
    }

    //Process GPU results
    for (i = 0; i < GPU_N; i++)
    {
        float sum;

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

        *(plan[i].h_Sum) = (float)sum;

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

    printf("%5s %10s %10s \n","GPU_N","data(M)","Time(ms)");
    printf("%5d %10d %10.3f\n", GPU_N, DATA_N/1024/1024, GetTimer());

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
