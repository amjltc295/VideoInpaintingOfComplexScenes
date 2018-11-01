%this function resizes images in a file (starting with fileName etc)

function[] = resize_images(fileName,resizeScale,interpolationMethod)
    if (nargin < 2)
        resizeScale = 2;
    end
    if (nargin < 3)
        interpolationMethod = 'nearest';
    end
    %if (~exist('Resized_images'))
    dirSuccess = mkdir('Resized_images');
    %end


    %get all .tiff files
    currentFiles = dir(strcat(fileName,'*','.png'));

    nbFrames = length(currentFiles);

    %nbMat = numbersLeadingZeros([1 nbFrames],2);    %create necessary indexing

    for ii=1:nbFrames
        %imshow(strcat(num2str(nbMat(ii,1)),num2str(nbMat(ii,2)),...
        %    num2str(nbMat(ii,3)),num2str(nbMat(ii,4)),'.tif' ));
        currFileName = currentFiles(ii).name;
        imgTemp = double(imread(currFileName));
        %imgTemp = imgTemp(1:68,1:264,:);
        imgTemp = imresize(imgTemp,resizeScale,interpolationMethod);
        cd 'Resized_images';
        imwrite(uint8(imgTemp),currFileName);
        cd ..;

    end
    
end