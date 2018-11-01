
%this function warps a image using an affine motion estimation

function[] = unwarp_images(originalfilesName,inpaintedfilesName,affineMotionFile)

    addpath('../Matlab_functions');

    %options
    %activate this parameter if you wish for the occluded region to be outined in green (for viewing purposes)
    addBorder = 0;
    %change this parameter if you wish to speed up or slow down the
    %result video
    frameStep = 1;

    ext = '.png';

    currentFiles = dir(strcat(inpaintedfilesName,'*',ext));

    originalFiles = dir(strcat(originalfilesName,'_original','*',ext));
    occlusionFiles = dir(strcat(originalfilesName,'_occlusion','*',ext));

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


    for ii=1:frameStep:nbFrames
        [warpingMapBackward,warpingMapForward] = find_warping_map(imgSize(1),imgSize(2),round(ii),referenceFrame,dominantMotion,motionOrigins);
        %warp image
        outOfBoundsInds = (warpingMapBackward(:,:,2)<1 | warpingMapBackward(:,:,2)>imgSize(1) | ...
                           warpingMapBackward(:,:,1)<1 | warpingMapBackward(:,:,1)>imgSize(2));
        %clamp the coordinates
        warpX = max(min(warpingMapBackward(:,:,1),imgSize(2)),1);
        warpY = max(min(warpingMapBackward(:,:,2),imgSize(1)),1);

        %get the original images
        currFileOrginal = originalFiles(round(ii)).name;
        imgOriginal = double(imread(currFileOrginal));

        %get the occlusion indices
        currFileOcclusion = occlusionFiles(round(ii)).name;
        imgOcclusion = double(rgb2gray(imread(currFileOcclusion)))>3;
        imgErode = imerode(imgOcclusion,strel('arbitrary',[1 1 1; 1 1 1; 1 1 1]));
        imgBorder = abs(imgOcclusion-imgErode)>0;

        occInds = find(imgOcclusion>0);
        borderInds = find(imgBorder>0);

        currFileName = currentFiles(round(ii)).name;
        imgInpainted = double(imread(currFileName));

        for jj=1:3
            imgOriginalTemp = imgOriginal(:,:,jj);

            imgTemp = squeeze(imgInpainted(:,:,jj));
            imgTemp = interp2(originalX,originalY,imgTemp,warpX,warpY,'nearest');

            imgCurr = imgOriginalTemp;
            imgCurr(occInds) = imgTemp(occInds);

            if (addBorder >0)
                if (jj==2)
                    imgCurr(borderInds) = 255;
                end
            end

            imgInpainted(:,:,jj) = imgCurr;
        end

        imwrite(uint8(imgInpainted),[originalfilesName '_inpainted_unwarped_frame_'  sprintf('%05d', ii) '.png']);

        ii
    end
end