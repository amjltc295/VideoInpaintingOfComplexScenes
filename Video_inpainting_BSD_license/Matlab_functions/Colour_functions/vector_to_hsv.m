%this function converts a 3D vector field to a hsv image

function[vectorOut] = vector_to_hsv(vectorField)
    
    epsilon = 0.001;

    angle = atan2(vectorField(:,:,1),vectorField(:,:,2));

    angle = angle + abs(min(angle(:)));
    hue = angle./(max(max(angle(:)),epsilon));
    
    value = ( (vectorField(:,:,1)).^2 + (vectorField(:,:,2)).^2 );
    value = value./(max(max(value(:)),epsilon));
    
    vectorFieldT = vectorField(:,:,3);
    vectorFieldT = vectorFieldT + min(vectorFieldT(:));
    saturation = vectorFieldT./(max(max(vectorFieldT(:)),epsilon));
    
    vectorOut(:,:,1) = hue;
    vectorOut(:,:,2) = saturation;
    vectorOut(:,:,3) = value;
    
end