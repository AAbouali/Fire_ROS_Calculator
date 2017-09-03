function check_accuracy 
global Xworld Yworld numframes shape XcornersWorld YcornersWorld cornersnum resultsfolder results resultrow  R t cameraParams
global dist_name DistImage handles time ffpoints fflineeq loudstatuse workpathname work X Y Xcorners Ycorners realt_dist appPath
if loudstatuse==1 
    load([workpathname,work])
    %%%
    %if loading a session made by version 1.0 or 1.1
    %load([workpathname,work],'XcornersWorld', 'YcornersWorld', 'ffpoints', 'fflineeq', 'time', 'R', 't', 'cameraParams', 'Xworld', 'Yworld', 'X', 'Y',...
    %    'numframes', 'Xcorners', 'Ycorners', 'shape')
    %Xnew=cell(1,numframes); Ynew=cell(1,numframes); Xworldnew=cell(1,numframes); Yworldnew=cell(1,numframes); eqnew=cell(1,numframes);
    %for i=1:numframes
    %    Xnew{i}=X(:,i); Ynew{i}=Y(:,i); Xworldnew{i}=Xworld(:,i); Yworldnew{i}=Yworld(:,i); eqnew{i}(:,1:2)=fflineeq(:,2*i-1:2*i);
    %end
    %X=Xnew; Y=Ynew; Xworld=Xworldnew; Yworld=Yworldnew; fflineeq=eqnew;
    %%%%
end
%% buildign GUI
f = figure('Visible','off','Position',[680,266,850,420]);
haxis = axes('box','off','xtick',[],'ytick',[],'ztick',[],'xcolor',[1 1 1],'ycolor',[1 1 1],'Units','pixels',...
    'Position',[25,22,575,435],'color','white');
hbuttonSelect = uicontrol('Style','pushbutton','String','Select Image',...
    'Position',[625,300,100,35],'callback',@buttonSelect_Callback);
heditSelect = uicontrol('Style','edit','Position',[730,300,100,35],'FontSize',10);
htextReal = uicontrol('Style','text','String','Real Distace=','FontWeight','bold','FontSize',10,'Position',[625,250,100,20]);
heditReal = uicontrol('Style','edit','Position',[725,245,60,30],'FontSize',10,'Callback',@editReal_callback);
htextReal = uicontrol('Style','text','String','mm','FontWeight','bold','FontSize',10,'Position',[785,250,40,20]);
htextName = uicontrol('Style','text','String','Saving name:','FontWeight','bold','FontSize',10,'Position',[625,210,100,20]);
heditName = uicontrol('Style','edit','Position',[725,205,100,30],'FontSize',10,'Callback',@editName_callback);
hbuttonCalculate = uicontrol('Style','pushbutton','String','Calculate Accuracy','Enable','off',...
    'Position',[650,150,150,35],'callback',{@calculate_Callback});
htextResult = uicontrol('Style','text','String','Error:','FontWeight','bold','FontSize',10,'Position',[650,100,50,20]);
heditResult = uicontrol('Style','edit','Enable','off','Position',[700,95,100,30],'FontSize',10);


f.Name = 'Checking Calibration Accuracy';
movegui(f,'center')
f.MenuBar = 'none';
f.ToolBar = 'none';
f.NumberTitle='off';
f.Visible = 'on';

warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jframe=get(f,'javaframe');
jIcon=javax.swing.ImageIcon(fullfile(appPath,'icon ROS.gif'));
jframe.setFigureIcon(jIcon);

%% interactiv controls
    function buttonSelect_Callback(src,event)
        [DistImageName, DistImage_pathname] = uigetfile({'*.jpg;*.tif;*.png;*.gif','All Image Files';...
            '*.*','All Files' },'Select an image to measure distances from it');
        DistImage=imread(fullfile(DistImage_pathname,DistImageName));
        hDistImage = image(haxis,DistImage);
        haxis.Box='off';haxis.XTick=[];haxis.YTick=[];haxis.ZTick=[];haxis.XColor=[1 1 1];haxis.YColor=[1 1 1];
        c = uicontextmenu;
        hDistImage.UIContextMenu = c;
        m1 = uimenu(c,'Label','Add Lines','Callback',@drawLines);
        set(heditSelect,'String',DistImageName);
    end
    function editReal_callback(src,event)
        realt_dist=str2double(get(heditReal,'String'));
    end
    function editName_callback(src,event)
        dist_name=get(heditName,'String');
        hbuttonCalculate.Enable='on';
    end
    function drawLines(source,callbackdata)
        global hline1
        switch source.Label
            case 'Add Lines'
                hline1 = imline(haxis);
        end
    end
    function calculate_Callback(src,event)
        global hline1
        posline = getPosition(hline1);
        Worldposline = pointsToWorld(cameraParams, R, t, posline);
        MeasuredDist = ((Worldposline(1,1) - Worldposline(2,1)) ^ 2 + (Worldposline(1,2) - Worldposline(2,2)) ^ 2) ^ 0.5;
        Error= abs((realt_dist-MeasuredDist)/realt_dist*100); 
        results{resultrow,1}=[dist_name,'(Accuracy Check)'];
        resultrow=resultrow+1;
        results{resultrow,1}='Real Distance='; results{resultrow,2}=realt_dist;
        resultrow=resultrow+1;
        results{resultrow,1}='Measured Distance='; results{resultrow,2}=MeasuredDist;
        resultrow=resultrow+1;
        results{resultrow,1}='Error(%)='; results{resultrow,2}=Error; 
        resultrow=resultrow+2;
        set(heditResult,'String',[num2str(Error),'%'])
    end
end