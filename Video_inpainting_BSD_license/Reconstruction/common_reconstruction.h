/*common includes necessary for the video reconstruction*/

#ifndef COMMON_RECONSTRUCTION_H
#define COMMON_RECONSTRUCTION_H

	#include <math.h>
	#include <float.h>
	#include <stdio.h>
	#include <stdlib.h>
	#include <time.h>
	//#include <windows.h>
    #include <vector>
    #include <utility>
    #include <numeric>
    #include <algorithm>

	#ifndef MY_PRINTF
	#define MY_PRINTF mexPrintf
	#endif
        
    #ifndef NCHANNELS
    #define NCHANNELS 3
    #endif

    #ifndef WEIGHTED_MEAN_RECONSTRUCTION
    #define WEIGHTED_MEAN_RECONSTRUCTION 0
    #endif

    #ifndef BEST_PATCH_RECONSTRUCTION
    #define BEST_PATCH_RECONSTRUCTION 1
    #endif

    #ifndef NEAREST_NEIGHBOUR_RECONSTRUCTION
    #define NEAREST_NEIGHBOUR_RECONSTRUCTION 2
    #endif

#endif
