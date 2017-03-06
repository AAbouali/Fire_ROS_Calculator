function lines_number
global nolines fig
x=1;
fig = figure('Visible','off','Position',[600,400,250,60]);
hokay    = uicontrol(fig,'Style','pushbutton','FontSize',13,...
    'String','OK','Position',[90,15,70,30],'FontWeight','bold','callback',{@hokay_Callback});
htext2  = uicontrol(fig,'Style','text','String','Number of Lines to Draw:',...
    'FontSize',13,'Position',[5,60,200,30]);
htext  = uicontrol(fig,'Style','edit','Position',[200,65,40,25],'FontSize',13);
fig.Name = 'Number of lines';
movegui(fig,'center')
fig.MenuBar = 'none';
fig.ToolBar = 'none';
fig.NumberTitle='off';
fig.Visible = 'on';    
    function hokay_Callback(src,event)
        x=get(htext,'String');
        nolines=str2double(x);
        close
    end
end
