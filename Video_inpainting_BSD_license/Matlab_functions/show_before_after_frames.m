%this function is for purely display purposes. It shows the before/after
%frames in the image volume around the current frame
%varargin :
%   1/ imgVolume
%   2/ create new figure (optional, default = true)
%   3/ frame number vector
%   4/ occVol (optional)
function[] = show_before_after_frames(varargin)

    imgVolumeTemp = varargin{1};
    structEl = strel('square', 3);
    
    %format the input image sequence
    if (size(imgVolumeTemp,1) == 3)
        imgVolumeTemp = permute(imgVolumeTemp,[2 3 4 1]);
    end
    if (nargin>=2)
        newFigure = varargin{2};
    else
        newFigure = 1;
    end
    
    if (nargin >=3)
        frameNbVector = varargin{3};
        if (isempty(frameNbVector))
            frameNbVector = 1:size(imgVolumeTemp,3);
        end
    else
        frameNbVector = 1:size(imgVolumeTemp,3);
    end
    
    if (nargin >=4)
        occVol = varargin{4};
    end

    %imgVolume size
    imgVolSize = size(imgVolumeTemp);
    if (length(imgVolSize) <5)
        imgVolume(:,:,:,:,1) = imgVolumeTemp;
        imgVolSize(5) = 1;
    else
        imgVolume = imgVolumeTemp;
    end
    rowsSubplot = floor(sqrt(imgVolSize(3)));
    colsSubplot = ceil(imgVolSize(3)/rowsSubplot);
    
    for ii=1:imgVolSize(5)
        if (newFigure >0)
            figure;
        end
        for jj=1:imgVolSize(3)
            currAxes = subplot(rowsSubplot,colsSubplot,jj);      %set up the subplot
            if ((length(imgVolSize) == 3) || (ndims(imgVolSize) == 3))    %we have greyscale images
                imshow(squeeze(imgVolume(:,:,jj,:,ii)),[]);
                axis on;
                set(currAxes,'Title',text('String',num2str(frameNbVector(jj))));
            elseif (imgVolSize(4) == 2)   %case of optical flows
                imshow(uint8(flowToColor(squeeze(imgVolume(:,:,jj,:,ii)))));
                axis on;
                set(currAxes,'Title',text('String',num2str(frameNbVector(jj))));
            else    %assume that they are colour images
                if (ndims(imgVolume) == 3)
                    imshow(squeeze(imgVolume(:,:,jj,:,ii)),[]);
                else
                    imshow(uint8(squeeze(imgVolume(:,:,jj,:,ii))));
                end
                axis on;
                set(currAxes,'Title',text('String',num2str(frameNbVector(jj))));
            end
            if (nargin >=4)     %draw the occlusion
                occVolTemp = occVol(:,:,jj);
                if (sum(occVolTemp(:)) == 0)
                    continue;
                end
                occVolTemp(1,:) = 0; occVolTemp(:,1) = 0; occVolTemp(end,:) = 0; occVolTemp(:,end) = 0;
                occVolErode = imerode(occVolTemp,structEl);
                occVolBorder = occVol(:,:,jj) - occVolErode;
                occVolBorder(1,:) = 0; occVolBorder(:,1) = 0; occVolBorder(end,:) = 0; occVolBorder(:,end) = 0;
                occVolBorderInds = find(occVolBorder >0 );
                [yInds,xInds] = ind2sub(size(occVolBorder),occVolBorderInds);
    
                
                convHullOcc = convhull(xInds,yInds);
                for kk=1:(length(convHullOcc)-1)
                    xHull = [xInds(convHullOcc(kk));xInds(convHullOcc(kk+1))];
                    yHull = [yInds(convHullOcc(kk));yInds(convHullOcc(kk+1))];
                    line(xHull,yHull,'color','r');
                end
            end
            %axis off;
        end
    end
end