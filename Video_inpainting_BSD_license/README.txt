Copyright (c) 2014, Alasdair Newson, Andrés Almansa, Matthieu Fradet, Yann Gousseau, Patrick Pérez
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors
may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

This file explains how to use the video inpainting code in this directory. Please read all of the
file before asking any questions, as a lot of information is contained here.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% TERMS OF USE %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

If you wish to use this code, please cite the following paper :

Video Inpainting of Complex Scenes
Alasdair Newson, Andrés Almansa, Matthieu Fradet, Yann Gousseau, Patrick Pérez
SIAM Journal of Imaging Science 2014 7:4, 1993-2019 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% INSTALLATION %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

To install the software, you need to be able to compile mex files on your
machine. If you do not know how to do this, type 'mex -setup' in the
Matlab command window. The code has been tested for Visual Studio 2008
and gcc compilers in Matlab.

Extract the source code to a directory and cd to this directory
in a matlab command window. Now execute the following script :

>> make_all_mex_files

If this is done successfully, you should have the following output :

Compiling spatio-temporal PatchMatch
Compiling reconstruction of the video
Compiling reconstruction of the texture features
Compiling the random numbers seed

If not, then please contact the author for help!

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% USAGE %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

There is a demonstration matlab script 'video_inpainting_demo.m',
which 

The inpainting may be started with the function 'start_inpaint_wexler'.

To test the inpainting, you can try the following command :
>> video_inpainting_demo

This is a simple example which should execute with success. The demo
file calls the 'start_inpaint_wexler' function, which in turn
calls the video inpainting function 'inpaint_wexler'.

The function 'start_inpaint_wexler' may be called in several ways :

1/ start_inpaint_wexler(videoFileName,occlusionFileName);
	If called in this way, the input video is given by videoFileName
	and the input occlusion is given by occlusionFileName. This means that the video input
	file should be a video (.avi etc...). The occlusion may be a video or image file. If it
	is an image file, then the occlusion is considered to be the same for each frame.
	
2/ start_inpaint_wexler(videoFileName,occlusionFileName,'all');
	If called in this way, the input files are all those files beginning with 'videoFileName'
	and 'occlusionFileName'. It is up to the user to make sure that the files are named
	correctly so that they are read in the right order, which means for example putting
	zeros in front of the frame number.
	
3/ start_inpaint_wexler(videoFileName,occlusionFileName,firstFrameNb,lastFrameNb);
	If called this way, the video file is created out of the concatenation of
	the images starting with 'videoFileName' and going from firstFrame to lastFrame.
	Note that no zeros should be in front of the frame number in this case. The occlusion
	is assumed to be either a video or a single frame
	
4/ start_inpaint_wexler(videoFileName,occlusionFileName,firstFrameNbVideo,lastFrameNbVideo,firstFrameNbOcclusion,lastFrameNbOcclusion);
	If called this way, the video file is created out of the concatenation of
	the images starting with 'videoFileName' and going from firstFrame to lastFrame.
	Note that no zeros should be in front of the frame number in this case. The occlusion
	is created in the same manner. Obviously the lengths of the video and the occlusion
	must be the same.
	
	
Please note that if the user specifies a first and last frame number, but provides a
video file, not an image file, then the frame numbers are ignored and the video files
are read as usual.

!!!! NOTE !!!!! Matlab is very touchy about video files. The only ones which usually work
are non-compressed avi files. Contact the author if you have problems !

The output images are saved in the directory 'Output'!

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%          IMAGE INDEXING       %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

IMPORTANT : The image indexing used in this program is NOT that which is naturally
present in Matlab. Matlab uses column-first indexing, whereas most
c++ programs use row-first. The indexing is done in the following manner :

[colour xCoordinate yCoordinate tCoordinate]

This was done in an effort to speed up patch comparisons. Therefore,
the videos are permuted when they are input to 'inpaint_video.m'.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%          PARAMETERS        %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

There are several internal parameters, and a few modifiable input parameters. Here they are :

Modifiable paramters :

 - Patch size (default :  5x5x5)
 - Use of features ("useFeatures") default yes, activated)
 - Number of pyramid levels
 
Internal parameters (should not be modified):
 - Number of iterations of propagation/random search in patchMatch ("nbItersPatchMatch"). Set to 10.
 - Random search window size reduction factor ("alpha"). Set to 0.5.
 - Partial patch comparison ("partialComparison"). This parameter determines whether whole
 patches are compared, or only the part which is known. This parameter is used for the initialisation
 process
 - Reconstruction method ("reconstructionType"). This is done using either a weighted mean (reconstructionType=0)
 or using the best NN patch for each pixel (reconstructionType=1). This parameter is managed automatically.
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% HINTS AND HELPER FUNCTIONS %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

These functions may be found in the "matlab_functions" sub-directory.
They can help you to figure out what is happening and diagnose bad results.

- The function 'show_before_after_frames' displays the image sequence in a subplot
figure. If you are not sure what is going on, try putting a breakpoint in
the code and typing : 'show_before_after_frames(imgVol)' or
'show_before_after_frames(occVol)' to see the occlusion volume.

- The function 'analyse_shift_vol' is very useful to see what the patchMatch
correspondencies look like. Try typing 'analyse_shift_volume(imgVol,imgVol,shiftVol,frameNumber)',
where 'frameNumber' is a frame of the image sequence 'imgVol'.

- If ever you want to stop the code, but don't want to kill it, just create
an empty file named 'stop_and_debug.txt' in the directory where the inpainting
code is. This will put the code on pause, and you can debug in the matlab
command window or in the editor.

- Note that for HD sequences (>500x500 pixels), the computer must have a lot of RAM.
If not, this can freeze the computer !

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% Misc %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

The video test example ('beach_umbrella') given for testing this code is from the work of Wexler et. al presented
in the paper :
	'Space-time Completion', Yonatan Wexler, Eli Shechtman, and Michal Irani, PAMI 2007

Thank you for using the software, and have fun !!!
