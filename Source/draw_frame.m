function draw_frame
global cornersnum Xcorners Ycorners
[JPGcorners, JPGcorners_pathname] = uigetfile({'*.jpg;*.tif;*.png;*.gif;*.bmp','All Image Files';...
    '*.*','All Files' },'Select an image to detect the corners of the bed from it');

hcornersF=figure('Visible','off','Units','normalized');
haxis = axes(hcornersF,'Units','normalized','Position',[0,0.15,1,0.8]);
htextNumber  = uicontrol(hcornersF,'Style','text','String','Bed Corners number:','Units','normalized',...
    'FontWeight','bold','FontSize',10,'Position',[0.1,0.01,0.25,0.06]);
heditNumber  = uicontrol('Style','edit','Units','normalized','Position',[0.36,0.01,0.2,0.08],'FontSize',10,'callback',{@number_Callback});
hok   = uicontrol('Style','pushbutton','String','OK','Units','normalized',...
    'Position',[0.7,0.01,0.2,0.08],'callback',{@ok_Callback});
cornersimage=imread(fullfile(JPGcorners_pathname,JPGcorners)); himage=image(haxis,cornersimage);
haxis.Box='off';haxis.XTick=[];haxis.YTick=[];haxis.ZTick=[];haxis.XColor=[1 1 1];haxis.YColor=[1 1 1];
c = uicontextmenu;
himage.UIContextMenu = c;
m1 = uimenu(c,'Label','Add Lines','Callback',@drawLines,'Enable','off');

hcornersF.Name = 'Draw the Frame';
movegui(hcornersF,'center')
hcornersF.MenuBar = 'none';
hcornersF.ToolBar = 'none';
hcornersF.NumberTitle='off';
hcornersF.Visible = 'on';

    function number_Callback(src,event)
        cornersnum=str2double(get(heditNumber,'String'));
        m1.Enable='on';
    end
    function drawLines(src,event)
        global handles
        handles.frame = cell(cornersnum);
        for k=1:cornersnum
            handles.frame{k} = imline(haxis);
        end
    end
    function ok_Callback(src,event)
        global handles
        posline=cell(cornersnum);
        Xcorners=zeros(4,1);
        Ycorners=zeros(4,1);
        for i=1:cornersnum
            posline{i} = getPosition(handles.frame{i});
        end
        for i=1:cornersnum
            Xcorners(i,1)=posline{i}(1,1);
            Ycorners(i,1)=posline{i}(1,2);
        end
        close(hcornersF)
    end
end