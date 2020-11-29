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
unsigned int  get_conflicts(unsigned int * combination, unsigned int combination_size);  // int -> unsigned int   ,  vecotor->int * []
void warmGPU(); 
void warmGPU0_1(); 
void setDevice(int i);
int  getDevice();
////////////////////////////////////////////////////////////////////////////////
