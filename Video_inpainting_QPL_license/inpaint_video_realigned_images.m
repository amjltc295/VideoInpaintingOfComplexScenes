%this function inpaints a video, with the video domain specified
%(this is useful when inpainting realigned videos)

% varargin
% 1/ input video
% 2/ occlusion volume
% 3/ image domain
% 4/ inpainting parameters

function[imgOut, shiftVolOut] = inpaint_video_realigned_images(varargin)

    imgVolIn = varargin{1};
    occVolIn = varargin{2};
    imgDomainVolIn = varargin{3};

    %if we want to save the info
    saveInfo = 0;

    %FIXED PARMETERS !!!
    %GAUSSIAN PYRAMID PARAMETERS
    filterSize = 3;    %fixed
    sigma = 1.5;
    scaleStep = 0.5;    %fixed
        
    useAllPatches = 0;
    reconstructionType = 0;

    %parse inpainting parameters
    [maxLevel,patchSizeX,patchSizeY,patchSizeT,textureFeaturesActivated,sigmaColour,file] = ...
    parse_inpaint_parameters(varargin{4});
    %patchMatch parameters
    patchSize = [patchSizeX patchSizeY min(patchSizeT,size(imgVolIn,4))];
    patchMatchParams.patchSizeX = patchSize(1);
    patchMatchParams.patchSizeY = patchSize(2);
    patchMatchParams.patchSizeT = patchSize(3);
    patchMatchParams.w = max([size(imgVolIn,2) size(imgVolIn,3) size(imgVolIn,4)]);  %manual
	patchMatchParams.alpha = 0.5;   %fixed
    patchMatchParams.fullSearch = 0;
    patchMatchParams.partialComparison = 1;
    patchMatchParams.nbItersPatchMatch = 10;
    patchMatchParams.patchIndexing = 0;
    patchMatchParams.longPropagation = 0;
    patchMatchParams.reconstructionType = reconstructionType;
    patchMatchParams.annSearch = 0;

    nbIterationsWexler = 20;
    residualThresh = 0.1;
    
    imgVolPyramid = get_image_volume_pyramid(imgVolIn,filterSize,sigma,maxLevel,size(imgVolIn,4));%patchSize(3)
    occVolPyramid = get_image_volume_pyramid(occVolIn,filterSize,sigma,maxLevel,size(imgVolIn,4));%patchSize(3)
    imgDomainVolPyramid = get_image_volume_pyramid(imgDomainVolIn,filterSize,sigma,maxLevel,size(imgVolIn,4));%patchSize(3)
    
    if (textureFeaturesActivated>0)
        disp('Calculating texture feature pyramids');
        featurePyramid = get_video_features(imgVolIn,occVolIn,maxLevel,file);
    end
    
    shiftVolHistory = cell(0);
    imgVolHistory = cell(0);
    occVolHistory = cell(0);
    t1 = tic;
    
    for ii=maxLevel:-1:1
        pp=1;
        iterationNb = 1;
        residual = inf;

        occVol = single(occVolPyramid{ii});
        occVolFine = single(occVolPyramid{max(ii-1,1)}); 
        
        imgVol(1,:,:,:) = imgVolPyramid{ii,1};  %get the red channel for this image volume
        imgVol(2,:,:,:) = imgVolPyramid{ii,2};  %get the blue channel for this image volume
        imgVol(3,:,:,:) = imgVolPyramid{ii,3};  %get the green channel for this image volume
        
        imgVolFine(1,:,:,:) = imgVolPyramid{max(ii-1,1),1};  %get the red channel for this image volume
        imgVolFine(2,:,:,:) = imgVolPyramid{max(ii-1,1),2};  %get the blue channel for this image volume
        imgVolFine(3,:,:,:) = imgVolPyramid{max(ii-1,1),3};  %get the green channel for this image volume
        
        imgDomainVol = imgDomainVolPyramid{ii};
        imgDomainVol(occVol>0) = 0;
        
        if (exist('featurePyramid','var'))
            gradX = single(featurePyramid{ii,1});
            gradY = single(featurePyramid{ii,2});
            normGradX = single(featurePyramid{ii,3});
            normGradY = single(featurePyramid{ii,4});

            patchMatchParams.gradX = gradX;
            patchMatchParams.gradY = gradY;
            patchMatchParams.normGradX = normGradX;
            patchMatchParams.normGradY = normGradY;
        end
        
                
        if (ii~=maxLevel)
            %recreate the image volume : if we are not at the coarsest
            %level
            occVolToInpaint = single(zeros(size(occVol)));
            occVolToInpaint(occVol>0) = -1;     %tell the reconstruction to inpaint these pixels AND to take them into account
            occVolToInpaint(imgDomainVol>0) = 2;    %tell the reconstruction NOT to take these pixels into account
            if (exist('featurePyramid','var') && exist('shiftVol'))
                [imgVol,gradX,gradY,normGradX,normGradY] = reconstruct_video_and_features_mex(imgVol,occVolToInpaint,...
                        shiftVol,patchMatchParams,...
                        sigmaColour,useAllPatches,reconstructionType);%
                patchMatchParams.gradX = single(gradX); patchMatchParams.gradY = single(gradY); patchMatchParams.normGradX = single(normGradX); patchMatchParams.normGradY = single(normGradY);
            else
                [imgVol] = reconstruct_video_mex(imgVol,occVolToInpaint,...
                        shiftVol,patchMatchParams,...
                        sigmaColour,useAllPatches,reconstructionType);%
            end
        end
        
        structElPatch = strel('arbitrary', ones(patchSize(2),patchSize(1),patchSize(3)));
        occVolDilate = imdilate(occVol,structElPatch);
        occVolFineDilate = imdilate(occVolFine,structElPatch);

        if(saveInfo >0)
            imgVolHistory{iterationNb} = imgVol;
            occVolHistory{iterationNb} = occVol;
            shiftVolHistory{iterationNb} = [];
        end
        iterationNb = iterationNb+1;
        while (pp<= nbIterationsWexler && residual > residualThresh)%

            sizeImgVol = size(imgVol);
            imgVolIterMinusOne = imgVol+1-1;
            
            if (ii ~= maxLevel || pp>1)     %not bottom level
                
                if (exist('shiftVol'))% && (ii ~=maxLevel))% && pp>1)%  %
                    firstGuess = shiftVol+1-1;%zeros([size(imgVol,1) size(imgVol,2) size(imgVol,3) 4]);%
                else
                    firstGuess = single(zeros([4 size(imgVol,2) size(imgVol,3) size(imgVol,4)]));
                end

                %calculate nearest neighbour shift map
                occVolToModify = occVolDilate;
                occVolPatchMatch = single(zeros(size(occVolDilate)));
                occVolPatchMatch(occVolDilate>0) = 2;   %tell the algorithm that these pixels are occluded, but take them into account
                occVolPatchMatch(imgDomainVol>0) = 1;   %tell the algorithm that these pixels are NOT to be taken into account (and they are occluded)

                shiftVol = spatio_temporal_patch_match_mex( imgVol, imgVol,...
                    patchMatchParams,firstGuess,occVolPatchMatch,occVolToModify);

                if (exist('stop_and_debug.txt'))
                    keyboard;
                end

                occVolToInpaint = single(zeros(size(occVol)));
                occVolToInpaint(occVol>0) = -1;     %tell the reconstruction to inpaint these pixels AND to take them into account
                occVolToInpaint(imgDomainVol>0) = 2;    %tell the reconstruction NOT to take these pixels into account
                if (exist('featurePyramid','var') && exist('shiftVol'))
                    [imgVol,gradX,gradY,normGradX,normGradY] = reconstruct_video_and_features_mex(imgVol,occVolToInpaint,...
                            shiftVol,patchMatchParams,...
                            sigmaColour,useAllPatches,reconstructionType);%
                    patchMatchParams.gradX = single(gradX); patchMatchParams.gradY = single(gradY); patchMatchParams.normGradX = single(normGradX); patchMatchParams.normGradY = single(normGradY);
                else
                    [imgVol] = reconstruct_video_mex(imgVol,occVolToInpaint,...
                        shiftVol,patchMatchParams,...
                            sigmaColour,useAllPatches,reconstructionType);%
                end
% %                   
% %                 imgVol = reconstruct_coarse_level_wexler(imgVol,occVol,distanceWeighting,shiftVol,patchSize,sigmaColour,gamma,useAllPatches,reconstructionType);


                if (saveInfo == 1)
                    imgVolHistory{iterationNb} = imgVol;
                    occVolHistory{iterationNb} = occVol;
                    shiftVolHistory{iterationNb} = shiftVol;
                end
                iterationNb = iterationNb+1;
                %show_before_after_frames(imgVol);
                
            else     %coarsest level : initialisation
                
                %get the dilated (by half a patch size) occlusion volume
                
                occVolIter = occVol;
                sumHole = sum(occVolIter(:));
                while(sumHole >0)
                    sumHole = sum(occVolIter(:));

                    structElCube = strel('arbitrary', ones(3,3,3));
                    occVolErode = imerode_custom_image_domain(occVolIter,occVol,structElCube,imgDomainVol);
                    
                    %set up the partial occlusion volume : 0 for non occlusion; 1 for occluded and not to take into account; 2 for occluded and to take into account
                    occVolPatchMatch = occVolDilate;
                    occVolPatchMatch((occVolDilate - occVolIter) == 1) = 2;
                    occVolPatchMatch(imgDomainVol>0) = 1;
                        
                    %initial guess
                    if (~exist('shiftVol'))
                        firstGuess = single(zeros([4 size(imgVol,2) size(imgVol,3) size(imgVol,4)]));
                    else
                        firstGuess = shiftVol+1-1;
                    end
                    
% % %                     if (exist('imgDomainVolPyramid','var'))
% % %                         occVolPatchMatch(imgDomainVol>0) = -2;
% % %                     end
                    shiftVol = spatio_temporal_patch_match_mex(imgVol, imgVol,...
                     patchMatchParams,firstGuess,occVolPatchMatch,occVolDilate);

                    if (exist('stop_and_debug.txt'))
                        keyboard;
                    end
                    
                    occVolBorder = abs(occVolIter - occVolErode);
                    %if the occVol == 2, then we cannot use the colour info, but
                    %we do not inpaint it
                    occVolBorder(occVolErode == 1) = 2;
                    occVolBorder(imgDomainVol>0) = 2;
                    
                    if (exist('featurePyramid','var') && exist('shiftVol'))
                        [imgVol,gradX,gradY,normGradX,normGradY] = reconstruct_video_and_features_mex(imgVol,occVolBorder,...
                            shiftVol,patchMatchParams,...
                            sigmaColour,useAllPatches,reconstructionType);%
                        patchMatchParams.gradX = single(gradX); patchMatchParams.gradY = single(gradY); patchMatchParams.normGradX = single(normGradX); patchMatchParams.normGradY = single(normGradY);
                    else
                        [imgVol] = reconstruct_video_mex(imgVol,occVolBorder,...
                            shiftVol,patchMatchParams,...
                                sigmaColour,useAllPatches,reconstructionType);%
                    end
% % %                     
                    occVolIter = occVolErode;
                    
                    if (saveInfo == 1)
                        imgVolHistory{iterationNb} = imgVol;
                        occVolHistory{iterationNb} = occVol;
                        shiftVolHistory{iterationNb} = shiftVol;
                    end
                    iterationNb = iterationNb+1;
                    %show_before_after_frames(imgVol);
                end
            end
            pp=pp+1;
            
            occVolInds = find(occVol > 0);
            %sigmaColour = max(sigmaColour*0.7,0.01);
            residual = sum(abs(imgVolIterMinusOne(:) - imgVol(:)))/(single(3*sum(occVol(:)>0)))
        end
        beep;

        if (ii>1)
            imgVol = imgVolFine;%[];%
            %interpolate the shift volume
            shiftVol = single(interpolate_disp_field(shiftVol,imgVol,1/scaleStep, patchSize,'nearest'));
        end

        
        
        if (ii==1)
            t2 = toc(t1)
            occVolToInpaint = single(zeros(size(occVol)));
            occVolToInpaint(occVol>0) = -1;     %tell the reconstruction to inpaint these pixels AND to take them into account
            occVolToInpaint(imgDomainVol>0) = 2;    %tell the reconstruction NOT to take these pixels into account
            imgVol = reconstruct_video_mex(imgVol,occVolToInpaint,...
                        shiftVol,patchMatchParams,sigmaColour,useAllPatches,1);
            occInds = find(occVol>0);
            energy = sum(shiftVol(occInds + 3*prod(sizeImgVol(1:2))));
            imgOut = imgVol;
            shiftVolOut = shiftVol;
            
            diary off;
            return;
        end
        imgVolPerfect = single([]);
        occVolDilate = single([]);
        occVolPatchMatch = single([]);
        imgVolFine = single([]);

        nbIterationsWexler = 20;
        
        sigmaColour = 75;
        
    end
    imgOut = imgVol;
end
