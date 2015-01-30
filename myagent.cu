//George Lees Jr.

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

#define N 1000
#include <iostream>
#include <ctime>

extern "C"


__global__ void NearestNeighborKernel(float* A_x_d, float* A_y_d ,float* B_x_d, float* B_y_d, float* A_agentstrength_d, float* B_agentstrength_d)
{
int j_min_d;
int idx = threadIdx.x + blockIdx.x * blockDim.x;
if(idx < N)//so threads don't go past the bounds
	{
	
	float dist_min = 3.40282e38f;
	
	for(int j = 0; j < N; j++)
		{
		if(j == idx) continue;

		float dist_vec_d = sqrt(pow((A_x_d[idx]-B_x_d[j]),2)+pow((A_y_d[idx]-B_y_d[j]),2));

		//syncthreads

		if(dist_vec_d < dist_min)
			{
			dist_min = dist_vec_d;
			j_min_d= j;
			}

		//syncthreads

		if(dist_min<0.02 && B_agentstrength_d[j_min_d]>0.001)
    		{
        	/* Simple fight model - weakest agent killed */

    		if(A_agentstrength_d[j]<B_agentstrength_d[j_min_d])
        	{
        	A_agentstrength_d[j]=0;
        	}
    		else
        	{
        	B_agentstrength_d[j_min_d]=0;
        	}
    		}
	}
	}
}

int main(void)
{

// Declare variables and pointers on host to send to gpu
float *A_x, *A_y, *B_x, *B_y;
float *A_agentstrength;
float *B_agentstrength;
int vector_size;
vector_size = N*sizeof(float);
A_x = (float *)malloc(vector_size);
A_y = (float *)malloc(vector_size);
B_x = (float *)malloc(vector_size);
B_y = (float *)malloc(vector_size);
A_agentstrength = (float *)malloc(vector_size);
B_agentstrength = (float *)malloc(vector_size);


int i, time;
float delx, dely;
int total_dead_A[N];
int total_dead_B[N];
FILE *myfile;
FILE *myfile2;

// Declare variables on device
float *A_x_d;
float *A_y_d;
float *B_x_d;
float *B_y_d;
float *A_agentstrength_d;
float *B_agentstrength_d;
cudaMalloc(&A_x_d, vector_size);
cudaMalloc(&A_y_d, vector_size);
cudaMalloc(&B_x_d, vector_size);
cudaMalloc(&B_y_d, vector_size);
cudaMalloc(&A_agentstrength_d, vector_size);
cudaMalloc(&B_agentstrength_d, vector_size);


/* open files to write results */

myfile = fopen("agentresults.dat","w");
myfile2 = fopen("agentsummary.dat","w");

/* A loop to set the initial positions and strengths of 200 agents
 * (100 in team A and 100 in team B) which are random distributed
 * in a region with corners (-4,-4),(-4,4), (4,-4) and (4,4).
 * Strengths are assigned as random numbers between 0.5 and 1.0.
 * If agentstrength is less than 0.001 it is considered dead.        */

for (i=1;i<=N;++i)
{
A_x[i] = -4.0 + 8.0*((float) rand() / (float) (RAND_MAX-1));
A_y[i] = -4.0 + 8.0*((float) rand() / (float) (RAND_MAX-1));
B_x[i] = -4.0 + 8.0*((float) rand() / (float) (RAND_MAX-1));
B_y[i] = -4.0 + 8.0*((float) rand() / (float) (RAND_MAX-1));

A_agentstrength[i]=0.5 + 0.5* ((float) rand() / (float) (RAND_MAX-1));
B_agentstrength[i]=0.5 + 0.5* ((float) rand() / (float) (RAND_MAX-1));
}

// Start the time loop

for(time=1;time<=100;++time)
{

/* Loop through all agents on both teams (A and B)
 * and update their positions by adding random numbers to their
 * position (x,y). Note that if they move outside a region bounded
 * by the corners (-5,-5), (-5,5), (5,-5) and (5,5) they are put
 * back in the region.
 */

	for (i=1;i<=N;++i)
	{

	    if(A_agentstrength[i]>0.001)
	    {

		    delx = (float) rand() / (float) (RAND_MAX-1) - 0.5 ;
		    dely = (float) rand() / (float) (RAND_MAX-1) - 0.5;

	    	A_x[i] = A_x[i] + delx;
		A_y[i] = A_y[i] + dely;

		/* If, by adding the movement we move the agent out of the confining region
		 * then move the agent back to stay in region   */

		if(A_x[i]>5) {A_x[i]=A_x[i]-delx;}
		if(A_x[i]<-5) {A_x[i]=A_x[i]+delx;}
		if(A_y[i]>5) {A_y[i]=A_y[i]-dely;}
		if(A_y[i]<-5) {A_y[i]=A_y[i]+dely;}

	    }
	    if(B_agentstrength[i]>0.001)
	    {

		    delx = (float) rand() / (float) (RAND_MAX-1) - 0.5;
		    dely = (float) rand() / (float) (RAND_MAX-1) - 0.5;

	    	B_x[i] = B_x[i] + delx;
		B_y[i] = B_y[i] + dely;

		/* If, by adding the movement we move the agent out of the confining region
		 * then move the agent back to stay in region   */

		if(B_x[i]>5) {B_x[i]=B_x[i]-delx;}
		if(B_x[i]<-5) {B_x[i]=B_x[i]+delx;}
		if(B_y[i]>5) {B_y[i]=B_y[i]-dely;}
		if(B_y[i]<-5) {B_y[i]=B_y[i]+dely;}

	    }
	}

	/* Loop through all agents on both teams A and for each agent
 	* find the nearest individual on team B. Then fight with it.
 	* Loser dies.*/
	//&&
	/* If the nearest agent on team B is close enough to the agent i on team A
	* and not already dead then fight */
	// transfer vectors A_x, A_y, B_x, B_y to gpu
	cudaMemcpy(A_x_d, A_x, vector_size, cudaMemcpyHostToDevice);
	cudaMemcpy(A_y_d, A_y, vector_size, cudaMemcpyHostToDevice);
	cudaMemcpy(B_x_d, B_x, vector_size, cudaMemcpyHostToDevice);
	cudaMemcpy(B_y_d, B_y, vector_size, cudaMemcpyHostToDevice);
	cudaMemcpy(A_agentstrength_d, A_agentstrength, vector_size, cudaMemcpyHostToDevice);
	cudaMemcpy(B_agentstrength_d, B_agentstrength, vector_size, cudaMemcpyHostToDevice);
	

	NearestNeighborKernel<<< 4, 512>>> (A_x_d, A_y_d, B_x_d,
	B_y_d, A_agentstrength_d, B_agentstrength_d);

	cudaMemcpy(A_x, A_x_d, vector_size, cudaMemcpyDeviceToHost);
	cudaMemcpy(A_y, A_y_d, vector_size, cudaMemcpyDeviceToHost);
	cudaMemcpy(B_x, B_x_d, vector_size, cudaMemcpyDeviceToHost);
	cudaMemcpy(B_y, B_y_d, vector_size, cudaMemcpyDeviceToHost);
	cudaMemcpy(A_agentstrength,A_agentstrength_d, vector_size, cudaMemcpyDeviceToHost);
	cudaMemcpy(B_agentstrength,B_agentstrength_d, vector_size, cudaMemcpyDeviceToHost);

   /* Print out all agent positions and strengths for both teams */

    for(i=1;i<=N;++i)
    {
    fprintf(myfile, "%f %f %f %f %f %f \n",A_x[i],A_y[i],A_agentstrength[i],B_x[i],B_y[i],B_agentstrength[i]);
    }


    /* Compute number dead for both teams */

     total_dead_A[time]=0;
     total_dead_B[time]=0;
     for(i=1;i<=N;++i)
     {
     if(A_agentstrength[i]<0.001){total_dead_A[time]=total_dead_A[time]+1;}
     if(B_agentstrength[i]<0.001){total_dead_B[time]=total_dead_B[time]+1;}
     }
     fprintf(myfile2, "%d %d  \n",total_dead_A[time],total_dead_B[time]);


/* Go back for another time step */

}

free(A_x);free(A_y);free(B_x);free(B_y);
cudaFree(A_x_d);
cudaFree(A_y_d);
cudaFree(B_x_d);
cudaFree(B_y_d);

    /* Close files */

    if(myfile!=NULL)
    {
    fclose(myfile);
    }
    if(myfile2!=NULL)
    {
    fclose(myfile2);
    }


    return EXIT_SUCCESS;
}
