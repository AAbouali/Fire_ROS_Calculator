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

function enter_ref_points
global numframes localtime app appPath Fref Xref Yref bwporig XrefReal YrefReal
N=size(Xref,1)+2;
%%
Fref = figure('Visible','off','Units','normalized','Position',[0.2 0.3 0.6 0.4]);
hGroup = uibuttongroup('Units','Normalized','Position',[0.5 0.05 0.49 0.88]);
Text = uicontrol(Fref,'Style','Text','String','Enter the X-Y coordinates of the Ref. Points in (mm)','FontSize',12,'FontWeight','bold',...
        'Units','normalized','Position',[0.3 0.95 0.4 0.04]);
Text = uicontrol(Fref,'Style','Text','String','X','FontSize',11,'FontWeight','bold',...
        'Parent',hGroup,'Units','normalized','Position',[0.41 1-2/(N+2) 0.1 1/(N+2)]);
Text = uicontrol(Fref,'Style','Text','String','Y','FontSize',11,'FontWeight','bold',...
        'Parent',hGroup,'Units','normalized','Position',[0.55 1-2/(N+2) 0.1 1/(N+2)]);
for i = 3:N
    app.Text(i) = uicontrol('Style','Text','String',['Point ' num2str(i-2) ':'],...
        'Parent',hGroup,'FontSize',11,'Units','normalized','Position',[0.2 1-i/(N+2) 0.2 1/(N+2)-0.02],...
        'HorizontalAlignment','right');
    app.InputX(i) = uicontrol('Style','edit',...
        'Parent',hGroup,'Units','normalized','Position',[0.41 1-i/(N+2) 0.1 1/(N+2)-0.02],...
        'BackgroundColor','white','HorizontalAlignment','left');
    app.InputY(i) = uicontrol('Style','edit',...
        'Parent',hGroup,'Units','normalized','Position',[0.55 1-i/(N+2) 0.1 1/(N+2)-0.02],...
        'BackgroundColor','white','HorizontalAlignment','left');
end
hButton = uicontrol('Style','pushbutton','Parent',hGroup,'Units','normalized',...
    'String','OK','Position',[0.3 0.05 0.4 1/(N+1)],'FontSize',12,'FontWeight','bold','Callback',{@pushbuttonOK_Callback});

haxisRef = axes(Fref,'Units','normalized',... 
    'Position',[0,0.1,0.5,0.8],'color','white','PlotBoxAspectRatio',[1 1 1]);
image(haxisRef,bwporig);
axis image;
haxisRef.Box='off';haxisRef.XTick=[];haxisRef.YTick=[];haxisRef.ZTick=[];haxisRef.XColor=[1 1 1];haxisRef.YColor=[1 1 1];
hold on
plot(Xref,Yref, 'w+', 'MarkerSize', 30, 'LineWidth', 2);
for i=1:size(Xref,1)
    text(Xref(i,1)+(size(bwporig,1)*0.05),Yref(i,1)+(size(bwporig,2)*0.05),['point ' num2str(i)],'FontSize',10,'Color','k','BackgroundColor','w','EdgeColor','k')
end
hold off
Fref.Name = 'Refrance Points';
movegui(Fref,'center')
Fref.MenuBar = 'none';
Fref.ToolBar = 'none';
Fref.NumberTitle='off';
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jframe=get(Fref,'javaframe');
jIcon=javax.swing.ImageIcon(fullfile(appPath,'icon ROS.gif'));
jframe.setFigureIcon(jIcon);
Fref.Visible = 'on';

    function pushbuttonOK_Callback(src,event)
        XrefReal=zeros(size(Xref,1),1);
        YrefReal=zeros(size(Xref,1),1);
        for j=3:N
            XrefReal(j-2,1) = str2double(get(app.InputX(j),'String'));
            YrefReal(j-2,1) = str2double(get(app.InputY(j),'String'));
        end
        close(Fref)
    end
end