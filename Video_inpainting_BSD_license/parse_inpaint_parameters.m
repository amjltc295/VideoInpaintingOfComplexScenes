
%function to parse the inpainting parameters
function[maxLevel,patchSizeX,patchSizeY,patchSizeT,textureFeaturesActivated,sigmaColour,file] = ...
    parse_inpaint_parameters(inpaintingParameters)

    %set default parameters
    sigmaColour = 75;
    maxLevel = 4;
    patchSizeX = 5;
    patchSizeY = 5;
    patchSizeT = 5;
    textureFeaturesActivated = 1;    %by default, features are activated

    % Parse the arguments to the function  
    for ii=1:length(inpaintingParameters)
        str = inpaintingParameters{ii};
        if (strcmp(str,'file')>0)
            file = inpaintingParameters{ii+1};
        end
		if (strcmp(str,'maxLevel')>0)
            maxLevel = inpaintingParameters{ii+1};
        end
        if (strcmp(str,'patchSizeX')>0)
			patchSizeX = inpaintingParameters{ii+1};
        end
		if (strcmp(str,'patchSizeY')>0)
			patchSizeY = inpaintingParameters{ii+1};
        end
		if (strcmp(str,'patchSizeT')>0)
			patchSizeT = inpaintingParameters{ii+1};
        end
        if (strcmp(str,'textureFeaturesActivated')>0)
			textureFeaturesActivated = inpaintingParameters{ii+1};
        end
    end

end