%this function draws an occlusion around an image present in imgHandle


function draw_occlusion(imgVolIn,occVolIn,frameNum,imgHandle)

    lineType = 'true';

    occVol = squeeze(occVolIn(:,:,frameNum));
    imgVol = squeeze(imgVolIn(:,:,frameNum,:));
    
    structElSquare = strel('square', 3);
    occVolErode(:,:) = imerode(occVol(:,:),structElSquare);
        
    occBorder = abs(occVol - occVolErode);
    occBorderInds = find(occBorder(:,:) > 0);
    [yOccInds,xOccInds] = ind2sub([size(occBorder,1) size(occBorder,2)],occBorderInds);

    if(strcmp(lineType,'convexHull'))
        if (nargin <4)
            figure;
            imshow(uint8(squeeze(imgVol(:,:,frameNum,:))));
            imgHandle = gca;
        end
        
        convHullOcc = convhull(xOccInds,yOccInds);
        for jj=1:(length(convHullOcc)-1)
            xHull = [xOccInds(convHullOcc(jj));xOccInds(convHullOcc(jj+1))];
            yHull = [yOccInds(convHullOcc(jj));yOccInds(convHullOcc(jj+1))];
            line(xHull,yHull,'color','r','Parent',imgHandle);
        end
    elseif(strcmp(lineType,'true'))
        imgVol(occBorderInds) = 0;
        imgVol(occBorderInds + size(imgVol,1)*size(imgVol,2)) = 255;
        imgVol(occBorderInds + 2*size(imgVol,1)*size(imgVol,2)) = 0;
        
        figure;
        imshow(uint8(imgVol));
    end
end