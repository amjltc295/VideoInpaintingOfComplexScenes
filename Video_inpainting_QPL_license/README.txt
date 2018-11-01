
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%    CITATION    %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

If you wish to use this code for publications, please cite the
following paper:

Video Inpainting of Complex Scenes
Alasdair Newson, Andres Almansa, Matthieu Fradet, Yann Gousseau, Patrick Perez
SIAM Journal of Imaging Science 2014 7:4, 1993-2019 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

This file explains how to use the video inpainting code in this directory. Please read all of the
file before asking any questions, as a lot of information is contained here.

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
%%%%%%% INSTALLING MOTION2D %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

To deal with camera shake and motion, our work uses the "Motion2D" software
of Odobez et al. Their code has been included in this package, but can be downloaded
from :

http://www.irisa.fr/vista/Motion2D/

To use this code, you will have to extract the Motion2D code. Open a terminal
and type:

tar -zxvf Motion2D-1.3.11.1.tar.gz

Then, enter the newly extracted Motion2D-1.3.11.1 directory. Instructions on
how to install the software are written in the INSTALL file, but here are the steps
you should take. In the terminal, type:

./configure

Now type:

make

If the installation went correctly, you should have a binary file in the bin/
directory or one of its subdirectories, corresponding to your operating system.
If you have problems installing, see the website for help.

Now that you have the executable, we will be accessing it from a matlab
function. This means that you need to place this executable in another directory.
Please change the current directory to the one where the binary file is,
and type in the terminal:

cp Motion2D ../../../Realignment/

Now everything should be working correctly. You can close the terminal. If
you have problems with these steps, please contact the first author. Note that dealing
with camera shake is optional (but strongly recommended), so you can execute the
inpainting code without it.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% INPAINTING CODE USAGE %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

There are two demonstration matlab scripts:
    - 'video_inpainting_demo.m',
    - 'video_inpainting_demo_with_realignment.m'

The first does not use the Motion2D software, the second does. An example
video ('beach umbrella' of Wexler et al). is included in the 'Content' folder.

The 'video_inpainting_demo.m' is a simple example which should execute with success.
You can also execute the 'video_inpainting_demo_with_realignment.m' function, but
in the 'beach umbrella' case, the camera shake realignment is not necessary.
The output is saved in the directory indicated at the end when the code
has finished executing.

Please note that using the camera realignment results in longer execution times.

The demo files call the 'start_inpaint_video' function, which in turn
calls the video inpainting function 'inpaint_video'.

The function 'start_inpaint_video' may be called in several ways :

1/ start_inpaint_video(videoFileName,occlusionFileName);
	If called in this way, the input video is given by videoFileName
	and the input occlusion is given by occlusionFileName. This means that the video input
	file should be a video (.avi etc...). The occlusion may be a video or image file. If it
	is an image file, then the occlusion is considered to be the same for each frame.
	
2/ start_inpaint_video(videoFileName,occlusionFileName,'all');
	If called in this way, the input files are all those files beginning with 'videoFileName'
	and 'occlusionFileName'. It is up to the user to make sure that the files are named
	correctly so that they are read in the right order, which means for example putting
	zeros in front of the frame number.
	
3/ start_inpaint_video(videoFileName,occlusionFileName,firstFrameNb,lastFrameNb);
	If called this way, the video file is created out of the concatenation of
	the images starting with 'videoFileName' and going from firstFrame to lastFrame.
	Note that no zeros should be in front of the frame number in this case. The occlusion
	is assumed to be either a video or a single frame
	
4/ start_inpaint_video(videoFileName,occlusionFileName,firstFrameNbVideo,lastFrameNbVideo,firstFrameNbOcclusion,lastFrameNbOcclusion);
	If called this way, the video file is created out of the concatenation of
	the images starting with 'videoFileName' and going from firstFrame to lastFrame.
	Note that no zeros should be in front of the frame number in this case. The occlusion
	is created in the same manner. Obviously the lengths of the video and the occlusion
	must be the same.
	
Please note that if the user specifies a first and last frame number, but provides a
video file, not an image file, then the frame numbers are ignored and the video files
are read as usual.

!!!! NOTE !!!!! Matlab is very touchy about video files. The only ones which usually work
are avi files. Contact the author if you have problems !


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%          PARAMETERS        %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

There are several internal parameters, and a few modifiable input parameters.
The most IMPORTANT parameter which you must set manually is the
number of pyramid levels ! For smaller videos, as in the 'beach umbrella'
example (264x68), use 3 levels. For larger, HD videos (1440x1080) use 5 levels.
You can try different values for this parameter to get the best result.

Here they are the other parameters, which you should in general leave alone,
unless you are experimenting.

Modifiable paramters :

 - Patch size (default : 5x5x5, should be sufficient for most examples)
 - Use of features ("useFeatures") default yes, activated)
 
Internal parameters (should not be modified):
 - Number of iterations of propagation/random search in patchMatch ("nbItersPatchMatch"). Set to 10.
 - Random search window size reduction factor ("alpha"). Set to 0.5.
 - Partial patch comparison ("partialComparison"). This parameter determines whether whole
 patches are compared, or only the part which is known. This parameter is used for the initialisation
 process
 - Reconstruction method ("reconstructionType"). This is done using either a weighted mean (reconstructionType=0)
 or using the best NN patch for each pixel (reconstructionType=1). This parameter is managed automatically.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%          IMAGE INDEXING       %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

IMPORTANT : The image indexing used in this program is NOT that which is naturally
present in Matlab. Matlab uses column-first indexing, whereas most
c++ programs use row-first. The indexing in this code is done in the following manner :

[colour xCoordinate yCoordinate tCoordinate]

This was done in an effort to speed up patch comparisons. Therefore,
the videos are permuted when they are input to 'inpaint_video.m'.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% HINTS AND HELPER FUNCTIONS %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

These functions may be found in the "matlab_functions" sub-directory.
They can help you to figure out what is happening and diagnose bad results.

- If ever you want to stop the code, but don't want to kill it, just create
an empty file named 'stop_and_debug.txt' in the directory where the inpainting
code is. This will put the code on pause, and you can debug in the matlab
command window or in the editor.

- The function 'show_before_after_frames' displays the image sequence in a subplot
figure. If you are not sure what is going on, try putting a breakpoint in
the code and typing : 'show_before_after_frames(imgVol)' or
'show_before_after_frames(occVol)' to see the occlusion volume.

- The function 'analyse_shift_vol' is very useful to see what the patchMatch
correspondencies look like. Try typing 'analyse_shift_volume(imgVol,imgVol,shiftVol,frameNumber)',
where 'frameNumber' is a frame of the image sequence 'imgVol'.

- Note that for HD sequences (>500x500 pixels), the computer must have a lot of RAM.
If not, this can freeze the computer !

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% Misc %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

The video test example ('beach_umbrella') given for testing this code is from the work of Wexler et. al presented
in the paper :
	'Space-time Completion', Yonatan Wexler, Eli Shechtman, and Michal Irani, PAMI 2007

Thank you for using the software, and have fun !!!
