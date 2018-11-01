%this function plots a displacement field in 3D

function[figHandle] = plot_disp_field_hsv(dispField,fileName,patchSize, occlusionMask, compression)

    if (ischar(dispField))
        dispField = load(dispField);
        dispField = dispField.dispField;
    end
    sizeDispField = size(dispField);
    sizeDispField = sizeDispField([2 1 3]);
    
    if (nargin < 4)
        compression = 1;
    end
    
    hPatchSize = floor(patchSize/2);
    epsilon = 0.001;
    
    [X,Y,Z] = meshgrid(1:sizeDispField(1),1:sizeDispField(2),1:sizeDispField(3));
    %figure;
    
    %imgVolume size
    imgVolSize = sizeDispField;
    
    
    if (compression)
        vid = VideoWriter(strcat(fileName,'.avi'));
    else
        vid = VideoWriter(strcat(fileName,'.avi'),'Uncompressed AVI');
    end
    open(vid);

    %%%set invalid indices to 0
%     dispField(:,:,1:hPatchSize(3),:) = 0;
%     dispField(:,:,(end-hPatchSize(3)+1):end,:) = 0;
    if (nargin >3)      %we have the occlusion mask
        if (ischar(occlusionMask))
            occlusionMask = double(imread(occlusionMask));
        end
        unoccInds = find(occlusionMask == 0);
        for ii=1:size(dispField,3)
            for jj=1:size(dispField,4)
                dispFieldTemp = dispField(:,:,ii,jj);
                dispFieldTemp(unoccInds) = 0;
                dispField(:,:,ii,jj) = dispFieldTemp;
            end
        end
    else
        dispField(1:hPatchSize(2),:,:,:) = 0;
        dispField((end-hPatchSize(2)+1):end,:,:,:) = 0;
        dispField(:,1:hPatchSize(1),:,:) = 0;
        dispField(:,(end-hPatchSize(1)+1):end,:,:) = 0;
    end
    
    dispFieldX = dispField(:,:,:,1);
    dispFieldY = dispField(:,:,:,2);
    dispFieldT = dispField(:,:,:,3);
    
    maxX = max(abs(dispFieldX(:)));
    maxY = max(abs(dispFieldY(:)));
    maxT = sizeDispField(3);%max(dispFieldT(:));

    for ii=1:sizeDispField(3)
        imgTemp(:,:,1) = dispFieldX(:,:,ii)./maxX;
        imgTemp(:,:,2) = dispFieldY(:,:,ii)./maxY;
        imgTemp(:,:,3) = dispFieldT(:,:,ii)./maxT;
        
        imgTemp = hsv2rgb(vector_to_hsv(squeeze(imgTemp)));
        
        currFrame.cdata = imgTemp;
        currFrame.colormap = [];
        
        writeVideo(vid,currFrame);
    end

end