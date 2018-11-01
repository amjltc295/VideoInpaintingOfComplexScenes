%this function finds the warping map for a series of images with respect
%to a reference image.
%We suppose an affine parametric motion model

%   motionParameters :
%   [c1 c2   a1  a2  a3  a4]
%   output :
%   [height,width,[xCoords yCoords],frameNb]

function[warpingMapBackward,warpingMapForward] = find_complete_warping_map(height,width,nbFrames,motionParameters,motionOrigins)

    [originalCoordsX,originalCoordsY] = meshgrid( 1 : width, 1:height );

    warpingMapBackward = zeros(height,width,2,nbFrames);
    warpingMapForward = zeros(height,width,2,nbFrames);
    
    warpingMapBackward(:,:,1,1) = originalCoordsX;
    warpingMapBackward(:,:,2,1) = originalCoordsY;
    
    warpingMapForward(:,:,1,1) = originalCoordsX;
    warpingMapForward(:,:,2,1) = originalCoordsY;
    
    motionMatCum = eye(3,3);

    for ii=2:nbFrames
            
        coordSystemX = originalCoordsX - motionOrigins(ii-1,1);
        coordSystemY = originalCoordsY - motionOrigins(ii-1,2);
        
        %   x(i+1) = xi + c1 + a1*xi + a2*yi
        %   [xi+1 yi+1 1]' = [a1+1 a2+1 c1] * [xi]
        %                    [a3+1 a4+1 c2]   [yi]
        %                    [0  0   1]   [1 ]
        
        motionMat = [ motionParameters(ii-1,3)+1 motionParameters(ii-1,4) motionParameters(ii-1,1);...
                    motionParameters(ii-1,5) motionParameters(ii-1,6)+1 motionParameters(ii-1,2); 0 0 1];
        
        motionMatCum = motionMat * motionMatCum;
        % xA = (W)^-1 * xB
        xB = [ (coordSystemX(:))' ; (coordSystemY(:))']; %; ones(1,length(coordSystemX(:))) 
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%% get the mapping from frame B to frame A %%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        invMotionMatCum = inv(motionMatCum);
        xBackward = [invMotionMatCum(1,1:2)*xB+invMotionMatCum(1,3); ...
                     invMotionMatCum(2,1:2)*xB+invMotionMatCum(2,3)];
        warpTempBackwardX = xBackward(1,:) + motionOrigins(ii-1,1);
        warpTempBackwardY = xBackward(2,:) + motionOrigins(ii-1,2);
        
        warpingMapBackward(:,:,1,ii) = reshape( warpTempBackwardX, [height width]);
        warpingMapBackward(:,:,2,ii) = reshape( warpTempBackwardY, [height width]);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%% get the mapping from frame A to frame B %%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %xForward = motionMatCum * xB;
        xForward = [motionMatCum(1,1:2)*xB+motionMatCum(1,3); ...
                    motionMatCum(2,1:2)*xB+motionMatCum(2,3)];
        
        warpTempForwardX = xForward(1,:) + motionOrigins(ii-1,1);
        warpTempForwardY = xForward(2,:) + motionOrigins(ii-1,2);

        warpingMapForward(:,:,1,ii) = reshape( warpTempForwardX, [height width]);
        warpingMapForward(:,:,2,ii) = reshape( warpTempForwardY, [height width]);
    end
end