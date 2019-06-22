%Fire ROS Calculator is a program with GUI built to measure the rate of spread (ROS) 
%of a fire propagating over a surface in a laboratory setting
%
%This program was developed by [ADAI|CEIF](http://www.adai.pt) team (Association for the Development of 
%Industrial Aerodynamics | Center of Studies about Forest Fires), University of Coimbra, Portugal. 
%
%This is a sub-program from the Fire ROS Calcualtor 
%
%Copyright (C) 2019  Abdelrahman Abouali
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <https://www.gnu.org/licenses/>.

function check_accuracy2 
global  R t cameraParams
global  DistImage realt_dist EvImage Size boardSize appPath loadCalib calibrationFile
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
hbuttonCalculate = uicontrol('Style','pushbutton','String','Calculate Accuracy','Enable','on',...
    'Position',[650,150,150,35],'callback',{@calculate_Callback});
htextResult = uicontrol('Style','text','String','Error:','FontWeight','bold','FontSize',10,'Position',[650,100,50,20]);
heditResult = uicontrol('Style','edit','Enable','off','Position',[700,95,100,30],'FontSize',10);



hDistImage = image(haxis,EvImage);
haxis.Box='off';haxis.XTick=[];haxis.YTick=[];haxis.ZTick=[];haxis.XColor=[1 1 1];haxis.YColor=[1 1 1];
c = uicontextmenu;
hDistImage.UIContextMenu = c;
m1 = uimenu(c,'Label','Add Lines','Callback',@drawLines);

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

if loadCalib==1
    load(calibrationFile)
end
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
    function drawLines(source,callbackdata)
        global hline2
        switch source.Label
            case 'Add Lines'
                hline2 = imline(haxis);
        end
    end
    function calculate_Callback(src,event)
        global hline2 
        posline = getPosition(hline2);
        im = undistortImage(EvImage, cameraParams,'OutputView', 'full');
        
        %Get the extrinsics (rotation and translation) for fuel bed image
        [imagePoints,boardSize] = detectCheckerboardPoints(im);
        if boardSize(1,1)==0
            hW = warndlg({'CheckBoard not detected'},'Error!','modal');
        else
        worldPoints = generateCheckerboardPoints(boardSize, Size);
        [R, t] = extrinsics(imagePoints, worldPoints, cameraParams);
        Worldposline = pointsToWorld(cameraParams, R, t, posline);
        MeasuredDist = ((Worldposline(1,1) - Worldposline(2,1)) ^ 2 + (Worldposline(1,2) - Worldposline(2,2)) ^ 2) ^ 0.5;
        Error= abs(((realt_dist-MeasuredDist)/realt_dist)*100); 
        set(heditResult,'String',[num2str(Error),'%'])
        end
    end
end