function repeat_selection
global repeatF answer_rep
repeatF = figure('Visible','off','Position',[600,400,300,60]);
htext1  = uicontrol('Style','text','String','Did you select the fire front correctly?',...
    'FontSize',11,'Position',[5,60,290,30]);
hYes    = uicontrol('Style','pushbutton','FontSize',10,...
    'String','Yes','Position',[15,15,130,35],'FontWeight','bold','callback',{@hYes_Callback});
hRep  = uicontrol('Style','pushbutton','FontSize',10,...
    'String','Repeat Selection','Position',[155,15,130,35],'FontWeight','bold','callback',{@hRep_Callback});
repeatF.Name = 'Checking Selection';
movegui(repeatF,'center')
repeatF.MenuBar = 'none';
repeatF.ToolBar = 'none';
repeatF.NumberTitle='off';
repeatF.Visible = 'on';
    function hYes_Callback(src,event)
        answer_rep=1;
        close(repeatF)
    end
    function hRep_Callback(src,event)
        close(repeatF)
    end
end