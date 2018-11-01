
%this function warps a image using an affine motion estimation

function[vidOut,vidOutOcc,vidOutImgDomain] = warp_images(fileName,affineMotionFile)

    vidOut = VideoWriter(strcat(fileName,'_realigned.avi'),'Uncompressed Avi');
    open(vidOut);
    vidOutOcc = VideoWriter(strcat(fileName,'_realigned_occlusion.avi'),'Uncompressed Avi');
    open(vidOutOcc);
    vidOutImgDomain = VideoWriter(strcat(fileName,'_realigned_image_domain.avi'),'Uncompressed Avi');
    open(vidOutImgDomain);

    ext = '.png';
    
    originalFiles = dir(strcat(fileName,'_original_frame','*',ext));
    occlusionFiles = dir(strcat(fileName,'_occlusion_frame','*',ext));

    %get height etc...
    firstFileName = originalFiles(1).name;
    nbFrames = length(originalFiles);
    imgTemp = imread(firstFileName);
    imgSize = size(imgTemp);
    
    %this is the number of the frame to whose coordinate system all the
    %images are warped (by default the middle one, but you can change this)
    referenceFrame = round(nbFrames/2);

    [dominantMotion,motionOrigins] = read_global_motion_odobez(affineMotionFile);

    [originalX,originalY] = meshgrid(1:imgSize(2),1:imgSize(1));

    for ii=1:nbFrames
        [warpingMapBackward,warpingMapForward] = find_warping_map(imgSize(1),imgSize(2),ii,referenceFrame,dominantMotion,motionOrigins);
        %warp image
        outOfBoundsInds = (warpingMapForward(:,:,2)<1 | warpingMapForward(:,:,2)>imgSize(1) | ...
                           warpingMapForward(:,:,1)<1 | warpingMapForward(:,:,1)>imgSize(2));
        %clamp the coordinates
        warpX = max(min(warpingMapForward(:,:,1),imgSize(2)),1);
        warpY = max(min(warpingMapForward(:,:,2),imgSize(1)),1);

        %get the original images
        currFileOrginal = originalFiles(ii).name;
        imgOriginal = double(imread(currFileOrginal));

        %get the occlusion indices
        currFileOcclusion = occlusionFiles(ii).name;
        imgOcclusion = double(rgb2gray(imread(currFileOcclusion)))>3;

        for jj=1:3
            %warp original colour images
            imgTemp = squeeze(imgOriginal(:,:,jj));
            imgTemp = interp2(originalX,originalY,imgTemp,warpX,warpY);
            imgTemp(outOfBoundsInds) = 0;
            imgOriginalWarped(:,:,jj) = imgTemp;
        end
        currFrame.cdata = uint8(imgOriginalWarped);
        currFrame.colormap = [];
        writeVideo(vidOut,currFrame);

        %write occlusion
        imgTemp = interp2(originalX,originalY,double(imgOcclusion),warpX,warpY);
        imgTemp(outOfBoundsInds) = 0;   %set out of bounds inds to 0
        currFrame.cdata = uint8(255*repmat(imgTemp,[1 1 3]));
        currFrame.colormap = [];
        writeVideo(vidOutOcc,currFrame);

        %write image showing image domain
        imgTemp = zeros(imgSize(1:2));
        imgTemp(outOfBoundsInds) = 255;
        currFrame.cdata = uint8(repmat(imgTemp,[1 1 3]));
        currFrame.colormap = [];
        writeVideo(vidOutImgDomain,currFrame);

    end

    close(vidOut);
    close(vidOutOcc);
    close(vidOutImgDomain);
    
end