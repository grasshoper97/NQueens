gpucheck: gpucheck.o   Kernel_p.o 
	/usr/local/cuda-8.0/bin/nvcc -ccbin g++   -m64 -std=c++11  -Xcompiler -g    -gencode  arch=compute_37,code=sm_37   -o gpucheck  gpucheck.o   Kernel_p.o  -lcudadevrt

gpucheck.o : gpucheck.cpp Kernel_p.h
	/usr/local/cuda-8.0/bin/nvcc -ccbin g++ -I/usr/local/NVIDIA_CUDA-8.0_Samples/common/inc  -m64 -std=c++11  -Xcompiler -g  -dc -gencode arch=compute_37,code=compute_37 -o gpucheck.o -c gpucheck.cpp

Kernel_p.o: Kernel_p.cu Kernel_p.h	
	/usr/local/cuda-8.0/bin/nvcc -ccbin g++ -I/usr/local/NVIDIA_CUDA-8.0_Samples/common/inc  -m64 -std=c++11  -Xcompiler -g  -dc -gencode  arch=compute_37,code=sm_37 -o Kernel_p.o -c Kernel_p.cu

clean:
	rm -rf  gpucheck  *.o
