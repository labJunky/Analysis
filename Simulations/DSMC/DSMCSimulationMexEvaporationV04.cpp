/*
 *  DSMCSimulationMex.cpp
 *  
 *
 *  Created by Chris on 9/07/09.
 *  Copyright 2009 Watkins Corp. All rights reserved.
 *
 */

#include <stdio.h>
#include <math.h>
#include <time.h>
#include "mex.h"

//#define numberCells 8000

/*Declare some global variables that can be used by all functions					*/
const int		   numberCellsPerWidth   = 50;						//Number of cells in each linear direction
const int		   numberCells = numberCellsPerWidth*numberCellsPerWidth*numberCellsPerWidth;		//Number of cells
const long int     initialN    = 20000;								//Number of simulated particles.
long int           N           = initialN;
double             A, dt;											//External magnetic field gradient.
const double       mu          = 9.27e-24;							//Bohr magneton.
const unsigned int numberReal  = (int) 2e8;							//Number of real atoms.
unsigned int       Fn          = numberReal/N;						//Number of real atoms each simulated atom represents.
const double       mass        = 1.443160648e-25;					//Mass of Rubidium 87 atom.
const double	   kB          = 1.38e-23;							//Boltzmann constant.
const double       pi          = 3.14159265;						//Pi
const double       u           = 9.27e-24;							//Bohr Magneton.
unsigned int       numCol      = 0;									//Number of collisions
double             radius      = 0.01;								//Maximum distance to which the cells extend
const unsigned int loopsPerCollision = 10;							//Number of time steps between simulating collisions
unsigned int       numberTruncated = 0;								//Number of evaporated atoms

//Random number Generator
typedef unsigned long long int Ullong;
struct Ran
{
   Ullong u,v,w;
   float x1, x2, q;
   Ran(Ullong j) : v(4101842887655102017LL), w(1)
   {
       u=j^v; int64();
       v=u; int64();
       w=v; int64();
   }
   inline Ullong int64() {
       u = u * 2862933555777941757LL + 7046029254386353087LL;
       v^= v >> 17; v^= v << 31; v^= v >> 8;
       w = 4294957665U*(w & 0xffffffff) + (w >> 32);
       w = 4294957665U*w + (w >> 32);
       Ullong x = u ^ (u<<21); x ^= x >> 35; x ^= x <<4;
       return (x+v)^w;
   }
   inline double doub()
   {
       return 5.42101086242752217E-20 * int64();
   }
    
};

//Ran rf((int)time(NULL));
Ran rf((int)123456);

//Main function
void mexFunction (int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{	
	double                *xo, *vo, *position, *velocity, parameters[nrhs - 4];											//Pointers to the input variables.
	unsigned int          cellCount[numberCells], aCell[initialN], cellIndex[numberCells], sortedAtoms[initialN];	//Counters for the collision algorithm
	double                sigCrMax[numberCells], remainder[numberCells];											//Varaibles required to calculate the number of collision pairs
	long long int         n;																						//Number of time steps to integrate for.   
	unsigned int		  i, numberOfParameters = nrhs - 4;

	void initialiseArrays (unsigned int aCell[initialN], unsigned int sortedAtoms[initialN], double sigCrMax[numberCells], unsigned int cellIndex[numberCells], double *v, double remainder[numberCells]);
	void moveAtoms (long long int n, double dt, double *x, double *v, double parameters[ ], unsigned int aCell[initialN],  unsigned int sortedAtoms[initialN], double sigCrMax[numberCells], unsigned int cellIndex[numberCells],  unsigned int cellCount[numberCells], double remainder[numberCells]);
	
	//Create the output variables
	plhs[0] = mxCreateDoubleMatrix(initialN, 3, mxREAL);
	plhs[1] = mxCreateDoubleMatrix(initialN, 3, mxREAL);
	
	//Assign pointers to the output variables
	position = mxGetPr(plhs[0]);
	velocity = mxGetPr(plhs[1]);
	
	/*Retrieve the input variables.													*/
	n    = mxGetScalar (prhs[0]);
	dt   = mxGetScalar (prhs[1]);
	xo   = mxGetPr (prhs[2]);
	vo   = mxGetPr (prhs[3]);
	
	/*//Find out what kind of trap we are simulating 1 = anti-Helmholtz, 2 = harmonic
	//Assign the trap parameters
	if (mode == 1)
	{
		A[0] = mxGetScalar (prhs[6]);
		A[1] = 0;
		A[2] = 0;
	}
	else if (mode == 2) 
	{
		omega[0] = mxGetScalar (prhs[6]);
		omega[1] = mxGetScalar (prhs[7]);
		omega[2] = mxGetScalar (prhs[8]);
	}*/
	
	for (i = 0; i < nrhs - 4; i++)
	{
		parameters[i] = mxGetScalar (prhs[i + 4]);
	}
	
	
	
	/*Initialise the counting arrays used for the collision step					*/
	initialiseArrays (aCell, sortedAtoms, sigCrMax, cellIndex, vo, remainder);
	/*Move the atoms N time steps using the Beeamn Algorithm						*/
	moveAtoms (n, dt, xo, vo, parameters, aCell, sortedAtoms, sigCrMax, cellIndex, cellCount, remainder);
	
	//Assign final distribution to the output variable
	for ( i = 0; i < 3*initialN; i++)
	{
		position[i] = xo[i];
		velocity[i] = vo[i];
	}
	
	printf("Number of collisions: %i\n", numCol);
	printf("Number of atoms in the last cell: %i\n", cellCount[numberCells - 1]);
	printf("Number of atoms evaporated: %i\n", numberTruncated);
}

//Set all of the initial cell counters to zero and guess initial values for sigCrMax
void initialiseArrays(unsigned int aCell[initialN],  unsigned int sortedAtoms[initialN], double sigCrMax[numberCells], unsigned int cellIndex[numberCells], double *v, double remainder[numberCells]) 
{	
	register unsigned int i;
	const double          a         = 5.3e-9;                    //constant crosssection formula
	double                velocity2 = 0;
	double                T;                 
		
	//Set initial cell counters to zero
	for( i = 0; i < N; i++)
	{
		aCell[i] = 0;
		sortedAtoms[i] = 0;
    }
	
	//Initialise the sigCrMax in each cell
    for ( i = 0; i < numberCells; i++)
	{
		sigCrMax[i]  = 8*pi*a*a;
		cellIndex[i] = 0;
		remainder[i] = 0;
    }
}

//Move and collide atoms
void moveAtoms (long long int n, double dt, double *x, double *v, double parameters[ ], unsigned int aCell[initialN],  unsigned int sortedAtoms[initialN], double sigCrMax[numberCells], unsigned int cellIndex[numberCells],  unsigned int cellCount[numberCells], double remainder[numberCells])
{
	register unsigned long long int i, j;
	double							xold[3*initialN], axold[initialN], ayold[initialN], azold[initialN], ax[initialN], ay[initialN], az[initialN], axnew[initialN], aynew[initialN], aznew[initialN];
	double                          potential, Tx, Ty, Tz, T, velocity2x = 0, velocity2y = 0, velocity2z = 0;
	double							collisionTime = dt*loopsPerCollision;
	double                          kineticEnergyx, kineticEnergyy, kineticEnergyz, kineticEnergy, avgKinetic, time, distance, pace;
	double                          potentialEnergy, potentialEnergyx, potentialEnergyy, potentialEnergyz, avgPotential;	
	double							potential2 = 0, potential2x = 0, potential2y = 0, potential2z = 0;
	FILE							*location, *speed, *output, *singleAtom, *singleVelocity;
	
	void zero_counts (unsigned int cellCount[numberCells]);
	void bin_atoms (double *position, unsigned int cellCount[numberCells], unsigned int aCell[initialN]);
	void collideAtoms (double *position, double collisionTime, double *velocity, double T, unsigned int aCell[initialN],  unsigned int sortedAtoms[initialN], double sigCrMax[numberCells], unsigned int cellIndex[numberCells], unsigned int cellCount[numberCells], double remainder[numberCells]);
	void evaporateAtoms (double *x, double *v, unsigned int aCell[initialN], double parameters[ ], double avgKinetic, double avgPotential);
	
	//Open an output file to store all of the useful thermdynamic data
	output = fopen ("output.txt", "w");
	
	if (output == NULL)
	{
		printf("An error occured while creating the output file.\n");
	}
	
	/*Need to initialise the Beeman method by finding the n = -1 values*/
	# if trap == 1 
	{
		for (i = 0; i < N; i++)
		{
			xold[i]            = x[i]            - v[i]*dt;
			xold[i+initialN]   = x[i+initialN]   - v[i+initialN]*dt;
			xold[i+2*initialN] = x[i+2*initialN] - v[i+2*initialN]*dt;
		
			potential = -mu*parameters[1]*dt/(2*mass*sqrt(xold[i]*xold[i] + xold[i+initialN]*xold[i+initialN] + 4*xold[i+2*initialN]*xold[i+2*initialN]));
			
			axold[i] = potential*xold[i];
			ayold[i] = potential*xold[i+initialN];
			azold[i] = 4.0*potential*xold[i+2*initialN];
		}
	}
	#elif trap == 2
	{
		for (i = 0; i < N; i++)
		{
			xold[i]            = x[i]            - v[i]*dt;
			xold[i+initialN]   = x[i+initialN]   - v[i+initialN]*dt;
			xold[i+2*initialN] = x[i+2*initialN] - v[i+2*initialN]*dt;
		
			axold[i] = -parameters[1]*parameters[1]*xold[i];
			ayold[i] = -parameters[2]*parameters[2]*xold[i+initialN];
			azold[i] = -parameters[3]*parameters[3]*xold[i+2*initialN];
		}
	}
	#endif
	
	/*Evaluate the solution over n time steps											*/
	for (j = 0; j < n; j++)
	{
		//Set variables used to evaluate the kinetic and potential energies to zero
		velocity2x  = 0;
		velocity2y  = 0;
		velocity2z  = 0;
		
		potential2  = 0;
		potential2x = 0;
		potential2y = 0;
		potential2z = 0;

		/*Evaluate the solution for one time step using the Beeman algorithm.			*/
		for (i = 0; i < N; i++)
		{
			# if trap == 1 
			{
				//Variable used to calculate the accelerations
				potential = -mu*parameters[1]*dt/(2*mass*sqrt(x[i]*x[i] + x[i+initialN]*x[i+initialN] + 4*x[i+2*initialN]*x[i+2*initialN]));
			
				//Calculate the accelerations in each direction
				ax[i] = potential*x[i];
				ay[i] = potential*x[i+initialN];
				az[i] = 4.0*potential*x[i+2*initialN];
			}
			#elif trap == 2
			{
				//Calculate the accelerations
				ax[i] = -parameters[1]*parameters[1]*x[i];
				ay[i] = -parameters[2]*parameters[2]*x[i+initialN];
				az[i] = -parameters[3]*parameters[3]*x[i+2*initialN];
			}
			#endif
				
			//Update the position
			x[i]            = x[i]            + v[i]*dt            + (1.0/6.0) * (4*ax[i] - axold[i]) * dt * dt;											//xn+1
			x[i+initialN]   = x[i+initialN]   + v[i+initialN]*dt   + (1.0/6.0) * (4*ay[i] - ayold[i]) * dt * dt;											//yn+1	
			x[i+2*initialN] = x[i+2*initialN] + v[i+2*initialN]*dt + (1.0/6.0) * (4*az[i] - azold[i]) * dt * dt;											//zn+1
				
			# if trap == 1 
			{
				potential = -mu*parameters[1]*dt/(2*mass*sqrt(x[i]*x[i] + x[i+initialN]*x[i+initialN] + 4*x[i+2*initialN]*x[i+2*initialN]));
			
				//Recalculate the accelerations in each direction
				axnew[i] = potential*x[i];
				aynew[i] = potential*x[i+initialN];
				aznew[i] = 4.0*potential*x[i+2*initialN];
			}
			#elif trap == 2
			{
				//Recalculate the accelerations
				axnew[i] = -parameters[1]*parameters[1]*x[i];
				aynew[i] = -parameters[2]*parameters[2]*x[i+initialN];
				aznew[i] = -parameters[3]*parameters[3]*x[i+2*initialN];
			}
			#endif
				
			//Update the velcoities
			v[i]            = v[i]            + (1.0/6.0) * (2*axnew[i] + 5*ax[i] - axold[i]) * dt;															//vxn+1
			v[i+initialN]   = v[i+initialN]   + (1.0/6.0) * (2*aynew[i] + 5*ay[i] - ayold[i]) * dt;															//vyn+1
			v[i+2*initialN] = v[i+2*initialN] + (1.0/6.0) * (2*aznew[i] + 5*az[i] - azold[i]) * dt;															//vzn+1
			
			axold[i] = ax[i];
			ayold[i] = ay[i];
			azold[i] = az[i];
			
			//ax[i] = axnew[i];
			//ay[i] = aynew[i];
			//az[i] = aznew[i];
			
			velocity2x  += v[i]*v[i];
			velocity2y  += v[i+initialN]*v[i+initialN];
			velocity2z  += v[i+2*initialN]*v[i+2*initialN];
			
			# if trap == 1 
			{
				potential2 += sqrt(x[i]*x[i] + x[i+initialN]*x[i+initialN] + 4*x[i+2*initialN]*x[i+2*initialN]);
			}
			#elif trap == 2
			{
				potential2 += parameters[1] * parameters[1] * x[i]*x[i] + parameters[2] * parameters[2] * x[i+initialN]*x[i+initialN] + parameters[3] * parameters[3] * x[i+2*initialN]*x[i+2*initialN];
			}
			#endif
		}
		
		
		//Calculate the potential and kinetic energies
		kineticEnergyx   = 0.5 * mass * velocity2x;
		kineticEnergyy   = 0.5 * mass * velocity2y;
		kineticEnergyz   = 0.5 * mass * velocity2z;
		kineticEnergy    = kineticEnergyx + kineticEnergyy + kineticEnergyz;
		avgKinetic       = kineticEnergy / N;
		
		# if trap == 1 
		{
			potentialEnergy    = 0.5 * mu * parameters[1] * potential2;
			avgPotential       = potentialEnergy / N;
		}
		#elif trap == 2
		{
			potentialEnergy = 0.5 * mass * potential2;
			avgPotential    = potentialEnergy / N;
		}
		#endif
		
		Tx = 2.0 * kineticEnergyx / N / kB;
		Ty = 2.0 * kineticEnergyy / N / kB;
		Tz = 2.0 * kineticEnergyz / N / kB;
		T  = 1 / 3.0 * kineticEnergy / N / kB;
		
		time = j * dt;
		
		//Print the useful thermodynamic quantities in the output file
		fprintf(output, "%3.6g %i %6.6g %6.6g %6.6g %6.6g %6.6g %6.6g\n", time, N*Fn, Tx, Ty, Tz, T, avgKinetic, avgPotential);
		
		//Collide atoms every loopsPerCollision time steps, evaporate atoms here aswell
		if (j % loopsPerCollision == 0 && j > 0)
		{
			collideAtoms (x, collisionTime, v, T, aCell,  sortedAtoms, sigCrMax, cellIndex, cellCount, remainder);
			evaporateAtoms (x, v, aCell, parameters, avgKinetic, avgPotential);
		}
		
	}
	
	//Close the output file
	fclose(output);
}

//Collision Algorithm
void collideAtoms (double *position, double collisionTime, double *velocity, double T, unsigned int aCell[initialN],  unsigned int sortedAtoms[initialN], double sigCrMax[numberCells], unsigned int cellIndex[numberCells], unsigned int cellCount[numberCells], double remainder[numberCells]) 
{
	register unsigned int i          = 0;
	const double          a          = 5.3e-9;                    //constant crosssection formula
	double                cellLength = 2.0 * radius / (numberCellsPerWidth);
	double                VC         = cellLength * cellLength * cellLength;
	double                Aselect;
	int                   Nselect;
	double                B, A, C, VR, crossSection;
	double                Vrel[3], newV[3], Vcm[3];
	unsigned int          atom1, atom2;
	
	void zero_counts (unsigned int cellCount[numberCells]);
	void bin_atoms (double *position, unsigned int cellCount[numberCells], unsigned int aCell[initialN]);
	void index_cells (unsigned int cellCount[numberCells], unsigned int cellIndex[numberCells]);
	void sort_atoms(unsigned int aCell[initialN], unsigned int cellIndex[numberCells], unsigned int cellCount[numberCells], unsigned int sortedAtoms[initialN]);
	
	//Zero the counter for the number of atoms in each cell
	zero_counts (cellCount);
	//Allocate the atoms to a particular cell
	bin_atoms (position, cellCount, aCell);
	//Number each atom with its particular cell number
	index_cells (cellCount, cellIndex);
	//Place atoms in an array in cell order
	sort_atoms (aCell, cellIndex, cellCount, sortedAtoms);
	
	//Calculate the collision cross Section
	crossSection = 8*pi*a*a;
   
   //Consider collisions in each cell
	while (i < (numberCells - 1)) 
	{
		if (cellCount[i] > 1) 
		{
			//Calculate the number of pairs to collide
			Aselect = 0.5 * cellCount[i] * cellCount[i] * Fn * sigCrMax[i] * collisionTime / VC + remainder[i];
			Nselect = (int) Aselect;
			remainder[i] = Aselect - Nselect;
			
			while (Nselect >= 0) 
			{

				//If there are not enough atoms to collide add Nselect to the remainder to be used next time
				if (Nselect < 2)
				{
					remainder[i] += Nselect;
					Nselect       = 0;
				}
				else
				{
					atom1 = atom2 = 0;
					
					//randomly choose particles to collide
					while (atom1 == atom2) 
					{
						atom1 = sortedAtoms[cellIndex[i] + (int)(rf.doub()*cellCount[i])];
						atom2 = sortedAtoms[cellIndex[i] + (int)(rf.doub()*cellCount[i])];
					}
				
					//Calculate their average speed
					Vrel[0] = velocity[atom1]            - velocity[atom2];
					Vrel[1] = velocity[atom1+initialN]   - velocity[atom2+initialN];
					Vrel[2] = velocity[atom1+2*initialN] - velocity[atom2+2*initialN];
					VR      = sqrt(Vrel[0]*Vrel[0] + Vrel[1]*Vrel[1] + Vrel[2]*Vrel[2]);
				
					//Collide with the collision probability
					if ((VR*crossSection/sigCrMax[i]) > rf.doub()) 
					{    
						//Find centre of mass velocities
						Vcm[0] = 0.5*(velocity[atom1]            + velocity[atom2]);
						Vcm[1] = 0.5*(velocity[atom1+initialN]   + velocity[atom2+initialN]);
						Vcm[2] = 0.5*(velocity[atom1+2*initialN] + velocity[atom2+2*initialN]);
	    
						//Calculate the new center of mass velcoities using the Marsaglia algorithm
						B       = 2*rf.doub() - 1;
						A       = sqrt(1 - B*B);
						C       = 2*pi*rf.doub();
						newV[0] = B*VR;
						newV[1] = A*VR*cos(C);
						newV[2] = A*VR*sin(C);
						
						//Calculate the post collison velocities
						velocity[atom1]            = Vcm[0] - 0.5*newV[0];
						velocity[atom1+initialN]   = Vcm[1] - 0.5*newV[1];
						velocity[atom1+2*initialN] = Vcm[2] - 0.5*newV[2];
						velocity[atom2]            = Vcm[0] + 0.5*newV[0];
						velocity[atom2+initialN]   = Vcm[1] + 0.5*newV[1];
						velocity[atom2+2*initialN] = Vcm[2] + 0.5*newV[2];
						
						//Count the collsion
						numCol++;
					}
				}
				
				//Check if this is the more probable than current most probable 
				if (VR*crossSection > sigCrMax[i]) 
				{
					sigCrMax[i] = VR * crossSection;
				}
				
				//Decrese the number of pairs to select and move on to the next pair
				Nselect += -1;
			}
		}
		i++;
	}
}

//Zero the number of atoms in each cell counter
void zero_counts (unsigned int cellCount[numberCells]) 
{
	register unsigned int i;
	for (i = 0; i < numberCells; i++)
	{
		cellCount[i] = 0;
	}
}

//Assign atoms to a particular cell
void bin_atoms (double *position, unsigned int cellCount[numberCells], unsigned int aCell[initialN]) 
{
	register unsigned int i;
	unsigned int          cellnum;
	double				  x, y, z;
	double                invcellLength = (double) numberCellsPerWidth / 2.0 / radius;				//Inverse of the cell length

	for (i = 0; i < N; i++) 
	{
		x = position[i];
		y = position[i+initialN];
		z = position[i+2*initialN];
		
		if (x*x + y*y + z*z < radius*radius)
		{
			cellnum = (unsigned int)((x+radius)*invcellLength) + (unsigned int)((y+radius)*invcellLength) * numberCellsPerWidth + (unsigned int)((z+radius)*invcellLength) * numberCellsPerWidth * numberCellsPerWidth;
			aCell[i] = cellnum;
			cellCount[cellnum]++;
		}
		else
		{
			aCell[i] = numberCells - 1;
			cellCount[numberCells - 1]++;
		}
	}
}

//Take note of the particular cell that each atoms is in
void index_cells (unsigned int cellCount[numberCells], unsigned int cellIndex[numberCells]) 
{
	register unsigned int i = 0, accum = 0;
  
	for (i = 0; i < numberCells; i++)    
	{
		cellIndex[i] = accum;
		accum += (int)cellCount[i];
		cellCount[i] = 0;
	}
}

//Arrange atom sin cell order
void sort_atoms(unsigned int aCell[initialN], unsigned int cellIndex[numberCells], unsigned int cellCount[numberCells], unsigned int sortedAtoms[initialN]) 
{
	register unsigned int i;
	unsigned int          cellnum;
  
	for (i = 0; i < N; i++)     
	{
		cellnum = aCell[i];
		sortedAtoms[(int)cellIndex[cellnum]+cellCount[cellnum]] = i;
		cellCount[cellnum] += 1;
	}
}

//Evaporate atoms
void evaporateAtoms (double *x, double *v, unsigned int aCell[initialN], double parameters[ ], double avgKinetic, double avgPotential)
{
	int    i, j;
	double potential, kinetic;
	double cutoff = (1.0 + parameters[0]) *  (avgPotential + avgKinetic);
	
	for (i = 0; i < N;)
	{
		//If the total energy of a particular particle is greater than (1 + beta) * averageEnergy then remove it from the simulation
		//This is doen by moving it to the end of the array and reducing the N, which is the variable that keeps track of the effective 
		//Length of a array.
		#if trap == 1
		{
			if (0.5 * mu * parameters[1] * sqrt(x[i] * x[i] + x[i+initialN] * x[i+initialN] + 4 * x[i+2*initialN] * x[i+2*initialN]) > cutoff)
			{
				x[i]            = x[N-1];
				x[i+initialN]   = x[initialN + N-1];
				x[i+2*initialN] = x[2*initialN + N-1];
				
				v[i]            = v[N-1];
				v[i+initialN]   = v[initialN + N-1];
				v[i+2*initialN] = v[2*initialN + N-1];
			
				aCell[i] = aCell[N-1];
				N = N - 1;
				numberTruncated += Fn;
			}
			else
			{
				i++;
			}
		}
		#elif trap == 2
		{
			kinetic   = 0.5 * mass * (v[i] * v[i] + v[i+initialN]*v[i+initialN] + v[i+2*initialN]*v[i+2*initialN]);
			potential = 0.5 * mass * (parameters[1] * parameters[1] * x[i] * x[i] + parameters[2] * parameters[2] * x[i+initialN] * x[i+initialN] + parameters[3] * parameters[3] * x[i+2*initialN] * x[i+2*initialN]);
			
			if (potential + kinetic > cutoff)
			{
				x[i]            = x[N-1];
				x[i+initialN]   = x[initialN + N-1];
				x[i+2*initialN] = x[2*initialN + N-1];
				
				v[i]            = v[N-1];
				v[i+initialN]   = v[initialN + N-1];
				v[i+2*initialN] = v[2*initialN + N-1];
			
				aCell[i] = aCell[N-1];
				N = N - 1;
				numberTruncated += Fn;
			}
			else
			{
				i++;
			}
		}
		#endif
	}
	
	//If the number of remaining atoms gets below 4000 then halve Fn and double N
	if (N < 4000)
	{
		for (j = 1; j <= N; j++)
		{
			x[2*N - j]              = -x[N - j];
			x[2*N - j + initialN]   = -x[N - j + initialN];
			x[2*N - j + 2*initialN] =  x[N - j + 2*initialN];
			
			v[2*N - j]              = -v[N - j];
			v[2*N - j + initialN]   = -v[N - j + initialN];
			v[2*N - j + 2*initialN] =  v[N - j + 2*initialN];
		}
		
		N = 2*N;
		Fn = Fn/2;
	}
}

