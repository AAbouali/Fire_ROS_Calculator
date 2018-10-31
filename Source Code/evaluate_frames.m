function evaluate_frames
global numframes cornersnum Xworld Yworld appPath BI MaskROI Bnd hL editMode hArea project_name resultsfolder
global R t cameraParams X Y Xcorners Ycorners frames frame Fselection fflineeq drawfront MainF
%% building the GUI
f = figure('Visible','off','Position',[680,215,800,500],'CloseRequestFcn',@f_CloseRequestFcn);
panel=uipanel(f,'Position',[0,0,1,1]);
htextFrame  = uicontrol(panel,'Style','text','String','Select Frame:',...
    'FontWeight','bold','FontSize',12,'Units','normalized','Position',[0.78,0.826,0.146,0.056]);
hpopFrame  = uicontrol(panel,'Style','pop','Units','normalized','FontSize',10,...
    'Position',[0.78,0.77,0.173,0.056],'String',frames,'callback',{@popFrame_Callback});
hbgEdit  = uibuttongroup(panel,'Units','pixels','Title','Modify Fire Front','FontSize',10,...
    'Units','normalized','Position',[0.762 0.157 0.21 0.493],'SelectionChangedFcn',@selectionMode);
hMTool   = uicontrol(hbgEdit,'Style','pushbutton','String','Modify Tool','Units','normalized',...
    'Position',[0.075,0.78,0.87,0.15],'FontSize',10,'callback',{@MTool_Callback});
htextMode  = uicontrol(hbgEdit,'Style','text','String','Mode:',...
    'FontSize',11,'Units','normalized','Position',[0.11,0.65,0.317,0.075]);
hradioAdd    = uicontrol(hbgEdit  ,'Style','radiobutton','String','Add','Units','normalized',...
    'Position',[0.124 0.53 0.627 0.115],'FontSize',11,'Enable','off');
hradioRemove    = uicontrol(hbgEdit  ,'Style','radiobutton','String','Remove','Units','normalized',...
    'Position',[0.124 0.43 0.627 0.115],'FontSize',11,'Enable','off');
hcheckApply = uicontrol(hbgEdit,'Style','checkbox','String','Apply for next frames','Units','normalized',...
    'FontSize',9.5,'Value',0,'Position',[0.05 0.20 0.95 0.25]);
hApply   = uicontrol(hbgEdit,'Style','pushbutton','String','Apply','Units','normalized',...
    'Position',[0.199,0.03,0.627,0.195],'FontSize',11,'FontWeight','bold','callback',{@Apply_Callback});
haxis       = axes(panel,'box','off','xtick',[],'ytick',[],'ztick',[],'xcolor',[1 1 1],'ycolor',[1 1 1],...
    'Position',[0.03,0.1,0.70,0.8],'color','white');

f.Name = 'Evaluate Fire Front Detection';
movegui(f,'center')
f.MenuBar = 'none';
f.ToolBar = 'none';
f.NumberTitle='off';
f.Visible = 'on';

warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jframe=get(f,'javaframe');
jIcon=javax.swing.ImageIcon(fullfile(appPath,'icon ROS.gif'));
jframe.setFigureIcon(jIcon);
changefFrames=[]; q=1; edit=0;
editMode=1; allFrames=0;
%% callbacks
    function popFrame_Callback(src,event)
        global him
        Fselection=get(hpopFrame,'Value');
        him=image(haxis,frame{Fselection});
        haxis.Box='off';haxis.XTick=[];haxis.YTick=[];haxis.ZTick=[];haxis.XColor=[1 1 1];haxis.YColor=[1 1 1];
        hold on
        hL=line(X{Fselection},Y{Fselection},'Color','g','LineWidth',1.2);
        if Fselection>1
           line(X{Fselection-1},Y{Fselection-1},'Color','w','LineWidth',1.2);
        end
        for j=1:cornersnum
            line([Xcorners(j,1),Xcorners(j+1,1)],([Ycorners(j,1),Ycorners(j+1,1)]),'Color','b','LineWidth',2)
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
    function Apply_Callback(src,event)
        global him
        edit=1;
        allFrames=get(hcheckApply,'Value');
        set(f, 'pointer', 'watch'); drawnow;
        Mask = createMask(hArea,him);
        if editMode==1
            BI{Fselection}(Mask == 1) = 1;
        elseif editMode==2
            BI{Fselection}(Mask == 1) = 0;
        end
        BI{Fselection}(MaskROI == 0) = 0;
        [Bnd{Fselection},L,N] = bwboundaries(BI{Fselection},'noholes',8);
        if N>1
            SizeN=zeros(1,N);
            for k=1:N
                SizeN(1,k)=size(Bnd{Fselection}{k},1);
            end
            Bnd{Fselection}{1}=Bnd{Fselection}{find(SizeN==max(SizeN))};
        end
        X{Fselection}=Bnd{Fselection}{1}(:,2);
        Y{Fselection}=Bnd{Fselection}{1}(:,1);
        imagePoints=[];
        imagePoints(:,1)=X{Fselection}(:,1);
        imagePoints(:,2)=Y{Fselection}(:,1);
        worldPoints = pointsToWorld(cameraParams, R, t, imagePoints);
        Xworld{Fselection}=worldPoints(:,1);
        Yworld{Fselection}=worldPoints(:,2);
        for j=1:size(Xworld{Fselection},1)-1
            fflineeq{Fselection}(j,:) = polyfit([Xworld{Fselection}(j,1) Xworld{Fselection}(j+1,1)],[Yworld{Fselection}(j,1) Yworld{Fselection}(j+1,1)],1);
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
                [Bnd{i},L,N] = bwboundaries(BI{i},'noholes',8);
                if N>1
                    SizeN=zeros(1,N);
                    for k=1:N
                        SizeN(1,k)=size(Bnd{i}{k},1);
                    end
                    Bnd{i}{1}=Bnd{i}{find(SizeN==max(SizeN))};
                end
                X{i}=Bnd{i}{1}(:,2);
                Y{i}=Bnd{i}{1}(:,1);
                imagePoints=[];
                imagePoints(:,1)=X{i}(:,1);
                imagePoints(:,2)=Y{i}(:,1);
                worldPoints = pointsToWorld(cameraParams, R, t, imagePoints);
                Xworld{i}=worldPoints(:,1);
                Yworld{i}=worldPoints(:,2);
                for j=1:size(Xworld{i},1)-1
                    fflineeq{i}(j,:) = polyfit([Xworld{i}(j,1) Xworld{i}(j+1,1)],[Yworld{i}(j,1) Yworld{i}(j+1,1)],1);
                end
                if any(changefFrames==i)==0
                    changefFrames(1,q)=i; q=q+1;
                end
            end
        end
        delete(hL)
        hL=line(X{Fselection},Y{Fselection},'Color','g','LineWidth',1.2);
        set(f, 'pointer', 'arrow'); drawnow;
    end
% To save the updated locations of the fire fronts on the saved session
% file (worksapce)
    function f_CloseRequestFcn(src,event)
        set(MainF, 'pointer', 'watch'); drawnow;
        delete(f)
        if edit==1
            save([resultsfolder,'\',project_name], 'fflineeq', 'Xworld', 'Yworld', 'X', 'Y','-append')
            if drawfront==1
                namedrawfront=[project_name ' DFF'];
                fff = figure('visible','off'); haxesff=axes(fff);
                for i=changefFrames
                    image(haxesff,frame{i});
                    hold on
                    for j=1:i
                        line(haxesff,X{j}(:,1),Y{j}(:,1),'Color','g','LineWidth',1.2)
                    end
                    for j=1:cornersnum
                        line(haxesff,[Xcorners(j,1),Xcorners(j+1,1)],([Ycorners(j,1),Ycorners(j+1,1)]),'Color','b','LineWidth',2)
                    end
                    haxesff.Box='off';haxesff.XTick=[];haxesff.YTick=[];haxesff.ZTick=[];haxesff.XColor=[1 1 1];haxesff.YColor=[1 1 1];haxesff.Position=[0 0 1 1];
                    hold off
                    FileName = sprintf([namedrawfront,'%d.png'], i);
                    frontFrame = getframe(haxesff);
                    frontIamge = frame2im(frontFrame);
                    frontIamge = imresize(frontIamge, [NaN size(frame{i},2)]) ;
                    imwrite(frontIamge,[resultsfolder,'\',namedrawfront,'\',FileName],'png')
                    %print(ff, '-r110', '-dpng', [resultsfolder,'\',namedrawfront,'\',FileName]);
                end
                delete(fff)
            end
        end
        set(MainF, 'pointer', 'arrow'); drawnow;
    end
end