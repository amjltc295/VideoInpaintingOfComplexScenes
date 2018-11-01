%this function retrieves a spatio-temporal pyramid of features
%for the purpose of video inpainting


function[featurePyramid] = get_video_features(imgVol,occVol,maxLevel,fileName)

    imgVolSize = size(imgVol);
    
    %set up feature images
    featurePyramid = cell(maxLevel,4);
    
    
    for ii=1:maxLevel
        yLength = length(1:(2^(ii-1)):imgVolSize(2));
        xLength = length(1:(2^(ii-1)):imgVolSize(3));
        tLength = length(1:imgVolSize(4));
        
        featurePyramid{ii,1} = zeros(yLength,xLength,tLength);
        featurePyramid{ii,2} = zeros(yLength,xLength,tLength);
        featurePyramid{ii,3} = zeros(yLength,xLength,tLength);
        featurePyramid{ii,4} = zeros(yLength,xLength,tLength);
    end
    
% % %     opticalFlow = load(strcat(fileName,'_dense_motion.mat'));
% % %     opticalFlow = opticalFlow.denseMotion;
    for ii=1:imgVolSize(4)
        imgTemp = permute(squeeze(imgVol(:,:,:,ii)),[2 3 1]);
        occTemp = occVol(:,:,ii);
        featurePyramidTemp = get_caselles_descriptors(imgTemp,occTemp,maxLevel);
        
        
        for jj=1:maxLevel
            gradXtemp = featurePyramid{jj,1};
            gradYtemp = featurePyramid{jj,2};
            normGradXtemp = featurePyramid{jj,3};
            normGradYtemp = featurePyramid{jj,4};
            
            %retrieve the feature information
            gradXtemp(:,:,ii) = single(featurePyramidTemp{jj,1});
            gradYtemp(:,:,ii) = single(featurePyramidTemp{jj,2});
            normGradXtemp(:,:,ii) = single(featurePyramidTemp{jj,3});
            normGradYtemp(:,:,ii) = single(featurePyramidTemp{jj,4});
            
            featurePyramid{jj,1} = gradXtemp;
            featurePyramid{jj,2} = gradYtemp;
            featurePyramid{jj,3} = normGradXtemp;
            featurePyramid{jj,4} = normGradYtemp;
            
        end
        
    end
    
end