
%this function compiles the mex functions necessary
%for the video inpainting
close all;
clear all;
restoredefaultpath;

debugOn = 0;

%%%%   Compiling spatio-temporal PatchMatch mex file  %%%%
disp('Compiling spatio-temporal PatchMatch');
cd 'Patch_match';
make_spatio_temporal_patch_match(debugOn);
cd ..;


%%%%   Compiling video reconstruction mex file  %%%%
disp('Compiling reconstruction of the video');
cd 'Reconstruction';
make_reconstruct_video(debugOn);
cd ..;


%%%%   Compiling texture reconstruction mex file   %%%%
disp('Compiling reconstruction of the texture features');
cd 'Reconstruction';
make_reconstruct_video_and_features(debugOn);
cd ..;

%%%%   Compiling texture reconstruction mex file   %%%%
disp('Compiling the random numbers seed');
mex seed_random_numbers.cpp;