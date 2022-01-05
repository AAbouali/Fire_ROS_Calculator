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

function evaluate_frames
global numframes cornersnum Xworld Yworld appPath BI MaskROI Bnd hL editMode hArea project_name resultsfolder XcornersWorld YcornersWorld ffpoints time
global R t cameraParams X Y Xcorners Ycorners frames frame Fselection fflineeq drawfront MainF Nfires fireLastFrame shape results resultrow loadsession
%% building the GUI
f = figure('Visible','off','Position',[680,215,800,500],'CloseRequestFcn',@f_CloseRequestFcn);
panel=uipanel(f,'Position',[0,0,1,1]);
htextFrame  = uicontrol(panel,'Style','text','String','Select Frame:',...
    'FontWeight','bold','FontSize',12,'Units','normalized','Position',[0.78,0.826,0.146,0.056]);
hpopFrame  = uicontrol(panel,'Style','pop','Units','normalized','FontSize',10,...
    'Position',[0.78,0.77,0.173,0.056],'String',frames,'callback',{@popFrame_Callback});
hbgEdit  = uibuttongroup(panel,'Units','pixels','Title','Modify Fire Front','FontSize',10,...
    'Units','normalized','Position',[0.762 0.157 0.21 0.6],'SelectionChangedFcn',@selectionMode);
hMTool   = uicontrol(hbgEdit,'Style','pushbutton','String','Modify Tool','Units','normalized',...
    'Position',[0.075,0.82,0.87,0.15],'FontSize',10,'callback',{@MTool_Callback});
htextMode  = uicontrol(hbgEdit,'Style','text','String','Mode:',...
    'FontSize',11,'Units','normalized','Position',[0.11,0.71,0.317,0.075]);
hradioAdd    = uicontrol(hbgEdit  ,'Style','radiobutton','String','Add','Units','normalized',...
    'Position',[0.124 0.61 0.627 0.115],'FontSize',11,'Enable','off');
hradioRemove    = uicontrol(hbgEdit  ,'Style','radiobutton','String','Remove','Units','normalized',...
    'Position',[0.124 0.53 0.627 0.115],'FontSize',11,'Enable','off');
htextFire  = uicontrol(hbgEdit,'Style','text','String','Fire No:',...
    'FontSize',11,'Units','normalized','Position',[0.06,0.45,0.5,0.075]);
hpopFire  = uicontrol(panel,'Style','pop','Units','normalized','FontSize',10,...
    'Position',[0.78,0.35,0.173,0.056],'String',num2cell(1:Nfires),'callback',{@popFire_Callback});
hcheckApply = uicontrol(hbgEdit,'Style','checkbox','String','Apply for next frames','Units','normalized',...
    'FontSize',9.5,'Value',0,'Position',[0.05 0.15 0.95 0.25]);
hApply   = uicontrol(hbgEdit,'Style','pushbutton','String','Apply','Units','normalized',...
    'Position',[0.199,0.02,0.627,0.17],'FontSize',11,'FontWeight','bold','callback',{@Apply_Callback});
haxis       = axes(panel,'box','off','xtick',[],'ytick',[],'ztick',[],'xcolor',[1 1 1],'ycolor',[1 1 1],...
    'Position',[0.03,0.1,0.70,0.8],'color','white');

f.Name = 'Evaluate Fire Front Detection';
movegui(f,'center')
f.MenuBar = 'none';
f.ToolBar = 'none';
f.NumberTitle='off';


warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jframe=get(f,'javaframe');
jIcon=javax.swing.ImageIcon(fullfile(appPath,'icon ROS.gif'));
jframe.setFigureIcon(jIcon);
f.Visible = 'on';
changefFrames=[]; q=1; edit=0;
editMode=1; allFrames=0; fireToEditNo=1;
%% callbacks
    function popFrame_Callback(src,event)
        global him handles
        Fselection=get(hpopFrame,'Value');
        axesHandlesToChildObjects = findobj(haxis, 'Type', 'image');
        if ~isempty(axesHandlesToChildObjects)
            delete(axesHandlesToChildObjects);
        end
        him=image(haxis,frame{Fselection});
        haxis.Box='off';haxis.XTick=[];haxis.YTick=[];haxis.ZTick=[];haxis.XColor=[1 1 1];haxis.YColor=[1 1 1];
        hold on
        for k=1:Nfires
            if Fselection<=fireLastFrame(1,k)
                handles.hL{k}=line(X{k,Fselection},Y{k,Fselection},'Color','g','LineWidth',1.2);
            end
            if Fselection>1 && Fselection<=fireLastFrame(1,k)+1
                line(X{k,Fselection-1},Y{k,Fselection-1},'Color','w','LineWidth',1.2);
            end
        end
        for j=1:cornersnum
            line([Xcorners(j,1),Xcorners(j+1,1)],([Ycorners(j,1),Ycorners(j+1,1)]),'Color','b','LineWidth',2)
        end
        for k=1:Nfires
            if Fselection<=fireLastFrame(1,k)
            text(X{k,1}(randi([1 size(X{k,1},1)],1,1),1),Y{k,1}(randi([1 size(Y{k,1},1)],1,1),1),sprintf('Fire%d',k),'FontSize',10,'Color','k','BackgroundColor','w','EdgeColor','k')
            end
        end
    end
    function MTool_Callback(src,event)
        %C = imfuse(frame{Fselection},BI{Fselection}); image(haxis,C);
         hArea = imfreehand(haxis);
        hradioAdd.Enable='on'; hradioRemove.Enable='on';
    end
    function selectionMode(src,event)
        selection=event.NewValue.String;
        if strcmp(selection,'Add')
            editMode=1;
        elseif strcmp(selection,'Remove')
            editMode=2;
        end
    end
    function popFire_Callback(src,event)
        fireToEditNo=get(hpopFire,'Value');
    end
    function Apply_Callback(src,event)
        global him handles Bn
        edit=1;
        allFrames=get(hcheckApply,'Value');
        set(f, 'pointer', 'watch'); drawnow;
        Mask = createMask(hArea,him);
        if Fselection > fireLastFrame(1,fireToEditNo)
            fireLastFrame(1,fireToEditNo)=Fselection;
        end
        if editMode==1
            BI{Fselection}(Mask == 1) = 1;
        elseif editMode==2
            BI{Fselection}(Mask == 1) = 0;
        end
        BI{Fselection}(MaskROI == 0) = 0;
        [Bn,~,N] = bwboundaries(BI{Fselection},'noholes',8);
        
        SizeDetFires=zeros(1,N);
        for s=1:N
            %SizeDetFires(1,s)=numel(Bn{s,1});
            SizeDetFires(1,s)=polyarea(Bn{s}(:,2), Bn{s}(:,1));
        end
        [~,order]=sort(SizeDetFires,'descend');
        Bnd=Bn{order(1,fireToEditNo)};
        X{fireToEditNo,Fselection}=Bnd(:,2);
        Y{fireToEditNo,Fselection}=Bnd(:,1);
        imagePoints=[];
        imagePoints(:,1)=X{fireToEditNo,Fselection}(:,1);
        imagePoints(:,2)=Y{fireToEditNo,Fselection}(:,1);
        worldPoints = pointsToWorld(cameraParams, R, t, imagePoints);
        Xworld{fireToEditNo,Fselection}=worldPoints(:,1);
        Yworld{fireToEditNo,Fselection}=worldPoints(:,2);
        for j=1:size(Xworld{fireToEditNo,Fselection},1)-1
            fflineeq{Fselection}(j,:) = polyfit([Xworld{fireToEditNo,Fselection}(j,1) Xworld{fireToEditNo,Fselection}(j+1,1)],[Yworld{fireToEditNo,Fselection}(j,1) Yworld{fireToEditNo,Fselection}(j+1,1)],1);
        end
        if any(changefFrames==Fselection)==0
            changefFrames(1,q)=Fselection; q=q+1;
        end
        if allFrames==1
            for i=Fselection+1:numframes
                if editMode==1
                    BI{i}(Mask == 1) = 1;
                elseif editMode==2
                    BI{i}(Mask == 1) = 0;
                end
                BI{i}(MaskROI == 0) = 0;
                Bn=[];
                [Bn,~,N] = bwboundaries(BI{i},'noholes',8);
                SizeDetFires=zeros(1,N);
                for s=1:N
                    %SizeDetFires(1,s)=numel(Bn{s,1});
                    SizeDetFires(1,s)=polyarea(Bn{s}(:,2), Bn{s}(:,1));
                end
                [~,order]=sort(SizeDetFires,'descend');
                Bnd=Bn{order(1,fireToEditNo)};
                X{fireToEditNo,i}=Bnd(:,2);
                Y{fireToEditNo,i}=Bnd(:,1);
                imagePoints=[];
                imagePoints(:,1)=X{fireToEditNo,i}(:,1);
                imagePoints(:,2)=Y{fireToEditNo,i}(:,1);
                worldPoints = pointsToWorld(cameraParams, R, t, imagePoints);
                Xworld{fireToEditNo,i}=worldPoints(:,1);
                Yworld{fireToEditNo,i}=worldPoints(:,2);
                for j=1:size(Xworld{fireToEditNo,i},1)-1
                    fflineeq{i}(j,:) = polyfit([Xworld{fireToEditNo,i}(j,1) Xworld{fireToEditNo,i}(j+1,1)],[Yworld{fireToEditNo,i}(j,1) Yworld{fireToEditNo,i}(j+1,1)],1);
                end
                if any(changefFrames==i)==0
                    changefFrames(1,q)=i; q=q+1;
                end
            end
        end
        delete(handles.hL{fireToEditNo})
        handles.hL{fireToEditNo}=line(X{fireToEditNo,Fselection},Y{fireToEditNo,Fselection},'Color','g','LineWidth',1.2);
        delete(hArea);
        set(f, 'pointer', 'arrow'); drawnow;
    end
% To save the updated locations of the fire fronts on the saved session
% file (worksapce)
    function f_CloseRequestFcn(src,event)
        global namedrawfront
        set(MainF, 'pointer', 'watch'); drawnow;
        delete(f)
        if edit==1
            if loadsession==1
                namedrawfront=[project_name ' DFF'];folder=fullfile(resultsfolder,namedrawfront);
                if exist(folder)==0
                    mkdir(folder)
                end
                save([resultsfolder,'\',project_name],'XcornersWorld', 'YcornersWorld', 'ffpoints', 'fflineeq', 'time', 'R', 't', 'cameraParams', 'Xworld', 'Yworld', 'X', 'Y',...
                    'numframes', 'Xcorners', 'Ycorners', 'shape', 'cornersnum', 'Nfires', 'fireLastFrame', 'drawfront', 'results', 'resultrow' )
            else
                save([resultsfolder,'\',project_name], 'fflineeq', 'Xworld', 'Yworld', 'X', 'Y','-append')
            end
            if drawfront==1
                fff = figure('visible','off'); haxesff=axes(fff);
                for i=1:numframes
                    image(haxesff,frame{i});
                    hold on
                    for j=1:i
                        for k=1:Nfires
                            if j<=fireLastFrame(1,k)
                                line(haxesff,X{k,j}(:,1),Y{k,j}(:,1),'Color','g','LineWidth',1.2)
                            end
                        end
                    end
                    for j=1:cornersnum
                        line(haxesff,[Xcorners(j,1),Xcorners(j+1,1)],([Ycorners(j,1),Ycorners(j+1,1)]),'Color','b','LineWidth',2)
                    end
                    hold off
                    haxesff.Box='off';haxesff.XTick=[];haxesff.YTick=[];haxesff.ZTick=[];haxesff.XColor=[1 1 1];haxesff.YColor=[1 1 1];haxesff.Position=[0 0 1 1];
                    FileName = sprintf([namedrawfront,'%d.png'], i);
                    frontFrame = getframe(haxesff);
                    frontIamge = frame2im(frontFrame);
                    frontIamge = imresize(frontIamge, [NaN size(frame{i},2)]) ;
                    imwrite(frontIamge,[resultsfolder,'\',namedrawfront,'\',FileName],'png')
                    %print(ff, '-r110', '-dpng', [resultsfolder,'\',namedrawfront,'\',FileName]);
                end
                close(fff)
            end
        end
        set(MainF, 'pointer', 'arrow'); drawnow;
    end
end