%this function gets the descriptors of caselles et al


function[featurePyramid] = get_caselles_descriptors(imgIn,occIn,maxLevel,opticalFlow)

    %deal with the gradients on the border the downsampled gradients
    [gradX,gradY] = gradient(double(rgb2gray(uint8(imgIn))));
    occDilated = imdilate(occIn,strel('arbitrary',ones(3,3)));
    occBorderInds = find(abs(occDilated-occIn)>0);

    featureType = 'gradient';

    if (strcmp(featureType,'opticalFlow') == 1)
        gradX = opticalFlow(:,:,1);
        gradY = opticalFlow(:,:,2);
    elseif (strcmp(featureType,'gradient') == 1)
        for ii=1:length(occBorderInds)
            [yOcc,xOcc] = ind2sub(size(occIn),occBorderInds(ii));
            yUp = max(yOcc-1,1);
            yDown = min(yOcc+1,size(occIn,1));
            xLeft = max(xOcc-1,1);
            xRight = min(xOcc+1,size(occIn,2));
            %y difference
            gradY(yOcc,xOcc) = ( (imgIn(yDown,xOcc) - imgIn(yOcc,xOcc))*(occIn(yDown,xOcc)==0) + ...
                ( (imgIn(yOcc,xOcc) - imgIn(yUp,xOcc))*(occIn(yUp,xOcc)==0) ) )/(max((occIn(yDown,xOcc)==0) + (occIn(yUp,xOcc)==0),1));
            gradX(yOcc,xOcc) = ( (imgIn(yOcc,xRight) - imgIn(yOcc,xOcc))*(occIn(yOcc,xRight)==0) + ...
                ( (imgIn(yOcc,xOcc) - imgIn(yOcc,xLeft))*(occIn(yOcc,xLeft)==0) ) )/(max((occIn(yOcc,xRight)==0) + (occIn(yOcc,xLeft)==0),1));
        end
    end

    normGradX = abs(gradX);
    normGradY = abs(gradY);
    
    featurePyramid = cell(maxLevel,4);
    
    featurePyramid{1,1} = gradX;
    featurePyramid{1,2} = gradY;
    featurePyramid{1,3} = normGradX;
    featurePyramid{1,4} = normGradY;
    
    %%%calculate the filtered versions of the features
    gradXtemp = conv_2_masked(gradX,ones(2^maxLevel),~occIn);
    gradYtemp = conv_2_masked(gradY,ones(2^maxLevel),~occIn);
    normGradXtemp = conv_2_masked(normGradX,ones(2^maxLevel),~occIn);
    normGradYtemp = conv_2_masked(normGradY,ones(2^maxLevel),~occIn);
% %     gradXtemp = gradX;
% %     gradYtemp = gradY;
% %     normGradXtemp = normGradX;
% %     normGradYtemp = normGradY;

    
    for level = maxLevel:-1:1
        featurePyramid{level,1} = gradXtemp(1:2^(level-1):end,1:2^(level-1):end);
        featurePyramid{level,2} = gradYtemp(1:2^(level-1):end,1:2^(level-1):end);
        featurePyramid{level,3} = normGradXtemp(1:2^(level-1):end,1:2^(level-1):end);
        featurePyramid{level,4} = normGradYtemp(1:2^(level-1):end,1:2^(level-1):end);
    end
    
end