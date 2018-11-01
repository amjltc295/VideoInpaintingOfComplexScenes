/*this is the include function for the reconstruction of the video and features*/

#ifndef VIDEOS_RECONSTRUCTION_H
#define VIDEOS_RECONSTRUCTION_H


	#include "common_reconstruction.h"
    #include "../Image_structures/image_structures.h"
    #include "reconstruction_tools.h"

    template <class T>
    int check_is_occluded( nTupleVolume<T> *imgVolOcc, int x, int y, int t);

    template <class T>
    int check_disp_field(nTupleVolume<T> *dispField, nTupleVolume<T> *departVolume, nTupleVolume<T> *arrivalVolume, nTupleVolume<T> *occVol);
	
    template <class T>
    void reconstruct_videos(nTupleVolume<T>* imgVol, nTupleVolume<T>* occVol,
            nTupleVolume<T> *gradXvol, nTupleVolume<T> *gradYvol, nTupleVolume<T> *normGradXvol, nTupleVolume<T> *normGradYvol,
            nTupleVolume<T>* dispField, float sigmaColour, int useAllPatches, int reconstructionType);

#endif