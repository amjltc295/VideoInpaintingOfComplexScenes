//this function defines the tools necessary for the spatio-temporal patch match algorithm

#ifndef PATCH_MATCH_TOOLS
#define PATCH_MATCH_TOOLS

	#include "common_patch_match.h"
	#include "../Image_structures/image_structures.h"
    #include "patch_match_measure.h"
    
    bool check_min_shift_distance(int xShift,int yShift,int tShift, const parameterStruct *params);
	template <class T>
    int check_is_occluded( nTupleVolume<T> *imgVolOcc, int x, int y, int t);
    template <class T>
    bool check_already_used_patch( nTupleVolume<T> *dispField, int x, int y, int t, int dispX, int dispY, int dispT);
    template <class T>
    int check_in_boundaries( nTupleVolume<T> *imgVol, int x, int y, int t, const parameterStruct *params);
	template <class T>
    int check_in_inner_boundaries( nTupleVolume<T> *imgVol, int x, int y, int t, const parameterStruct *params);
    
    //full search
    template <class T>
    void patch_match_full_search(nTupleVolume<T> *dispField, nTupleVolume<T> *imgVolA,nTupleVolume<T> *imgVolB,
            nTupleVolume<T> *occVol,nTupleVolume<T> *modVol, const parameterStruct *params);
    
    //shift volume initialisation
    template <class T>
    void initialise_displacement_field(nTupleVolume<T> *dispField, nTupleVolume<T> *departVolume, nTupleVolume<T> *arrivalVolume,
            nTupleVolume<T> *firstGuessVolume, nTupleVolume<T> *occVol, const parameterStruct *params);
	
    //Random search
    template <class T>
	int patch_match_random_search(nTupleVolume<T> *dispField, nTupleVolume<T> *imgVolA, nTupleVolume<T> *imgVolB,
            nTupleVolume<T> *occVol,  nTupleVolume<T> *modVol, const parameterStruct *params);
    
    //propagation functions
    template <class T>
    int patch_match_propagation(nTupleVolume<T> *dispField, nTupleVolume<T> *departVolume, nTupleVolume<T> *arrivalVolume,
            nTupleVolume<T> *occVol,  nTupleVolume<T> *modVol,
		const parameterStruct *params, int iterationNb);
    template <class T>
    int patch_match_long_propagation(nTupleVolume<T> *dispField, nTupleVolume<T> *imgVolA, nTupleVolume<T> *imgVolB,
            nTupleVolume<T> *occVol,  nTupleVolume<T> *modVol, const parameterStruct *params);
    template <class T>
    float calclulate_patch_error(nTupleVolume<T> *departVolume,nTupleVolume<T> *arrivalVolume,nTupleVolume<T> *dispField, nTupleVolume<T> *occVol,
		int xA, int yA, int tA, float minError, const parameterStruct *params);
    template <class T>
	float get_min_correct_error(nTupleVolume<T> *dispField,nTupleVolume<T> *departVol,nTupleVolume<T> *arrivalVol, nTupleVolume<T> *occVol,
							int x, int y, int t, int beforeOrAfter, int *correctInd, float *minVector, float minError,
                            const parameterStruct *params);
    template <class T>
	float ssd_minimum_value(nTupleVolume<T> *imgVolA, nTupleVolume<T> *imgVolB, nTupleVolume<T> *occVol, int xA, int yA, int tA,
						int xB, int yB, int tB, float minVal, const parameterStruct *params);

    //utility functions
    template <class T>
	int check_disp_field(nTupleVolume<T> *dispField, nTupleVolume<T> *departVolume, nTupleVolume<T> *arrivalVolume,
            nTupleVolume<T> *occVol, const parameterStruct *params);
#endif