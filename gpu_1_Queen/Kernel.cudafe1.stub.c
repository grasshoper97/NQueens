#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-function"
#pragma GCC diagnostic ignored "-Wcast-qual"
#define __NV_MODULE_ID _14_Kernel_cpp1_ii_a105f23b
#define __NV_CUBIN_HANDLE_STORAGE__ extern
#include "crt/host_runtime.h"
#include "Kernel.fatbin.c"
extern void __device_stub__Z8Ker_Warmv(void);
extern void __device_stub__Z21Ker_Check_CombinationPiiPj(int *, int, unsigned *);
static void __nv_cudaEntityRegisterCallback(void **);
static void __sti____cudaRegisterAll_14_Kernel_cpp1_ii_a105f23b(void) __attribute__((__constructor__));
void __device_stub__Z8Ker_Warmv(void){__cudaLaunch(((char *)((void ( *)(void))Ker_Warm)));}
# 10 "Kernel.cu"
void Ker_Warm(void)
# 10 "Kernel.cu"
{__device_stub__Z8Ker_Warmv();



}
# 1 "Kernel.cudafe1.stub.c"
void __device_stub__Z21Ker_Check_CombinationPiiPj( int *__par0,  int __par1,  unsigned *__par2) {  __cudaSetupArgSimple(__par0, 0UL); __cudaSetupArgSimple(__par1, 8UL); __cudaSetupArgSimple(__par2, 16UL); __cudaLaunch(((char *)((void ( *)(int *, int, unsigned *))Ker_Check_Combination))); }
# 16 "Kernel.cu"
void Ker_Check_Combination( int *__cuda_0,int __cuda_1,unsigned *__cuda_2)
# 21 "Kernel.cu"
{__device_stub__Z21Ker_Check_CombinationPiiPj( __cuda_0,__cuda_1,__cuda_2);
# 42 "Kernel.cu"
}
# 1 "Kernel.cudafe1.stub.c"
static void __nv_cudaEntityRegisterCallback( void **__T20) {  __nv_dummy_param_ref(__T20); __nv_save_fatbinhandle_for_managed_rt(__T20); __cudaRegisterEntry(__T20, ((void ( *)(int *, int, unsigned *))Ker_Check_Combination), _Z21Ker_Check_CombinationPiiPj, (-1)); __cudaRegisterEntry(__T20, ((void ( *)(void))Ker_Warm), _Z8Ker_Warmv, (-1)); }
static void __sti____cudaRegisterAll_14_Kernel_cpp1_ii_a105f23b(void) {  ____cudaRegisterLinkedBinary(__nv_cudaEntityRegisterCallback);  }

#pragma GCC diagnostic pop
