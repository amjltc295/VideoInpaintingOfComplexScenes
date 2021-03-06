%this function takes several videos and displays them
%side by side

close all;
clear all;

spaceWidth = 10;
orientation = 'vertical';

frameStep = 0.5;

file1 = 'Usine_scratch_original';
file2 = 'Usine_scratch_restored';
%file3 = 'beach_umbrella_ours';

%get input videos
vid1 = VideoReader(strcat(file1,'.avi'));
vid2 = VideoReader(strcat(file2,'.avi'));
%vid3 = VideoReader(strcat(file3,'.avi'));
nbFrames = get(vid2,'NumberOfFrames');

%create output video
vidOut = VideoWriter(strcat(file1,'_output.avi'),'Uncompressed Avi');
open(vidOut);

for ii=1:frameStep:(nbFrames-1)
%     img1 = read(vid1,round(ii));
%     img2 = read(vid2,round(ii));
%     img3 = read(vid3,round(ii));
%     
%     imgTemp = uint8(zeros([size(img1,1) size(img1,2)+size(img2,2)+size(img3,2)+2*spaceWidth 3]));
    
%     imgTemp(:,1:size(img1,2),:) = img1;
%     previousInd = size(img1,2);
%     imgTemp(:,(previousInd+spaceWidth+1):(previousInd+spaceWidth+size(img2,2)),:) = img2;
%     previousInd = previousInd+spaceWidth+size(img2,2);
%     imgTemp(:,(previousInd+spaceWidth+1):(previousInd+spaceWidth+size(img3,2)),:) = img3;
    
    if (strcmp(orientation,'horizontal'))
        img1 = read(vid1,round(ii));
        img2 = read(vid2,round(ii));

        imgTemp = uint8(zeros([size(img1,1) size(img1,2)+size(img2,2)+spaceWidth 3]));

        imgTemp(:,1:size(img1,2),:) = img1;
        previousInd = size(img1,2);
        imgTemp(:,(previousInd+spaceWidth+1):(previousInd+spaceWidth+size(img2,2)),:) = img2;
    else
        img1 = read(vid1,round(ii));
        img2 = read(vid2,round(ii));

        imgTemp = uint8(zeros([size(img1,1)+size(img2,1)+spaceWidth size(img1,2)  3]));

        imgTemp(1:size(img1,1),:,:) = img1;
        previousInd = size(img1,1);
        imgTemp((previousInd+spaceWidth+1):(previousInd+spaceWidth+size(img2,1)),:,:) = img2;
    end
    
    writeVideo(vidOut,imgTemp);
end

close(vidOut);
