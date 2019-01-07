%this function reads a video file in matlab
% please note : matlab is very picky about the video files it can read,
% uncompressed avi is preferable

function[imgVol] = read_video(varargin)

    videoFile = varargin{1};
    if (nargin == 3)
        firstFrame = varargin{2};
        lastFrame = varargin{3};
    else
        firstFrame = -1;
        lastFrame = -1;
    end

    %get the extension of the video file
    [~,videoName,vidExtension] = fileparts(videoFile);


    if (strcmp(vidExtension,'.avi') || strcmp(vidExtension,'.mpeg'))       %we have a video file
        vidTemp = VideoReader(videoFile);
        nbFrames = get(vidTemp,'NumberOfFrames');
        if (strcmp(computer,'GLNXA64') || strcmp(computer,'GLNX86'))    %if the we are in a linux environment
            for ii=1:nbFrames
                imgTemp = read(vidTemp,ii);
                imgVol(:,:,ii,:) = double(imgTemp);
            end
        elseif (strcmp(computer,'PCWIN') || strcmp(computer,'PCWIN64'))    %if the we are in a windows environment
            for ii=1:nbFrames
                imgVol(:,:,ii,:) = double(read(vidTemp,ii));
            end
        elseif ( strcmp(computer,'MACI64') )    %if the we are in a mac OSX environment
        	for ii=1:nbFrames
                imgVol(:,:,ii,:) = double(read(vidTemp,ii));
            end
        else        %other cases : note, has not been tested for these platforms
            disp('Please note, the software has not been tested for your operating system.');
            for ii=1:nbFrames
                imgVol(:,:,ii,:) = double(read(vidTemp,ii));
            end
        end
    else        %we suppose that the input is a series of image files
        if ( (firstFrame == -1) || (lastFrame == -1))   %we try and read ALL the files in the current directory with the correct name
            currentFiles = jointdir([dir(fullfile(videoFile, '*.png')), dir(fullfile(videoFile, '*.jpg'))]);
            nbFrames = length(currentFiles)
            %read images
            for ii=1:nbFrames
                currFileName = fullfile(currentFiles(ii).folder, currentFiles(ii).name);
                imgVol(:,:,ii,:) = double(imread(currFileName));
            end
        else
            for ii=firstFrame:lastFrame
                currentFile = dir(strcat(videoName,num2str(ii),'.*'));
                if (~isempty(currentFile))
                    imgVol(:,:,ii,:) = double(imread(currentFile.name));
                else
                    disp('Error : cannot read file :');
                    strcat(videoFile,num2str(ii),'*')
                end
            end
        end
    end
    imgVol = squeeze(imgVol);   %get rid of potential useless dimensions
end
