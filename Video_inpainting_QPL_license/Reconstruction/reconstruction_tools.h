/*this function defines the tools necessary for the reconstruction algorithm*/

#ifndef RECONSTRUCTION_TOOLS
#define RECONSTRUCTION_TOOLS

	#include "common_reconstruction.h"
	#include "../Image_structures/image_structures.h"
    
    template <class T>
	int check_is_occluded( nTupleVolume<T> *imgVolOcc, int x, int y, int t);
    
    template <class T>
	int check_in_inner_boundaries( nTupleVolume<T> *imgVol, int x, int y, int t);
    
    template <class T>
    int check_disp_field(nTupleVolume<T> *dispField, nTupleVolume<T> *departVolume, nTupleVolume<T> *arrivalVolume, nTupleVolume<T> *occVol);
    
    float get_adaptive_sigma(float *weights, int weightsLength, float percentileSigma);
 
    template <class T>
    int estimate_best_colour(nTupleVolume<T> *imgVol, nTupleVolume<T> *imgVolModified,float *weights, int weightsLength,
                                float *colours, float sigmaColour, int i, int j, int k);
    
#endif