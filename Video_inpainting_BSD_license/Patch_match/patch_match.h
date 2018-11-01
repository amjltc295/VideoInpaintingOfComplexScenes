//this is the include function for the spatio-temporal patch-match

#ifndef PATCH_MATCH_H
#define PATCH_MATCH_H


	#include "common_patch_match.h"
    #include "../Image_structures/image_structures.h"
	#include "patch_match_tools.h"

    template <class T>
	nTupleVolume<T> * patch_match_ANN(nTupleVolume<T> *imgVolA, nTupleVolume<T> *imgVolB, nTupleVolume<T> *firstGuessVol,
        nTupleVolume<T> *imgVolOcc, nTupleVolume<T> *imgVolMod, 
        const parameterStruct *params);

    template <class T>
	nTupleVolume<T> * wrapper_patch_Match_ANN(T *videoA, T *videoB, T *videoFirstGuess, T *videoOcc, T *videoMod,
                                    int xSizeA, int ySizeA, int tSizeA, 
									int xSizeB, int ySizeB, int tSizeB, int nTupleSize,
                                    int patchSizeX, int patchSizeY, int patchSizeT,
                                    const parameterStruct *params);
#endif