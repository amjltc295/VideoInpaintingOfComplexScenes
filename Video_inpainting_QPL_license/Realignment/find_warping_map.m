%this function finds the warping map for a series of images with respect
%to a reference image.
%We suppose an affine parametric motion model

%   motionParameters :
%   [c1 c2   a1  a2  a3  a4]
%   output :
%   [height,width,[xCoords yCoords],frameNb]

function[warpingMapBackward,warpingMapForward] = find_warping_map(height,width,frameNb,referenceFrame,motionParameters,motionOrigins)

    [originalCoordsX,originalCoordsY] = meshgrid( 1 : width, 1:height );

    warpingMapBackward = zeros(height,width,2);
    warpingMapForward = zeros(height,width,2);
    
    if (frameNb == referenceFrame)
        warpingMapBackward(:,:,1) = originalCoordsX;
        warpingMapBackward(:,:,2) = originalCoordsY;

        warpingMapForward(:,:,1) = originalCoordsX;
        warpingMapForward(:,:,2) = originalCoordsY;
    else
        motionMatCum = eye(3,3);
        for ii=referenceFrame:sign(frameNb-referenceFrame):(frameNb+sign(referenceFrame-frameNb))

            %   x(i+1) = xi + c1 + a1*xi + a2*yi
            %   [xi+1 yi+1 1]' = [a1+1 a2+1 c1] * [xi]
            %                    [a3+1 a4+1 c2]   [yi]
            %                    [0  0   1]   [1 ]
            motionFrameInd = ii - 1*(referenceFrame>frameNb);
            motionMat = [ motionParameters(motionFrameInd,3)+1 motionParameters(motionFrameInd,4) motionParameters(motionFrameInd,1);...
                        motionParameters(motionFrameInd,5) motionParameters(motionFrameInd,6)+1 motionParameters(motionFrameInd,2); 0 0 1];

            if (sign(frameNb-referenceFrame) == 1)
                motionMatCum = motionMat * motionMatCum;
            else
                motionMatCum = motionMat \ motionMatCum;
            end
        end
            
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%% get the mapping from frame B to frame A %%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        coordSystemX = originalCoordsX - motionOrigins(ii-1,1);
        coordSystemY = originalCoordsY - motionOrigins(ii-1,2);
        % xA = (W)^-1 * xB
        xB = [ (coordSystemX(:))' ; (coordSystemY(:))']; %; ones(1,length(coordSystemX(:))) 

        invMotionMatCum = inv(motionMatCum);
        xBackward = [invMotionMatCum(1,1:2)*xB+invMotionMatCum(1,3); ...
                     invMotionMatCum(2,1:2)*xB+invMotionMatCum(2,3)];
        warpTempBackwardX = xBackward(1,:) + motionOrigins(min(frameNb,size(motionOrigins,1)),1);
        warpTempBackwardY = xBackward(2,:) + motionOrigins(min(frameNb,size(motionOrigins,1)),2);

        warpingMapBackward(:,:,1) = reshape( warpTempBackwardX, [height width]);
        warpingMapBackward(:,:,2) = reshape( warpTempBackwardY, [height width]);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%% get the mapping from frame A to frame B %%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %xForward = motionMatCum * xB;
        xForward = [motionMatCum(1,1:2)*xB+motionMatCum(1,3); ...
                    motionMatCum(2,1:2)*xB+motionMatCum(2,3)];

        warpTempForwardX = xForward(1,:) + motionOrigins(min(frameNb,size(motionOrigins,1)),1);
        warpTempForwardY = xForward(2,:) + motionOrigins(min(frameNb,size(motionOrigins,1)),2);

        warpingMapForward(:,:,1) = reshape( warpTempForwardX, [height width]);
        warpingMapForward(:,:,2) = reshape( warpTempForwardY, [height width]);
        
    end

    
end