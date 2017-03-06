function main_fun
global Xcorners Ycorners pathname filesim numframes framefiles bwporig TimeSelection shape localtime results resultrow resultsfolder 
global drawfront project_name cornersnum MainF images squareSize imagesUsed workpathname work loudstatuse AngleWorld Lworld
%% building the GUI
MainF = figure('Visible','off','Position',[680,93,800,580],'CloseRequestFcn',@MainF_CloseRequestFcn);
htgroup = uitabgroup('Parent', MainF );
htabNew = uitab('Parent', htgroup,'Units','pixels','Title', '   New Project   ');
htabLoad = uitab('Parent', htgroup, 'Title', '   Load Project   ');
htabMatch = uitab('Parent', htgroup, 'Title', '   Match Images   ');
% first tab (New Project)
% Inputs panel (left)
hpanelInput=uipanel(htabNew,'Units','pixels','Title','Inputs','FontSize',10,'Position',[0,0,450,595]);
htextPname  = uicontrol(hpanelInput,'Style','text','String','Project Name:',...
    'FontSize',11,'FontWeight','bold','Position',[80,535,115,25]);
heditPname  = uicontrol(hpanelInput,'Style','edit','Position',[198,535,180,25],'FontSize',10,'FontWeight','bold');
htextIcalib  = uicontrol(hpanelInput,'Style','text','String','Calibration Images:',...
    'FontSize',11,'Position',[13,485,140,24]);
heditIcalib  = uicontrol(hpanelInput,'Style','edit','Position',[155,485,180,25],'FontSize',10);
hbuttonIcalib  = uicontrol(hpanelInput,'Style','pushbutton','String','Add Files','FontSize',10,...
    'Position',[345,485,85,25],'callback',{@buttonIcalib_Callback});
htextIframes  = uicontrol(hpanelInput,'Style','text','String',' Fire Front Images:',...
    'FontSize',11,'Position',[13,450,140,24]);
heditIframes  = uicontrol(hpanelInput,'Style','edit','Position',[155,450,180,25],'FontSize',10);
hbuttonIframes  = uicontrol(hpanelInput,'Style','pushbutton','String','Add Files','FontSize',10,...
    'Position',[345,450,85,25],'callback',{@buttonIframes_Callback});
htextIbed  = uicontrol(hpanelInput,'Style','text','String',' Bed Surface Ref.:',...
    'FontSize',11,'Position',[13,415,140,24]);
heditIbed  = uicontrol(hpanelInput,'Style','edit','Position',[155,415,180,25],'FontSize',10);
hbuttonIbed  = uicontrol(hpanelInput,'Style','pushbutton','String','Add Files','FontSize',10,...
    'Position',[345,415,85,25],'callback',{@buttonIbed_Callback});
htextSize  = uicontrol(hpanelInput,'Style','text','String','Size of the Check board Square:',...
    'FontSize',11,'Position',[40,360,240,24]);
heditSize  = uicontrol(hpanelInput,'Style','edit','Position',[270,360,70,25],'FontSize',10);
htextMm  = uicontrol(hpanelInput,'Style','text','String','mm','FontSize',11,'Position',[342,360,28,24]);
%time Group
hbgTime     = uibuttongroup(hpanelInput,'Units','pixels','Title','Time Laps','FontSize',10,'Position',[100 260 260 90],'SelectionChangedFcn',@selectionTime);
hradioConstant    = uicontrol(hbgTime  ,'Style','radiobutton','String','Constant Lap','Position',[20 44 100 23],'FontSize',10);
hradioVariable   = uicontrol(hbgTime  ,'Style','radiobutton','String','Variable Lap','Position',[20 16 100 23],'FontSize',10);
heditLaps    = uicontrol(hbgTime,'Style','edit','Position',[140,44,95,23],'FontSize',10,'callback',{@editLaps_Callback});
hbuttonLaps  = uicontrol(hbgTime,'Style','pushbutton','String','Add Laps','FontSize',10,...
    'Position',[140,14,95,23],'callback',{@buttonLaps_Callback},'Enable','off');
htextS  = uicontrol(hbgTime,'Style','text','String','s','FontSize',11,'Position',[237,44,10,23]);
%Fuel bed group
hbgBed     = uibuttongroup(hpanelInput,'Units','pixels','Title','Fuel Bed Geometry','FontSize',10,...
    'Position',[50 130 350 120],'SelectionChangedFcn',@selectionTime);
htextShape  = uicontrol(hbgBed,'Style','text','String','Fuel Bed Shape','FontSize',11,'Position',[25,72,107,24]);
hpopShape  = uicontrol(hbgBed,'Style','pop','Units','pixels','String',{'Rectangular';'Triangle';'Draw Shape Manually';'Not Specified'},...
    'value',4,'FontSize',10,'Position',[135,73,170,24],'callback',{@popShape_Callback});
htextLength  = uicontrol(hbgBed,'Style','text','String','Length','FontSize',11,'Position',[6,40,50,23]);
heditLength    = uicontrol(hbgBed,'Style','edit','Position',[58,40,75,23],'FontSize',10,'Enable','off');
htextCm1  = uicontrol(hbgBed,'Style','text','String','cm','FontSize',11,'Position',[133,40,30,23]);       
hbuttonDetect  = uicontrol(hbgBed,'Style','pushbutton','String','Detect Bed Location','FontSize',10,...
    'Position',[180,40,150,23],'callback',{@buttonDetect_Callback},'Enable','off');
htextAngle  = uicontrol(hbgBed,'Style','text','String','Angle','FontSize',11,'Position',[6,10,50,23]);
heditAngle    = uicontrol(hbgBed,'Style','edit','Position',[58,10,75,23],'FontSize',10,'Enable','off');
htextCm2  = uicontrol(hbgBed,'Style','text','String','°','FontSize',11,'Position',[133,10,30,23]);
hbuttonDraw  = uicontrol(hbgBed,'Style','pushbutton','String','Draw Shape Manually','FontSize',10,...
    'Position',[180,10,150,23],'callback',{@buttonDraw_Callback},'Enable','off');
%%%%%
hcheckSave = uicontrol(hpanelInput,'Style','checkbox','String','Save Frame Images with drawn fire front line',...
    'FontSize',9.5,'Value',0,'Position',[35 95 290 23],'callback',{@checkSave_Callback});
htextResults  = uicontrol(hpanelInput,'Style','text','String','Results Directory:','FontSize',11,'Position',[35,60,130,23]);
heditResults    = uicontrol(hpanelInput,'Style','edit','Position',[162,60,160,25],'FontSize',10,'Enable','off');
hbuttonSelect  = uicontrol(hpanelInput,'Style','pushbutton','String','Select Folder','FontSize',10,...
    'Position',[330,59,95,28],'callback',{@buttonSelect_Callback});
hbuttonCalibrate  = uicontrol(hpanelInput,'Style','pushbutton','String','Calibrate and Detect Fire Front','FontSize',10,...
    'FontWeight','bold','Position',[100,13,250,35],'callback',{@buttonCalibrate_Callback},'Enable','off');

%results panel (right)
hpanelRes=uipanel(htabNew,'Units','pixels','Title','Results','FontSize',10,'Position',[450,0,350,595]);
htextCCI  = uicontrol(hpanelRes,'Style','text','String','Considered No. of Calibration Images:',...
    'FontSize',10,'Position',[25,535,235,20]);
heditCCI  = uicontrol(hpanelRes,'Style','edit','Position',[260,535,65,23],'FontSize',10,'FontWeight','bold','Enable','off');
htextCFI  = uicontrol(hpanelRes,'Style','text','String','Considered No. of Fire Front Frames:',...
    'FontSize',10,'Position',[25,505,235,20]);
heditCFI  = uicontrol(hpanelRes,'Style','edit','Position',[260,505,65,23],'FontSize',10,'FontWeight','bold','Enable','off');
htextPresent  = uicontrol(hpanelRes,'Style','text','String','Present Results',...
    'FontSize',11,'FontWeight','bold','Position',[50,450,120,23]);
hbuttonAROS  = uicontrol(hpanelRes,'Style','pushbutton','String','Calculate Average ROS','FontSize',10,...
    'FontWeight','bold','Position',[50,400,250,35],'callback',{@buttonAROS_Callback},'Enable','off');
hbuttonDROS  = uicontrol(hpanelRes,'Style','pushbutton','String','Calculate Dynamic ROS','FontSize',10,...
    'FontWeight','bold','Position',[50,350,250,35],'callback',{@buttonDROS_Callback},'Enable','off');
hbuttonDist  = uicontrol(hpanelRes,'Style','pushbutton','String','Measure Distances','FontSize',10,...
    'FontWeight','bold','Position',[50,300,250,35],'callback',{@buttonDist_Callback},'Enable','off');
hbuttonMap  = uicontrol(hpanelRes,'Style','pushbutton','String','Build the Fire Propagation Map','FontSize',10,...
    'FontWeight','bold','Position',[50,250,250,35],'callback',{@buttonMap_Callback},'Enable','off');
hbuttonIso  = uicontrol(hpanelRes,'Style','pushbutton','String','Build iso-surface From ROS''s','FontSize',10,...
    'FontWeight','bold','Position',[50,200,250,35],'callback',{@buttonIso_Callback},'Enable','off');
hbuttonCheck  = uicontrol(hpanelRes,'Style','pushbutton','String','Check Calibration Accuracy','FontSize',10,...
    'FontWeight','bold','Position',[50,150,250,35],'callback',{@buttonCheck_Callback},'Enable','off');
hbuttonReset  = uicontrol(hpanelRes,'Style','pushbutton','String','Reset','FontSize',10,...
    'FontWeight','bold','Position',[50,30,100,40],'callback',{@buttonReset_Callback});
hbuttonSaveE  = uicontrol(hpanelRes,'Style','pushbutton','String','Save Excel','FontSize',10,...
    'FontWeight','bold','Position',[200,30,100,40],'callback',{@buttonSaveE_Callback},'Enable','off');
% first tab (New Project)
% Inputs panel (left)
hpanelLoad=uipanel(htabLoad,'Units','pixels','Title','Load Project','FontSize',10,'Position',[0,0,450,595]);
htextLprojcet  = uicontrol(hpanelLoad,'Style','text','String','     Select Project:',...
    'FontSize',11,'FontWeight','bold','Position',[13,500,140,24]);
heditLprojcet = uicontrol(hpanelLoad,'Style','edit','Position',[155,500,180,25],'FontSize',10);
hbuttonLprojcet  = uicontrol(hpanelLoad,'Style','pushbutton','String','Add Projcet','FontSize',10,...
    'Position',[343,498,90,30],'callback',{@buttonLprojcet_Callback});
htextAresults  = uicontrol(hpanelLoad,'Style','text','String','Results Directory:',...
    'FontSize',11,'FontWeight','bold','Position',[13,450,140,24]);
heditAresults  = uicontrol(hpanelLoad,'Style','edit','Position',[155,450,180,25],'FontSize',10);
hbuttonAresults  = uicontrol(hpanelLoad,'Style','pushbutton','String','Select Folder','FontSize',10,...
    'Position',[343,448,90,30],'callback',{@buttonSelect2_Callback});
htextNewName  = uicontrol(hpanelLoad,'Style','text','String','New Version Name:',...
    'FontSize',11,'FontWeight','bold','Position',[40,380,150,24]);
heditNewName = uicontrol(hpanelLoad,'Style','edit','Position',[190,380,200,25],'FontSize',10,'callback',{@editNewName_Callback});
%results panel (right)
hpanelResult=uipanel(htabLoad,'Units','pixels','Title','Results','FontSize',10,'Position',[450,0,350,595]);
htextCFI2  = uicontrol(hpanelResult,'Style','text','String','Considered No. of Fire Front Frames:',...
    'FontSize',10,'Position',[25,510,235,20]);
heditCFI2  = uicontrol(hpanelResult,'Style','edit','Position',[260,510,65,23],'FontSize',10,'FontWeight','bold','Enable','off');
htextPresent  = uicontrol(hpanelResult,'Style','text','String','Present Results',...
    'FontSize',11,'FontWeight','bold','Position',[50,450,120,23]);
hbuttonAROS2  = uicontrol(hpanelResult,'Style','pushbutton','String','Calculate Average ROS','FontSize',10,...
    'FontWeight','bold','Position',[50,400,250,35],'callback',{@buttonAROS_Callback},'Enable','off');
hbuttonDROS2  = uicontrol(hpanelResult,'Style','pushbutton','String','Calculate Dynamic ROS','FontSize',10,...
    'FontWeight','bold','Position',[50,350,250,35],'callback',{@buttonDROS_Callback},'Enable','off');
hbuttonDist2  = uicontrol(hpanelResult,'Style','pushbutton','String','Measure Distances','FontSize',10,...
    'FontWeight','bold','Position',[50,300,250,35],'callback',{@buttonDist_Callback},'Enable','off');
hbuttonMap2  = uicontrol(hpanelResult,'Style','pushbutton','String','Build the Fire Propagation Map','FontSize',10,...
    'FontWeight','bold','Position',[50,250,250,35],'callback',{@buttonMap_Callback},'Enable','off');
hbuttonIso2 = uicontrol(hpanelResult,'Style','pushbutton','String','Build iso-surface From ROS''s','FontSize',10,...
    'FontWeight','bold','Position',[50,200,250,35],'callback',{@buttonIso_Callback},'Enable','off');
hbuttonCheck2  = uicontrol(hpanelResult,'Style','pushbutton','String','Check Clibration Accuracy','FontSize',10,...
    'FontWeight','bold','Position',[50,150,250,35],'callback',{@buttonCheck_Callback},'Enable','off');
hbuttonSaveE2  = uicontrol(hpanelResult,'Style','pushbutton','String','Save Excel','FontSize',10,...
    'FontWeight','bold','Position',[200,30,100,40],'callback',{@buttonSaveE_Callback},'Enable','off');

%the matach tab 
hpanelMatch=uipanel(htabMatch,'Units','pixels','Title','Match Calibration and Fire Images','FontSize',10,'Position',[0,0,800,595]);
htextIcrop  = uicontrol(hpanelMatch,'Style','text','String','Images to Be Cropped:',...
    'FontSize',11,'Position',[98,485,160,24]);
heditIcrop  = uicontrol(hpanelMatch,'Style','edit','Position',[255,485,180,25],'FontSize',10);
hbuttonIcrop  = uicontrol(hpanelMatch,'Style','pushbutton','String','Add Files','FontSize',10,...
    'Position',[445,485,85,25],'callback',{@buttonIcrop_Callback});
htextIref  = uicontrol(hpanelMatch,'Style','text','String','     Refrance Image:',...
    'FontSize',11,'Position',[100,438,160,24]);
heditIref  = uicontrol(hpanelMatch,'Style','edit','Position',[255,438,180,25],'FontSize',10);
hbuttonIref  = uicontrol(hpanelMatch,'Style','pushbutton','String','Add Files','FontSize',10,...
    'Position',[445,438,85,25],'callback',{@buttonIref_Callback});
htextIcorr  = uicontrol(hpanelMatch,'Style','text','String',' Matching Ref. Image:',...
    'FontSize',11,'Position',[100,385,160,24]);
heditIcorr  = uicontrol(hpanelMatch,'Style','edit','Position',[255,385,180,25],'FontSize',10);
hbuttonIcorr = uicontrol(hpanelMatch,'Style','pushbutton','String','Add Files','FontSize',10,...
    'Position',[445,385,85,25],'callback',{@buttonIcorr_Callback});
htextIname  = uicontrol(hpanelMatch,'Style','text','String','Cropped Images Name:',...
    'FontSize',11,'FontWeight','bold','Position',[110,330,200,25]);
heditIname  = uicontrol(hpanelMatch,'Style','edit','Position',[298,330,180,25],'FontSize',10,'FontWeight','bold','callback',{@editIname_Callback});
htextDir  = uicontrol(hpanelMatch,'Style','text','String',' Saving Directory:',...
    'FontSize',11,'Position',[100,280,160,24]);
heditDir  = uicontrol(hpanelMatch,'Style','edit','Position',[255,280,180,25],'FontSize',10);
hbuttonDir = uicontrol(hpanelMatch,'Style','pushbutton','String','Select Folder','FontSize',10,...
    'Position',[445,280,85,25],'callback',{@buttonDir_Callback});
hbuttonAdjust  = uicontrol(hpanelMatch,'Style','pushbutton','String','Adjust Scale and Size','FontSize',10,...
    'FontWeight','bold','Position',[170,200,250,40],'callback',{@buttonAdjust_Callback},'Enable','off');
hbuttonMatch  = uicontrol(hpanelMatch,'Style','pushbutton','String','Match Images and Save','FontSize',10,...
    'FontWeight','bold','Position',[170,140,250,40],'callback',{@buttonMatch_Callback},'Enable','off');

MainF.Name = 'Fire ROS Calculator';
movegui(MainF,'center')
MainF.MenuBar = 'none';
MainF.ToolBar = 'none';
MainF.NumberTitle='off';
MainF.Visible = 'on';

warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jframe=get(MainF,'javaframe');
jIcon=javax.swing.ImageIcon('icon ROS.gif');
jframe.setFigureIcon(jIcon);

%setting some values
shape=4;
TimeSelection=1;
resultrow=5;
results=cell(0);
loudstatuse=0;

    function MainF_CloseRequestFcn(src,event)
        global exitF answer_exit
        check_exit
        waitfor(exitF)
        if answer_exit==1
            %delete(MainF)
            exit
        end
    end
%% interactiv controls to get the inputs  (New project Tab)
    function buttonIcalib_Callback(src,event)
        [images, pathname] = uigetfile({'*.jpg;*.tif;*.png;*.gif','All Image Files';...
            '*.*','All Files' },'Select the Calibration Images','MultiSelect', 'on');
        filesim = fullfile(pathname , images);
        set(heditIcalib,'String',pathname);
    end
    function buttonIframes_Callback(src,event)
        [frames, framespathname] = uigetfile({'*.jpg;*.tif;*.png;*.gif','All Image Files';...
            '*.*','All Files' },'Select the Frames','MultiSelect', 'on');
        framefiles=fullfile(framespathname,frames);
        numframes = numel(frames);
        set(heditIframes,'String',framespathname);
    end
    function buttonIbed_Callback(src,event)
        [bwp, bwp_pathname] = uigetfile({'*.jpg;*.tif;*.png;*.gif','All Image Files';...
            '*.*','All Files' },'Select the Fuel Bed Image with Pattern');
        bwporig = imread(fullfile(bwp_pathname,bwp));
        set(heditIbed,'String',bwp_pathname);
    end
    function selectionTime(src,event)
        selection=event.NewValue.String;
        if strcmp(selection,'Constant Lap')
            TimeSelection=1;
            heditLaps.Enable='on';
            hbuttonLaps.Enable='off';
        elseif strcmp(selection,'Variable Lap')
            TimeSelection=2;
            hbuttonLaps.Enable='on';
            heditLaps.Enable='off';
        end
    end
    function buttonLaps_Callback(src,event)
        enter_time_lap
        results{4,1}='Variable time laps are: (in order) ';results{4,2:(size(localtime,2)+1)}=num2cell(localtime(1,:));
    end
    function editLaps_Callback(src,event)
            laps = str2double(get(heditLaps,'String'));
            localtime(1,(1:numframes-1))=laps;
            results{4,1}='Constant time lap is: ';results{4,2}=laps;
    end
    function popShape_Callback(src,event)
        shapeSelection=get(hpopShape,'Value');
        if shapeSelection==1
            shape=1;
            heditLength.Enable='on'; 
            heditAngle.Enable='off';
            set(heditAngle,'String',90)
            hbuttonDetect.Enable='on'; 
            hbuttonDraw.Enable='off';
        elseif shapeSelection==2
            shape=2;
            heditLength.Enable='on'; 
            heditAngle.Enable='on'; 
            hbuttonDetect.Enable='on'; 
            hbuttonDraw.Enable='off';
        elseif shapeSelection==3
            shape=3;
            heditLength.Enable='off'; 
            heditAngle.Enable='off'; 
            hbuttonDetect.Enable='off'; 
            hbuttonDraw.Enable='on';
        else
            shape=4;
            heditLength.Enable='off'; 
            heditAngle.Enable='off'; 
            hbuttonDetect.Enable='off'; 
            hbuttonDraw.Enable='off';
        end
    end
    function buttonDetect_Callback(src,event)
        [JPGcorners, JPGcorners_pathname] = uigetfile({'*.jpg;*.tif;*.png;*.gif;*.bmp','All Image Files';...
            '*.*','All Files' },'Select an image to detect the corners of the bed from it');
        hcornersF=figure('NumberTitle','off'); imshow(fullfile(JPGcorners_pathname,JPGcorners),'InitialMagnification', 'fit');
        title('Detect one edge (length) of the the bed');
        hframe = imline(gca);
        wait(hframe);
        posframe = getPosition(hframe);
        Xcorners(1:2,1)=posframe(1:2,1);
        Ycorners(1:2,1)=posframe(1:2,2);
        close(hcornersF)
    end
    function buttonDraw_Callback(src,event)
        draw_frame
    end
    function checkSave_Callback(src,event)
        set(MainF, 'pointer', 'watch')
        drawfront=get(hcheckSave,'value');
        set(MainF, 'pointer', 'arrow')
    end
    function buttonSelect_Callback(src,event)
        resultsfolder = uigetdir('C:\','Select a Folder To Save the Results On');
        set(heditResults,'String',resultsfolder);
        hbuttonCalibrate.Enable='on';
    end
    function buttonCalibrate_Callback(src,event)
        set(MainF, 'pointer', 'watch')
        drawnow;
        squareSize=str2double(get(heditSize,'String'));
        Lworld=str2double(get(heditLength,'String'))*10;
        AngleWorld=str2double(get(heditAngle,'String'));
        project_name=get(heditPname,'String');
        main_calibration
        hbuttonAROS.Enable='on'; hbuttonDROS.Enable='on'; hbuttonDist.Enable='on'; hbuttonMap.Enable='on';
        hbuttonIso.Enable='on'; hbuttonCheck.Enable='on'; hbuttonSaveE.Enable='on';
        set(heditCCI,'String',num2str(length(imagesUsed(imagesUsed==1))));
        set(heditCFI,'String',num2str(numframes));
        set(MainF, 'pointer', 'arrow')
    end

%% interactive controls for the results panel (New project Tab)
    function buttonAROS_Callback(src,event)
        average_ROS
    end
    function buttonDROS_Callback(src,event)
        dynamic_ROS
    end
    function buttonDist_Callback(src,event)
        measuring_dist
    end
    function buttonMap_Callback(src,event)
        build_prop_map
    end
    function buttonIso_Callback(src,event)
        build_isoROS
    end
    function buttonCheck_Callback(src,event)
        check_accuracy
    end
    function buttonReset_Callback(src,event)
        global answer_reset resetF
        check_reset
        waitfor(resetF)
        if answer_reset==1
            set(heditPname,'String',[]); set(heditIcalib,'String',[]); set(heditIframes,'String',[]); set(heditIbed,'String',[]);
            set(heditAngle,'String',[]); set(heditLength,'String',[]); set(heditSize,'String',[]); set(heditResults,'String',[]);
            set(heditAngle,'String',[]); set(heditLaps,'String',[]); set(heditCCI,'String',[]); set(heditCFI,'String',[]);
            hcheckSave.Value=0; hpopShape.Value=4;
            heditLength.Enable='off'; heditAngle.Enable='off'; hbuttonDetect.Enable='off';  hbuttonDraw.Enable='off';
            heditLaps.Enable='on'; hbuttonLaps.Enable='off'; hbuttonCalibrate.Enable='off';
            hbuttonAROS.Enable='off'; hbuttonDROS.Enable='off'; hbuttonDist.Enable='off'; hbuttonMap.Enable='off';
            hbuttonIso.Enable='off'; hbuttonCheck.Enable='off'; hbuttonSaveE.Enable='off';
            shape=4;TimeSelection=1;resultrow=5;results=cell(0);
            Xcorners=[]; Ycorners=[]; pathname=[]; filesim=[]; numframes=[]; framefiles=[]; bwporig=[]; TimeSelection=[]; localtime=[];
            resultsfolder=[]; drawfront=[]; project_name=[]; cornersnum=[]; images=[]; XcornersWorld=[]; YcornersWorld=[]; ffpoints=[];
            fflineeq=[]; time=[]; R=[]; t=[]; cameraParams=[]; Xworld=[]; Yworld=[]; X=[]; Y=[];
        end
    end
    function buttonSaveE_Callback(src,event)
        set(MainF, 'pointer', 'watch')
        xlswrite([resultsfolder,'\',project_name,' Results'],results);
        set(MainF, 'pointer', 'arrow')
    end

%% interactive controls for the load panel (load project Tab)
    function buttonLprojcet_Callback(src,event)  
        [work, workpathname] = uigetfile('*.mat','Choose a Project');
        loudstatuse=1;
        set(heditLprojcet,'String',work);
        load([workpathname,work],'numframes')
        results=cell(0);
        results{1,1}='Project Name: '; results{1,2}=project_name;
        resultrow=2;
    end
    function buttonSelect2_Callback(src,event)
        resultsfolder = uigetdir('C:\','Select a Folder To Save the Results On');
        set(heditAresults,'String',resultsfolder);
    end
    function editNewName_Callback(src,event)
        
        project_name=get(heditNewName,'String');
        hbuttonAROS2.Enable='on'; hbuttonDROS2.Enable='on'; hbuttonDist2.Enable='on'; hbuttonMap2.Enable='on';
        hbuttonIso2.Enable='on'; hbuttonCheck2.Enable='on'; hbuttonSaveE2.Enable='on';
        set(heditCFI2,'String',num2str(numframes));
        results{1,1}='Project Name: '; results{1,2}=project_name;
        resultrow=2;
    end

%% interactive controls for the Matching Images Tab
    function buttonIcrop_Callback(src,event)
        global Mfilesim Mimages
        [Mimages, Mpathname] = uigetfile({'*.jpg;*.tif;*.png;*.gif','All Image Files';...
            '*.*','All Files' },'Select Images to be cropped','MultiSelect', 'on');
        set(heditIcrop,'String',Mpathname);
        Mfilesim = fullfile(Mpathname , Mimages);  
    end
    function buttonIref_Callback(src,event)
        global jpgim
        [jpg, jpg_pathname] = uigetfile({'*.jpg;*.tif;*.png;*.gif','All Image Files';...
            '*.*','All Files' },'Select an image from the images need to br crop');
        jpgim = imread(fullfile(jpg_pathname,jpg));
        set(heditIref,'String',jpg_pathname);
        hbuttonAdjust.Enable='on';
    end
    function buttonIcorr_Callback(src,event)
        global irim
        [ir, ir_pathname] = uigetfile({'*.jpg;*.tif;*.png;*.gif','All Image Files';...
            '*.*','All Files' },'Select and Image to Match the images to it (correct one)');
        irim = imread(fullfile(ir_pathname,ir));
        set(heditIcorr,'String',ir_pathname);
    end
    function editIname_Callback(src,event)
        global image_name
        image_name=get(heditIname,'String');
    end
    function buttonDir_Callback(src,event)
        global Iresultsfolder
         Iresultsfolder = uigetdir('C:\','Select a Folder To Save the Images On');
         set(heditDir,'String',Iresultsfolder);
    end
    function buttonAdjust_Callback(src,event)
        global  irim jpgim rect scale
        %calulateing the scale for resizing
        figure('NumberTitle','off','Name','Adjusting Scale'); imshow(irim,'InitialMagnification', 'fit');
        title('Detect two clear points');
        [X0,Y0] = ginput(2);
        close
        Dir = ((X0(1,1) - X0(2,1)) ^ 2 + (Y0(1,1) - Y0(2,1)) ^ 2) ^ 0.5;
        figure('NumberTitle','off','Name','Adjusting Scale'); imshow(jpgim,'InitialMagnification', 'fit');
        title('Detect the same two points');
        pause(8)
        [Xjpg,Yjpg] = ginput(2);
        close
        Djpg = ((Xjpg(1,1) - Xjpg(2,1)) ^ 2 + (Yjpg(1,1) - Yjpg(2,1)) ^ 2) ^ 0.5;
        scale=Dir/Djpg;
        jpgim=imresize(jpgim,scale);
        %determining the cropping size
        figure('NumberTitle','off','Name','Adjusting Size'); imshow(irim,'InitialMagnification', 'fit');
        title('Detect One Clear points');
        [Xir,Yir] = ginput(1);
        close
        figure('NumberTitle','off','Name','Adjusting Size'); imshow(jpgim,'InitialMagnification', 'fit');
        title('Detect The Same Point');
        [Xcorjpg,Ycorjpg] = ginput(1);
        close
        Xmin=Xcorjpg-Xir-1;
        Ymin=Ycorjpg-Yir-1;
        rect=[Xmin, Ymin, size(irim,2)-1, size(irim,1)-1];
        hbuttonMatch.Enable='on';
    end
    function buttonMatch_Callback(src,event)
        set(MainF, 'pointer', 'watch')
        global image_name Iresultsfolder Mimages Mfilesim rect scale MnumImages
        MnumImages = numel(Mimages);
        files=cell(1,MnumImages);
        for i=1:MnumImages
            jpg=imread(Mfilesim{i});
            %resize the image
            jpgsc=imresize(jpg,scale);
            pattern=imcrop(jpgsc,rect);
            baseFileName = sprintf([image_name,' I %d.png'], i);
            files{i} = fullfile(Iresultsfolder, baseFileName);
            imwrite(pattern, files{i});
        end
        set(MainF, 'pointer', 'arrow')
    end
end