//George Lees Jr.
//Parallel Computing
//Project 2
//Partial diff domain decomp mpi
#include <stdio.h>
#include <mpi.h>

main(int argc, char *argv[]){

MPI_Init(&argc, &argv);


float a_new[100];
float a_old[100];
int i,rank,size;
float u,dx,dt;
float x;
float time, total_time;
//N is half the array so i can break up the work amongst processes
int N;
N=50;
MPI_Status status;
MPI_Comm_rank(MPI_COMM_WORLD,&rank);
MPI_Comm_size(MPI_COMM_WORLD,&size);

u=0.99;
dx=1.0;
dt=1.0;
total_time = 20.0;

	//process 0 is just gonna worry about first half
	if(rank==0){
		for(i=0;i<N;++i){
			a_old[i]=0.0;
		}
		

		for(i=5;i<10;++i){
			a_old[i]=1.0;
		}
	}
	//process 1 is gonna worry aout second half
	else{
		for(i=50;i<100;++i){
			a_old[i]=0.0;
		}	
	}



time=0.0;


while(time<total_time)
{	   //process 0 send a_old[49] to process 1 	
	   if(rank==0)
	   {
		   a_new[0]=0.0;
		   MPI_Send(&a_old[N-1],1,MPI_FLOAT,1,99,MPI_COMM_WORLD);
	   }
	   //so process 1 can calculate a_new[50] here
	   else
	   {
		   MPI_Recv(&x,1,MPI_FLOAT,0,99,MPI_COMM_WORLD,&status);
		   a_new[N]=a_old[N]-(u*dt/dx)*(a_old[N]-x);
	   }

	   //then process 0 can flop through first half of array
	   if(rank==0){
		   for(i=1;i<N;++i)
		   {
		   	a_new[i]=a_old[i]-(u*dt/dx)*(a_old[i]-a_old[i-1]);   
		   }
		   for(i=1;i<N;++i)
		   {
	           	a_old[i]=a_new[i];
		   }
	   }

	   //while process 1 can flop through a_new[51-99]	
	   else{
		   for(i=51;i<100;++i)
		   {
		   	a_new[i]=a_old[i]-(u*dt/dx)*(a_old[i]-a_old[i-1]);  
		   }
	           for(i=51;i<100;++i)
		   {
	           	a_old[i]=a_new[i];
		   }
	   } 

time=time+dt;
}	
	//then we have to send a_new[50-99] to process 0 for printing
	if (rank!=0){
		for(i=0;i<50;++i)
		{
			MPI_Send(&a_new[N+i],1,MPI_FLOAT,0,99,MPI_COMM_WORLD);
		}
	}
	else{
		for(i=0;i<50;++i)
		{
			MPI_Recv(&x,1,MPI_FLOAT,1,99,MPI_COMM_WORLD,&status);
		        a_new[N+i]=x;
	   	}
	}

	if(rank==0){
		for(i=0;i<100;++i){
			printf("%f %f\n",(float)i,a_new[i]);
		}	
	}		
   
  
MPI_Finalize();
}
