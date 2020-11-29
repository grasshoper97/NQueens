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
/*   need not
__global__ void warmup();

__global__ void check_combination (
		int *d_combination,			// 
		int combination_size,		// length of combinations =queen number =N
		int *d_result				// return conflicts count.
		);
*/

extern int pairs_size;
extern int *d_pairs_i;
extern int *d_pairs_j;

void gen_transfer_pairs( int N);
void release_d_pairs();
void warmGPU(); 
unsigned int  get_conflicts(int * combination, int combination_size); 
////////////////////////////////////////////////////////////////////////////////
