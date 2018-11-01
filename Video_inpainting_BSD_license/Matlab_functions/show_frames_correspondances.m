%this function takes a series of figures, and plots them in a subplot, and
%optionally draws lines showing correspondances between them
% pointSeqA = [cols rows times];
function[] = show_frames_correspondances(imgVolA,imgVolB,pointSeqA,pointSeqB,showLines)

    %imgVolume size
    imgVolSizeA = size(imgVolA);
    rowsSubplot = 2;
    colsSubplot = imgVolSizeA(3);
    
    fCurrent = figure;
	set(fCurrent,'Units','normalized');

    hA = zeros(imgVolSizeA(3),1);    %handle arrays
    hB = zeros(imgVolSizeA(3),1);
    %show the images
    for ii=1:imgVolSizeA(3)
        hA(ii) = subplot(rowsSubplot,colsSubplot,ii);      %set up the subplot
        %set(hA(ii),'dataAspectRatio',[1 2 1]);
        image(uint8(squeeze(imgVolA(:,:,ii,:))));
        hB(ii) = subplot(rowsSubplot,colsSubplot,ii + (imgVolSizeA(3)));      %set up the subplot
        image(uint8(squeeze(imgVolB(:,:,ii,:))));
    end
    
    %show the correspondances
    for ii=1:size(pointSeqA,1)
        % Convert axes coordinates to figure coordinates for 1st axes
        [xa1 ya1] = ds2nfu(hA(pointSeqA(ii,3)),pointSeqA(ii,1),size(imgVolA,1)-pointSeqA(ii,2)+1);
        % and flip the y axis
        [xa2 ya2] = ds2nfu(hB(pointSeqB(ii,3)),pointSeqB(ii,1),size(imgVolB,1)-pointSeqB(ii,2)+1);

        % draw the lines
        for jj=1:numel(xa1)
            lHandle = annotation(fCurrent,'line',[xa1(jj) xa2(jj)],[ya1(jj) ya2(jj)],'color','r');
            if (~showLines)
                set(lHandle,'Visible','off');
                delete(lHandle);
            end
        end

    end
end