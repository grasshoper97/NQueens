
gpucheck: gpucheck.o   Kernel.o 
	/usr/local/cuda-8.0/bin/nvcc -ccbin g++   -m64 -std=c++11  -Xcompiler -g    -gencode arch=compute_35,code=sm_35 -gencode arch=compute_37,code=sm_37 -gencode arch=compute_50,code=sm_50 -gencode arch=compute_52,code=sm_52 -gencode arch=compute_60,code=sm_60 -gencode arch=compute_60,code=compute_60 -o gpucheck  gpucheck.o   Kernel.o  -lcudadevrt

gpucheck.o : gpucheck.cpp Kernel.h
	/usr/local/cuda-8.0/bin/nvcc -ccbin g++ -I/usr/local/NVIDIA_CUDA-8.0_Samples/common/inc  -m64 -std=c++11  -Xcompiler -g  -dc -gencode arch=compute_35,code=sm_35 -gencode arch=compute_37,code=sm_37 -gencode arch=compute_50,code=sm_50 -gencode arch=compute_52,code=sm_52 -gencode arch=compute_60,code=sm_60 -gencode arch=compute_60,code=compute_60 -o gpucheck.o -c gpucheck.cpp

Kernel.o: Kernel.cu Kernel.h	
	/usr/local/cuda-8.0/bin/nvcc -ccbin g++ -I/usr/local/NVIDIA_CUDA-8.0_Samples/common/inc  -m64 -std=c++11  -Xcompiler -g  -dc -gencode arch=compute_35,code=sm_35 -gencode arch=compute_37,code=sm_37 -gencode arch=compute_50,code=sm_50 -gencode arch=compute_52,code=sm_52 -gencode arch=compute_60,code=sm_60 -gencode arch=compute_60,code=compute_60 -o Kernel.o -c Kernel.cu

clean:
	rm -rf  gpucheck  *.o
