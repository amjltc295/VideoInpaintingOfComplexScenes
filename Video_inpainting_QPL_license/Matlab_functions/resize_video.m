%this script subsamples a video and saves it as an uncompressed avi

function[] = resize_video(fileIn,resizeScale)

    vidIn = VideoReader(strcat(fileIn,'.avi'));
    width = get(vidIn,'width');
    height = get(vidIn,'height');
    
    resizeSize = resizeScale.*[height width];

    vidOut = VideoWriter(strcat(fileIn,'_resized.avi'),'Uncompressed Avi');
    maxFrames = get(vidIn,'NumberOfFrames');
    open(vidOut);
    for ii=1:maxFrames
        imgTemp = read(vidIn,ii);
        imgTemp = imresize(imgTemp,resizeSize);
        imgTemp.cdata = imgTemp;
        imgTemp.colormap = [];
        writeVideo(vidOut,imgTemp);
    end

    close(vidOut);
end