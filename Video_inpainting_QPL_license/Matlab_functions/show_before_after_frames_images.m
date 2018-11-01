%this function is for purely display purposes. It shows the before/after
%frames in the image volume around the current frame
%varargin :
%   1/ imgVolume
%   2/ corresponding pixels in before/after frames
%   3/ box size [height width]
function[] = show_before_after_frames_images(fileName)

    tempDir = dir(strcat(fileName,'*'));

    for ii=1:length(tempDir)
        imgVolume(:,:,ii,:) = double(imread(tempDir(ii).name));
    end
    
    %imgVolume size
    imgVolSize = size(imgVolume);
    rowsSubplot = floor(sqrt(imgVolSize(3)));
    colsSubplot = ceil(imgVolSize(3)/rowsSubplot);
    
    figure;
    
    for ii=1:imgVolSize(3)
        currAxes = subplot(rowsSubplot,colsSubplot,ii);      %set up the subplot
        if ((length(imgVolSize) == 3) || (ndims(imgVolSize) == 3))    %we have greyscale images
            imshow(imgVolume(:,:,ii),[]);
            set(currAxes,'Title',text('String',num2str(ii)));
        else    %assume that they are colour images
            imshow(uint8(squeeze(imgVolume(:,:,ii,:))));
            set(currAxes,'Title',text('String',num2str(ii)));
        end
        axis on;
    end
end