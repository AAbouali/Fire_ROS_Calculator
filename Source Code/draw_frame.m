%Fire ROS Calculator is a program with GUI built to measure the rate of spread (ROS) 
%of a fire propagating over a surface in a laboratory setting
%
%This program was developed by [ADAI|CEIF](http://www.adai.pt) team (Association for the Development of 
%Industrial Aerodynamics | Center of Studies about Forest Fires), University of Coimbra, Portugal. 
%
%This is a sub-program from the Fire ROS Calcualtor 
%
%Copyright (C) 2019  Abdelrahman Abouali
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <https://www.gnu.org/licenses/>.

function draw_frame
global cornersnum Xcorners Ycorners framespathname
%%
[JPGcorners, JPGcorners_pathname] = uigetfile({'*.jpg;*.tif;*.png;*.gif;*.bmp','All Image Files';...
    '*.*','All Files' },'Select an image to detect the corners of the bed from it',framespathname);

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
        Xcorners=[];Ycorners=[];
        global handles
        posline=cell(cornersnum);
        Xcorners=zeros(cornersnum+1,1);
        Ycorners=zeros(cornersnum+1,1);
        for i=1:cornersnum
            posline{i} = getPosition(handles.frame{i});
        end
        for i=1:cornersnum
            Xcorners(i,1)=posline{i}(1,1);
            Ycorners(i,1)=posline{i}(1,2);
        end
        Xcorners(cornersnum+1,1)=Xcorners(1,1);
        Ycorners(cornersnum+1,1)=Ycorners(1,1);
        close(hcornersF)
    end
end