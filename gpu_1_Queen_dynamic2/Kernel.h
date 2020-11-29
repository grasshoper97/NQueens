// 计算适应值
#include <cuda_runtime.h>
#include <cuda.h>
#include <helper_cuda.h>
#include <helper_string.h>
#include <chrono>
#include <vector>
using namespace std;
using namespace chrono;
////////////////////////////////////////////////////////////////////////////////
/*
__global__ void warmup();

__global__ void check_combination (
		int *d_combination,			// 
		int combination_size,		// length of combinations =queen number =N
		int *d_result				// return conflicts count.
		);
*/
unsigned int  get_conflicts(int * combination, int combination_size); 
void warmGPU(); 
void setDevice(int i);
void show_config(int combination_size);
////////////////////////////////////////////////////////////////////////////////
