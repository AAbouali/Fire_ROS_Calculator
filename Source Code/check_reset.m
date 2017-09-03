function check_reset
global resetF answer_reset appPath
resetF = figure('Visible','off','Position',[600,400,300,60]);
htext1  = uicontrol('Style','text','String','Are you sure you want to Reset?',...
    'FontSize',11,'Position',[5,60,290,30]);
hExit    = uicontrol('Style','pushbutton','FontSize',10,...
    'String','Reset','Position',[155,15,130,35],'FontWeight','bold','callback',{@Exit_Callback});
hCancel  = uicontrol('Style','pushbutton','FontSize',10,...
    'String','Cancel','Position',[15,15,130,35],'FontWeight','bold','callback',{@Cancel_Callback});

resetF.Name = 'Reset...';
movegui(resetF,'center')
resetF.MenuBar = 'none';
resetF.ToolBar = 'none';
resetF.NumberTitle='off';
resetF.Visible = 'on';

warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jframe=get(resetF,'javaframe');
jIcon=javax.swing.ImageIcon(fullfile(appPath,'icon ROS.gif'));
jframe.setFigureIcon(jIcon);

    function Exit_Callback(src,event)
        answer_reset=1;
        close(resetF)
    end
    function Cancel_Callback(src,event)
        answer_reset=2;
        close(resetF)
    end
end