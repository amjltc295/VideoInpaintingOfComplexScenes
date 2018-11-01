%function to initialise the analysis of a shift volume

%inputs :
%   1/ Figure
%   2/ imgVolA
%   3/ imgVolB
%   4/ shiftVol
%   5/ onlyCorrespondingFrames
%   6/ colour
%   7/ screenSize
%   8/ correspondanceMat (optional, if we already know the original positions)

function[hPrinciple,correspondanceMat,hSubplot,lineHandle] = initialise_analysis_figure(fCurrent,analysis,imgVolA,imgVolB,shiftVol,frameNum,occVol,...
    patchSize,onlyCorrespondingFrames,colour,screenSize,correspondanceMat)

    %parameters
    maxCorrespondancies = 10*10;

    %determine the sizes of the subplots : by default, we put the main
    %image above (most images are wider than they are high)
    imgVolSizeA = size(imgVolA);
    imgVolSizeB = size(imgVolB);
    
    if (imgVolSizeA(1) < imgVolSizeA(2))
        m = floor(sqrt(imgVolSizeA(3)));
        n = ceil((imgVolSizeA(3))/m);
    else
        n = floor(sqrt(imgVolSizeA(3)));
        m = ceil((imgVolSizeA(3))/n);
    end
    
    %show the images
    %show the main image
    
    if (imgVolSizeA(1) < imgVolSizeA(2))
        hPrinciple = subplot(2*m,n,[1 m*n],'replace');
    else
        hPrinciple = subplot(m,2*n,[1 n*(2*m-1)],'replace');
    end
    image(uint8(squeeze(imgVolA(:,:,frameNum,:))));
    set(hPrinciple,'Title',text('String',num2str(frameNum)));
    set(hPrinciple,'UserData',-1);
    %%%% draw a line around the occlusion
    if (~isempty(occVol))
        draw_occlusion(hPrinciple,occVol,frameNum);
    end

    for ii=1:imgVolSizeB(3)   %up to the maximum frame
        if (imgVolSizeB(1) < imgVolSizeB(2))
            hSubplot(ii) = subplot(2*m,n,m*n+ii);      %set up the subplot
        else
            hSubplot(ii) = subplot(m,2*n, (floor((ii-1)/n))*(2*n) + n + mod(ii,n)+1);      %set up the subplot
        end
        image(uint8(squeeze(imgVolB(:,:,ii,:))));
        set(hSubplot(ii),'Title',text('String',num2str(ii)));
        set(hSubplot(ii),'UserData',ii);
    end

    
    if (nargin < 12)
        if (strcmp(analysis,'shiftVol'))
            currRect = getrect(hPrinciple);
            xMin = round(currRect(1)); yMin = round(currRect(2));
            width = max(round(currRect(3)),1); height = max(round(currRect(4)),1);
        elseif (strcmp(analysis,'colourDistribution'))
            [ptsX,ptsY] = getpts(hPrinciple);
            currPts = round([ptsX(1) ptsY(1)]);
            xMin = currPts(1) - floor(patchSize(2)/2); yMin = currPts(2) - floor(patchSize(1)/2); tMin = frameNum - floor(patchSize(3)/2);
            xMax = currPts(1) + floor(patchSize(2)/2); yMax = currPts(2) + floor(patchSize(1)/2); tMax = frameNum + floor(patchSize(3)/2);
        end
    else
        if(strcmp(analysis,'shiftVol'))
            xMin = min(correspondanceMat(:,1)); yMin = min(correspondanceMat(:,2));
            width = max(correspondanceMat(:,1)) - min(correspondanceMat(:,1)) + 1;
            height = max(correspondanceMat(:,2)) - min(correspondanceMat(:,2)) + 1;
            correspondanceMat = [];
        elseif (strcmp(analysis,'colourDistribution'))
            xMin = min(correspondanceMat,[],1); xMin = max(correspondanceMat,[],1);
            yMin = min(correspondanceMat,[],2); yMin = max(correspondanceMat,[],2);
            tMin = min(correspondanceMat,[],3); tMin = max(correspondanceMat,[],3);
        end
    end

    if (strcmp(analysis,'shiftVol'))
        correspondanceMat = zeros(1,6);
        correspondanceMat(1,:) = [];
        
        if (nargin == 13)
            for ii=1:length(pixelInds)
                [currY,currX] = ind2sub([imgVolSizeA(1) imgVolSizeB(2)],pixelInds(ii));

                xShifted = currX + ( shiftVol(currY,currX,1) );
                yShifted = currY + ( shiftVol(currY,currX,2) );
                tShifted = 1;

                correspondanceMat(end+1,1) = (currX);
                correspondanceMat(end,2) = (currY);
                correspondanceMat(end,3) = (1);

                correspondanceMat(end,4) = (xShifted);
                correspondanceMat(end,5) = (yShifted);
                correspondanceMat(end,6) = (tShifted);
            end
        else
            mStep = height/sqrt(maxCorrespondancies);
            nStep = width/sqrt(maxCorrespondancies);
            hStep = max(round(mStep),1);
            wStep = max(round(nStep),1);
            iiTemp = 0;
            jjTemp = 0;
            
            for ii=0:wStep:(width-1)
                for jj=0:hStep:(height-1)
                    xShifted = (xMin+ii) + ( shiftVol(yMin+jj,xMin+ii,frameNum,1) );
                    yShifted = (yMin+jj) + ( shiftVol(yMin+jj,xMin+ii,frameNum,2) );
                    tShifted = (frameNum) + ( shiftVol(yMin+jj,xMin+ii,frameNum,3) );

                    correspondanceMat(end+1,1) = (xMin+ii);
                    correspondanceMat(end,2) = (yMin+jj);
                    correspondanceMat(end,3) = (frameNum);

                    correspondanceMat(end,4) = (xShifted);
                    correspondanceMat(end,5) = (yShifted);
                    correspondanceMat(end,6) = (tShifted);

                    jjTemp = jjTemp + 1;
                end
                jjTemp = 0;
                iiTemp = iiTemp +1;
            end
        end
        
        %sort the correspondancies in order of increasing frame number
        [~,order] = sort(correspondanceMat(:,6));
        correspondanceMat = correspondanceMat(order,:);
        framesVect = unique(correspondanceMat(:,6));

        if (onlyCorrespondingFrames)    %only show the corresponding frames
            delete(hPrinciple);
            if (exist('hSubplot','var'))
                for ii=1:length(hSubplot)
                    delete(hSubplot(ii));
                end
            end

            nbFrames = length(framesVect);
            if (imgVolSizeA(1) < imgVolSizeA(2))
                m = floor(sqrt(nbFrames));
                n = ceil(nbFrames/m);
            else
                n = floor(sqrt(nbFrames));
                m = ceil(nbFrames/n);
            end


            if (imgVolSizeA(1) < imgVolSizeA(2))
                hPrinciple = subplot(2*m,n,1:(m*n));
            else
                hPrinciple = subplot(m,2*n,[1 n*(2*m-1)]);
            end

            if (size(imgVolA,4)== 2)    %grey scale
                imshow(squeeze(imgVolA(:,:,frameNum,1)),[]);
            else
                image(uint8(squeeze(imgVolA(:,:,frameNum,:))));
            end
            set(hPrinciple,'Title',text('String',num2str(frameNum)));
            set(hPrinciple,'UserData',-1);

            hSubplot = [];
            for ii=1:nbFrames   %up to the maximum frame
                frameNbTemp = framesVect(ii);
                if (imgVolSizeB(1) < imgVolSizeB(2))
                    hSubplot(ii,1) = subplot(2*m,n,m*n+ii);      %set up the subplot
                else
                    hSubplot(ii,1) = subplot(m,2*n, (floor((ii-1)/n))*(2*n) + n + mod(ii,n)+1);      %set up the subplot
                end
                if (size(imgVolB,4)== 2)    %grey scale
                    imshow(squeeze(imgVolB(:,:,frameNbTemp,1)),[]);
                else
                    image(uint8(squeeze(imgVolB(:,:,frameNbTemp,:))));
                end
                set(hSubplot(ii,1),'Title',text('String',num2str(frameNbTemp)));
                set(hSubplot(ii,1),'UserData',frameNbTemp);
                hSubplot(ii,2) = frameNbTemp;
            end
        end

        for ii=1:size(correspondanceMat,1)
            [x1 y1] = axescoord2figurecoord(correspondanceMat(ii,1),correspondanceMat(ii,2),hPrinciple);
            currentHandle = hSubplot( hSubplot(:,2) == correspondanceMat(ii,6),1);
            [x2 y2] = axescoord2figurecoord(correspondanceMat(ii,4),correspondanceMat(ii,5),currentHandle);

            lineHandle(ii) = annotation(fCurrent,'line',[x1 x2],[y1 y2],'color',colour);
        end
        
    elseif(strcmp(analysis,'colourDistribution'))
        xCentre = (xMin+xMax)/2;
        yCentre = (yMin+yMax)/2;
        tCentre = (tMin+tMax)/2;
        %get the correspondances around the current pixel
        for ii=xMin:(xMax)
            for jj=yMin:yMax
                for kk=tMin:tMax
                    %get the relative shifts of the pixels in the current
                    %patch neighbourhood
                    xShift = xCentre - ii;
                    yShift = yCentre - jj;
                    tShift = tCentre - kk;
                    
                    xShifted = ii + ( shiftVol(jj,ii,kk,1) ) + xShift;
                    yShifted = jj + ( shiftVol(jj,ii,kk,2) ) + yShift;
                    tShifted = kk + ( shiftVol(jj,ii,kk,3) ) + tShift;

                    correspondanceMat(jj-yMin+1 + (patchSize(1))*(ii-xMin) + (patchSize(1))*(patchSize(2))*(kk-tMin),1) = ii;
                    correspondanceMat(jj-yMin+1 + (patchSize(1))*(ii-xMin) + (patchSize(1))*(patchSize(2))*(kk-tMin),2) = jj;
                    correspondanceMat(jj-yMin+1 + (patchSize(1))*(ii-xMin) + (patchSize(1))*(patchSize(2))*(kk-tMin),3) = kk;

                    correspondanceMat(jj-yMin+1 + (patchSize(1))*(ii-xMin) + (patchSize(1))*(patchSize(2))*(kk-tMin),4) = xShifted;
                    correspondanceMat(jj-yMin+1 + (patchSize(1))*(ii-xMin) + (patchSize(1))*(patchSize(2))*(kk-tMin),5) = yShifted;
                    correspondanceMat(jj-yMin+1 + (patchSize(1))*(ii-xMin) + (patchSize(1))*(patchSize(2))*(kk-tMin),6) = tShifted;
                end
            end
        end
        
        %now display the colour distribution
        
        %first display the image
        if (imgVolSizeA(1) < imgVolSizeA(2))    %the image is wider than large
            hPrinciple = subplot(2,2,1:2);
        else                                    %the image is larger than wide
            hPrinciple = subplot(2,2,[1 3]);
        end
        image(uint8(squeeze(imgVolA(:,:,frameNum,:))));
        set(hPrinciple,'Title',text('String',num2str(frameNum)));
        set(hPrinciple,'UserData',-1);
        
        %now display the colour distribution
        if (imgVolSizeA(1) < imgVolSizeA(2))    %the image is wider than large
            hSubplot(1) = subplot(2,2,3);
            hSubplot(2) = subplot(2,2,4);
        else                                    %the image is larger than wide
            hSubplot(1) = subplot(2,2,2);
            hSubplot(2) = subplot(2,2,4);
        end
        
        colourVect = zeros(size(correspondanceMat,1),3);
        for ii=1:size(correspondanceMat,1)
            for jj=1:3
                colourVect(ii,jj) = imgVolB(correspondanceMat(ii,5),correspondanceMat(ii,4),correspondanceMat(ii,6),jj);
            end
            weights(ii) = shiftVol(correspondanceMat(ii,5),correspondanceMat(ii,4),correspondanceMat(ii,6),4);
        end
        
        stdDev(1) = std(colourVect(:,1));
        stdDev(2) = std(colourVect(:,2));
        stdDev(3) = std(colourVect(:,3));
        
        bandwidth = 0.2*max(stdDev);
        [clustCent,data2cluster,~] = MeanShiftCluster(colourVect',bandwidth,weights);
        
        %plot the scatter diagram
        S = repmat(30,size(colourVect,1),1);

        C = repmat(50,size(colourVect,1),1);
        
        %first scatter plot
% %         scatter3(hSubplot(1),colourVect(:,1),...
% %             colourVect(:,2),...
% %             colourVect(:,3),'Filled');
% %         xlim(hSubplot(1),[0 255]);
% %         ylim(hSubplot(1),[0 255]);
% %         zlim(hSubplot(1),[0 255]);
% %         xlabel(hSubplot(1),strcat('Red, stdDev : ',num2str(stdDev(1))));
% %         ylabel(hSubplot(1),strcat('Green, stdDev : ', num2str(stdDev(2))));
% %         zlabel(hSubplot(1),strcat('Blue, stdDev : ',num2str(stdDev(3))));
% %         
        %second scatter plot
% %         Sprime = [S;50];
% %         Cprime = [C;100];
% %         scatter3(hSubplot(1),[colourVect(:,1);median(colourVect(:,1))],...
% %             [colourVect(:,2);median(colourVect(:,2))],...
% %             [colourVect(:,3);median(colourVect(:,3))],Sprime,Cprime,'Filled');
% %         xlim(hSubplot(1),[0 255]);
% %         ylim(hSubplot(1),[0 255]);
% %         zlim(hSubplot(1),[0 255]);
% %         xlabel(hSubplot(1),strcat('Red, stdDev : ',num2str(stdDev(1))));
% %         ylabel(hSubplot(1),strcat('Green, stdDev : ', num2str(stdDev(2))));
% %         zlabel(hSubplot(1),strcat('Blue, stdDev : ',num2str(stdDev(3))));
        
        Sprime = [S;50];
        Cprime = [C;100];
        [~,minWeightInd] = min(weights);
        scatter3(hSubplot(1),[colourVect(:,1);colourVect(minWeightInd,1)],...
            [colourVect(:,2);colourVect(minWeightInd,2)],...
            [colourVect(:,3);colourVect(minWeightInd,3)],Sprime,Cprime,'Filled');
        xlim(hSubplot(1),[0 255]);
        ylim(hSubplot(1),[0 255]);
        zlim(hSubplot(1),[0 255]);
        xlabel(hSubplot(1),strcat('Red, stdDev : ',num2str(stdDev(1))));
        ylabel(hSubplot(1),strcat('Green, stdDev : ', num2str(stdDev(2))));
        zlabel(hSubplot(1),strcat('Blue, stdDev : ',num2str(stdDev(3))));
        
        %third scatter plot
        S = [S;50];
        C = [C;100];
        scatter3(hSubplot(2),[colourVect(:,1);clustCent(1,1)],...
            [colourVect(:,2);clustCent(2,1)],...
            [colourVect(:,3);clustCent(3,1)],S,C,'Filled');
        xlim(hSubplot(2),[0 255]);
        ylim(hSubplot(2),[0 255]);
        zlim(hSubplot(2),[0 255]);
        xlabel(hSubplot(2),strcat('Red, stdDev : ',num2str(stdDev(1))));
        ylabel(hSubplot(2),strcat('Green, stdDev : ', num2str(stdDev(2))));
        zlabel(hSubplot(2),strcat('Blue, stdDev : ',num2str(stdDev(3))));
        
        lineHandle = [];
    end

    

    if (~isempty(occVol))
        draw_occlusion(hPrinciple,occVol,frameNum);
    end
end