%this function shows the correspondances between an image volume, showing
%only the corresponding frames at a time
% inputs :
% 1: imgVolA
% 2: imgVolB
% 3: shiftVol
% 4: frameNum
% 5: patchSizes
% 6: occVol


function[] = analyse_shift_volume(varargin)

    %input variables
    imgVolA = varargin{1};
    imgVolB = varargin{2};
    shiftVol = varargin{3};
    frameNum = varargin{4};
    patchSize = varargin{5};
    if (nargin == 5)
        occVol = [];
    else
        occVol = varargin{6};
    end
    
    colour = 'g';
    
    %parameters and default values
    sizeImg = size(imgVolA);
    onlyCorrespondingFrames = 1;
    
    if (ndims(imgVolA) == 3)
        imgVolTemp = imgVolA;
        clear imgVolA;
        imgVolA(:,:,1,:) = imgVolTemp;
    end
    if (ndims(imgVolB) == 3)
        imgVolTemp = imgVolB;
        clear imgVolB;
        imgVolB(:,:,1,:) = imgVolTemp;
    end
    
    if (ndims(shiftVol) < 5)
        imgVolA(:,:,:,:,1) = imgVolA;
        imgVolB(:,:,:,:,1) = imgVolB;
        shiftVol(:,:,:,:,1) = shiftVol;
    end
    
    %imgVolume size
    imgVolSizeA = size(imgVolA);
    imgVolSizeB = size(imgVolB);
    
    fCurrent = figure;

    %set(fCurrent,'Units','normalized');
    %reset the toolbar to its original format
    set(fCurrent,'toolbar','figure');
        %%%% button to reset the analysis figure
    hresetanalysisbutton= uicontrol('Style','pushbutton',...
         'String','Reset analysis','Position',[2,50,180,30],...
         'Tag','resetButton');
    set(hresetanalysisbutton,'Callback',{'resetanalysisbutton_callback'});
    
    %%%% popup menu to change the current frame being analysed
    htextChangeFrame = uicontrol('Style','edit',...
            'String','Frame Choice',...
            'Position',[2 150 80 30],'Tag','text');
    popupStr = num2str(1);
    for ii=2:imgVolSizeA(3)
        popupStr = strcat(popupStr,'|',num2str(ii));
    end
    hchangeframebutton= uicontrol('Style','popupmenu',...
         'String',popupStr,'Position',[2,100,180,30],...
         'Tag','changeFrameButton');
    set(hchangeframebutton,'Callback',{'changeframepopup_callback'});
    
    screenSize = get(0, 'ScreenSize');
    set(fCurrent, 'Position', [0 0 screenSize(3) screenSize(4) ] );
    set(fCurrent,'Units','normalized');
    zh = zoom(gcf);
    set(zh,'actionpostcallback',{@postZoomFunc,'zoom post'});
    
    correspondencyNum = 1;
    [hPrinciple,correspondanceMat,hSubplot,lineHandle] = ...
        initialise_analysis_figure(fCurrent,'shiftVol',imgVolA(:,:,:,:,correspondencyNum),imgVolB(:,:,:,:,correspondencyNum),...
        shiftVol(:,:,:,:,correspondencyNum),...
        frameNum,occVol,patchSize,...
        onlyCorrespondingFrames,colour,screenSize);
    
    currUserData.correspondanceMat = correspondanceMat;
    currUserData.lineHandle = lineHandle;
    currUserData.hPrinciple = hPrinciple;
    currUserData.imgVolSizeA = imgVolSizeA;
    currUserData.imgVolSizeB = imgVolSizeB;
    currUserData.imgVolA = imgVolA;
    currUserData.imgVolB = imgVolB;
    currUserData.shiftVol = shiftVol;
    currUserData.frameNum = frameNum;
    currUserData.patchSize = patchSize;
    currUserData.correspondencyNum = 1;
    currUserData.onlyCorrespondingFrames = onlyCorrespondingFrames;
    currUserData.analysis = 'shiftVol';
    currUserData.colour = colour;
    currUserData.hSubplot = hSubplot;
    currUserData.screenSize = screenSize;
    if (nargin >4)
        currUserData.occVol = occVol;
    else
        currUserData.occVol = [];
    end
    set(fCurrent,'UserData',currUserData);

% % % %     set(lHandle,'Visible','off');
% % % %     delete(lHandle);
end

function postZoomFunc(source, event, s)

    colour = 'g';
    if strcmp(s,'zoom post')
        currUserData = get(gcf,'UserData');
        if (strcmp(currUserData.analysis,'shiftVol'))
            %get necessary information
            correspondanceMat = currUserData.correspondanceMat;
            lineHandle = currUserData.lineHandle;
            hPrinciple = currUserData.hPrinciple;
            hSubplot = currUserData.hSubplot;
            imgVolSizeA = currUserData.imgVolSizeA;
            imgVolSizeB = currUserData.imgVolSizeB;
            currAxes = event.Axes;
            currFrame = get(currAxes,'UserData');
            if ( currFrame ~= -1)   %if we have not resized the main image
                imgSize = imgVolSizeB;
            else
                imgSize = imgVolSizeA;
            end

            xlim = round(get(currAxes,'xlim')) + [-1 1]; %round the x and y limits
            ylim = round(get(currAxes,'ylim')) + [-1 1];
            xlim(1) = max(xlim(1),1);
            xlim(2) = min(xlim(2),imgSize(2));
            ylim(1) = max(ylim(1),1);
            ylim(2) = min(ylim(2),imgSize(1));

            set(currAxes,'xlim',xlim);
            set(currAxes,'ylim',ylim);
            %now recalculate the necessary coordinates
            for ii=1:size(correspondanceMat,1)
                if ( currFrame ~= -1)   %if we have not resized the main image
                    if (correspondanceMat(ii,6) ~= currFrame)
                        continue;
                    end
                else
                    if (ii==1)
                        hPrinciple = currAxes;
                    end
                    currAxes = hSubplot( hSubplot(:,2) == correspondanceMat(ii,6),1);
                end
                %delete the necessary line
                set(lineHandle(ii),'Visible','off');
                delete(lineHandle(ii));
                %now redraw the necessary line
                [x1 y1] = axescoord2figurecoord(correspondanceMat(ii,1),correspondanceMat(ii,2),hPrinciple);
                [x2 y2] = axescoord2figurecoord(correspondanceMat(ii,4),correspondanceMat(ii,5),currAxes);

                lineHandle(ii) = annotation(gcf,'line',[x1 x2],[y1 y2],'color',colour);

            end
            %now set the figure user data to the corrected values
            currUserData.lineHandle = lineHandle;
            currUserData.hPrinciple = hPrinciple;
            set(gcf,'UserData',currUserData);
        end
    end
end
