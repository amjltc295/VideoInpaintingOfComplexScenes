%this function changes the type of analysis carried out on a shift volume
%for video inpainting

function[] = changeanalysispopup_callback(source, event)


    fCurrent = get(source,'Parent');
    currUserData = get(fCurrent,'UserData');
    imgVolA = currUserData.imgVolA;
    imgVolB = currUserData.imgVolB;
    shiftVol = currUserData.shiftVol;
    frameNum = currUserData.frameNum;
    patchSize = currUserData.patchSize;
    correspondencyNum = currUserData.correspondencyNum;
    
    %get the correspondencies being analysed
    fAnalysisList = get_figure_child(fCurrent,'changeAnalysisButton');
    analysisNum = get(fAnalysisList,'Value');
    if (analysisNum == 1)
        currUserData.analysis = 'shiftVol';
    elseif (analysisNum == 2)
        currUserData.analysis = 'colourDistribution';
    end
        
    occVol = currUserData.occVol;
    onlyCorrespondingFrames = currUserData.onlyCorrespondingFrames;
    colour = currUserData.colour;
    screenSize = currUserData.screenSize;
    
    [hPrinciple,correspondanceMat,hSubplot,lineHandle] = ...
        initialise_analysis_figure(fCurrent,currUserData.analysis,imgVolA(:,:,:,:,correspondencyNum),imgVolB(:,:,:,:,correspondencyNum),...
        shiftVol(:,:,:,:,correspondencyNum),...
        frameNum,occVol,patchSize,...
        onlyCorrespondingFrames,colour,screenSize);
    
    currUserData.correspondanceMat = correspondanceMat;
    currUserData.lineHandle = lineHandle;
    currUserData.frameNum = frameNum;
    currUserData.hPrinciple = hPrinciple;
    currUserData.hSubplot = hSubplot;

    set(fCurrent,'UserData',currUserData);
    
end