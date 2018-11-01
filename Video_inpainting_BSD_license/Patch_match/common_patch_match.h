//common includes necessary for the maximum meaningful code

#ifndef COMMON_PATCH_MATCH_H
#define COMMON_PATCH_MATCH_H

	#include <math.h>
	#include <float.h>
	#include <stdio.h>
	#include <stdlib.h>
	#include <time.h>
    #include <ctime>
    #include <cstdlib> // C standard library
    #include <fstream> // file I/O
    #include <iostream>
	//#include <windows.h>
        
    //CUDA INCLUDES
//     #include <cuda.h>
//     #include <cutil.h>
//     #include <cutil_inline.h>
//     #include <cuda_runtime.h>

    #include "mex.h"

	#ifndef MY_PRINTF
	#define MY_PRINTF mexPrintf
	#endif
            
    /** PI */
	#ifndef M_PI
	#define M_PI   3.14159265358979323846
	#endif
            
    #ifndef DEBUG_ON
	#define DEBUG_ON 0
	#endif


#endif
