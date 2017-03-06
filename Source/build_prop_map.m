function build_prop_map
global Xworld Yworld numframes shape XcornersWorld YcornersWorld cornersnum resultsfolder plotcolors linestyles time
global R t cameraParams ffpoints fflineeq loudstatuse workpathname work X Y Xcorners Ycorners
if loudstatuse==1
    load([workpathname,work])
end
load plotcolorsmat.mat
%% building the GUI
f = figure('Visible','off','Position',[680,200,735,420]);
htextTitle  = uicontrol('Style','text','String','The Propagation of the fire front',...
    'FontWeight','bold','FontSize',12,'Position',[50,415,450,22]);
htextName    = uicontrol('Style','text','String','Map name:',...
    'FontWeight','bold','FontSize',11,'Position',[100,25,80,20]);
heditName    = uicontrol('Style','edit','Position',[185,20,150,30],'FontWeight','bold','FontSize',12,...
    'Enable','on','Callback',@name_Callback );
hbuttonSave  = uicontrol('Style','pushbutton','String','Save','Enable','off',...
    'FontWeight','bold','FontSize',12,'Position',[400,15,100,40],'callback',{@save_Callback});
hbgStyle     = uibuttongroup('Units','pixels','Title','Lines Style','FontSize',9,'Position',[550 260 167 120],'SelectionChangedFcn',@selectionStyle);
hCdashed      = uicontrol(hbgStyle,'Style','radiobutton','String','Colored and Dashed','Position',[13 80 140 25],'FontSize',9);
hCsolid       = uicontrol(hbgStyle,'Style','radiobutton','String','Colored and Solid','Position',[13 55 140 25],'FontSize',9);
hBdashed      = uicontrol(hbgStyle,'Style','radiobutton','String','B&W and Dashed','Position',[13 30 140 25],'FontSize',9);
hBsolid       = uicontrol(hbgStyle,'Style','radiobutton','String','B&W and Solid','Position',[13 5 140 25],'FontSize',9);
hbgFrame     = uibuttongroup('Units','pixels','Title','Fule Bed Frames','FontSize',9,'Position',[550 176 120 70],'SelectionChangedFcn',@selectionFrame);
hOn          = uicontrol(hbgFrame,'Style','radiobutton','String','On','Position',[13 30 40 25],'FontSize',9);
hOff          = uicontrol(hbgFrame,'Style','radiobutton','String','Off','Position',[13 5 40 25],'FontSize',9);
htextRank    = uicontrol('Style','text','String','First frame rank relativly to the whole test:',...
    'FontWeight','bold','FontSize',9,'Position',[550,100,100,50]);
heditRank    = uicontrol('Style','edit','Position',[650,110,60,30],'FontWeight','bold','FontSize',12,...
    'String','1','Callback',@rank_Callback );
haxis        = axes('box','off','xtick',[],'ytick',[],'ztick',[],'xcolor',[1 1 1],'ycolor',[1 1 1],'Units','pixels',...
    'Position',[28,66,500,340],'color','white','PlotBoxAspectRatio',[1 1 1]);

expframerank=1;
YworldPr=Yworld*-1;
YcornersWorldPr=YcornersWorld*-1;
hold on
for i=1:numframes
    line(Xworld(:,i),(YworldPr(:,i)),'Color',plotcolors(i+(expframerank-1),:),'linestyle',linestyles{i+(expframerank-1),1},'LineWidth',1)
end
if shape~=4
    for i=1:cornersnum
        line([XcornersWorld(i,1),XcornersWorld(i+1,1)],([YcornersWorldPr(i,1),YcornersWorldPr(i+1,1)]),'Color','b','LineWidth',2)
    end
end
hold off
axis equal
f.Name = 'Propagation Map';
movegui(f,'center')
f.MenuBar = 'none';
f.ToolBar = 'none';
f.NumberTitle='off';
f.Visible = 'on';

warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jframe=get(f,'javaframe');
jIcon=javax.swing.ImageIcon('icon ROS.gif');
jframe.setFigureIcon(jIcon);
%% interactive controls of the map
map_style=1;
if shape~=4
mapframe=1;
else mapframe=2;
end

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
        end
    end

    function updateplot
        cla reset
        haxis.Box='off';haxis.XTick=[];haxis.YTick=[];haxis.ZTick=[];haxis.XColor=[1 1 1];haxis.YColor=[1 1 1];
        axis equal
        hold on
        if map_style==1
            for i=1:numframes
                line(haxis,Xworld(:,i),(YworldPr(:,i)),'Color',plotcolors(i+(expframerank-1),:),'linestyle',linestyles{i+(expframerank-1),1},'LineWidth',1)
            end
        elseif map_style==2
            for i=1:numframes
                line(haxis,Xworld(:,i),(YworldPr(:,i)),'Color',plotcolors(i+(expframerank-1),:),'LineWidth',1)
            end
        elseif map_style==3
            for i=1:numframes
                line(haxis,Xworld(:,i),(YworldPr(:,i)),'Color','k','linestyle',linestyles{i+(expframerank-1),1},'LineWidth',1)
            end
        else
            for i=1:numframes
                line(haxis,Xworld(:,i),(YworldPr(:,i)),'Color','k','LineWidth',1)
            end
        end
        
        if mapframe==1 && shape~=4
            for i=1:cornersnum
                line(haxis,[XcornersWorld(i,1),XcornersWorld(i+1,1)],([YcornersWorldPr(i,1),YcornersWorldPr(i+1,1)]),'Color','b','LineWidth',2)
            end
        end
        hold off
    end

    function save_Callback(source,event)
        global mapname
        hf2=figure('Visible','off'); haxesf=axes(hf2);
        haxesf.Box='off';haxesf.XTick=[];haxesf.YTick=[];haxesf.ZTick=[];haxesf.XColor=[1 1 1];haxesf.YColor=[1 1 1];
        title('Fire Front Propagation Map');
        hold on
        if map_style==1
            for i=1:numframes
                line(Xworld(:,i),(YworldPr(:,i)),'Color',plotcolors(i+(expframerank-1),:),'linestyle',linestyles{i+(expframerank-1),1},'LineWidth',1)
            end
        elseif map_style==2
            for i=1:numframes
                line(Xworld(:,i),(YworldPr(:,i)),'Color',plotcolors(i+(expframerank-1),:),'LineWidth',1)
            end
        elseif map_style==3
            for i=1:numframes
                line(Xworld(:,i),(YworldPr(:,i)),'Color','k','linestyle',linestyles{i+(expframerank-1),1},'LineWidth',1)
            end
        else
            for i=1:numframes
                line(Xworld(:,i),(YworldPr(:,i)),'Color','k','LineWidth',1)
            end
        end
        
        if mapframe==1 && shape~=4
            for i=1:cornersnum
                line([XcornersWorld(i,1),XcornersWorld(i+1,1)],([YcornersWorldPr(i,1),YcornersWorldPr(i+1,1)]),'Color','b','LineWidth',2)
            end
        end
        hold off
        axis equal
        saveas(gcf,[resultsfolder,'/',mapname],'jpeg')
    end
end