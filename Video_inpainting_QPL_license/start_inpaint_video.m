%this function reads video files, and starts the video inpainting
%input :
%   videoFile : name of video file : video (either be in .avi format, or a sequence of images)
%   occFile : name of occlusion file : either video or image(s)
%

function[outputPath] = start_inpaint_video(varargin)
    close all;
    restoredefaultpath;
    currDir = cd;
    addpath(genpath(currDir));

    videoFile = varargin{1};
    occlusionFile = varargin{2};
    [videoPath,file,~] = fileparts(videoFile);
    [occlusionPath,~,~] = fileparts(occlusionFile);
    
    %turn off warning if it exists
    warning('off','MATLAB:aviread:FunctionToBeRemoved');

    seed_random_numbers();
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% get the input video %%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('Reading input video');
    imgVol = read_video(videoFile);
    if (isempty(imgVol))
        return;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% get the occulusion video %%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('Reading input occlusion');
    occVol = read_video(occlusionFile);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% get the image domain     %%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if (exist(strcat(videoPath,'/',file,'_image_domain.avi')))
        imgDomainVol = read_video(strcat(videoPath,'/',file,'_image_domain.avi'));
        imgDomainVol = double(~~(squeeze(imgDomainVol(:,:,:,1))));
    end

    %case of colour occlusion
    if (ndims(occVol) == 4)
        occVol(:,:,:,2:3) = [];
    end
    
    % special case (quite common) where the occlusion file is one image
    if (ndims(occVol) == 2)
        occVol = repmat(occVol,[1 1 size(imgVol,3)]);
        if (isempty(occVol))
            return;
        end
    end
    
    %check the dimensions of the videos
    sizeVideo = size(imgVol);
    if ( ~(isequal(sizeVideo(1:3),size(occVol))))
        disp('problem, the input video and occlusion do not have the same dimension. exiting the program.');
        return;
    end

    if (size(imgVol,3) > 3)	%we need to permute the dimensions
        imgVol = permute(imgVol,[1 2 4 3]);
    end
    
    if ( size(imgVol,3) ~= size(imgVol,3) )
        disp('There was an error reading the input : the number of frames in the video and the occlusion are not the same');
        return;
    end
    %start the inpainting
    disp('Starting the video inpainting ! Hold on to your hats !!!');
    profile clear;
    profile on;
    
    inpainting_parameters = varargin(3:end);
    inpainting_parameters{end+1} = 'file';
    inpainting_parameters{end+1} = file;
    if (exist('imgDomainVol','var'))
    	imgVolOut = inpaint_video_realigned_images(single(permute(imgVol,[3 1 2 4])),occVol,imgDomainVol,inpainting_parameters);
    else
    	imgVolOut = inpaint_video(single(permute(imgVol,[3 1 2 4])),occVol,inpainting_parameters);
    end

    cd Output;
    write_image_volume(imgVolOut,strcat(file,'_inpainted'));
    outputPath = cd;
    cd ..
    	
end
