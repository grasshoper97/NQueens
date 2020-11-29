
gpucheck: gpucheck.o   Kernel.o 
	/usr/local/cuda-8.0/bin/nvcc -ccbin g++  -Xcompiler  -m64 -std=c++11  -g  -gencode arch=compute_37,code=sm_37  -o gpucheck  gpucheck.o   Kernel.o  -lcudadevrt -keep

gpucheck.o : gpucheck.cpp Kernel.h
	/usr/local/cuda-8.0/bin/nvcc -ccbin g++ -I/usr/local/NVIDIA_CUDA-8.0_Samples/common/inc  -m64 -std=c++11  -Xcompiler -g  -dc  -gencode arch=compute_37,code=sm_37  -o gpucheck.o -c gpucheck.cpp -keep

Kernel.o: Kernel.cu Kernel.h	
	/usr/local/cuda-8.0/bin/nvcc -ccbin g++ -I/usr/local/NVIDIA_CUDA-8.0_Samples/common/inc  -m64 -std=c++11  -Xcompiler -g  -dc  -gencode arch=compute_37,code=sm_37    -o Kernel.o -c Kernel.cu -keep

clean:
	rm -rf  gpucheck  *.o
