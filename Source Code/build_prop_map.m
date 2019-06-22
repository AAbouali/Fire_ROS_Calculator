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

function build_prop_map
global Xworld Yworld numframes shape XcornersWorld YcornersWorld cornersnum resultsfolder plotcolors linestyles time man_mod
global R t cameraParams ffpoints fflineeq loudstatuse workpathname work X Y Xcorners Ycorners appPath Nfires fireLastFrame smooth
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
load plotcolorsmat.mat
textColor={'black';'yellow';'magenta';'cyan';'red';'green';'blue';'white'};
%% building the GUI
f = figure('Visible','off','Position',[780,200,935,620]);
htextTitle  = uicontrol(f,'Style','text','String','The Propagation of the fire front',...
    'FontWeight','bold','FontSize',12,'Position',[150,615,450,22]);
htextName    = uicontrol(f,'Style','text','String','Map name:',...
    'FontWeight','bold','FontSize',11,'Position',[200,25,80,20]);
heditName    = uicontrol(f,'Style','edit','Position',[285,20,150,30],'FontWeight','bold','FontSize',12,...
    'Enable','on','Callback',@name_Callback );
hbuttonSave  = uicontrol(f,'Style','pushbutton','String','Save','Enable','off',...
    'FontWeight','bold','FontSize',12,'Position',[460,15,100,40],'callback',{@save_Callback});
hbgStyle     = uibuttongroup(f,'Units','pixels','Title','Lines Style','FontSize',9,'Position',[750 510 167 150],'SelectionChangedFcn',@selectionStyle);
hCdashed      = uicontrol(hbgStyle,'Style','radiobutton','String','Colored and Dashed','Position',[13 105 140 25],'FontSize',9);
hCsolid       = uicontrol(hbgStyle,'Style','radiobutton','String','Colored and Solid','Position',[13 80 140 25],'FontSize',9);
hBdashed      = uicontrol(hbgStyle,'Style','radiobutton','String','B&W and Dashed','Position',[13 55 140 25],'FontSize',9);
hBsolid       = uicontrol(hbgStyle,'Style','radiobutton','String','B&W and Solid','Position',[13 30 140 25],'FontSize',9);
hBfill       = uicontrol(hbgStyle,'Style','radiobutton','String','Colored filling','Position',[13 5 140 25],'FontSize',9);
hbgFrame     = uibuttongroup(f,'Units','pixels','Title','Fule Bed Frame','FontSize',9,'Position',[750 430 120 70],'SelectionChangedFcn',@selectionFrame);
hOn          = uicontrol(hbgFrame,'Style','radiobutton','String','On','Position',[13 30 40 25],'FontSize',9);
hOff          = uicontrol(hbgFrame,'Style','radiobutton','String','Off','Position',[13 5 40 25],'FontSize',9);
hcheckSmooth = uicontrol(f,'Units','pixels','Style','checkbox','String','Smooth Front Lines','FontSize',10,'Value',0,'Position',[750 400 150 23],'callback',{@checkSmooth_Callback});
hpopSmoothDegree = uicontrol(f,'Style','pop','Units','pixels','FontSize',10,'Position',[750,370,130,25],'String',{'Smooth Degree 1','Smooth Degree 2','Smooth Degree 3'},'callback',{@popSmoothDegree_Callback});
hbgTimeText     = uibuttongroup(f,'Units','pixels','Title','Time Lables','FontSize',9,'Position',[750 90 167 270],'SelectionChangedFcn',@selectionFrame);
hcheckTime = uicontrol(hbgTimeText,'Style','checkbox','String','Add time lables','FontWeight','bold',...
    'FontSize',10,'Value',0,'Position',[15 225 150 23],'callback',{@checkTime_Callback});
             uicontrol(hbgTimeText,'Style','text','String','Num. of lables:','FontSize',9,'Position',[10,193,85,25]);
heditNLable    = uicontrol(hbgTimeText,'Style','edit','Position',[98,195,50,25],'FontWeight','bold','FontSize',10,'String','4','Enable','off','callback',{@editNLable_Callback});
             uicontrol(hbgTimeText,'Style','text','String','Font Size:','FontSize',9,'Position',[10,163,85,25]);
heditFsize    = uicontrol(hbgTimeText,'Style','edit','Position',[98,165,50,25],'FontWeight','bold','FontSize',10,'String','8','Enable','off','callback',{@editFsize_Callback});
             uicontrol(hbgTimeText,'Style','text','String','Color:','FontSize',9,'Position',[10,133,65,25]);
hpopColor = uicontrol(hbgTimeText,'Style','pop','Units','pixels','FontSize',10,'Position',[70,135,80,25],'String',textColor,'Enable','off','callback',{@popColor_Callback});
hcheckBorder = uicontrol(hbgTimeText,'Style','checkbox','String','Border and Background','FontSize',9,'Value',0,'Position',[10 107 150 23],'callback',{@checkColor_Callback});
             uicontrol(hbgTimeText,'Style','text','String','Change location of labels','FontWeight','bold','FontSize',9.2,'Position',[3,70,163,25]);
             uicontrol(hbgTimeText,'Style','text','String','Label:','FontSize',10,'Position',[4,43,65,25]);
hpopLable = uicontrol(hbgTimeText,'Style','pop','Units','pixels','FontSize',10,...
    'Position',[60,45,100,25],'String','no selection','Enable','off');
hbuttonLable = uicontrol(hbgTimeText,'Style','pushbutton','String','Change','Enable','off',...
    'FontWeight','bold','FontSize',12,'Position',[30,10,100,25],'callback',{@change_Callback});
htextRank    = uicontrol(f,'Style','text','String','Relative rank of the first frame:',...
    'FontWeight','bold','FontSize',9,'Position',[750,30,100,50]);
heditRank    = uicontrol(f,'Style','edit','Position',[850,50,60,30],'FontWeight','bold','FontSize',12,...
    'String','1','Callback',@rank_Callback );
haxis        = axes(f,'box','off','xtick',[],'ytick',[],'ztick',[],'xcolor',[1 1 1],'ycolor',[1 1 1],'Units','pixels',...
    'Position',[28,66,700,540],'color','white','PlotBoxAspectRatio',[1 1 1]);

expframerank=1; YworldPr=cell(Nfires,numframes);
for k=1:Nfires
    for i=1:fireLastFrame(1,k)
        YworldPr{k,i}=Yworld{k,i}*-1;
    end
end
YcornersWorldPr=YcornersWorld*-1;
hold on
for k=1:Nfires
    for i=1:fireLastFrame(1,k)
        line(Xworld{k,i},(YworldPr{k,i}),'Color',plotcolors(i+(expframerank-1),:),'linestyle',linestyles{i+(expframerank-1),1},'LineWidth',1)
    end
end
if shape~=4
    for i=1:cornersnum
        line([XcornersWorld(i,1),XcornersWorld(i+1,1)],([YcornersWorldPr(i,1),YcornersWorldPr(i+1,1)]),'Color','k','LineWidth',2)
    end
end
hold off
axis equal

if man_mod==0
    hBfill.Enable='on';
end

map_style=1; lable=0; fontSize=10; Nlables=4;

if shape~=4
    mapframe=1;
else
    mapframe=2;
end

f.Name = 'Propagation Map';
movegui(f,'center')
f.MenuBar = 'none';
f.ToolBar = 'none';
f.NumberTitle='off';


warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jframe=get(f,'javaframe');
jIcon=javax.swing.ImageIcon(fullfile(appPath,'icon ROS.gif'));
jframe.setFigureIcon(jIcon);
f.Visible = 'on';

%smoothing fire frontline
smoothX=cell(Nfires,numframes);
smoothY=cell(Nfires,numframes);
for k=1:Nfires
    for i=1:fireLastFrame(1,k)
        smoothX{k,i} = sgolayfilt(Xworld{k,i}, 2, 45);
        smoothY{k,i} = sgolayfilt(YworldPr{k,i}, 2, 45);
    end
end
smooth=0;
%% interactive controls of the map
    function name_Callback(source,event)
        global mapname
        mapname=get(heditName ,'String');
        hbuttonSave.Enable='on';
    end
    function rank_Callback(source,event)
        expframerank=str2double(get(heditRank ,'String'));
        updateplot
    end
    function selectionFrame(source,event)
        selection=event.NewValue.String;
        if strcmp(selection,'On')
            mapframe=1;
            updateplot
        else
            mapframe=2;
            updateplot
        end
    end

    function selectionStyle(source,event)
        selection=event.NewValue.String;
        if strcmp(selection,'Colored and Dashed')
            map_style=1;
            updateplot
        elseif strcmp(selection,'Colored and Solid')
            map_style=2;
            updateplot
        elseif strcmp(selection,'B&W and Dashed')
            map_style=3;
            updateplot
        elseif strcmp(selection,'B&W and Solid')
            map_style=4;
            updateplot
        elseif strcmp(selection,'Colored filling')
            map_style=5;
            updateplot
        end
    end
    function checkTime_Callback(source,event)
        global Spos Stime
        lable=get(hcheckTime,'value');
        if lable==1
            heditFsize.Enable='on'; heditNLable.Enable='on'; hpopLable.Enable='on'; hbuttonLable.Enable='on';
            hpopColor.Enable='on'; hcheckBorder.Enable='on';
            Spos=zeros(Nlables,2); Stime=cell(Nlables,1);
            for i=1:Nlables
                Sframe=i*floor(numframes/(Nlables+1));
                Sorder=randi([1,size(Xworld{1,Sframe},1)]);
                Spos(i,1)=Xworld{1,Sframe}(Sorder,1); Spos(i,2)=YworldPr{1,Sframe}(Sorder,1);
                Stime{i,1}=[num2str(time(1,Sframe+1)+((expframerank-1)*time(1,1))),'s'];
            end
            hpopLable.String=Stime; hpopLable.Value=1;
        else
            heditFsize.Enable='off'; heditNLable.Enable='off'; hpopLable.Enable='off'; hbuttonLable.Enable='off';
            hpopColor.Enable='off'; hcheckBorder.Enable='off';
        end
        updateplot
    end
    function checkSmooth_Callback(source,event)
        smooth=get(hcheckSmooth,'value');
        updateplot
    end
    function popSmoothDegree_Callback(source,event)
        smoothDegree=get(hpopSmoothDegree,'value');
        if smoothDegree==1
            for k=1:Nfires
                for i=1:fireLastFrame(1,k)
                    smoothX{k,i} = sgolayfilt(Xworld{k,i}, 5, 45);
                    smoothY{k,i} = sgolayfilt(YworldPr{k,i}, 5, 45);
                end
            end
        elseif smoothDegree==2
            for k=1:Nfires
                for i=1:fireLastFrame(1,k)
                    smoothX{k,i} = sgolayfilt(Xworld{k,i}, 5, 87);
                    smoothY{k,i} = sgolayfilt(YworldPr{k,i}, 5, 87);
                end
            end
        else
            for k=1:Nfires
                for i=1:fireLastFrame(1,k)
                    smoothX{k,i} = sgolayfilt(Xworld{k,i}, 5, 167);
                    smoothY{k,i} = sgolayfilt(YworldPr{k,i}, 5, 167);
                end
            end
        end
        updateplot
    end
    function checkColor_Callback(source,event)
        updateplot
    end
    function popColor_Callback(source,event)
        updateplot
    end
    function change_Callback(source,event)
        global Spos
        Labselection=get(hpopLable,'Value');
        Sframe=Labselection*floor(numframes/(Nlables+1));
        line(haxis,Xworld{1,Sframe},(YworldPr{1,Sframe}),'Color','r','LineWidth',2)
        [Spos(Labselection,1),Spos(Labselection,2)] = ginput(1);
        updateplot
    end
    function editFsize_Callback(source,event)
        fontSize=str2double(get(heditFsize,'String'));
        updateplot
    end
    function editNLable_Callback(source,event)
        global Spos Stime
        Nlables=str2double(get(heditNLable,'String'));
        for i=1:Nlables
            Sframe=i*floor(numframes/(Nlables+1));
            Sorder=randi([1,size(Xworld{1,Sframe},1)]);
            Spos(i,1)=Xworld{1,Sframe}(Sorder,1); Spos(i,2)=YworldPr{1,Sframe}(Sorder,1);
            Stime{i,1}=[num2str(time(1,Sframe+1)+((expframerank-1)*time(1,1))),'s'];
        end
        hpopLable.String=Stime; hpopLable.Value=1;
        updateplot
    end
    function updateplot
        global Spos Stime
        colorSelc=get(hpopColor,'Value'); Bord=get(hcheckBorder,'Value');
        cla reset
        haxis.Box='off';haxis.XTick=[];haxis.YTick=[];haxis.ZTick=[];haxis.XColor=[1 1 1];haxis.YColor=[1 1 1];
        axis equal
        hold on
        if smooth==0 %if smoothing is OFF
            if map_style==1
                for k=1:Nfires
                    for i=1:fireLastFrame(1,k)
                        line(haxis,Xworld{k,i},(YworldPr{k,i}),'Color',plotcolors(i+(expframerank-1),:),'linestyle',linestyles{i+(expframerank-1),1},'LineWidth',1)
                    end
                end
            elseif map_style==2
                for k=1:Nfires
                    for i=1:fireLastFrame(1,k)
                        line(haxis,Xworld{k,i},(YworldPr{k,i}),'Color',plotcolors(i+(expframerank-1),:),'LineWidth',1)
                    end
                end
            elseif map_style==3
                for k=1:Nfires
                    for i=1:fireLastFrame(1,k)
                        line(haxis,Xworld{k,i},(YworldPr{k,i}),'Color','k','linestyle',linestyles{i+(expframerank-1),1},'LineWidth',1)
                    end
                end
            elseif map_style==4
                for k=1:Nfires
                    for i=1:fireLastFrame(1,k)
                        line(haxis,Xworld{k,i},(YworldPr{k,i}),'Color','k','LineWidth',1)
                    end
                end
            else
                for k=1:Nfires
                    for i=[fireLastFrame(1,k):-1:1]
                        fill(Xworld{k,i},YworldPr{k,i},plotcolors(i+(expframerank-1),:))
                    end
                end
            end
            
            if mapframe==1
                for i=1:cornersnum
                    line(haxis,[XcornersWorld(i,1),XcornersWorld(i+1,1)],([YcornersWorldPr(i,1),YcornersWorldPr(i+1,1)]),'Color','k','LineWidth',2)
                end
            end
            
            if lable==1
                if Bord==1
                    for i=1:Nlables
                        text(Spos(i,1),Spos(i,2),Stime{i,1},'FontSize',fontSize,'Color',textColor{colorSelc,1},'BackgroundColor','w','EdgeColor','k')
                    end
                else
                    for i=1:Nlables
                        text(Spos(i,1),Spos(i,2),Stime{i,1},'FontSize',fontSize,'Color',textColor{colorSelc,1})
                    end
                end
            end
        else %if smoothing is ON
            if map_style==1
                for k=1:Nfires
                    for i=1:fireLastFrame(1,k)
                        line(haxis,smoothX{k,i},(smoothY{k,i}),'Color',plotcolors(i+(expframerank-1),:),'linestyle',linestyles{i+(expframerank-1),1},'LineWidth',1)
                    end
                end
            elseif map_style==2
                for k=1:Nfires
                    for i=1:fireLastFrame(1,k)
                        line(haxis,smoothX{k,i},(smoothY{k,i}),'Color',plotcolors(i+(expframerank-1),:),'LineWidth',1)
                    end
                end
            elseif map_style==3
                for k=1:Nfires
                    for i=1:fireLastFrame(1,k)
                        line(haxis,smoothX{k,i},(smoothY{k,i}),'Color','k','linestyle',linestyles{i+(expframerank-1),1},'LineWidth',1)
                    end
                end
            elseif map_style==4
                for k=1:Nfires
                    for i=1:fireLastFrame(1,k)
                        line(haxis,smoothX{k,i},(smoothY{k,i}),'Color','k','LineWidth',1)
                    end
                end
            else
                for k=1:Nfires
                    for i=[fireLastFrame(1,k):-1:1]
                        fill(smoothX{k,i},smoothY{k,i},plotcolors(i+(expframerank-1),:))
                    end
                end
            end
            
            if mapframe==1
                for i=1:cornersnum
                    line(haxis,[XcornersWorld(i,1),XcornersWorld(i+1,1)],([YcornersWorldPr(i,1),YcornersWorldPr(i+1,1)]),'Color','k','LineWidth',2)
                end
            end
            
            if lable==1
                if Bord==1
                    for i=1:Nlables
                        text(Spos(i,1),Spos(i,2),Stime{i,1},'FontSize',fontSize,'Color',textColor{colorSelc,1},'BackgroundColor','w','EdgeColor','k')
                    end
                else
                    for i=1:Nlables
                        text(Spos(i,1),Spos(i,2),Stime{i,1},'FontSize',fontSize,'Color',textColor{colorSelc,1})
                    end
                end
            end
        end
        hold off
    end

    function save_Callback(source,event)
        set(f, 'pointer', 'watch');drawnow;
        global mapname Spos Stime
        Bord=get(hcheckBorder,'Value'); colorSelc=get(hpopColor,'Value');
        hf2=figure('Visible','off','Position',[28,66,700,540]); haxesf=axes(hf2);
        haxesf.Box='off';haxesf.XTick=[];haxesf.YTick=[];haxesf.ZTick=[];haxesf.XColor='none';haxesf.YColor='none';
        hold on
        if smooth==0 %if smoothing is OFF
            if map_style==1
                for k=1:Nfires
                    for i=1:fireLastFrame(1,k)
                        line(haxesf,Xworld{k,i},(YworldPr{k,i}),'Color',plotcolors(i+(expframerank-1),:),'linestyle',linestyles{i+(expframerank-1),1},'LineWidth',1)
                    end
                end
            elseif map_style==2
                for k=1:Nfires
                    for i=1:fireLastFrame(1,k)
                        line(haxesf,Xworld{k,i},(YworldPr{k,i}),'Color',plotcolors(i+(expframerank-1),:),'LineWidth',1)
                    end
                end
            elseif map_style==3
                for k=1:Nfires
                    for i=1:fireLastFrame(1,k)
                        line(haxesf,Xworld{k,i},(YworldPr{k,i}),'Color','k','linestyle',linestyles{i+(expframerank-1),1},'LineWidth',1)
                    end
                end
            elseif map_style==4
                for k=1:Nfires
                    for i=1:fireLastFrame(1,k)
                        line(haxesf,Xworld{k,i},(YworldPr{k,i}),'Color','k','LineWidth',1)
                    end
                end
            else
                for k=1:Nfires
                    for i=[fireLastFrame(1,k):-1:1]
                        fill(Xworld{k,i},YworldPr{k,i},plotcolors(i+(expframerank-1),:))
                    end
                end
            end
            
            if mapframe==1
                for i=1:cornersnum
                    line(haxesf,[XcornersWorld(i,1),XcornersWorld(i+1,1)],([YcornersWorldPr(i,1),YcornersWorldPr(i+1,1)]),'Color','k','LineWidth',2)
                end
            end
            
            if lable==1
                if Bord==1
                    for i=1:Nlables
                        text(Spos(i,1),Spos(i,2),Stime{i,1},'FontSize',fontSize,'Color',textColor{colorSelc,1},'BackgroundColor','w','EdgeColor','k')
                    end
                else
                    for i=1:Nlables
                        text(Spos(i,1),Spos(i,2),Stime{i,1},'FontSize',fontSize,'Color',textColor{colorSelc,1})
                    end
                end
            end
        else %if smoothing is ON
            if map_style==1
                for k=1:Nfires
                    for i=1:fireLastFrame(1,k)
                        line(haxesf,smoothX{k,i},(smoothY{k,i}),'Color',plotcolors(i+(expframerank-1),:),'linestyle',linestyles{i+(expframerank-1),1},'LineWidth',1)
                    end
                end
            elseif map_style==2
                for k=1:Nfires
                    for i=1:fireLastFrame(1,k)
                        line(haxesf,smoothX{k,i},(smoothY{k,i}),'Color',plotcolors(i+(expframerank-1),:),'LineWidth',1)
                    end
                end
            elseif map_style==3
                for k=1:Nfires
                    for i=1:fireLastFrame(1,k)
                        line(haxesf,smoothX{k,i},(smoothY{k,i}),'Color','k','linestyle',linestyles{i+(expframerank-1),1},'LineWidth',1)
                    end
                end
            elseif map_style==4
                for k=1:Nfires
                    for i=1:fireLastFrame(1,k)
                        line(haxesf,smoothX{k,i},(smoothY{k,i}),'Color','k','LineWidth',1)
                    end
                end
            else
                for k=1:Nfires
                    for i=[fireLastFrame(1,k):-1:1]
                        fill(smoothX{k,i},smoothY{k,i},plotcolors(i+(expframerank-1),:))
                    end
                end
            end
            
            if mapframe==1
                for z=1:cornersnum
                    line(haxesf,[XcornersWorld(z,1),XcornersWorld(z+1,1)],([YcornersWorldPr(z,1),YcornersWorldPr(z+1,1)]),'Color','k','LineWidth',2)
                end
            end
            
            if lable==1
                if Bord==1
                    for i=1:Nlables
                        text(Spos(i,1),Spos(i,2),Stime{i,1},'FontSize',fontSize,'Color',textColor{colorSelc,1},'BackgroundColor','w','EdgeColor','k')
                    end
                else
                    for i=1:Nlables
                        text(Spos(i,1),Spos(i,2),Stime{i,1},'FontSize',fontSize,'Color',textColor{colorSelc,1})
                    end
                end
            end
        end
        hold off
        axis equal
        figg=gcf;
        print(figg,[resultsfolder,'/',mapname],'-dpng','-r600')
        %saveas(gcf,[resultsfolder,'/',mapname],'jpeg')
        set(f, 'pointer', 'arrow');drawnow;
    end
end