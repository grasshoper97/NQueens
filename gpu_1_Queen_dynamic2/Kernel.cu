/* 2018.11.10   // very slow average 200s
* 	every thread check for a Queen. not a pair[]
* 2018.12.4
*	use dynamic parallel to speed up large N number.
*   in Sub Kernel. set x of header Queen = -1 to avoid caculate global index of subArr[].
*/

#include "Kernel.h"
//#define DEBUG 		0
//every block has x Queen, i.e.  x raws.
#define BLOCK_SIZE 	512 

// number that every thread int sub_Kernel loops ,i.e. pairs that this thread checked;
// threshold
#define SUB_TASK  (128*1024)
// thread numbers in every sub block 
#define SUB_BLOCK_SIZE  32

//----------------------------Kernel----------------------------------------
__global__ void Ker_Warm(){
	// empty body, just warmup GPU;
	if(threadIdx.x == 0 )
		printf("GPU is OK!\n");
}

__global__ void Ker_Sub(
		int super_tid,
		/*int X,*/     // use -1 instead.
		int Y,
		int *SubArr,	// Arr[super.tid+1, N-1]
		int SubLen ,    // N-1 -( super.tid+1) + 1
		unsigned int *d_result           )
{
	const int sub_tid = blockDim.x * blockIdx.x + threadIdx.x;   	// [0.. 127]
	//int my_job_begin = SUB_TASK * sub_tid ;
	//int my_job_end	 = SUB_TASK * (sub_tid+1);
	int X=-1;  // convert sub[] index to global[] index;
	for(int sx = SUB_TASK * sub_tid;  sx< SUB_TASK * (sub_tid + 1) && sx < SubLen ; sx++){
		int sy = SubArr[sx];  // Arr[super_tid + 1 + sx]
		# ifdef DEBUG
		printf("Super [%5d] Sub[%5d]-------->>>compare %5d to %5d\n ", super_tid, sub_tid, X, sx );
		#endif
		if(Y == sy || X+Y == sx + sy  ||  Y -X == sy - sx) { // not a	Permutations, it is random numbers. 
			atomicAdd ((unsigned int *)&d_result[0],1);
		}//if
	}//for

}

// check for a Queen , i.e. a round.  compare arr[tid] to arr[tid+1 .. N-1].
__global__ void Ker_Check_Combination (
		int *Arr,			// arr[0,N-1]
		int N,						// length of combinations =queen number =N
		unsigned int *d_result				// return conflicts count.
		)
{
	const int tid = blockDim.x * blockIdx.x + threadIdx.x;   
	if(tid >= N -1)  // last queen arr[N-1] need't check.   
		return;

	
	//int curX=tid;  // curX is global index in Arr[], in subArr, use -1
	int curY=Arr[tid];
	int len_of_rest_Queens = N -1-tid;
	# ifdef DEBUG
	printf("Super[%5d]-------------------->>>  len_of_rest_Queens %5d, sub_ker_threads %5d  \n", 
										 tid , len_of_rest_Queens    , sub_ker_threads);
	#endif

	if( len_of_rest_Queens > SUB_TASK ) {
		//call sub kernel. 
		//printf("Sub Kernel called in thread:%5d\n", tid);
		int sub_ker_threads = (len_of_rest_Queens + SUB_TASK -1) / SUB_TASK ;
		Ker_Sub<<< ( sub_ker_threads + SUB_BLOCK_SIZE -1 ) / SUB_BLOCK_SIZE , SUB_BLOCK_SIZE >>> ( tid , /*curX,  -1 instead */  curY, &Arr[tid+1] ,  len_of_rest_Queens, d_result);
	}
	else {
		// for small tasks, check by itself.
		int curX=tid;
		//check every queen after cur;
		for(int iX=tid+1 ; iX <= N-1 ; iX++){
			int iY=Arr[iX];
			if(iY == curY || iX+iY == curX+ curY  ||  iY -iX == curY - curX) { // not a	Permutations, it is random numbers. 
				//printf("-------->>> (%5d,%5d) (%5d,%5d) thread:%5d  \n ", curX,curY,iX,iY,tid);
				atomicAdd ((unsigned int *)&d_result[0],1);
				// break;   // get all conflicts
			}
		}

	}



}// end of Kernel


//----------------------------CPU Interface----------------------------------------
void setDevice(int i)
{
	checkCudaErrors( cudaSetDevice( i )  );    
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


void show_config(int combination_size)
{
	printf("%20s\t%20s\t%20s\n","super block size","sub block size","sub task size");
	printf("%20d\t%20d\t%20d\n",BLOCK_SIZE, SUB_BLOCK_SIZE, SUB_TASK);
	printf("Ker_Check_Combination<<< %5d,%5d >>> \n", (combination_size + BLOCK_SIZE-1)/BLOCK_SIZE  ,  BLOCK_SIZE );
}

unsigned int get_conflicts(int * combination, int combination_size)
{
	int *h_combination = 0;  //store a number in [1~N]
	int *d_combination = 0;
	unsigned int * h_result= 0;
	unsigned int * d_result= 0;
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
	checkCudaErrors(cudaMalloc((void **)&d_result ,     1                * sizeof(unsigned int)));
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
		fprintf(stderr, "Failed to launch (error code= %s)!\n", cudaGetErrorString(cuda_err));
		exit(EXIT_FAILURE);
	}  
	# ifdef DEBUG
	else
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
		fprintf(stderr, "D->H error! (error code= %s)!\n", cudaGetErrorString(cuda_err));
		exit(EXIT_FAILURE);
	}  
	# ifdef DEBUG
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
