#include <math.h>
#include <stdio.h>
#include <iostream>
using namespace std;


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

int main(void) {   
    double randomNumber = rf.doub();
	printf("%d \n", randomNumber);
	cin.get();
} 