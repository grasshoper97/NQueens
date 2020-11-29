mstream: mstream.o
	/usr/local/cuda-8.0/bin/nvcc -ccbin g++   -m64 -std=c++11  -Xcompiler -g    -gencode arch=compute_35,code=sm_35 -gencode arch=compute_37,code=sm_37  -o mstream mstream.o   -lcudadevrt


mstream.o: mstream.cu
	/usr/local/cuda-8.0/bin/nvcc -ccbin g++ -I/usr/local/NVIDIA_CUDA-8.0_Samples/common/inc  -m64 -std=c++11  -Xcompiler -g  -dc -gencode arch=compute_35,code=sm_35 -gencode arch=compute_37,code=sm_37  -o mstream.o -c mstream.cu

clean:
	rm -rf  mstream  *.o
