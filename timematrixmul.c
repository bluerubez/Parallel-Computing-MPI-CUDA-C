/*George Lees Jr.
Matrix Multiplication Cuda
This Cuda/C program creates two matrices and sends them to a cuda kernel
to do the matrix multiplication. The most efficient way to this is to pass
the matrices to the Cuda kernel as arrays and also perform the calculation
on the arrays instead of the matrices due to vectorization and also because
you can not pass matrices to a Cuda kernel unless you know the size of the 
matrices at compile time. */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>


#define BLOCK_SIZE 16


int main(void)
{
	int A_rows, A_cols,sum, B_rows, B_cols,C_rows,C_cols,Width,Height,i,j,k;
	clock_t begin, end;
	double time_spent;
	
	int N,K;
	K = 100;			
	N = K*BLOCK_SIZE;
	
	Width=N;
	Height=N;
	A_rows=N;
	A_cols=N;
	B_rows=N;
	B_cols=N;
	C_rows=N;
 	C_cols=N;

	float* A_mat;
	A_mat = (float*) malloc(N*N*sizeof(float));

	float* B_mat;
	B_mat = (float*) malloc(N*N*sizeof(float));

	//resultant matrix dimensions a x b * c x d = a x d , where b=c
	float* C_mat;
	C_mat = (float*) malloc(N*N*sizeof(float));

	float* C_mat2;
	C_mat2 = (float*) malloc(N*N*sizeof(float));

	int sizeofA = N*N;
	int sizeofB = N*N;


	//make corresponding amount of random numbers
	srand( time( NULL ) );
	
	for (int i=0; i< sizeofA; i++)
		{
			A_mat[i]=(float) (rand() % 999);
		}

	for (int i=0; i< sizeofB; i++)
		{
			B_mat[i]=(float) (rand() % 999);
		}

	begin = clock();
	// Now do the matrix multiplication on the CPU
 	for(i=0; i<A_rows; ++i){
    		for(j=0; j<B_cols; ++j){
			sum = 0;
    			for(k=0; k<Width; ++k)
    			{
        			sum+=A_mat[i*Width+k]*B_mat[k*Width+j];
    			}
			C_mat2[i*Width+j]=sum;	
		}
	}
	end = clock();
	time_spent = (double)(end - begin) / CLOCKS_PER_SEC;

	
	free(A_mat);

	free(B_mat);

	free(C_mat);


printf ("Time for the kernel: %f ms\n", time_spent);



    return EXIT_SUCCESS;
}
	

