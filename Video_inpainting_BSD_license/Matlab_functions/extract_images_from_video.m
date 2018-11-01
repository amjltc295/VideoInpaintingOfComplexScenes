
%input arguments
%1/ Input video name
%2/ Output files name
%3/ maximum number of frames to convert (by default, all frames in video)
function[] = extract_images_from_video(varargin)

    %input arguments
    fileIn = varargin{1};
    vidIn = VideoReader(fileIn);
    
    %output files name
    outputFileName =  varargin{2};
    
    if (nargin <3)
        maxFrames = get(vidIn,'NumberOfFrames');
    else
        maxFrames = varargin{3};
        if isempty(maxFrames)
            maxFrames = get(vidIn,'NumberOfFrames');
        end
    end
    
    for ii=1:maxFrames
        imgTemp = read(vidIn,ii);
        imwrite(imgTemp,strcat(outputFileName,'_frame_',sprintf('%04d', ii),'.png'));
    end
    
end