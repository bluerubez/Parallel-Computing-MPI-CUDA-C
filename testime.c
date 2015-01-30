#include <mpi.h>
//#include <stdio.h>

void GPU_STUFF();

int main(int argc, char * argv[])
{
int rank;
MPI_Init(&argc, &argv);

MPI_Comm_rank(MPI_COMM_WORLD, &rank);

if(rank!=1)
{
GPU_STUFF(rank);
}

MPI_Finalize();
return 0;
}
