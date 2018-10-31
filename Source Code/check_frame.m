function check_frame
global  Xcorners Ycorners cornersnum checkf checkimage XcornersWorld YcornersWorld Lworld cameraParams R t AngleWorld shape cancelProc appPath flip
checkf = figure('Visible','off','Position',[680,266,800,420]); 
haxis = axes(checkf,'Units','pixels','Position',[25,22,575,435]);
htextNumber = uicontrol('Style','text','String','Is The location of the bed correct?',...
    'FontWeight','bold','FontSize',11,'Position',[620,320,150,40]);
hbuttonCorrect = uicontrol(checkf,'Style','pushbutton','String','Continue',...
    'Position',[650,270,100,35],'callback',@buttonCorrect_Callback);
hbuttonFlip = uicontrol(checkf,'Style','pushbutton','String','Flip',...
    'Position',[650,215,100,35],'callback',@buttonFlip_Callback);
hbuttonCancel = uicontrol(checkf,'Style','pushbutton','String','Cancel',...
    'Position',[650,160,100,35],'callback',@buttonCancel_Callback);
himage= image(haxis,imread(checkimage));
haxis.Box='off';haxis.XTick=[];haxis.YTick=[];haxis.ZTick=[];haxis.XColor=[1 1 1];haxis.YColor=[1 1 1];
hold on
for i=1:cornersnum
    line([Xcorners(i,1),Xcorners(i+1,1)],([Ycorners(i,1),Ycorners(i+1,1)]),'Color','b','LineWidth',2)
end
hold off

flip=1;

jframe=get(checkf,'javaframe'); jframe.setFigureIcon(javax.swing.ImageIcon(fullfile(appPath,'icon ROS.gif')));
checkf.Name = 'Checking Frame Location';
movegui(checkf,'center')
checkf.MenuBar = 'none';
checkf.ToolBar = 'none';
checkf.NumberTitle='off';
checkf.Visible = 'on';
 %%
    function buttonCorrect_Callback(src,event)
        close(checkf)
        cancelProc=0;
    end
    function buttonFlip_Callback(src,event)
        if shape==2
            if flip==1
                s=atan2((YcornersWorld(2,1)-YcornersWorld(1,1)),(XcornersWorld(2,1)-XcornersWorld(1,1))) ;       
                Angle=s+degtorad(AngleWorld);
                XcornersWorld(3,1)=Lworld*cos(Angle)+XcornersWorld(1,1);
                YcornersWorld(3,1)=Lworld*sin(Angle)+YcornersWorld(1,1);
                flip=2;
            elseif flip==2
                s=atan2((YcornersWorld(2,1)-YcornersWorld(1,1)),(XcornersWorld(2,1)-XcornersWorld(1,1)))+pi ;       
                Angle=s+degtorad(AngleWorld);
                XcornersWorld(3,1)=Lworld*cos(Angle)+XcornersWorld(1,1);
                YcornersWorld(3,1)=Lworld*sin(Angle)+YcornersWorld(1,1);
                flip=3;
            elseif flip==3
                s=atan2((YcornersWorld(2,1)-YcornersWorld(1,1)),(XcornersWorld(2,1)-XcornersWorld(1,1)))+pi ;       
                Angle=s+degtorad(AngleWorld);
                XcornersWorld(3,1)=Lworld*cos(Angle)+XcornersWorld(2,1);
                YcornersWorld(3,1)=Lworld*sin(Angle)+YcornersWorld(2,1);
                flip=1;
            end
            imagePoint= worldToPoints(cameraParams, R, t, [XcornersWorld(3,1),YcornersWorld(3,1)]);
            Xcorners(3,1)= imagePoint(1,1);
            Ycorners(3,1)= imagePoint(1,2);

        elseif shape==1
            s=atan2((YcornersWorld(2,1)-YcornersWorld(1,1)),(XcornersWorld(2,1)-XcornersWorld(1,1)))  ;
            Angle=s+(pi/2);
            XcornersWorld(4,1)=Lworld*cos(Angle)+XcornersWorld(1,1);
            YcornersWorld(4,1)=Lworld*sin(Angle)+YcornersWorld(1,1);
            XcornersWorld(3,1)=Lworld*cos(Angle)+XcornersWorld(2,1);
            YcornersWorld(3,1)=Lworld*sin(Angle)+YcornersWorld(2,1);
            for i=3:4
                imagePoint= worldToPoints(cameraParams, R, t, [XcornersWorld(i,1),YcornersWorld(i,1)]);
                Xcorners(i,1)= imagePoint(1,1);
                Ycorners(i,1)= imagePoint(1,2);
            end
        end
        image(haxis,imread(checkimage));
        haxis.Box='off';haxis.XTick=[];haxis.YTick=[];haxis.ZTick=[];haxis.XColor=[1 1 1];haxis.YColor=[1 1 1];
        hold on
        for i=1:cornersnum
            line([Xcorners(i,1),Xcorners(i+1,1)],([Ycorners(i,1),Ycorners(i+1,1)]),'Color','b','LineWidth',2)
        end
        hold off
    end
    function buttonCancel_Callback(src,event)
        cancelProc=1;
        close(checkf)
    end
end

