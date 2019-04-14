function check_exit
global appPath MainF
exitF = figure('Visible','off','Position',[600,400,300,60]);
htext1  = uicontrol('Style','text','String','Are you sure you want to exit?',...
    'FontSize',11,'Position',[5,60,290,30]);
hExit    = uicontrol('Style','pushbutton','FontSize',10,...
    'String','Exit','Position',[155,15,130,35],'FontWeight','bold','callback',{@Exit_Callback});
hCancel  = uicontrol('Style','pushbutton','FontSize',10,...
    'String','Cancel','Position',[15,15,130,35],'FontWeight','bold','callback',{@Cancel_Callback});

exitF.Name = 'Exit ...';
movegui(exitF,'center')
exitF.MenuBar = 'none';
exitF.ToolBar = 'none';
exitF.NumberTitle='off';


warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jframe=get(exitF,'javaframe');
jIcon=javax.swing.ImageIcon(fullfile(appPath,'icon ROS.gif'));
jframe.setFigureIcon(jIcon);
exitF.Visible = 'on';

    function Exit_Callback(src,event)
        delete(exitF)
        if isdeployed
            quit force
        else
            delete(MainF)
        end
    end
    function Cancel_Callback(src,event)
        delete(exitF)
    end
end