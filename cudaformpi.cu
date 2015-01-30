#include <stdio.h>
#include <stdlib.h>

#define N 4
#define threads_per_block 4

__global__ void simpleKernel(float *out, float *in)
{
   int index;
   index = blockIdx.x*blockDim.x+threadIdx.x;
   if(index<N)
   {
   out[index]=in[index]*in[index]*in[index];
   }
}

extern "C"

void GPU_STUFF(int device)
{
cudaSetDevice(device);
printf("Device number %d \n",device);

float *s_host, *r_host;
int pad, i;
float *r_device;
float *s_device;
size_t size;
pad = threads_per_block - (N % threads_per_block);
size = (N+pad)*sizeof(float);
s_host = (float *)malloc(size);
r_host = (float *)malloc(size);
cudaMalloc(&s_device, size);
cudaMalloc(&r_device, size);

dim3 threads(threads_per_block);
dim3 grid( (N+pad)/threads_per_block );

for (i=0;i<N;i++)
{
r_host[i]=i;
}

cudaMemcpy(r_device, r_host, size, cudaMemcpyHostToDevice);

simpleKernel <<< grid, threads >>> (s_device,r_device);

cudaMemcpy(s_host, s_device, size, cudaMemcpyDeviceToHost);

for (i=0;i<N;i++)
{
printf("%3f %3f\n",r_host[i],s_host[i]);
}

free(s_host);
free(r_host);
cudaFree(r_device);
cudaFree(s_device);

}






