%this function reads the info in the affine motion estimation

% Motion matrix (input) :
%   [frameNb  rowOrigin  colOrigin  xComponent   yComponent]

%globalMotionOut :
%   [c1(x) c2(y)  a1  a2  a3  a4 ]

%   motionOrigins
%   [xCoordOrigin yCoordOrigin]

function[globalMotionOut,motionOrigins] = read_global_motion_odobez(file)

    fidTemp = fopen(file);
    globalMotionOut = textscan(fidTemp,'%f','HeaderLines',43);
    fclose(fidTemp);
    
    globalMotionOut = globalMotionOut{1,1};
    globalMotionOut = (reshape(globalMotionOut,[17 length(globalMotionOut)/17]))';
    globalMotionOut(:,1) = [];
    %get the origin coordinates
    motionOrigins = fliplr(globalMotionOut(:,1:2));
    globalMotionOut(:,9:end) = [];
    globalMotionOut(:,1:2) = [];
end