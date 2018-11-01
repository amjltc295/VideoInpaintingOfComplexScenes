

function[realignedVideoFilePath,realignedOcclusionFilePath] = create_realigned_videos(videoFilePath,occlusionFilePath)

    addpath('../Matlab_functions');
    addpath('../Content/');

    %extract original frames
    [~,videoFileName,~] = fileparts(videoFilePath);
    extract_images_from_video(videoFilePath,strcat(videoFileName,'_original'));
    vidTemp = VideoReader(videoFilePath);
    nbFrames = get(vidTemp,'NumberOfFrames');
    
    %extract occlusion frames
    [~,occlusionFileName,occlusionFileExt] = fileparts(occlusionFilePath);
    
    %determine if the occlusion file is a video or an image (you can modify this
    %if you like)
    fmtList = VideoReader.getFileFormats();
    if ( any(ismember(['.' {fmtList.Extension}],occlusionFileExt(2:end))) )
        extract_images_from_video(occlusionFilePath,strcat(videoFileName,'_occlusion'));
    else
        imgOcc = imread(occlusionFilePath);
        if (ndims(imgOcc) == 2) %we need to format the image into an RGB
            imgOcc = repmat(imgOcc,[1 1 3]);
        end
        for ii=1:nbFrames
            imwrite(imgOcc,strcat(occlusionFileName,'_frame_',sprintf('%04d', ii),'.png'));
        end
    end
    
    %now determine affine motion, and then warp input and create output videos
    originalFileName = strcat(videoFileName,'_original_frame_');
    affineMotionFile = strcat(videoFileName,'_global_motion.txt');
    system(strcat('./Motion2D -m AC -p ',originalFileName,'%04d.png -f ',num2str(1),' -i ',num2str(nbFrames-1),...
        ' -v -r ',affineMotionFile));
    [realignedVideo,realignedOcclusion] = warp_images(videoFileName,affineMotionFile);
    %get the output video file path
    realignedVideoFilePath = strcat(get(realignedVideo,'Path'),'/',get(realignedVideo,'Filename'));
    %get the output occlusion file path
    realignedOcclusionFilePath = strcat(get(realignedOcclusion,'Path'),'/',get(realignedOcclusion,'Filename'));
end