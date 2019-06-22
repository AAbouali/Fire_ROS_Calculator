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

function measuring_dist
global Xworld Yworld numframes shape XcornersWorld YcornersWorld cornersnum resultsfolder results resultrow  R t cameraParams fireLastFrame
global dist_name DistImage handles time ffpoints fflineeq loudstatuse workpathname work X Y Xcorners Ycorners appPath pathname Nfires
if loudstatuse==1
    load([workpathname,work])
end
%% building the GUI
f = figure('Visible','off','Position',[680,266,850,420]);
haxis = axes('box','off','xtick',[],'ytick',[],'ztick',[],'xcolor',[1 1 1],'ycolor',[1 1 1],'Units','pixels',...
    'Position',[25,22,575,435],'color','white','PlotBoxAspectRatio',[1 1 1]);
hbgSource = uibuttongroup('Units','pixels','Title','Source of Measuring','FontSize',9,'Position',[620 320 195 80],'SelectionChangedFcn',@selectionSource);
hradioMap = uicontrol(hbgSource,'Style','radiobutton','String','From the propagation map','Position',[10 30 180 25],'FontSize',9);
hradioImage = uicontrol(hbgSource,'Style','radiobutton','String','From an image of the fire','Position',[10 5 180 25],'FontSize',9);
hbuttonSelect = uicontrol('Style','pushbutton','String','Select Image','Enable','off',...
    'Position',[670,275,100,35],'callback',@select_Callback);
htextNumber = uicontrol('Style','text','String','Number of distances to be measured:',...
    'FontWeight','bold','FontSize',9,'Position',[615,210,140,30]);
heditNumber = uicontrol('Style','edit','String','1','Position',[755,210,50,30],'FontSize',10,'Callback',@editNumber_callback);
htextName = uicontrol('Style','text','String','Saving name of the measurment:',...
    'FontWeight','bold','FontSize',10,'Position',[615,160,220,20]);
heditName = uicontrol('Style','edit','Position',[635,130,180,30],'FontSize',10,'Callback',@editName_callback);
hcheckImage = uicontrol('Style','checkbox','String','Save image with the measured distances','FontSize',8.5,...
    'Value',0,'Position',[610 80 230 25]);
hbuttonCalculate = uicontrol('Style','pushbutton','String','Calculate Distance','Enable','off',...
    'Position',[605,25,150,35],'callback',{@calculate_Callback});
heditResult = uicontrol('Style','edit','Enable','off','Position',[765,25,70,35],'FontSize',10);

c = uicontextmenu;
haxis.UIContextMenu = c;
m1 = uimenu(c,'Label','Add Lines','Callback',@drawLines);
handles.frameLines = zeros(cornersnum,1);
handles.frontLines = zeros(numframes,1);
hold on
for k=1:Nfires
    for i=1:fireLastFrame(1,k)
        line(Xworld{k,i},Yworld{k,i},'Color','r','LineWidth',1);
    end
end
if shape~=4
    for i=1:cornersnum
       handles.frameLines(i)=line(haxis,[XcornersWorld(i,1),XcornersWorld(i+1,1)],([YcornersWorld(i,1),YcornersWorld(i+1,1)]),'Color','b','LineWidth',2);
    end
end
hold off
axis equal
f.Name = 'Measuring Distnaces';
movegui(f,'center')
f.MenuBar = 'none';
f.ToolBar = 'none';
f.NumberTitle='off';


warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jframe=get(f,'javaframe');
jIcon=javax.swing.ImageIcon(fullfile(appPath,'icon ROS.gif'));
jframe.setFigureIcon(jIcon);
f.Visible = 'on';
%% interactive controls
numdis=1;
image_source=1;
    function selectionSource(source,event)
        selection=event.NewValue.String;
        if strcmp(selection,'From the propagation map')
            hbuttonSelect.Enable = 'off';
            image_source=1;
            cla reset
            haxis.Box='off';haxis.XTick=[];haxis.YTick=[];haxis.ZTick=[];haxis.XColor=[1 1 1];haxis.YColor=[1 1 1];
            axis equal
            hold on
            for k=1:Nfires
                for i=1:fireLastFrame(1,k)
                    line(Xworld{k,i},Yworld{k,i},'Color','r','LineWidth',1);
                end
            end
            if shape~=4
                for i=1:cornersnum
                    line(haxis,[XcornersWorld(i,1),XcornersWorld(i+1,1)],([YcornersWorld(i,1),YcornersWorld(i+1,1)]),'Color','b','LineWidth',2);
                end
            end
            hold off
        else
            image_source=2;
            hbuttonSelect.Enable = 'on';
        end
    end

    function drawLines(source,callbackdata)
        handles.line = cell(numdis);
        switch source.Label
            case 'Add Lines'
                for k=1:numdis;
                    handles.line{k} = imline(haxis);
                    %position1 = wait(handles.line{k});
                end
        end
    end

    function select_Callback(src,event)
        [DistImageName, DistImage_pathname] = uigetfile({'*.jpg;*.tif;*.png;*.gif','All Image Files';...
            '*.*','All Files' },'Select an image to measure distances from it',pathname);
        DistImage=imread(fullfile(DistImage_pathname,DistImageName));
        cla reset
        hDistImage = image(haxis,DistImage);
        haxis.Box='off';haxis.XTick=[];haxis.YTick=[];haxis.ZTick=[];haxis.XColor=[1 1 1];haxis.YColor=[1 1 1];
        c = uicontextmenu;
        hDistImage.UIContextMenu = c;
        m1 = uimenu(c,'Label','Add Lines','Callback',@drawLines);
    end

    function editNumber_callback(source,event)
        numdis=str2double(get(heditNumber ,'String'));
    end

    function editName_callback(source,event)
        dist_name=get(heditName ,'String');
        hbuttonCalculate.Enable='on';
    end

    function calculate_Callback(src,event)
        save_image = get(hcheckImage, 'Value');
        posline=cell(1,numdis);
        for i=1:numdis
            posline{1,i} = getPosition(handles.line{i});
        end
        MeasuredDist=zeros(1,numdis);
        if image_source==1
            for i=1:numdis
                MeasuredDist(1,i) = ((posline{1,i}(1,1) - posline{1,i}(2,1)) ^ 2 + (posline{1,i}(1,2) - posline{1,i}(2,2)) ^ 2) ^ 0.5;
            end
        else
            for i=1:numdis
                %imagePoint1(1,1)=posline{1,i}(1,1);imagePoint1(1,2)=posline{1,i}(1,2);
                %imagePoint2(1,1)=posline{1,i}(2,1);imagePoint2(1,2)=posline{1,i}(2,2);
                %worldPoint1 = pointsToWorld(cameraParams, R, t, imagePoint1);
                %worldPoint2 = pointsToWorld(cameraParams, R, t, imagePoint2);
                %XcornersWorld(i,1)=worldPoint(1,1);
                %YcornersWorld(i,1)=worldPoint(1,2);
                Worldposline = pointsToWorld(cameraParams, R, t, posline{1,i});
                MeasuredDist(1,i) = ((Worldposline(1,1) - Worldposline(2,1)) ^ 2 + (Worldposline(1,2) - Worldposline(2,2)) ^ 2) ^ 0.5;
                %MeasuredDist(1,i) = ((worldPoint1(1,1) - worldPoint2(1,1)) ^ 2 + (worldPoint1(1,2) - worldPoint2(1,2)) ^ 2) ^ 0.5;
            end
        end
        if save_image==1;
            if image_source==1
                hFigResult=figure('Visible','off');
                title('Postion of the measured distance');
                hold on
                for k=1:Nfires
                    for i=1:fireLastFrame(1,k)
                        line(Xworld{k,i},Yworld{k,i},'Color','r','LineWidth',1);
                    end
                end
                for i=1:numdis
                    line([posline{1,i}(1,1),posline{1,i}(2,1)],[posline{1,i}(1,2),posline{1,i}(2,2)],'Color','g','LineWidth',2);
                end
                if shape~=4
                    for i=1:cornersnum
                        line([XcornersWorld(i,1),XcornersWorld(i+1,1)],([YcornersWorld(i,1),YcornersWorld(i+1,1)]),'Color','b','LineWidth',2)
                    end
                end
                hold off
                axis equal
                saveas(hFigResult,[resultsfolder,'\',dist_name,'(Distance)'],'jpeg')
                close(hFigResult)
            else
                hFigResult=figure('Visible','off');
                title('Postion of the measured distance');
                imshow(DistImage,'InitialMagnification', 'fit');
                hold on
                for i=1:numdis
                line([posline{1,i}(1,1),posline{1,i}(2,1)],[posline{1,i}(1,2),posline{1,i}(2,2)],'Color','g','LineWidth',2);
                end
                hold off
                axis off
                saveas(hFigResult,[resultsfolder,'\',dist_name,'(Distance)'],'jpeg')
                close(hFigResult)
            end
        end
        results{resultrow,1}=[dist_name,'(Distance)'];
        resultrow=resultrow+1;
        if numdis>1
            results{resultrow,1}=('The avarge distance (cm)');
            results{resultrow,2}=mean(MeasuredDist)/10;
            resultrow=resultrow+1;
        end
        results{resultrow,1}=('The measured distances (cm)');
        resultrow=resultrow+1;
        results(resultrow,1:size(MeasuredDist,2))=num2cell(MeasuredDist/10);
        resultrow=resultrow+2;
        set(heditResult,'String',[num2str(round(mean(MeasuredDist))/10),' cm']);
    end

end