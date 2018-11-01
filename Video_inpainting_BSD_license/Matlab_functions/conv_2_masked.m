%this function carries out a convolution with a mask

function[imgOut] = conv_2_masked(imgIn,filterIn,maskIn)

    %do not take the points of the mask into account
    imgTemp = imgIn;
    imgTemp(maskIn==0) = 0;
    
    %create the matrix giving the normalising factors
    imgNormalise = conv2(double(maskIn),filterIn,'same');
    imgNormalise = max(imgNormalise,1);
    
    imgOut = conv2(imgTemp,filterIn,'same');
    %normalise the output
    imgOut = imgOut./imgNormalise;
end