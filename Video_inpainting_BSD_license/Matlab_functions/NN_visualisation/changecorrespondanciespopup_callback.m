%this function changes the set of correspondencies of the 

function changecorrespondanciespopup_callback(source, event)

    fCurrent = get(source,'Parent');
    currUserData = get(fCurrent,'UserData');
    imgVolA = currUserData.imgVolA;
    imgVolB = currUserData.imgVolB;
    shiftVol = currUserData.shiftVol;
    frameNum = currUserData.frameNum;
    patchSize = currUserData.patchSize;
    correspondanceMat = currUserData.correspondanceMat;
    analysis = currUserData.analysis;
    
    %get the correspondencies being analysed
    fCorrespondenciesList = get_figure_child(fCurrent,'changeCorrespondenciesButton');
    correspondencyNum = get(fCorrespondenciesList,'Value');
    currUserData.correspondencyNum = correspondencyNum;
        
    occVol = currUserData.occVol;
    onlyCorrespondingFrames = currUserData.onlyCorrespondingFrames;
    colour = currUserData.colour;
    screenSize = currUserData.screenSize;
    
    [hPrinciple,correspondanceMat,hSubplot,lineHandle] = ...
        initialise_analysis_figure(fCurrent,analysis,imgVolA(:,:,:,:,correspondencyNum),imgVolB(:,:,:,:,correspondencyNum),...
        shiftVol(:,:,:,:,correspondencyNum),...
        frameNum,occVol,...
        onlyCorrespondingFrames,colour,screenSize,correspondanceMat);
    
    currUserData.correspondanceMat = correspondanceMat;
    currUserData.lineHandle = lineHandle;
    currUserData.frameNum = frameNum;
    currUserData.hPrinciple = hPrinciple;
    currUserData.hSubplot = hSubplot;

    set(fCurrent,'UserData',currUserData);
end