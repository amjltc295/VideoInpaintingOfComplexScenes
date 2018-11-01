%this function converts a video from "difficult" formats to easy ones to
%maniupulate

function[] = convert_video(fileIn)

    videoOut = VideoWriter('crossing_ladies_occlusion.avi','Uncompressed AVI');
    open(videoOut);

    videoIn = VideoReader(fileIn);

    video_temp = mmread(fileIn,1);
    maxFrames = abs(video_temp.nrFramesTotal);

    imgTemp = read(videoIn);
    for ii=1:size(imgTemp,4)
        currFrame.cdata = imgTemp(:,:,:,ii);
        currFrame.colormap = [];
        writeVideo(videoOut,currFrame);
        %writeVideo(vid,currentFrame);
    end

    close(videoOut);
    
end