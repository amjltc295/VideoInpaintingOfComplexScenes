%this function writes a series of images from an image volume

function[] = write_image_volume(imgVol,fileName)
    
    if (size(imgVol,1) == 3)
        imgVol = permute(imgVol,[2 3 4 1]);
    end

    sizeImgVol = size(imgVol);
    numCharacters = ceil(log10(sizeImgVol(3)));
    
    for ii=1:size(imgVol,3)
        frameNumber = number_leading_zeros(ii,3);
        imwrite(uint8(squeeze(imgVol(:,:,ii,:))),strcat(fileName,'_frame_',frameNumber,'.png'));
        
    end

end