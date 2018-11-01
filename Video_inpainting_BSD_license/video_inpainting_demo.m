
%this script runs a video inpainting test script using a video commonly
%found in the video inpainting literature.
%Have fun!

%clear figures and variables
close all;
clear all;
restoredefaultpath;
 
videoFile = './Content/beach_umbrella.avi';
occlusionFile = './Content/beach_umbrella_occlusion.png';

start_inpaint_video(videoFile,occlusionFile,'maxLevel',3,'textureFeaturesActivated',1);

disp('The inpainting has finished !!!');