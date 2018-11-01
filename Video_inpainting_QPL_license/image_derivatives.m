%this function calculates the image derivatives of a colour image volume

function[u,v] = image_derivatives(imgVol,opticalFlowType)

    %parameters
    epsilon = 1;
    imgVolSize = size(imgVol);
    
    if (length(imgVolSize) == 3)
        u = zeros();
        v = zeros();
        return;
    end

    if (strcmp(opticalFlowType,'rough'))
        %convert to greyscale
        imgVolGrey = zeros([imgVolSize(1) imgVolSize(2) imgVolSize(3)]);
        for ii=1:imgVolSize(3)
            imgVolGrey(:,:,ii) = double(rgb2gray(uint8(squeeze(imgVol(:,:,ii,:)))));
        end

        Yy = diff(imgVolGrey,1,1);  %y derivative
        Yy(imgVolSize(1),:,:) = 0;
        Yx = diff(imgVolGrey,1,2);  %x derivative
        Yx(:,imgVolSize(2),:) = 0;
        Yt = diff(imgVolGrey,1,3);  %temporal derivative
        Yt(:,:,imgVolSize(3)) = 0;

        u = Yt./(max(abs(Yy),epsilon));
        v = Yt./(max(abs(Yx),epsilon));

        u = u./max(max(abs(u(:))),epsilon);
        v = v./max(max(abs(v(:))),epsilon);
    elseif (strcmp(opticalFlowType,'tvl1'))
        [u,v] = optical_flow_sequence(imgVol);
    else
        disp('Error, problem with optical flow type in image_derivatives.m');
    end
end