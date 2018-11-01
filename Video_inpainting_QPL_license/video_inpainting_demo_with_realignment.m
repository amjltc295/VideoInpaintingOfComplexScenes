
%this script runs a video inpainting test script, with pre-realignment
%of the video
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

addpath('Content/');

cleanUpFiles = 1;    %whether to clean up intermediary files afterwards

%get input videos and occlusion files
fileName = 'beach_umbrella';
videoFile = [fileName '.avi'];
occlusionFile = [fileName '_occlusion.png'];

% % % %create intermediary realigned video files : these will be stored in
% the 'realignment' directory
cd 'Realignment';
[realignedVideoFilePath,realignedOcclusionFilePath] = create_realigned_videos(videoFile,occlusionFile);
cd ..;

%do the inpainting on the realigned images
outputFilePath = start_inpaint_video(realignedVideoFilePath,realignedOcclusionFilePath,'maxLevel',3,'textureFeaturesActivated',1);
disp('The inpainting has finished !!!');

%copy the output warped images to the realignment folder
copyfile(['Output/' fileName '_realigned_inpainted*'],'./Realignment');

cd 'Realignment/'
unwarp_images(fileName,[fileName '_realigned_inpainted'],[fileName '_global_motion.txt']);
cd ..;

%copy the final output images to the output folder
copyfile(['Realignment/' fileName '_inpainted_unwarped*'],'./Output');

if (cleanUpFiles >0)
	cd 'Realignment/'
    disp('Cleaning intermediary files');
    clean_intermediary_files;
    cd ..
end

disp('The resulting image files have been written to the following directory:');
outputFilePath
