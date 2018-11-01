//this function defines the image structures for use with patch match

#ifndef IMAGE_STRUCTURES_H
#define IMAGE_STRUCTURES_H

	#include <math.h>
	#include <float.h>
	#include <stdio.h>
	#include <stdlib.h>
	#include <time.h>
    #include <ctime>
    #include <cstdlib> // C standard library
    #include <string>
    #include <sstream>
    #include <fstream> // file I/O
    #include <iostream>
    #include <utility>
    #include <stdexcept>
    #include <vector>
    #include <queue>
    #include <bitset>
	//#include <windows.h>
        
    using std::string;
    using std::runtime_error;

    #include "mex.h"

	#ifndef MY_PRINTF
	#define MY_PRINTF mexPrintf
	#endif
            
    /** PI */
	#ifndef M_PI
	#define M_PI   3.14159265358979323846
	#endif
            
    #ifndef BYTE_SIZE
	#define BYTE_SIZE 8
	#endif
        
    #ifndef DESCRIPTOR_SIZE
	#define DESCRIPTOR_SIZE 128
	#endif
    
    #ifndef mxPOINTER_CLASS
    #define mxPOINTER_CLASS mxUINT64_CLASS
    #endif
            
    typedef uint64_T pointer_t;
            
    #ifndef ASSERT
    #define ASSERT(cond) if (!(cond)) { std::stringstream sout; \
        sout << "Error (line " << __LINE__ << "): " << #cond; \
        throw runtime_error(sout.str()); }
    #endif

    #define GET_VALUE get_value_nTuple_volume
	#define NDIMS 3
	typedef struct coordinate
	{
		int x;
		int y;
		int t;
	}coord;
    
    int earlyTerminationInd;
    float earlyTermination;
    int totalTerminationInd;
    
    float randomGenerationTime;
    float ssdTime;
    
    typedef struct param
	{
        int patchSizeX;
        int patchSizeY;
        int patchSizeT;
		int nIters;
		int w;
		float alpha;
        int partialComparison;
        int fullSearch;
        int patchIndexing;
        float *gradX;
        float *gradY;
        float *normGradX;
        float *normGradY;
	}parameterStruct;
    
    //various typedefs
    typedef std::pair<float,float> pairFloat;
    typedef std::pair<int,float> pairIntFloat;
    typedef std::vector<pairIntFloat> vectorPairIntFloat;

    template <class T>
	class nTupleVolume
	{
        private:
            T *values;
        
        public:
            int nTupleSize;
            int xSize;
            int ySize;
            int tSize;
            int patchSizeX;
            int patchSizeY;
            int patchSizeT;
            int hPatchSizeX;
            int hPatchSizeY;
            int hPatchSizeT;
            int nElsTotal;

            int nX;
            int nY;
            int nT;

			int nDims;
                        
            int indexing;
            int destroyValues;
            
            nTupleVolume(); //create an empty volume
            nTupleVolume(nTupleVolume<T> *imgVolIn);
            nTupleVolume(int nTupleSizeIn, int xSizeIn, int ySizeIn, int tSizeIn, int indexingIn);
            nTupleVolume(int nTupleSizeIn, int xSizeIn, int ySizeIn, int tSizeIn, int patchSizeXIn, int patchSizeYIn, int patchSizeTIn, int indexingIn);
            nTupleVolume(int nTupleSizeIn, int xSizeIn, int ySizeIn, int tSizeIn, int patchSizeXIn, int patchSizeYIn, int patchSizeTIn, int IndexingIn, T* valuesIn);
            ~nTupleVolume();

            T get_value(int x, int y, int t, int z);
            T* get_value_ptr(int x, int y, int t, int z);
            T* get_begin_ptr(int x, int y, int t);
            void set_value(int x, int y, int t, int z, T value);
	};
    
float min_float(float a, float b);
float max_float(float a, float b);
int min_int(int a, int b);
int max_int(int a, int b);

float rand_float_range(float a, float b);
int rand_int_range(int a, int b);
float round_float(float a);

// LINEAR INDEXING
template <class T>
void ind_to_sub(nTupleVolume<T>* imgVol, int linearIndex, int *x, int *y, int *t);
template <class T>
int sub_to_ind(nTupleVolume<T>* imgVol, int x, int y, int t);
//without nTupleVolume
int sub_to_ind(int xSize, int ySize, int tSize, int x, int y, int t);
void ind_to_sub(int xSize, int ySize, int tSize, int linearIndex, int *x, int *y, int *t);
int sub_to_ind(int nTupleSize, int xSize, int ySize, int tSize, int x, int y, int t, int nTuple);
void ind_to_sub(int nTupleSize, int xSize, int ySize, int tSize, int linearIndex, int *x, int *y, int *t, int *nTuple);

template <class T>
void patch_index_to_sub(nTupleVolume<T> *imgVol, int patchIndex, int& colourInd,int &xInd, int &yInd,int &tInd);

//Parser functions
void parse_patch_match_parameters(const mxArray* prhs,parameterStruct* patchMatchParams);

float pow_int(float a, int b);

template <class T>
int check_in_boundaries( nTupleVolume<T> *imgVol, int x, int y, int t, const parameterStruct *params);
template <class T>
int check_in_inner_boundaries( nTupleVolume<T> *imgVol, int x, int y, int t, const parameterStruct *params);
template <class T>
void clamp_coordinates(nTupleVolume<T>* imgVolA, int *x, int *y, int *t);

//copy the pixel array from the point in imgVolA(xA,yA,tA) to imgVolB(xB,yB,tB)
template <class T>
void copy_pixel_values_nTuple_volume(nTupleVolume<T>* imgVolA, nTupleVolume<T>* imgVolB, int x1, int y1, int t1, 
									 int x2, int y2, int t2);

#endif