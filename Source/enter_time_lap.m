function enter_time_lap
global numframes localtime  app
N=numframes;
f = figure('Visible','off');
hGroup = uibuttongroup('Units','Normalized','Position',[0 0 1 1]);
Text = uicontrol('Style','Text','String','Enter the Time Between the Frames in Seconds','FontWeight','bold',...
        'Parent',hGroup,'Units','normalized','Position',[0.2 1-1/(N+2) 0.7 1/(N+2)]);
for i = 2:N
    app.Text(i) = uicontrol('Style','Text','String',['Time between frame ' num2str(i-1) ' and ' num2str(i) ':'],...
        'Parent',hGroup,'Units','normalized','Position',[0.3 1-i/(N+2) 0.3 1/(N+2)],...
        'HorizontalAlignment','right');
    app.Input(i) = uicontrol('Style','edit',...
        'Parent',hGroup,'Units','normalized','Position',[0.6 1-i/(N+2) 0.1 1/(N+2)],...
        'BackgroundColor','white','HorizontalAlignment','left');
end
hButton = uicontrol('Style','pushbutton','Parent',hGroup,'Units','normalized',...
    'String','OK','Position',[0.3 0 0.4 1/(N+1)],'FontSize',13,'FontWeight','bold','Callback',{@pushbuttonOK_Callback});
f.Name = 'Time Laps';
movegui(f,'center')
f.MenuBar = 'none';
f.ToolBar = 'none';
f.NumberTitle='off';
f.Visible = 'on';

    function pushbuttonOK_Callback(src,event)
        localtime=zeros(1,N-1);
        for j=2:N
            localtime(1,j-1) = str2double(get(app.Input(j),'String'));
       end
        close(f)
    end
end