function build_prop_map
global Xworld Yworld numframes shape XcornersWorld YcornersWorld cornersnum resultsfolder plotcolors linestyles time man_mod
global R t cameraParams ffpoints fflineeq loudstatuse workpathname work X Y Xcorners Ycorners appPath
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
hbgStyle     = uibuttongroup(f,'Units','pixels','Title','Lines Style','FontSize',9,'Position',[750 460 167 150],'SelectionChangedFcn',@selectionStyle);
hCdashed      = uicontrol(hbgStyle,'Style','radiobutton','String','Colored and Dashed','Position',[13 105 140 25],'FontSize',9);
hCsolid       = uicontrol(hbgStyle,'Style','radiobutton','String','Colored and Solid','Position',[13 80 140 25],'FontSize',9);
hBdashed      = uicontrol(hbgStyle,'Style','radiobutton','String','B&W and Dashed','Position',[13 55 140 25],'FontSize',9);
hBsolid       = uicontrol(hbgStyle,'Style','radiobutton','String','B&W and Solid','Position',[13 30 140 25],'FontSize',9);
hBfill       = uicontrol(hbgStyle,'Style','radiobutton','String','Colored filling','Position',[13 5 140 25],'FontSize',9);
hbgFrame     = uibuttongroup(f,'Units','pixels','Title','Fule Bed Frames','FontSize',9,'Position',[750 376 120 70],'SelectionChangedFcn',@selectionFrame);
hOn          = uicontrol(hbgFrame,'Style','radiobutton','String','On','Position',[13 30 40 25],'FontSize',9);
hOff          = uicontrol(hbgFrame,'Style','radiobutton','String','Off','Position',[13 5 40 25],'FontSize',9);
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

expframerank=1; YworldPr=cell(1,numframes);
for i=1:numframes
    YworldPr{i}=Yworld{i}*-1;
end
YcornersWorldPr=YcornersWorld*-1;
hold on
for i=1:numframes
    line(Xworld{i},(YworldPr{i}),'Color',plotcolors(i+(expframerank-1),:),'linestyle',linestyles{i+(expframerank-1),1},'LineWidth',1)
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
f.Visible = 'on';

warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jframe=get(f,'javaframe');
jIcon=javax.swing.ImageIcon(fullfile(appPath,'icon ROS.gif'));
jframe.setFigureIcon(jIcon);
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
                Sorder=randi([1,size(Xworld{Sframe},1)]);
                Spos(i,1)=Xworld{Sframe}(Sorder,1); Spos(i,2)=YworldPr{Sframe}(Sorder,1);
                Stime{i,1}=[num2str(time(1,Sframe+1)+((expframerank-1)*time(1,1))),'s'];
            end
            hpopLable.String=Stime; hpopLable.Value=1;
        else
            heditFsize.Enable='off'; heditNLable.Enable='off'; hpopLable.Enable='off'; hbuttonLable.Enable='off';
            hpopColor.Enable='off'; hcheckBorder.Enable='off';
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
        line(haxis,Xworld{Sframe},(YworldPr{Sframe}),'Color','r','LineWidth',2)
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
            Sorder=randi([1,size(Xworld{Sframe},1)]);
            Spos(i,1)=Xworld{Sframe}(Sorder,1); Spos(i,2)=YworldPr{Sframe}(Sorder,1);
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
        if map_style==1
            for i=1:numframes
                line(haxis,Xworld{i},(YworldPr{i}),'Color',plotcolors(i+(expframerank-1),:),'linestyle',linestyles{i+(expframerank-1),1},'LineWidth',1)
            end
        elseif map_style==2
            for i=1:numframes
                line(haxis,Xworld{i},(YworldPr{i}),'Color',plotcolors(i+(expframerank-1),:),'LineWidth',1)
            end
        elseif map_style==3
            for i=1:numframes
                line(haxis,Xworld{i},(YworldPr{i}),'Color','k','linestyle',linestyles{i+(expframerank-1),1},'LineWidth',1)
            end
        elseif map_style==4
            for i=1:numframes
                line(haxis,Xworld{i},(YworldPr{i}),'Color','k','LineWidth',1)
            end
        else
            for i=[numframes:-1:1]
                fill(Xworld{i},YworldPr{i},plotcolors(i+(expframerank-1),:)) 
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
        hold off
    end

    function save_Callback(source,event)
        set(f, 'pointer', 'watch');drawnow;
        global mapname Spos Stime
        Bord=get(hcheckBorder,'Value'); colorSelc=get(hpopColor,'Value');
        hf2=figure('Visible','off','Position',[28,66,700,540]); haxesf=axes(hf2);
        haxesf.Box='off';haxesf.XTick=[];haxesf.YTick=[];haxesf.ZTick=[];haxesf.XColor=[1 1 1];haxesf.YColor=[1 1 1];
        title('Fire Front Propagation Map');
        hold on
        if map_style==1
            for i=1:numframes
                line(Xworld{i},(YworldPr{i}),'Color',plotcolors(i+(expframerank-1),:),'linestyle',linestyles{i+(expframerank-1),1},'LineWidth',1)
            end
        elseif map_style==2
            for i=1:numframes
                line(Xworld{i},(YworldPr{i}),'Color',plotcolors(i+(expframerank-1),:),'LineWidth',1)
            end
        elseif map_style==3
            for i=1:numframes
                line(Xworld{i},(YworldPr{i}),'Color','k','linestyle',linestyles{i+(expframerank-1),1},'LineWidth',1)
            end
        elseif map_style==4
            for i=1:numframes
                line(Xworld{i},(YworldPr{i}),'Color','k','LineWidth',1)
            end
        else
            for i=[numframes:-1:1]
                fill(Xworld{i},YworldPr{i},plotcolors(i+(expframerank-1),:)) 
            end
        end
        
        if mapframe==1 && shape~=4
            for i=1:cornersnum
                line([XcornersWorld(i,1),XcornersWorld(i+1,1)],([YcornersWorldPr(i,1),YcornersWorldPr(i+1,1)]),'Color','k','LineWidth',2)
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
        hold off
        axis equal
        figg=gcf;
        print(figg,[resultsfolder,'/',mapname],'-dpng','-r600')
        %saveas(gcf,[resultsfolder,'/',mapname],'jpeg')
        set(f, 'pointer', 'arrow');drawnow;
    end
end