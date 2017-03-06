function check_frame
global  Xcorners Ycorners cornersnum frame frame_corr checkf
checkf = figure('Visible','off','Position',[680,266,800,420]);
haxis = axes(checkf,'Units','pixels','Position',[25,22,575,435]);
htextNumber = uicontrol('Style','text','String','Is The location of the bed correct?',...
    'FontWeight','bold','FontSize',11,'Position',[620,320,150,40]);
hbuttonCorrect = uicontrol(checkf,'Style','pushbutton','String','Correct',...
    'Position',[650,270,100,35],'callback',@buttonCorrect_Callback);
hbuttonFlip = uicontrol(checkf,'Style','pushbutton','String','Flip',...
    'Position',[650,215,100,35],'callback',@buttonFlip_Callback);
himage= image(haxis,frame{1});
haxis.Box='off';haxis.XTick=[];haxis.YTick=[];haxis.ZTick=[];haxis.XColor=[1 1 1];haxis.YColor=[1 1 1];
hold on
for i=1:cornersnum
    line([Xcorners(i,1),Xcorners(i+1,1)],([Ycorners(i,1),Ycorners(i+1,1)]),'Color','b','LineWidth',2)
end
hold off

checkf.Name = 'Checking Frame Location';
movegui(checkf,'center')
checkf.MenuBar = 'none';
checkf.ToolBar = 'none';
checkf.NumberTitle='off';
checkf.Visible = 'on';

    function buttonCorrect_Callback(src,event)
        frame_corr=1;
        close(checkf)
    end
    function buttonFlip_Callback(src,event)
        frame_corr=2;
        close(checkf)
    end
end

