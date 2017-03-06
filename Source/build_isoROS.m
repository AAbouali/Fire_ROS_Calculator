function build_isoROS
global numframes cornersnum Xworld Yworld XcornersWorld YcornersWorld shape results resultrow resultsfolder time
global R t cameraParams ffpoints fflineeq posline nolines handles levels ROSiso Xiso Yiso ReshapeROSiso linelocalRofS newView
global workpathname work X Y Xcorners Ycorners loudstatuse
if loudstatuse==1
    load([workpathname,work])
end
%% building the GUI
f = figure('Visible','off','Position',[680,195,1000,470]);
%calculate ROS panle (Left)
ROSpanel=uipanel(f,'Units','pixels','Title','Calculate ROS''s','FontSize',9,'Position',[0,0,500,515]);
haxisROS = axes(ROSpanel,'box','off','xtick',[],'ytick',[],'ztick',[],'xcolor',[1 1 1],'ycolor',[1 1 1],'Units','pixels',...
    'Position',[50,120,400,350],'color','white');
c = uicontextmenu;
haxisROS.UIContextMenu = c;
m1 = uimenu(c,'Label','Add Lines','Callback',@drawLines);
htextStart  = uicontrol(ROSpanel,'Style','text','String',sprintf('Calculate ROS throw frames:'),...
    'FontSize',9,'Position',[50,65,90,30]);
heditStart  = uicontrol(ROSpanel,'Style','edit','Position',[145,65,70,30],'FontSize',10,'FontWeight','bold');
htextEnd    = uicontrol(ROSpanel,'Style','text','String','To','FontSize',9,'Position',[215,67,35,20]);
heditEnd    = uicontrol(ROSpanel,'Style','edit','Position',[250,65,70,30],'FontSize',10,'FontWeight','bold','callback',@heditEnd_Callback);
hbuttonAdd  = uicontrol(ROSpanel,'Style','pushbutton','String','Add ROS''s','Enable','off','FontSize',10,'FontWeight','bold',...
    'Position',[335,15,105,35],'callback',{@add_Callback});
hbuttonReset  = uicontrol(ROSpanel,'Style','pushbutton','String','Reset','FontSize',10,'FontWeight','bold',...
    'Position',[215,15,105,35],'callback',{@reset_Callback});
%iso surface panle (Right)
isopanel=uipanel(f,'Units','pixels','Title','Iso Surface','FontSize',9,'Position',[500,0,500,515]);
haxisIso = axes(isopanel,'Units','pixels','Position',[50,155,400,300],'color','white');
hbuttonBuild  = uicontrol(isopanel,'Style','pushbutton','String','Build Iso-Surface','Enable','off','FontSize',10,'FontWeight','bold',...
    'Position',[15,13,125,35],'callback',{@build_Callback});
hcheckFrame = uicontrol(isopanel,'Style','checkbox','String','Show Bed Frame','FontSize',9,...
    'Value',0,'Position',[35 80 125 25],'callback',{@checkFrame_Callback});
hcheckPoints = uicontrol(isopanel,'Style','checkbox','String','Show Points','FontSize',9,...
    'Value',0,'Position',[35 55 125 25],'callback',{@checkPoints_Callback});
hcheckFront = uicontrol(isopanel,'Style','checkbox','String','Show Fire Front','FontSize',9,...
    'Value',0,'Position',[35 105 125 25],'callback',{@checkFront_Callback});
hpopcolor  = uicontrol(isopanel,'Style','pop','Units','pixels','String',{'Jet Colors';'Hot Colors';'Parula Colors'},...
    'value',1,'FontSize',9,'Position',[185,107,110,25],'callback',{@popcolor_Callback});
hpopshading  = uicontrol(isopanel,'Style','pop','Units','pixels','String',{'Interp Shading';'Faceted Shading';'Flat Shading'},...
    'value',1,'FontSize',9,'Position',[185,80,110,25],'callback',{@popshading_Callback});
hcheckLevels = uicontrol(isopanel,'Style','checkbox','String','Levels','FontSize',9,...
    'Value',0,'Position',[187 52 60 25],'callback',{@checkLevels_Callback});
heditLevels  = uicontrol(isopanel,'Style','edit','Position',[245,52,50,25],'String','8','FontSize',9,'FontWeight','bold','Enable','off','callback',{@editLevels_Callback});
viewpanel    =uipanel(isopanel,'Units','pixels','Title','View','FontSize',9,'Position',[325,57,130,75]);
htextAzimuth  = uicontrol(viewpanel,'Style','text','String','Azimuth','FontSize',9,'Position',[13,35,48,17]);
heditAzimuth  = uicontrol(viewpanel,'Style','edit','String','-37.5','Position',[68,32,53,22],'FontSize',9,'FontWeight','bold','callback',{@editAzimuth_Callback});
htextElev    = uicontrol(viewpanel,'Style','text','String','Elevation','FontSize',9,'Position',[6,13,55,17]);
heditElev     = uicontrol(viewpanel,'Style','edit','String','30','Position',[68,9,53,22],'FontSize',9,'FontWeight','bold','callback',{@editElev_Callback});
htextName    = uicontrol(isopanel,'Style','text','String','Saving Name of the Surface','FontSize',9,'FontWeight','bold','Position',[150,13,100,30]);
heditName    = uicontrol(isopanel,'Style','edit','Position',[250,15,125,25],'FontSize',9,'FontWeight','bold','callback',{@editName_Callback});
hbuttonSave  = uicontrol(isopanel,'Style','pushbutton','String','Save','Enable','off','FontSize',10,'FontWeight','bold',...
    'Position',[400,13,85,35],'callback',{@buttonSave_Callback});
hbgTools     = uibuttongroup(isopanel,'Units','pixels','Title','Tools','FontSize',9,'Position',[70 462 350 35],'SelectionChangedFcn',@selectionTools);
hradioPan         = uicontrol(hbgTools  ,'Style','radiobutton','String','Pan','Position',[15 2 100 20],'FontSize',9);
hradioZoom         = uicontrol(hbgTools  ,'Style','radiobutton','String','Zoom','Position',[120 2 100 20],'FontSize',9);
hradioRotate        = uicontrol(hbgTools  ,'Style','radiobutton','String','Rotate','Position',[225 2 100 20],'FontSize',9);

hpan=pan(f);
hzoom=zoom(haxisIso);
hrotate=rotate3d(haxisIso);hrotate.RotateStyle = 'box';
c = uicontextmenu;
haxisROS.UIContextMenu = c;
m1 = uimenu(c,'Label','Add Lines','Callback',@drawLines);

% drawing the propagation map on the axis
hold on
for i=1:numframes
    line(haxisROS,Xworld(:,i),(Yworld(:,i)),'Color','r')
end
if shape~=4
    for i=1:cornersnum
        line(haxisROS,[XcornersWorld(i,1),XcornersWorld(i+1,1)],([YcornersWorld(i,1),YcornersWorld(i+1,1)]),'Color','b','LineWidth',2)
    end
end
f.Name = 'Present Fire ROS as iso-surface';
movegui(f,'center')
f.MenuBar = 'none';
f.ToolBar = 'none';
f.NumberTitle='off';
f.Visible = 'on';

warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jframe=get(f,'javaframe');
jIcon=javax.swing.ImageIcon('icon ROS.gif');
jframe.setFigureIcon(jIcon);

colorSelection=1;
shadingSelection=1;
levels=8;
hpoints=[];
Xiso=[];Yiso=[];ROSiso=[];
%% interactive controls for calculating ROS panel
% getting the postion of the line
    function drawLines(source,callbackdata)
        global fig
        switch source.Label
            case 'Add Lines'
                lines_number
                waitfor(fig)
                handles.line = cell(nolines);
                for k=1:nolines
                    handles.line{k} = imline(haxisROS);
                end
        end
    end
    function heditEnd_Callback(src,event)
        hbuttonAdd.Enable='on';
    end
% calculating the ROS and saving the result
    function add_Callback(src,event)
        set(f, 'pointer', 'watch')
        drawnow;
        posline=cell(1,nolines);
        for i=1:nolines
            posline{1,i} = getPosition(handles.line{i});
        end
        Fframe=str2double(get(heditStart,'String'));
        Lframe=str2double(get(heditEnd,'String'));
        totframes=Lframe-Fframe+1;
        %detectingt the intersection between this line and the fire fronts
        linetime(1,2:totframes)=time(1,(Fframe:(Lframe-1)));
        linetime(1,1)=0;%consider the first frame as the 0 refrance 
        if Fframe>1
            linetime(1,2:totframes)=linetime(1,2:totframes)-time(1,Fframe-1);
        end
        Dist=zeros(nolines,totframes);
        Distadd=zeros(nolines,totframes);
        linelocalRofS=zeros(nolines,totframes-1);
        lineROfS=zeros(2,nolines);
        line_x_intersect=zeros(nolines,totframes);
        line_y_intersect=zeros(nolines,totframes);
        %finding the intersection between the prescribed lines and the fire
        %front lines to calculate the passed distances 
        for j=1:nolines
        p1= worldToPoints(cameraParams, R, t, [posline{1,j}(1,1),posline{1,j}(1,2)]);
        p2= worldToPoints(cameraParams, R, t, [posline{1,j}(2,1),posline{1,j}(2,2)]);
            eqline=polyfit([posline{1,j}(1,1) posline{1,j}(2,1)],[posline{1,j}(1,2) posline{1,j}(2,2)],1);
            for i=Fframe:Lframe
                for k=1:ffpoints-1
                    line_x_intersect(j,i-Fframe+1) = fzero(@(x) polyval(eqline-fflineeq(k,[(2*i-1),2*i]),x),0);
                    line_y_intersect(j,i-Fframe+1) = polyval(fflineeq(k,[(2*i-1),2*i]),line_x_intersect(j,i-Fframe+1));
                    if ((( line_x_intersect(1,i-Fframe+1)>=Xworld(k,i) && line_x_intersect(j,i-Fframe+1)<=Xworld(k+1,i) && line_y_intersect(j,i-Fframe+1)>=Yworld(k,i) && line_y_intersect(j,i-Fframe+1)<=Yworld(k+1,i))||...
                            (line_x_intersect(j,i-Fframe+1)<=Xworld(k,i) && line_x_intersect(j,i-Fframe+1)>=Xworld(k+1,i) && line_y_intersect(j,i-Fframe+1)<=Yworld(k,i) && line_y_intersect(j,i-Fframe+1)>=Yworld(k+1,i))||...
                            (line_x_intersect(j,i-Fframe+1)<=Xworld(k,i) && line_x_intersect(j,i-Fframe+1)>=Xworld(k+1,i) && line_y_intersect(j,i-Fframe+1)>=Yworld(k,i) && line_y_intersect(j,i-Fframe+1)<=Yworld(k+1,i))||...
                            (line_x_intersect(j,i-Fframe+1)>=Xworld(k,i) && line_x_intersect(j,i-Fframe+1)<=Xworld(k+1,i) && line_y_intersect(j,i-Fframe+1)<=Yworld(k,i) && line_y_intersect(j,i-Fframe+1)>=Yworld(k+1,i))))&&...
                            ((line_x_intersect(j,i-Fframe+1)>=posline{1,j}(1,1) && line_x_intersect(j,i-Fframe+1)<=posline{1,j}(2,1))||(line_x_intersect(j,i-Fframe+1)<=posline{1,j}(1,1) && line_x_intersect(j,i-Fframe+1)>=posline{1,j}(2,1)))
                        
                        break
                    end
                end
            end
            %calculating the distance and RofS
            for i=1:totframes-1
                Dist(j,i+1) = ((line_x_intersect(j,i) - line_x_intersect(j,(i+1))) ^ 2 + (line_y_intersect(j,i) - line_y_intersect(j,(i+1))) ^ 2) ^ 0.5;
            end
            Dist(j,1)=0; %consider the first frame as the 0 refrance 
            Distadd(j,1)=Dist(j,1);
            for i=2:totframes
                Distadd(j,i)=Distadd(j,i-1)+Dist(j,i);
            end
            for i=1:totframes-1
                linelocalRofS(j,i)=(Distadd(j,i+1)-Distadd(j,i))/(linetime(1,i+1)-linetime(1,i));
            end
        end
        %reshaping the matrises of the intersection between the line and
        %the fire fornt and the dynamic ROS to prepare them for plotting
        %the iso surface
        LastIsoRow=size(Xiso,1);
        ReshapeXiso=zeros(1,size(line_x_intersect,2)-1);
        ReshapeYiso=zeros(1,size(line_y_intersect,2)-1);
        for j=1:nolines
            for i=1:(size(line_x_intersect,2)-1)
                ReshapeXiso(j,i)=(line_x_intersect(j,i)+line_x_intersect(j,i+1))/2; %the location of the ROS will be in the middle between the two points
            end
        end
        ReshapeXiso=reshape(ReshapeXiso,[numel(ReshapeXiso),1]);
        Xiso(LastIsoRow+1:LastIsoRow+size(ReshapeXiso,1),1)=ReshapeXiso;
        for j=1:nolines
            for i=1:(size(line_y_intersect,2)-1)
                ReshapeYiso(j,i)=(line_y_intersect(j,i)+line_y_intersect(j,i+1))/2;
            end
        end
        ReshapeYiso=reshape(ReshapeYiso,[numel(ReshapeYiso),1]);
        Yiso(LastIsoRow+1:LastIsoRow+size(ReshapeYiso,1),1)=ReshapeYiso;
        ReshapeROSiso=reshape(linelocalRofS,[numel(linelocalRofS),1]);
        ROSiso((LastIsoRow+1):LastIsoRow+size(ReshapeROSiso,1),1)=ReshapeROSiso;
        hbuttonBuild.Enable='on';
        set(f, 'pointer', 'arrow')
    end

    function reset_Callback(src,event)
        Xiso=[];Yiso=[];ROSiso=[];
        hbuttonBuild.Enable='off';heditLevels.Enable='off';
        hpopcolor.Value=1;hpopshading.Value=1;hcheckFrame.Value=0;
        hcheckFront.Value=0;hcheckPoints.Value=0;hcheckLevels.Value=0;
        cla(haxisROS)
        cla(haxisIso)
        hpan.Enable = 'off';hzoom.Enable = 'off';hrotate.Enable = 'off';
        heditAzimuth.String='-37.5';heditElev.String='30';
        hold on
        for i=1:numframes
            line(haxisROS,Xworld(:,i),(Yworld(:,i)),'Color','r')
        end
        if shape~=4
            for i=1:cornersnum
                line(haxisROS,[XcornersWorld(i,1),XcornersWorld(i+1,1)],([YcornersWorld(i,1),YcornersWorld(i+1,1)]),'Color','b','LineWidth',2)
            end
        end
        c = uicontextmenu;
        haxisROS.UIContextMenu = c;
        m1 = uimenu(c,'Label','Add Lines','Callback',@drawLines);
    end

%% interactive controls for iso surface panel

    function build_Callback(src,event)
        % Build the iso-surface form the ROS values and their locations X,Y
        F = scatteredInterpolant(Xiso,Yiso,ROSiso);
        tix = min(Xworld(:)):10:max(Xworld(:));
        tiy = min(Yworld(:)):10:max(Yworld(:));
        [xq,yq] = meshgrid(tix,tiy);
        vq = F(xq,yq);
        surf(haxisIso,xq,yq,vq);
        hold on
        zlim([0 (max(ROSiso(:))+0.1*max(ROSiso(:)))])
        colormap jet
        shading(haxisIso,'interp')
        currentView=[str2double(get(heditAzimuth,'String')),str2double(get(heditElev,'String'))];
        view(haxisIso,currentView);
        hpan.Enable = 'on';
    end

    function selectionTools(src,event)
        selection=event.NewValue.String;
        if strcmp(selection,'Pan')
            hzoom.Enable = 'off';
            hrotate.Enable = 'off';
            hpan.Enable = 'on';
        elseif strcmp(selection,'Zoom')
            hrotate.Enable = 'off';
            hpan.Enable = 'off';
            hzoom.Enable = 'on';
        else
            hpan.Enable = 'off';
            hzoom.Enable = 'off';
            hrotate.Enable = 'on';
            setAllowAxesRotate(hrotate,haxisROS,false);
            hrotate.ActionPostCallback = @rotate_callback;
        end
    end
    function rotate_callback(obj,event_obj)
        [newaz,newel] = view(haxisIso);
        set(heditAzimuth,'String',num2str(newaz));
        set(heditElev,'String',num2str(newel));
    end
        
    function checkFrame_Callback(src,event)
        Status = get(hcheckFrame, 'Value');
        if Status==1;
            handles.frameLines = zeros(cornersnum,1);
            hold on
            if shape~=4
                for i=1:cornersnum
                    handles.frameLines(i)=line(haxisIso,[XcornersWorld(i,1),XcornersWorld(i+1,1)],([YcornersWorld(i,1),YcornersWorld(i+1,1)]),'Color','b','LineWidth',2);
                end
            end
        else
            for i=1:cornersnum
                delete(handles.frameLines(i))
            end
        end
    end

    function checkFront_Callback(src,event)
        Zworld(1:size(Xworld,1),1:size(Xworld,2))=(max(ROSiso(:))+0.099*max(ROSiso(:)));
        Status = get(hcheckFront, 'Value');
        if Status==1;
            hold on
            for i=1:numframes
                line(haxisIso,Xworld(:,i),Yworld(:,i),Zworld(:,i),'Color',[0 0 0]);
            end
        else
             cla(haxisIso)
             build_Callback
        end
    end

    function checkPoints_Callback(src,event)
        Status = get(hcheckPoints, 'Value');
        if Status==1;
            hold on
            hpoints=plot3(haxisIso,Xiso,Yiso,ROSiso,'*','Color','b');
        else
            delete(hpoints)
        end
    end

    function popcolor_Callback(src,event)
        colorSelection=get(hpopcolor,'Value');
        if colorSelection==1
            if get(hcheckLevels, 'Value')==0
                colormap(haxisIso,jet)
            else
                colormap(haxisIso,jet(levels))
            end
        elseif colorSelection==2
            if get(hcheckLevels, 'Value')==0
                colormap(haxisIso,hot)
            else
                colormap(haxisIso,hot(levels))
            end
        else
            if get(hcheckLevels, 'Value')==0
                colormap(haxisIso,parula)
            else
                colormap(haxisIso,parula(levels))
            end
        end
    end

    function popshading_Callback(src,event)
        shadingSelection=get(hpopshading,'Value'); 
        if shadingSelection==1
            shading(haxisIso,'interp')
        elseif shadingSelection==2
            shading(haxisIso,'faceted')
        else
            shading(haxisIso,'flat')
        end
    end

    function checkLevels_Callback(src,event)
        if get(hcheckLevels,'Value')==1
            heditLevels.Enable='on';
            if colorSelection==1
                colormap(haxisIso,jet(levels))
            elseif colorSelection==2
                colormap(haxisIso,hot(levels))
            else
                colormap(haxisIso,parula(levels))
            end
        else
            heditLevels.Enable='off';
            if colorSelection==1
                colormap(haxisIso,jet)
            elseif colorSelection==2
                colormap(haxisIso,hot)
            else
                colormap(haxisIso,parula)
            end
        end
    end

    function editLevels_Callback(src,event)
        levels=str2double(get(heditLevels,'String'));
        if colorSelection==1
            colormap(haxisIso,jet(levels))
        elseif colorSelection==2
            colormap(haxisIso,hot(levels))
        else
            colormap(haxisIso,parula(levels))
        end
    end

    function editAzimuth_Callback(src,event)
        global az el
        az=str2double(get(heditAzimuth,'String'));
        view(haxisIso,az,el)
    end

    function editElev_Callback(src,event)
        global az el
        el=str2double(get(heditElev,'String'));
        view(haxisIso,az,el)
    end

    function editName_Callback(src,event)
        global isoName
        isoName=get(heditName,'String');
        hbuttonSave.Enable='on';
    end

    function buttonSave_Callback(src,event)
        global isoName
        hcurrentfig=figure('Visible','off');
        copyobj(haxisIso, hcurrentfig);
        print(hcurrentfig,[resultsfolder,'\',isoName],'-dpng','-r500')
    end
end