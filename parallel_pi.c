#include<stdio.h>
#include<math.h>
#include<stdlib.h>
#include<mpi.h>
#include<time.h>

main(int argc,char ** argv)
{

	int count,count1,N,i,j,rank,size,block;
	double x,y,pi;
	x=0;y=0;
	N=100000;
	count=0;

	clock_t begin, end;
	double time_spent;

	begin=clock();

	MPI_Status status;
	MPI_Init(&argc,&argv);
	MPI_Comm_rank(MPI_COMM_WORLD,&rank);
	MPI_Comm_size(MPI_COMM_WORLD,&size);


	srand(time(NULL)*rank);

		if (rank==0)
			{ block=N/size;

				for(j=1;j<size;j++)
				{
				MPI_Send(&block,1,MPI_INT,j,99,MPI_COMM_WORLD);
				}
			}

		else {
			MPI_Recv(&block,1,MPI_INT,0,99,MPI_COMM_WORLD,&status);
		     }
		
	if (rank==0){printf("%lf %lf %d %d\n",x,y,block,count);}

	for(i=0;i<block;i++){

		x=(double)rand()/(double)RAND_MAX;
		y=(double)rand()/(double)RAND_MAX;

			if(x*x+y*y<1){
			count=count+1;}
	}


	if (rank!=0)
			{ 

				//for(j=1;j<size;j++)
				//{
				MPI_Send(&count,1,MPI_INT,0,99,MPI_COMM_WORLD);
				//}
			}

		else {		
                                count1 = count;
				for(j=1;j<size;j++)
				{
				MPI_Recv(&count,1,MPI_INT,j,99,MPI_COMM_WORLD,&status);
                                count1 = count1 + count;
				}
		     }

	if (rank==0){ pi=4.0*(double)count1/(double)N;

	printf("%lf %lf %d %d %lf\n",x,y,block,count,pi);
	

	end=clock();
	time_spent=(double)(end-begin)/CLOCKS_PER_SEC;
	printf("time=%lf\n",time_spent);}

	MPI_Finalize();

}

