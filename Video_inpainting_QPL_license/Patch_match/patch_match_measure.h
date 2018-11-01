
//this function declares the patch match measure with which we compare patches


#ifndef PATCH_MATCH_MEASURE_H
#define PATCH_MATCH_MEASURE_H

    #include "common_patch_match.h"
    #include "../Image_structures/image_structures.h"

    template <class T>
    float ssd_patch_measure(nTupleVolume<T> *imgVolA, nTupleVolume<T> *imgVolB, nTupleVolume<T> *dispField, nTupleVolume<T> *occVol, int xA, int yA, int tA,
                    int xB, int yB, int tB, float minVal, const parameterStruct *params);

#endif