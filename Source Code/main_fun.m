function main_fun
global Xcorners Ycorners pathname calibrationFile numframes framefiles bwporig TimeSelection shape localtime results resultrow resultsfolder frames appPath checkimage videoObject
global drawfront project_name cornersnum MainF images squareSize imagesUsed workpathname work loudstatuse AngleWorld Lworld CLworld cameraParams calibList hwait man_mod interval 
%% read files 
if isdeployed
    appPath = 'C:\Program Files\ADAI-CEIF\application';
else
    appPath = pwd;
end
calibPath=fullfile(appPath,'calibrations');
if exist(calibPath, 'dir')==0
    mkdir(calibPath)
end
list = what(calibPath); calibList=list.mat; calibList{end+1,1}=('Load Calibration'); calibList=calibList';

%% building the GUI
MainF = figure('Visible','off','Position',[680,93,800,580],'CloseRequestFcn',@MainF_CloseRequestFcn);
htgroup = uitabgroup('Parent', MainF );
htabNew = uitab('Parent', htgroup,'Title', '   New Session   ');
htabLoad = uitab('Parent', htgroup, 'Title', '   Load Session   ');
htabMatch = uitab('Parent', htgroup, 'Title', '   Match Images   ');
htabExtract = uitab('Parent', htgroup, 'Title', '   Extract Frames   ');
htabEvaluate = uitab('Parent', htgroup, 'Title', '  Camera Calibration  ');
% first tab (New Project)
% Inputs panel (left)
hpanelInput=uipanel(htabNew,'Units','pixels','Title','Inputs','FontSize',10,'Position',[0,0,450,595]);
htextPname  = uicontrol(hpanelInput,'Style','text','String','Session Name:',...
    'FontSize',11,'FontWeight','bold','Position',[80,535,115,25]);
heditPname  = uicontrol(hpanelInput,'Style','edit','Position',[198,535,180,25],'FontSize',10,'FontWeight','bold');
htextIcalib  = uicontrol(hpanelInput,'Style','text','String','Camera Parameters:',...
    'FontSize',11,'Position',[13,485,140,24]);
hpopCalib  = uicontrol(hpanelInput,'Style','pop','Units','pixels','String',calibList,...
    'value',size(calibList,2),'FontSize',10,'Position',[155,485,150,25],'callback',{@popCalib_Callback});
hbuttonIcalib  = uicontrol(hpanelInput,'Style','pushbutton','String','Load Camera P.','FontSize',10,...
    'Position',[315,485,115,25],'callback',{@buttonIcalib_Callback});
htextIframes  = uicontrol(hpanelInput,'Style','text','String','  Fire Front Images:',...
    'FontSize',11,'Position',[13,450,140,24]);
heditIframes  = uicontrol(hpanelInput,'Style','edit','Position',[155,450,180,25],'FontSize',10);
hbuttonIframes  = uicontrol(hpanelInput,'Style','pushbutton','String','Add Frames','FontSize',10,...
    'Position',[345,450,85,25],'callback',{@buttonIframes_Callback});
htextIbed  = uicontrol(hpanelInput,'Style','text','String',' Surface Ref. Image:',...
    'FontSize',11,'Position',[13,415,140,24]);
heditIbed  = uicontrol(hpanelInput,'Style','edit','Position',[155,415,180,25],'FontSize',10);
hbuttonIbed  = uicontrol(hpanelInput,'Style','pushbutton','String','Add Image','FontSize',10,...
    'Position',[345,415,85,25],'callback',{@buttonIbed_Callback});
htextSize  = uicontrol(hpanelInput,'Style','text','String','Size of the Checkerboard Square:',...
    'FontSize',11,'Position',[45,370,240,24]);
heditSize  = uicontrol(hpanelInput,'Style','edit','Position',[277,370,70,25],'FontSize',10);
htextMm  = uicontrol(hpanelInput,'Style','text','String','mm','FontSize',11,'Position',[349,370,28,24]);
%time Group
hbgTime     = uibuttongroup(hpanelInput,'Units','pixels','Title','Time Laps','FontSize',10,'Position',[100 275 260 90],'SelectionChangedFcn',@selectionTime);
hradioConstant    = uicontrol(hbgTime  ,'Style','radiobutton','String','Constant Lap','Position',[20 44 100 23],'FontSize',10);
hradioVariable   = uicontrol(hbgTime  ,'Style','radiobutton','String','Variable Lap','Position',[20 16 100 23],'FontSize',10);
heditLaps    = uicontrol(hbgTime,'Style','edit','Position',[140,44,95,23],'FontSize',10,'callback',{@editLaps_Callback});
hbuttonLaps  = uicontrol(hbgTime,'Style','pushbutton','String','Add Laps','FontSize',10,...
    'Position',[140,14,95,23],'callback',{@buttonLaps_Callback},'Enable','off');
htextS  = uicontrol(hbgTime,'Style','text','String','s','FontSize',11,'Position',[237,44,10,23]);
%Fuel bed group
hbgBed     = uibuttongroup(hpanelInput,'Units','pixels','Title','Fuel Bed Geometry','FontSize',10,...
    'Position',[30 130 390 140],'SelectionChangedFcn',@selectionTime);
htextShape  = uicontrol(hbgBed,'Style','text','String','Fuel Bed Shape','FontSize',11,'Position',[45,92,107,24]);
hpopShape  = uicontrol(hbgBed,'Style','pop','Units','pixels','String',{'Rectangular';'Triangle';'Draw Shape Manually'},...
    'value',3,'FontSize',10,'Position',[155,92,170,24],'callback',{@popShape_Callback});
htextLength  = uicontrol(hbgBed,'Style','text','String','Joint Edge Length','HorizontalAlignment','right','FontSize',9,'Position',[5,33,130,21]);
heditLength    = uicontrol(hbgBed,'Style','edit','Position',[140,33,50,21],'FontSize',9,'Enable','off');
htextCm1  = uicontrol(hbgBed,'Style','text','String','cm','FontSize',10,'Position',[193,33,20,21]); 
htextLength2  = uicontrol(hbgBed,'Style','text','String','Detected Edge Length','FontSize',9,'HorizontalAlignment','right','Position',[5,60,130,21]);
heditLength2    = uicontrol(hbgBed,'Style','edit','Position',[140,60,50,21],'FontSize',9,'Enable','off');
htextCm1  = uicontrol(hbgBed,'Style','text','String','cm','FontSize',10,'Position',[193,60,20,21]);
hbuttonDetect  = uicontrol(hbgBed,'Style','pushbutton','String','Detect Bed Location','FontSize',10,...
    'Position',[225,50,150,23],'callback',{@buttonDetect_Callback},'Enable','off');
htextAngle  = uicontrol(hbgBed,'Style','text','String','Angle','FontSize',9,'HorizontalAlignment','right','Position',[5,7,130,21]);
heditAngle    = uicontrol(hbgBed,'Style','edit','Position',[140,7,50,21],'FontSize',9,'Enable','off');
htextCm2  = uicontrol(hbgBed,'Style','text','String','°','FontSize',10,'Position',[193,7,20,21]);
hbuttonDraw  = uicontrol(hbgBed,'Style','pushbutton','String','Draw Shape Manually','FontSize',10,...
    'Position',[225,15,150,23],'callback',{@buttonDraw_Callback});
%%%%%
hcheckSave = uicontrol(hpanelInput,'Style','checkbox','String','Save Frames with fire front lines',...
    'FontSize',9.5,'Value',0,'Position',[25 60 320 23],'callback',{@checkSave_Callback});
htextSens = uicontrol(hpanelInput,'Style','text','String','Detection Senstivity:','FontSize',9.5,'Position',[240 60 150 21]);
heditSens = uicontrol(hpanelInput,'Style','edit','String','0.5','FontSize',9.5,'Position',[375 60 50 21]);
htextResults  = uicontrol(hpanelInput,'Style','text','String','Results Directory:','FontSize',11,'Position',[35,95,130,23]);
heditResults    = uicontrol(hpanelInput,'Style','edit','Position',[162,95,160,25],'FontSize',10,'Enable','off');
hbuttonSelect  = uicontrol(hpanelInput,'Style','pushbutton','String','Select Folder','FontSize',10,...
    'Position',[330,94,95,28],'callback',{@buttonSelect_Callback});
hbuttonCalibrateM  = uicontrol(hpanelInput,'Style','pushbutton','String','Detect Fire Front Manually','FontSize',10,...
    'FontWeight','bold','Position',[7,13,215,35],'callback',{@buttonCalibrateM_Callback},'Enable','off');
hbuttonCalibrateA  = uicontrol(hpanelInput,'Style','pushbutton','String','Detect Fire Front Automatically ','FontSize',10,...
    'FontWeight','bold','Position',[227,13,215,35],'callback',{@buttonCalibrateA_Callback},'Enable','off');

%results panel (right)
hpanelRes=uipanel(htabNew,'Units','pixels','Title','Results','FontSize',10,'Position',[450,0,350,595]);
htextCFI  = uicontrol(hpanelRes,'Style','text','String','Total No. of Frames:',...
    'FontSize',10,'Position',[30,535,130,20]);
heditCFI  = uicontrol(hpanelRes,'Style','edit','Position',[170,535,150,23],'FontSize',10,'FontWeight','bold','Enable','off');
hframeEva  = uicontrol(hpanelRes,'Style','pushbutton','String','Evaluate Fire Fronts Detection','FontSize',10,...
    'FontWeight','bold','Position',[40,495,270,30],'callback',{@buttonFrameEva_Callback},'Enable','off');
htextPresent  = uicontrol(hpanelRes,'Style','text','String','Results:',...
    'FontSize',11,'FontWeight','bold','Position',[50,450,120,23]);
hbuttonAROS  = uicontrol(hpanelRes,'Style','pushbutton','String','Calculate Average ROS','FontSize',10,...
    'FontWeight','bold','Position',[50,400,250,35],'callback',{@buttonAROS_Callback},'Enable','off');
hbuttonDROS  = uicontrol(hpanelRes,'Style','pushbutton','String','Calculate Dynamic ROS','FontSize',10,...
    'FontWeight','bold','Position',[50,350,250,35],'callback',{@buttonDROS_Callback},'Enable','off');
hbuttonDist  = uicontrol(hpanelRes,'Style','pushbutton','String','Measure Distances','FontSize',10,...
    'FontWeight','bold','Position',[50,300,250,35],'callback',{@buttonDist_Callback},'Enable','off');
hbuttonMap  = uicontrol(hpanelRes,'Style','pushbutton','String','Build the Fire Propagation Map','FontSize',10,...
    'FontWeight','bold','Position',[50,250,250,35],'callback',{@buttonMap_Callback},'Enable','off');
hbuttonIso  = uicontrol(hpanelRes,'Style','pushbutton','String','Present ROS''s as iso-surface','FontSize',10,...
    'FontWeight','bold','Position',[50,200,250,35],'callback',{@buttonIso_Callback},'Enable','off');
hbuttonCheck  = uicontrol(hpanelRes,'Style','pushbutton','String','Check Accuracy','FontSize',10,...
    'FontWeight','bold','Position',[50,150,250,35],'callback',{@buttonCheck_Callback},'Enable','off');
hbuttonReset  = uicontrol(hpanelRes,'Style','pushbutton','String','Reset','FontSize',10,...
    'FontWeight','bold','Position',[50,30,100,40],'callback',{@buttonReset_Callback});
hbuttonSaveE  = uicontrol(hpanelRes,'Style','pushbutton','String','Save Excel','FontSize',10,...
    'FontWeight','bold','Position',[200,30,100,40],'callback',{@buttonSaveE_Callback},'Enable','off');
htextSave  = uicontrol(hpanelRes,'Style','text','String','Saved!',...
    'FontSize',9,'FontWeight','bold','Position',[195,7,120,20],'Visible','off');
% Second tab (Load Project)
% Inputs panel (left)
hpanelLoad=uipanel(htabLoad,'Units','pixels','Title','Load Project','FontSize',10,'Position',[0,0,450,595]);
htextLprojcet  = uicontrol(hpanelLoad,'Style','text','String','     Select Session:',...
    'FontSize',11,'FontWeight','bold','Position',[13,500,140,24]);
heditLprojcet = uicontrol(hpanelLoad,'Style','edit','Position',[155,500,180,25],'FontSize',10);
hbuttonLprojcet  = uicontrol(hpanelLoad,'Style','pushbutton','String','Load ','FontSize',10,...
    'Position',[343,498,90,30],'callback',{@buttonLprojcet_Callback});
htextAresults  = uicontrol(hpanelLoad,'Style','text','String','Results Directory:',...
    'FontSize',11,'FontWeight','bold','Position',[13,450,140,24]);
heditAresults  = uicontrol(hpanelLoad,'Style','edit','Position',[155,450,180,25],'FontSize',10);
hbuttonAresults  = uicontrol(hpanelLoad,'Style','pushbutton','String','Select Folder','FontSize',10,...
    'Position',[343,448,90,30],'callback',{@buttonSelect2_Callback});
htextNewName  = uicontrol(hpanelLoad,'Style','text','String','New Session Name:',...
    'FontSize',11,'FontWeight','bold','Position',[40,380,150,24]);
heditNewName = uicontrol(hpanelLoad,'Style','edit','Position',[190,380,200,25],'FontSize',10,'callback',{@editNewName_Callback});
%results panel (right)
hpanelResult=uipanel(htabLoad,'Units','pixels','Title','Results','FontSize',10,'Position',[450,0,350,595]);
htextCFI2  = uicontrol(hpanelResult,'Style','text','String','Total No. of Frames:',...
    'FontSize',10,'Position',[25,510,170,20]);
heditCFI2  = uicontrol(hpanelResult,'Style','edit','Position',[175,510,100,23],'FontSize',10,'FontWeight','bold','Enable','off');
htextPresent  = uicontrol(hpanelResult,'Style','text','String','Results:',...
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
hpanelMatch =uipanel(htabMatch,'Units','pixels','Title','Match calibration and fire images','FontSize',10,'Position',[0,0,800,595]);
hpopModeMat  = uicontrol(htabMatch,'Style','pop','Units','pixels','String',{'New Matching Setting';'Load Matching Setting'},...
    'value',1,'FontSize',11,'Position',[320,500,200,30],'callback',{@popModeMat_Callback});
uicontrol(hpanelMatch,'Style','text','String','Mode:','FontSize',12,'FontWeight','bold','Position',[255,502,50,24]);
htextIcrop  = uicontrol(hpanelMatch,'Style','text','String','Images to Be Matched:',...
    'FontSize',11,'Position',[170,435,160,24]);
heditIcrop  = uicontrol(hpanelMatch,'Style','edit','Position',[335,435,180,25],'FontSize',10);
hbuttonIcrop  = uicontrol(hpanelMatch,'Style','pushbutton','String','Add Files','FontSize',10,...
    'Position',[525,435,85,25],'callback',{@buttonIcrop_Callback});
htextIref  = uicontrol(hpanelMatch,'Style','text','String','     Sample Image:',...
    'FontSize',11,'Position',[180,388,160,24]);
heditIref  = uicontrol(hpanelMatch,'Style','edit','Position',[335,388,180,25],'FontSize',10);
hbuttonIref  = uicontrol(hpanelMatch,'Style','pushbutton','String','Add Files','FontSize',10,...
    'Position',[525,388,85,25],'callback',{@buttonIref_Callback});
htextIcorr  = uicontrol(hpanelMatch,'Style','text','String',' Reference Image:',...
    'FontSize',11,'Position',[180,340,160,24]);
heditIcorr  = uicontrol(hpanelMatch,'Style','edit','Position',[338,340,180,25],'FontSize',10);
hbuttonIcorr = uicontrol(hpanelMatch,'Style','pushbutton','String','Add Files','FontSize',10,...
    'Position',[525,340,85,25],'callback',{@buttonIcorr_Callback});
htextIname  = uicontrol(hpanelMatch,'Style','text','String','Output Images Name:',...
    'FontSize',11,'FontWeight','bold','Position',[190,280,200,25]);
heditIname  = uicontrol(hpanelMatch,'Style','edit','Position',[378,280,180,25],'FontSize',10,'FontWeight','bold','callback',{@editIname_Callback});
htextDir  = uicontrol(hpanelMatch,'Style','text','String',' Saving Directory:',...
    'FontSize',11,'Position',[180,230,160,24]);
heditDir  = uicontrol(hpanelMatch,'Style','edit','Position',[335,230,180,25],'FontSize',10);
hbuttonDir = uicontrol(hpanelMatch,'Style','pushbutton','String','Select Folder','FontSize',10,...
    'Position',[525,230,85,25],'callback',{@buttonDir_Callback});
hbuttonAdjust  = uicontrol(hpanelMatch,'Style','pushbutton','String','Adjust Scale and Frame','FontSize',10,...
    'FontWeight','bold','Position',[230,150,250,40],'callback',{@buttonAdjust_Callback},'Enable','off');
hbuttonMatch  = uicontrol(hpanelMatch,'Style','pushbutton','String','Match Images and Save','FontSize',10,...
    'FontWeight','bold','Position',[230,90,250,40],'callback',{@buttonMatch_Callback},'Enable','off');
hbuttonSaveSet = uicontrol(hpanelMatch,'Style','pushbutton','String','Save Setting','FontSize',10,...
    'FontWeight','bold','Position',[510,100,100,80],'callback',{@buttonSaveSet_Callback},'Enable','off');

%the Extract tab 
hpanelExtract=uipanel(htabExtract,'Units','pixels','Title','Extract frames from video','FontSize',10,'Position',[0,0,800,595]);
htextVideo  = uicontrol(hpanelExtract,'Style','text','String','             Video:',...
    'FontSize',11,'Position',[98,485,160,24]);
heditVideo  = uicontrol(hpanelExtract,'Style','edit','Position',[255,485,250,25],'FontSize',10);
hbuttonVideo  = uicontrol(hpanelExtract,'Style','pushbutton','String','Select Video','FontSize',10,...
    'Position',[515,485,100,25],'callback',{@buttonVideo_Callback});
htextRes  = uicontrol(hpanelExtract,'Style','text','String','  Results Folder:',...
    'FontSize',11,'Position',[100,438,160,24]);
heditRes  = uicontrol(hpanelExtract,'Style','edit','Position',[255,438,250,25],'FontSize',10);
hbuttonRes  = uicontrol(hpanelExtract,'Style','pushbutton','String','Select Folder','FontSize',10,...
    'Position',[515,438,100,25],'callback',{@buttonRes_Callback});
htextStime  = uicontrol(hpanelExtract,'Style','text','String','Start Time:',...
    'FontSize',11,'FontWeight','bold','Position',[150,350,100,25]);
heditStime1  = uicontrol(hpanelExtract,'Style','edit','String','0','Position',[248,350,50,25],'FontSize',10,'FontWeight','bold','callback',{@editStime1_Callback});
uicontrol(hpanelExtract,'Style','text','String',':',...
   'FontSize',12,'FontWeight','bold','Position',[300,350,10,25]);
heditStime2  = uicontrol(hpanelExtract,'Style','edit','String','0','Position',[310,350,50,25],'FontSize',10,'FontWeight','bold','callback',{@editStime2_Callback});
htextEtime  = uicontrol(hpanelExtract,'Style','text','String','  End Time:',...
    'FontSize',11,'FontWeight','bold','Position',[150,320,100,25]); 
heditEtime1  = uicontrol(hpanelExtract,'Style','edit','String','0','Position',[248,320,50,25],'FontSize',10,'FontWeight','bold','callback',{@editEtime1_Callback});
uicontrol(hpanelExtract,'Style','text','String',':',...
   'FontSize',12,'FontWeight','bold','Position',[300,320,10,25]);
heditEtime2  = uicontrol(hpanelExtract,'Style','edit','String','0','Position',[310,320,50,25],'FontSize',10,'FontWeight','bold','callback',{@editEtime2_Callback});
htextItime  = uicontrol(hpanelExtract,'Style','text','String','   Interval:',...
    'FontSize',11,'FontWeight','bold','Position',[150,290,100,25]); 
heditItime  = uicontrol(hpanelExtract,'Style','edit','String','0','Position',[248,290,50,25],'FontSize',10,'FontWeight','bold','callback',{@editItime_Callback});
uicontrol(hpanelExtract,'Style','text','String','s','FontSize',12,'Position',[300,290,10,25]);
htextNframes  = uicontrol(hpanelExtract,'Style','text','String','Number of frames:','FontSize',11,'Position',[100,240,150,25]); 
heditNframes  = uicontrol(hpanelExtract,'Style','edit','Position',[248,242,80,25],'FontSize',10,'FontWeight','bold','Enable','off');
hbgDim     = uibuttongroup(hpanelExtract,'Units','pixels','Title','Output Resolution','FontSize',10,...
    'Position',[400 250 200 120],'SelectionChangedFcn',@selectionDim);
hradioDim1   = uicontrol(hbgDim  ,'Style','radiobutton','String','Equal to the input video','Position',[10 70 180 23],'FontSize',10);
hradioDim2   = uicontrol(hbgDim  ,'Style','radiobutton','String','Customized','Position',[10 50 100 23],'FontSize',10);
heditDRow  = uicontrol(hbgDim,'Style','edit','Position',[10,15,70,25],'FontSize',10,'FontWeight','bold','Enable','off','callback',{@editDRow_Callback});
heditDCol  = uicontrol(hbgDim,'Style','edit','Position',[110,15,70,25],'FontSize',10,'FontWeight','bold','Enable','off','callback',{@editDCol_Callback});
uicontrol(hbgDim,'Style','text','Position',[80,15,30,23],'FontSize',10,'FontWeight','bold','String','X');
hbuttonExt  = uicontrol(hpanelExtract,'Style','pushbutton','String','Extract','FontSize',11,'FontWeight','bold',...
    'Position',[290,150,200,50],'callback',{@buttonExt_Callback});

%the calibration tab 
hpanelEvaluate=uipanel(htabEvaluate,'Units','pixels','Title','Creat or evaluate a camera calibration','FontSize',10,'Position',[0,0,800,595]);
htextAdd  = uicontrol(hpanelEvaluate,'Style','text','String','Calibration Images:',...
    'FontSize',11,'Position',[18,530,160,24]);
heditAdd  = uicontrol(hpanelEvaluate,'Style','edit','Position',[175,530,160,25],'FontSize',10);
hbuttonAdd  = uicontrol(hpanelEvaluate,'Style','pushbutton','String','Add Images','FontSize',10,...
    'Position',[357,530,100,27],'callback',{@buttonAdd_Callback});
htextSizeE  = uicontrol(hpanelEvaluate,'Style','text','String','Size of the Checkerboard Square:',...
    'FontSize',11,'Position',[60,480,240,24]);
heditSizeE  = uicontrol(hpanelEvaluate,'Style','edit','Position',[292,480,70,25],'FontSize',10);
uicontrol(hpanelEvaluate,'Style','text','String','mm','FontSize',11,'Position',[364,480,28,24]);
hbuttonDet  = uicontrol(hpanelEvaluate,'Style','pushbutton','String','Detect Checkerboard','FontSize',11,...
    'Position',[20,412,150,50],'Enable','off','callback',{@buttonDet_Callback});
hbuttonCalib  = uicontrol(hpanelEvaluate,'Style','pushbutton','String','Calibrate','FontSize',10,...
    'Position',[180,440,120,25],'Enable','off','callback',{@buttonCalib_Callback});
hbuttonLoadCalib  = uicontrol(hpanelEvaluate,'Style','pushbutton','String','Load Camera P.','FontSize',10,...
    'Position',[180,410,120,25],'Enable','off','callback',{@LoadCalib_Callback});
hbuttonSaveCalib  = uicontrol(hpanelEvaluate,'Style','pushbutton','String','Save Camera P.','FontSize',11,...
    'Position',[310,412,150,50],'Enable','off','callback',{@buttonSaveCalib_Callback});
htextAddI  = uicontrol(hpanelEvaluate,'Style','text','String','Added Images:',...
    'FontSize',11,'Position',[45,365,100,24]);
heditAddI  = uicontrol(hpanelEvaluate,'Style','edit','Position',[145,365,50,25],'FontSize',10,'Enable','off');
htextRejI  = uicontrol(hpanelEvaluate,'Style','text','String','Rejected Images:',...
    'FontSize',11,'Position',[260,365,120,24]);
heditRejI  = uicontrol(hpanelEvaluate,'Style','edit','Position',[380,365,50,25],'FontSize',10,'Enable','off');
uicontrol(hpanelEvaluate,'Style','text','String','Show Image:','FontSize',11,'Position',[20,322,100,24]);
hpopImage  = uicontrol(hpanelEvaluate,'Style','pop','Units','pixels','value',1,'String',{'Not Specified'},'FontSize',10,'Position',[120,322,150,24],'callback',{@popImage_Callback});
hbuttonCheckAcc  = uicontrol(hpanelEvaluate,'Style','pushbutton','String','Check Accuracy','FontSize',11,...
    'Position',[300,318,150,30],'Enable','off','callback',{@buttonCheckAcc_Callback});
haxisEval = axes(hpanelEvaluate,'box','off','xtick',[],'ytick',[],'ztick',[],'xcolor',[1 1 1],'ycolor',[1 1 1],'Units','pixels',...
    'Position',[20,10,450,300],'color','white');
haxisErr = axes(hpanelEvaluate,'Units','pixels','Position',[510,350,250,200],'color','white');
haxisExt = axes(hpanelEvaluate,'Units','pixels','Position',[510,80,250,200],'color','white');


MainF.Name = 'Fire ROS Calculator';
movegui(MainF,'center')
MainF.MenuBar = 'none';
MainF.ToolBar = 'none';
MainF.NumberTitle='off';
MainF.Visible = 'on';

warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jframe=get(MainF,'javaframe');
jIcon=javax.swing.ImageIcon(fullfile(appPath,'icon ROS.gif'));
jframe.setFigureIcon(jIcon);

%setting some values
shape=3; interval=0;
TimeSelection=1;
resultrow=5;
results=cell(0);
loudstatuse=0;

    function MainF_CloseRequestFcn(src,event)
        check_exit
    end
%% interactiv controls to get the inputs  (New project Tab)
    function popCalib_Callback(src,event)
        CalibSelection=get(hpopCalib,'Value');
        if CalibSelection==size(calibList,2)
            hbuttonIcalib.Enable='on';
        else
            hbuttonIcalib.Enable='off';
            calibrationFile = fullfile(calibPath ,calibList{1,CalibSelection});
        end
    end
    function buttonIcalib_Callback(src,event)
        [calibrationName, pathname] = uigetfile({'*.mat','MAT file';'*.*','All Files' },'Select a Saved Calibration ');
        calibrationFile = fullfile(pathname , calibrationName);
    end
    function buttonIframes_Callback(src,event)
        [frames, framespathname] = uigetfile({'*.jpg;*.tif;*.png;*.gif','All Image Files';...
            '*.*','All Files' },'Select the Frames','MultiSelect', 'on');
        framefiles=fullfile(framespathname,frames);
        numframes = numel(frames);
        set(heditIframes,'String',framespathname);
        laps = str2double(get(heditLaps,'String'));
        localtime(1,(1:numframes-1))=laps;
    end
    function buttonIbed_Callback(src,event)
        [bwp, bwp_pathname] = uigetfile({'*.jpg;*.tif;*.png;*.gif','All Image Files';...
            '*.*','All Files' },'Select the Fuel Bed Image with Pattern');
        bwporig = imread(fullfile(bwp_pathname,bwp));
        set(heditIbed,'String',bwp);
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
            heditLength.Enable='on'; heditLength2.Enable='on';  
            heditAngle.Enable='off';
            set(heditAngle,'String',90)
            hbuttonDetect.Enable='on'; 
            hbuttonDraw.Enable='off';
        elseif shapeSelection==2
            shape=2;
            heditLength.Enable='on'; heditLength2.Enable='on';  
            heditAngle.Enable='on'; 
            hbuttonDetect.Enable='on'; 
            hbuttonDraw.Enable='off';
        else 
            shape=3;
            heditLength.Enable='off'; heditLength2.Enable='off'; 
            heditAngle.Enable='off'; 
            hbuttonDetect.Enable='off'; 
            hbuttonDraw.Enable='on';
        end
    end
    function buttonDetect_Callback(src,event)
        [JPGcorners, JPGcorners_pathname] = uigetfile({'*.jpg;*.tif;*.png;*.gif;*.bmp','All Image Files';...
            '*.*','All Files' },'Select an image to detect the corners of the bed from it');
        checkimage=fullfile(JPGcorners_pathname,JPGcorners);
        hcornersF=figure('NumberTitle','off'); imshow(checkimage,'InitialMagnification', 'fit');
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
        hbuttonCalibrateM.Enable='on';
        hbuttonCalibrateA.Enable='on';
    end
    function buttonCalibrateM_Callback(src,event)
        global cancelProc
        if size(imread(framefiles{1}))==size(bwporig)
            man_mod=1;
            set(MainF, 'pointer', 'watch');drawnow;
            squareSize=str2double(get(heditSize,'String'));
            Lworld=str2double(get(heditLength,'String'))*10;
            CLworld=str2double(get(heditLength2,'String'))*10;
            AngleWorld=str2double(get(heditAngle,'String'));
            project_name=get(heditPname,'String');
            main_calibration
            if cancelProc==1
                set(MainF, 'pointer', 'arrow');drawnow
                return
            end
            man_detect
            hbuttonAROS.Enable='on'; hbuttonDROS.Enable='on'; hbuttonDist.Enable='on'; hbuttonMap.Enable='on';
            hbuttonIso.Enable='on'; hbuttonCheck.Enable='on'; hbuttonSaveE.Enable='on';
            set(heditCFI,'String',num2str(numframes));
            set(MainF, 'pointer', 'arrow');drawnow;
        else
            hW = warndlg(sprintf('The Calibration image doesn''t have the same dimensions as the frames'),'Error!','modal');
            jframe=get(hW,'javaframe'); jframe.setFigureIcon(javax.swing.ImageIcon(fullfile(appPath,'icon ROS.gif')));
        end
    end
    function buttonCalibrateA_Callback(src,event)
        global cancelProc detSens
        if size(imread(framefiles{1}))==size(bwporig)
            man_mod=0;
            hwait = waitbar(0,'Calibrating...','Name','Automatic fire front detection');
            jframe=get(hwait,'javaframe'); jframe.setFigureIcon(javax.swing.ImageIcon(fullfile(appPath,'icon ROS.gif')));
            detSens=str2double(get(heditSens,'String'));
            squareSize=str2double(get(heditSize,'String'));
            Lworld=str2double(get(heditLength,'String'))*10;
            CLworld=str2double(get(heditLength2,'String'))*10;
            AngleWorld=str2double(get(heditAngle,'String'));
            project_name=get(heditPname,'String');
            main_calibration
            if cancelProc==1
                close(hwait)
                return
            end
            auto_detect
            hbuttonAROS.Enable='on'; hbuttonDROS.Enable='on'; hbuttonDist.Enable='on'; hbuttonMap.Enable='on';
            hbuttonIso.Enable='on'; hbuttonCheck.Enable='on'; hbuttonSaveE.Enable='on'; hframeEva.Enable='on';
            set(heditCFI,'String',num2str(numframes));
            close(hwait)
        else
            hW = warndlg(sprintf('The Calibration image doesn''t have the same dimensions as the frames'),'Error!','modal');
            jframe=get(hW,'javaframe'); jframe.setFigureIcon(javax.swing.ImageIcon(fullfile(appPath,'icon ROS.gif')));
        end
    end

%% interactive controls for the results panel (New project Tab)
    function buttonFrameEva_Callback(src,event)
        evaluate_frames 
    end
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
            set(heditPname,'String',[]); set(heditIframes,'String',[]); set(heditIbed,'String',[]); set(heditLength2,'String',[])
            set(heditAngle,'String',[]); set(heditLength,'String',[]); set(heditSize,'String',[]); set(heditResults,'String',[]);
            set(heditAngle,'String',[]); set(heditLaps,'String',[]); set(heditCFI,'String',[]); hframeEva.Enable='off';
            hcheckSave.Value=0; hpopShape.Value=3; hpopCalib.Value=size(calibList,2); hbuttonIcalib.Enable='on';
            heditLength.Enable='off'; heditAngle.Enable='off'; hbuttonDetect.Enable='off';  hbuttonDraw.Enable='on';  heditLength2.Enable='off';
            heditLaps.Enable='on'; hbuttonLaps.Enable='off'; hbuttonCalibrateM.Enable='off'; hbuttonCalibrateA.Enable='off';
            hbuttonAROS.Enable='off'; hbuttonDROS.Enable='off'; hbuttonDist.Enable='off'; hbuttonMap.Enable='off';
            hbuttonIso.Enable='off'; hbuttonCheck.Enable='off'; hbuttonSaveE.Enable='off'; htextSave.Visible='off';
            shape=4;TimeSelection=1;resultrow=5;results=cell(0); loudstatuse=0;
            Xcorners=[]; Ycorners=[]; pathname=[]; filesim=[]; numframes=[]; framefiles=[]; bwporig=[]; TimeSelection=[]; localtime=[];
            resultsfolder=[]; drawfront=0; project_name=[]; cornersnum=[]; images=[]; XcornersWorld=[]; YcornersWorld=[]; ffpoints=[];
            fflineeq=[]; time=[]; R=[]; t=[]; cameraParams=[]; Xworld=[]; Yworld=[]; X=[]; Y=[];
        end
    end
    function buttonSaveE_Callback(src,event)
        set(MainF, 'pointer', 'watch');drawnow;
        xlswrite([resultsfolder,'\',project_name,' Results'],results);
        set(MainF, 'pointer', 'arrow');drawnow;
        htextSave.Visible='on';
    end

%% interactive controls for the load panel (load project Tab)
    function buttonLprojcet_Callback(src,event)  
        [work, workpathname] = uigetfile('*.mat','Load a Session');
        loudstatuse=1;
        set(heditLprojcet,'String',work);
        load([workpathname,work],'numframes')
        set(heditCFI2,'String',num2str(numframes));
        results=cell(0);
        results{1,1}='Session Name: '; results{1,2}=project_name;
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
        results{1,1}='Session Name: '; results{1,2}=project_name;
        resultrow=2;
    end

%% interactive controls for the Matching Images Tab
    function popModeMat_Callback(src,event)
        global MatchMode MatchFile
        MatchMode=get(hpopModeMat,'value');
        if MatchMode==2
            [MatchName, Matchpathname] = uigetfile({'*.mat','MAT file';'*.*','All Files' },'Select a Saved Cropping Setting ');
            MatchFile=fullfile(Matchpathname,MatchName);
            hbuttonIref.Enable='off'; hbuttonAdjust.Enable='off'; hbuttonMatch.Enable='on';
            hbuttonIcorr.Enable='off'; heditIref.Enable='off'; heditIcorr.Enable='off';
        else
            hbuttonIcorr.Enable='on'; hbuttonIref.Enable='on'; heditIref.Enable='on'; heditIcorr.Enable='on';
        end
    end
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
        [Xjpg,Yjpg] = ginput(2);
        close
        Djpg = ((Xjpg(1,1) - Xjpg(2,1)) ^ 2 + (Yjpg(1,1) - Yjpg(2,1)) ^ 2) ^ 0.5;
        scale=Dir/Djpg;
        jpgim=imresize(jpgim,scale);
        %determining the cropping size
        figure('NumberTitle','off','Name','Adjusting Frame'); imshow(irim,'InitialMagnification', 'fit');
        title('Detect One Clear points');
        [Xir,Yir] = ginput(1);
        close
        figure('NumberTitle','off','Name','Adjusting Frame'); imshow(jpgim,'InitialMagnification', 'fit');
        title('Detect The Same Point');
        [Xcorjpg,Ycorjpg] = ginput(1);
        close
        Xmin=Xcorjpg-Xir-1;
        Ymin=Ycorjpg-Yir-1;
        rect=[Xmin, Ymin, size(irim,2)-1, size(irim,1)-1];
        hbuttonMatch.Enable='on';hbuttonSaveSet.Enable='on';
    end
    function buttonMatch_Callback(src,event)
        global MatchMode MatchFile
        global image_name Iresultsfolder Mimages Mfilesim rect scale MnumImages
        set(MainF, 'pointer', 'watch');drawnow;
        if MatchMode==2
            load(MatchFile)
        end
        MnumImages = numel(Mimages);
        if iscell(Mimages)==0
            jpg=imread(Mfilesim);
            %resize the image
            jpgsc=imresize(jpg,scale);
            pattern=imcrop(jpgsc,rect);
            baseFileName = [image_name,' I1.png'];
            files{1} = fullfile(Iresultsfolder, baseFileName);
            imwrite(pattern, files{1});
        else
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
        end
        set(MainF, 'pointer', 'arrow');drawnow;
    end
    function buttonSaveSet_Callback(src,event)
        global rect scale Iresultsfolder
        [CNeme,Cpath] = uiputfile({'*.mat','Cropping Setting File'},'Save Cropping Setting As',Iresultsfolder);
        save(fullfile(Cpath,CNeme),'rect','scale')
    end
%% interactive controls for the Extracting Tab
    function buttonVideo_Callback(src,event)
        global movieFullFileName startTime endTime DimRatio vidHeight vidWidth
        [videoName, pathname] = uigetfile({'*.*','All Files' },'Select a video file');
        movieFullFileName = fullfile(pathname , videoName);
        set(heditVideo,'String',videoName);
        videoObject = VideoReader(movieFullFileName);
        vidHeight=videoObject.Height;vidWidth=videoObject.Width;
        DimRatio=vidHeight/vidWidth;
        startTime=[0 0];
        endTime=[0 0];
        set(heditDRow,'String',num2str(videoObject.Height))
        set(heditDCol,'String',num2str(videoObject.Width))
    end

    function buttonRes_Callback(src,event)
        global Savefolder
        Savefolder = uigetdir('C:\','Select a Folder To Save the Results On');
        set(heditRes,'String',Savefolder);
    end

    function editStime1_Callback(src,event)
        global startTime endTime
        startTime(1,1)=str2double(get(heditStime1,'String'));
        if interval~=0  
            NumSaveFrames=ceil(((endTime(1,1)*60+endTime(1,2))-(startTime(1,1)*60+startTime(1,2)))/interval);
            set(heditNframes,'String',NumSaveFrames);
        end
    end
    function editStime2_Callback(src,event)
        global startTime endTime
        startTime(1,2)=str2double(get(heditStime2,'String'));
        if interval~=0 
            NumSaveFrames=ceil(((endTime(1,1)*60+endTime(1,2))-(startTime(1,1)*60+startTime(1,2)))/interval);
            set(heditNframes,'String',NumSaveFrames);
        end
    end
    function editEtime1_Callback(src,event)
        global startTime endTime
        endTime(1,1)=str2double(get(heditEtime1,'String'));
        if interval~=0  
            NumSaveFrames=ceil(((endTime(1,1)*60+endTime(1,2))-(startTime(1,1)*60+startTime(1,2)))/interval);
            set(heditNframes,'String',NumSaveFrames);
        end
    end
    function editEtime2_Callback(src,event)
        global startTime endTime
        endTime(1,2)=str2double(get(heditEtime2,'String'));
        if interval~=0  
            NumSaveFrames=ceil(((endTime(1,1)*60+endTime(1,2))-(startTime(1,1)*60+startTime(1,2)))/interval);
            set(heditNframes,'String',NumSaveFrames);
        end
    end
    function editItime_Callback(src,event)
        global startTime endTime
        interval=str2double(get(heditItime,'String'));
        endTime(1,2)=str2double(get(heditEtime2,'String'));
        endTime(1,1)=str2double(get(heditEtime1,'String'));
        startTime(1,2)=str2double(get(heditStime2,'String'));
        startTime(1,1)=str2double(get(heditStime1,'String'));
        NumSaveFrames=ceil(((endTime(1,1)*60+endTime(1,2))-(startTime(1,1)*60+startTime(1,2)))/interval);
        set(heditNframes,'String',NumSaveFrames);
    end
    function selectionDim(src,event)
        global vidHeight vidWidth
        selection=event.NewValue.String;
        if strcmp(selection,'Equal to the input video')
            heditDRow.Enable='off'; heditDCol.Enable='off';
            vidHeight = videoObject.Height;
            vidWidth = videoObject.Width ;
            set(heditDRow,'String',num2str(videoObject.Height))
            set(heditDCol,'String',num2str(videoObject.Width))
        elseif strcmp(selection,'Customized')
            heditDRow.Enable='on'; heditDCol.Enable='on';
            set(heditDRow,'String',num2str(videoObject.Height))
            set(heditDCol,'String',num2str(videoObject.Width))
        end
    end
    function editDRow_Callback(src,event)
        global DimRatio vidHeight 
        vidHeight=str2double(get(heditDRow,'String'));
        vidWidth=(vidHeight/DimRatio);
        set(heditDCol,'String',num2str(ceil(vidWidth)))
    end
    function editDCol_Callback(src,event)
        global DimRatio vidHeight
        vidWidth=str2double(get(heditDCol,'String'));
        vidHeight=(vidWidth*DimRatio);
        set(heditDRow,'String',num2str(ceil(vidHeight)))
    end
    function buttonExt_Callback(src,event)
        global startTime endTime
        hwait = waitbar(0,'Reading video...','Name','Extracting frames from video');
        jframe=get(hwait,'javaframe'); jframe.setFigureIcon(javax.swing.ImageIcon(fullfile(appPath,'icon ROS.gif')));
        startTime(1,1)=str2double(get(heditStime1,'String')); startTime(1,2)=str2double(get(heditStime2,'String'));
        endTime(1,1)=str2double(get(heditEtime1,'String')); endTime(1,2)=str2double(get(heditEtime2,'String')); interval=str2double(get(heditItime,'String'));
        saveFrames
        close(hwait)
    end
%% interactiv controls for the calibration Tab
    function buttonAdd_Callback(src,event)
        global EvImages Eimages Epathname
        hbuttonSaveCalib.Enable='off';hbuttonCheckAcc.Enable='off';hbuttonLoadCalib.Enable='off';
        hbuttonCalib.Enable='off';hbuttonDet.Enable='off';
        set(heditAddI,'String','0');set(heditRejI,'String','0');
        hpopImage.String={'No Images'}; hpopImage.Value=1;
        haxisEval = axes(hpanelEvaluate,'box','off','xtick',[],'ytick',[],'ztick',[],'xcolor',[1 1 1],'ycolor',[1 1 1],'Units','pixels',...
            'Position',[20,10,450,300],'color','white');
        [Eimages, Epathname] = uigetfile({'*.jpg;*.tif;*.png;*.gif','All Image Files';...
            '*.*','All Files' },'Select the Calibration Images','MultiSelect', 'on');
        EvImages = fullfile(Epathname , Eimages);
        set(heditAdd,'String',Epathname);
        if iscell(Eimages)
            hbuttonDet.Enable='on';
        elseif Eimages~=0
            hbuttonDet.Enable='on';
        end
    end
    function buttonDet_Callback(src,event)
        global EvImage Epathname
        set(MainF, 'pointer', 'watch');drawnow;
        global EvImages boardSize imagePoints UsedimageFile Eimages
        [imagePoints, boardSize,imagesUsed] = detectCheckerboardPoints(EvImages);
        set(heditAddI,'String',length(imagesUsed(imagesUsed==1)))
        set(heditRejI,'String',length(imagesUsed(imagesUsed==0)))
        UsedimageFile=cell(1,length(imagesUsed(imagesUsed==1)));
        j=1;
        if length(imagesUsed)==1 && imagesUsed(1,1)==0
            hpopImage.String={'No Images'}; hpopImage.Value=1;
            haxisEval = axes(hpanelEvaluate,'box','off','xtick',[],'ytick',[],'ztick',[],'xcolor',[1 1 1],'ycolor',[1 1 1],'Units','pixels',...
                'Position',[20,10,450,300],'color','white');
            return
        end
        if length(imagesUsed)==1 && imagesUsed(1,1)==1
            UsedimageFile{1,1}=Eimages;
        else
            for i=1:length(imagesUsed)
                if imagesUsed(i,1)==1
                    UsedimageFile{1,j}=Eimages{i};
                    j=j+1;
                end
            end
        end
        hpopImage.String=UsedimageFile; hpopImage.Value=1;
        EvImage=imread(fullfile(Epathname , UsedimageFile{1}));
        image(haxisEval,EvImage);
        haxisEval.Box='off';haxisEval.XTick=[];haxisEval.YTick=[];haxisEval.ZTick=[];haxisEval.XColor=[1 1 1];haxisEval.YColor=[1 1 1];
        hold(haxisEval,'on')
        plot(haxisEval,imagePoints(:,1,1),imagePoints(:,2,1),'ro');
        hold(haxisEval,'off')
        if length(UsedimageFile)>=4
            hbuttonCalib.Enable='on';
            hbuttonLoadCalib.Enable='on';
        else
            hbuttonCalib.Enable='off';
            hbuttonLoadCalib.Enable='on';
        end
        set(MainF, 'pointer', 'arrow');drawnow;
    end
    function popImage_Callback(src,event)
        global UsedimageFile imagePoints EvImage Epathname
        Iselection=get(hpopImage,'Value');
        EvImage=imread(fullfile(Epathname , UsedimageFile{Iselection}));
        image(haxisEval,EvImage);
        haxisEval.Box='off';haxisEval.XTick=[];haxisEval.YTick=[];haxisEval.ZTick=[];haxisEval.XColor=[1 1 1];haxisEval.YColor=[1 1 1];
        hold(haxisEval,'on')
        plot(haxisEval,imagePoints(:,1,Iselection),imagePoints(:,2,Iselection),'ro');
        hold(haxisEval,'off')
    end
    function buttonCalib_Callback(src,event)
        set(MainF, 'pointer', 'watch');drawnow;
        global boardSize imagePoints Size loadCalib
        Size=str2double(get(heditSizeE,'String'));
        worldPoints = generateCheckerboardPoints(boardSize, Size);
        cameraParams = estimateCameraParameters(imagePoints, worldPoints);
        showReprojectionErrors(cameraParams,'Parent',haxisErr);
        showExtrinsics(cameraParams,'Parent',haxisExt);
        hbuttonSaveCalib.Enable='on';
        hbuttonCheckAcc.Enable='on';
        loadCalib=0;
        set(MainF, 'pointer', 'arrow');drawnow;
    end
    function buttonSaveCalib_Callback(src,event)
        [CNeme,Cpath] = uiputfile({'*.mat','Calibration File'},'Save Calibration As',calibPath);
        savingNeme=fullfile(Cpath,CNeme);
        save(savingNeme,'cameraParams')
    end
    function buttonCheckAcc_Callback(src,event)
        check_accuracy2
    end
    function LoadCalib_Callback(src,event)
        global loadCalib Size
        [calibrationName, ClaibPathname] = uigetfile({'*.mat','MAT file';'*.*','All Files' },'Select a Saved Calibration ',calibPath);
        calibrationFile = fullfile(ClaibPathname , calibrationName);
        Size=str2double(get(heditSizeE,'String'));
        loadCalib=1;
        hbuttonCheckAcc.Enable='on';
    end
end