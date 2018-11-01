%this function calculates the image pyramid of an (colour) image volume and
%its occlusion volume, for a certain number of levels
%inputs :
%   1/ imgage volume
%   2/ downsampling filter size
%   3/ downsampling filter sigma
%   4/ number of levels in pyramid
%   5/ minimum temporal size

function[imgVolPyramid] = get_image_volume_pyramid(varargin)

    %parse inputs
    imgVol = varargin{1};
    switch nargin
        case 1
            filterSize = 3;
            sigma = 1;
            nbLevels = 2;
            minTempSize = 1;
        case 2
            filterSize = varargin{2};
            sigma = 1;
            nbLevels = 2;
            minTempSize = 1;
        case 3
            filterSize = varargin{2};
            sigma = varargin{3};
            nbLevels = 2;
            minTempSize = 1;
        case 4
            filterSize = varargin{2};
            sigma = varargin{3};
            nbLevels = varargin{4};
            minTempSize = 1;
        case 5
            filterSize = varargin{2};
            sigma = varargin{3};
            nbLevels = varargin{4};
            minTempSize = varargin{5};
        otherwise
            disp('Error, get_image_volume_pyramid must have 1, 2, 3 or 4 inputs.');
    end
   
    %parameters
    dsStep = 2; %downsample step
    temporalFiltering = 0;
    gaussFilter = fspecial('gaussian',[filterSize 1],sigma);
    
    gaussFilterY(1:filterSize,1,1) = gaussFilter;
    gaussFilterX(1,1:filterSize,1) = gaussFilter;
    gaussFilterZ(1,1,1:filterSize) = gaussFilter;
    
    if (ndims(imgVol) == 3) %binary occlusion volume
        imgVolPyramid = cell(nbLevels,1);   %three image colours
        imgVolPyramid{1} = imgVol;
        
        for ii=2:nbLevels
            if ( (size(imgVolPyramid{ii-1,1},3) >= (2*minTempSize)) && (temporalFiltering >0) )   %we are able to downsample temporally
                imgTemp = imfilter(imfilter(imfilter(imgVolPyramid{ii-1},gaussFilterY,'same','symmetric'),gaussFilterX,'same','symmetric'),gaussFilterZ,'same','symmetric');%
                imgTemp = double(~~imgTemp);
                imgVolPyramid{ii} = imgTemp(1:dsStep:end,1:dsStep:end,1:dsStep:end);
                
            else   %we have reached the minimum temporal size
                imgTemp = imfilter(imfilter(imgVolPyramid{ii-1},gaussFilterY,'same','symmetric'),gaussFilterX,'same','symmetric');
                imgTemp = double(~~(imgTemp));
                imgVolPyramid{ii} = imgTemp(1:dsStep:end,1:dsStep:end,:);
            end
        end
    else
        imgVolPyramid = cell(nbLevels,3);   %three image colours
        imgVolPyramid{1,1} = squeeze(imgVol(1,:,:,:));
        imgVolPyramid{1,2} = squeeze(imgVol(2,:,:,:));
        imgVolPyramid{1,3} = squeeze(imgVol(3,:,:,:));
        
        for ii=2:nbLevels
            if ( (size(imgVolPyramid{ii-1,1},3) >= (2*minTempSize)) && temporalFiltering>0 )   %we are able to downsample temporally
                for jj=1:3  %number of colours
                    imgTemp = imfilter(imfilter(imfilter(imgVolPyramid{ii-1,jj},gaussFilterY,'same','symmetric'),gaussFilterX,'same','symmetric'),gaussFilterZ,'same','symmetric');%
                    imgVolPyramid{ii,jj} = imgTemp(1:dsStep:end,1:dsStep:end,1:dsStep:end);
                end
            else   %we have reached the minimum temporal size
                for jj=1:3  %number of colours
                    imgTemp = imfilter(imfilter(imgVolPyramid{ii-1,jj},gaussFilterY,'same','symmetric'),gaussFilterX,'same','symmetric');
                    imgVolPyramid{ii,jj} = imgTemp(1:dsStep:end,1:dsStep:end,:);
                end
            end
        end
    end

    
end
