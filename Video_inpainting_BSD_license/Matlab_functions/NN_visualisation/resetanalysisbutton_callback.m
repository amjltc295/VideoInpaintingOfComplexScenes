%this function resets the shift volume analysis figure

function resetanalysisbutton_callback(source, event)

    fCurrent = get(source,'Parent');
    currUserData = get(fCurrent,'UserData');
    imgVolA = currUserData.imgVolA;
    imgVolB = currUserData.imgVolB;
    shiftVol = currUserData.shiftVol;
    frameNum = currUserData.frameNum;
    patchSize = currUserData.patchSize;
    correspondencyNum = currUserData.correspondencyNum;
    analysis = currUserData.analysis;
    occVol = currUserData.occVol;
    onlyCorrespondingFrames = currUserData.onlyCorrespondingFrames;
    colour = currUserData.colour;
    screenSize = currUserData.screenSize;
    
    for ii=1:length(currUserData.lineHandle)
        delete(currUserData.lineHandle(ii));
    end
    
    [hPrinciple,correspondanceMat,hSubplot,lineHandle] = ...
        initialise_analysis_figure(fCurrent,analysis,imgVolA(:,:,:,:,correspondencyNum),...
        imgVolB(:,:,:,:,correspondencyNum),shiftVol,frameNum,occVol,patchSize,...
        onlyCorrespondingFrames,colour,screenSize);
    
    currUserData.correspondanceMat = correspondanceMat;
    currUserData.lineHandle = lineHandle;
    currUserData.hPrinciple = hPrinciple;
    currUserData.hSubplot = hSubplot;

    set(fCurrent,'UserData',currUserData);
end