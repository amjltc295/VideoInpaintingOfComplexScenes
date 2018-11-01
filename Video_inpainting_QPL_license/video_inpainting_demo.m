
%this script runs a video inpainting test script using a video commonly
%found in the video inpainting literature.
%Have fun!

% !!!!!  IMPORTANT !!!!!
% The most important parameter in this code is the 'maxLevel' parameter.
% For smaller videos, like the demo video (264x68), you should
% set this parameter to 3, but for larger ones (HD, around 1440x1080)
% you should set it to 5. You can try different values to see which
% produces the best result

%clear figures and variables
close all;
clear all;
restoredefaultpath;
 
videoFile = './Content/beach_umbrella.avi';
occlusionFile = './Content/beach_umbrella_occlusion.png';

outputFilePath = start_inpaint_video(videoFile,occlusionFile,'maxLevel',3,'textureFeaturesActivated',1);

disp('The inpainting has finished !!!');

disp('The output image files have been written to the following directory:');
outputFilePath