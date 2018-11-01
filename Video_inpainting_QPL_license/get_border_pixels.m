%this function retrieves the linear indices of border pixels in an image
%volume

function[linIndsOut] = get_border_pixels(sizeImgVol,patchSize)

    if (length(sizeImgVol) > 3)
        sizeImgVol(4) = [];
    end

    hPatchSize = floor(patchSize/2);
    
    %x coordinates
    [xBorder,yBorder,tBorder] = meshgrid(1:hPatchSize(2),1:sizeImgVol(1),1:sizeImgVol(3));
    xBorder = xBorder(:); yBorder = yBorder(:); tBorder = tBorder(:);
    
    [xBorderTemp, yBorderTemp, tBorderTemp] = meshgrid((sizeImgVol(2)-hPatchSize(2)+1):sizeImgVol(2),1:sizeImgVol(1),1:sizeImgVol(3));
    xBorder = [xBorder;xBorderTemp(:)]; yBorder = [yBorder;yBorderTemp(:)]; tBorder = [tBorder;tBorderTemp(:)];
    
    %y coordinates
    [xBorderTemp, yBorderTemp, tBorderTemp] = meshgrid(1:sizeImgVol(2),1:hPatchSize(1),1:sizeImgVol(3));
    xBorder = [xBorder;xBorderTemp(:)]; yBorder = [yBorder;yBorderTemp(:)]; tBorder = [tBorder;tBorderTemp(:)];
    [xBorderTemp, yBorderTemp, tBorderTemp] = meshgrid(1:sizeImgVol(2),(sizeImgVol(1)-hPatchSize(1)+1):sizeImgVol(1),1:sizeImgVol(3));
    xBorder = [xBorder;xBorderTemp(:)]; yBorder = [yBorder;yBorderTemp(:)]; tBorder = [tBorder;tBorderTemp(:)];
    
    %t coordinates
    [xBorderTemp, yBorderTemp, tBorderTemp] = meshgrid(1:sizeImgVol(2),1:sizeImgVol(1),1:hPatchSize(3));
    xBorder = [xBorder;xBorderTemp(:)]; yBorder = [yBorder;yBorderTemp(:)]; tBorder = [tBorder;tBorderTemp(:)];
    [xBorderTemp, yBorderTemp, tBorderTemp] = meshgrid(1:sizeImgVol(2),1:sizeImgVol(1),(sizeImgVol(3)-hPatchSize(3)+1):sizeImgVol(3));
    xBorder = [xBorder;xBorderTemp(:)]; yBorder = [yBorder;yBorderTemp(:)]; tBorder = [tBorder;tBorderTemp(:)];
    
    linIndsOut = sub2ind(sizeImgVol,yBorder(:),xBorder(:),tBorder(:));
end