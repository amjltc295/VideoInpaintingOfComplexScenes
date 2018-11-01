%this function interpolates a displacement field


function[dispFieldOut] = interpolate_disp_field(dispFieldIn,imgVolFine,scaleStep,patchSize,interpType)

    if (~exist('interpType'))
        interpType = 'trilinear';
    end

    if (strcmp(interpType,'trilinear'))
        if (size(dispFieldIn,3) == size(imgVolFine,3))
            [xCoordsFine,yCoordsFine,tCoordsFine] = meshgrid(1:1/scaleStep:size(dispFieldIn,2),1:1/scaleStep:size(dispFieldIn,1),1:size(dispFieldIn,3));
        else
            [xCoordsFine,yCoordsFine,tCoordsFine] = meshgrid(1:1/scaleStep:size(dispFieldIn,2),1:1/scaleStep:size(dispFieldIn,1),1:1/scaleStep:size(dispFieldIn,3));
        end

        for jj=1:4  %number of shifts (3 shifts + 1 error field)
            interpolated = trilinear_interpolation(dispFieldIn(:,:,:,jj),yCoordsFine(:),xCoordsFine(:),tCoordsFine(:));
            interpolated = reshape(interpolated,size(yCoordsFine,1),size(xCoordsFine,2),size(tCoordsFine,3));
            dispFieldOut(1:size(yCoordsFine,1),1:size(xCoordsFine,2),1:size(tCoordsFine,3),jj) = interpolated;
        end

        dispFieldOut = round(2*dispFieldOut);
        dispFieldOut(end:(size(imgVolFine,1)),end:(size(imgVolFine,2)),end:(size(imgVolFine,3)),:) = 0;
        [xCoordsFine,yCoordsFine,tCoordsFine] = meshgrid(1:size(imgVolFine,2),1:size(imgVolFine,1),1:size(imgVolFine,3));

        coordsFine(:,:,:,1) = xCoordsFine;
        coordsFine(:,:,:,2) = yCoordsFine;
        coordsFine(:,:,:,3) = tCoordsFine;

        sizeImg = size(imgVolFine);
        sizeRow = sizeImg(1);
        sizeImg(1) = sizeImg(2);
        sizeImg(2) = sizeRow;
        for ii=1:3  %number of dimensions
            dispFieldTemp = dispFieldOut(:,:,:,ii);
            outOfBounds = find( ( (coordsFine(:,:,:,ii) + dispFieldOut(:,:,:,ii)) < (patchSize(ii)) ) | ...
                ( (coordsFine(:,:,:,ii) + dispFieldOut(:,:,:,ii)) > (sizeImg(ii) -patchSize(ii)) ));
            dispFieldTemp(outOfBounds) = 0;
            dispFieldOut(:,:,:,ii) = dispFieldTemp;
        end

        dispFieldOut = round(dispFieldOut);
    elseif (strcmp(interpType,'nearest'))
        sizeDispField = size(dispFieldIn);
        sizeImgVolFine = size(imgVolFine);
        %get the interpolated coordinates
        if (sizeDispField(end) == sizeImgVolFine(end))      %no temporal subsampling
            [xCoordsFine,yCoordsFine,tCoordsFine] = meshgrid(1:sizeImgVolFine(3),1:sizeImgVolFine(2),1:sizeImgVolFine(end));
            %clamp the coordinates
            xCoordsInterp = max(min(round(xCoordsFine/2),sizeDispField(3)),1);
            yCoordsInterp = max(min(round(yCoordsFine/2),sizeDispField(2)),1);
            tCoordsInterp = max(min(tCoordsFine,sizeDispField(4)),1);
        else
            [xCoordsFine,yCoordsFine,tCoordsFine] = meshgrid(1:sizeImgVolFine(3),1:sizeImgVolFine(2),1:sizeImgVolFine(end));
            xCoordsInterp = max(min(round(xCoordsFine/2),sizeDispField(3)),1);
            yCoordsInterp = max(min(round(yCoordsFine/2),sizeDispField(2)),1);
            tCoordsInterp = max(min(round(tCoordsFine/2),sizeDispField(4)),1);
        end
        
        dispFieldOut = zeros([4 sizeImgVolFine(2:4)]);
        sizeDispFieldOut = size(dispFieldOut);
        
        %get the interpolated shift volume
        dispFieldX = squeeze(dispFieldIn(1,:,:,:));
        dispFieldY = squeeze(dispFieldIn(2,:,:,:));
        dispFieldT = squeeze(dispFieldIn(3,:,:,:));
            
        %interpolate the shift volume
        linInds = sub2ind(size(dispFieldX),yCoordsInterp,xCoordsInterp,tCoordsInterp);
        dispFieldXinterp = reshape(scaleStep*dispFieldX(linInds),sizeDispFieldOut(2:4));
        dispFieldYinterp = reshape(scaleStep*dispFieldY(linInds),sizeDispFieldOut(2:4));
        if (sizeDispField(end) == sizeImgVolFine(end))      %no temporal subsampling
            dispFieldTinterp = reshape(dispFieldT(linInds),sizeDispFieldOut(2:4));
        else
            dispFieldTinterp = reshape(scaleStep*dispFieldT(linInds),sizeDispFieldOut(2:4));
        end
        
        %clamp the shift field
        minBarrierX = ceil(patchSize(1)/2)*ones(sizeDispFieldOut(2:4));
        maxBarrierX = (sizeDispFieldOut(3) - ceil(patchSize(1)/2))*ones(sizeDispFieldOut(2:4));
        
        minBarrierY = ceil(patchSize(2)/2)*ones(sizeDispFieldOut(2:4));
        maxBarrierY = (sizeDispFieldOut(2) - ceil(patchSize(2)/2))*ones(sizeDispFieldOut(2:4));
        
        minBarrierT = ceil(patchSize(3)/2)*ones(sizeDispFieldOut(2:4));
        maxBarrierT = (sizeDispFieldOut(4) - ceil(patchSize(3)/2))*ones(sizeDispFieldOut(2:4));

        %set the interpolated 
        dispFieldOut(1,:,:,:) = max(min( dispFieldXinterp, maxBarrierX - xCoordsFine ), minBarrierX - xCoordsFine);
        dispFieldOut(2,:,:,:) = max(min( dispFieldYinterp, maxBarrierY - yCoordsFine ), minBarrierY - yCoordsFine);
        dispFieldOut(3,:,:,:) = max(min( dispFieldTinterp, maxBarrierT - tCoordsFine ), minBarrierT - tCoordsFine);

        %deal with the last field : the patch distance
        dispFieldTemp = squeeze(dispFieldIn(4,:,:,:));
        dispFieldOut(4,:,:,:) = reshape(dispFieldTemp(linInds(:)),sizeDispFieldOut(2:4));
    end

end