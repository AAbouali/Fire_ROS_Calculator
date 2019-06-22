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

function lines_number
global nolines fig appPath
%%
x=1;
fig = figure('Visible','off','Position',[600,400,250,60]);
hokay    = uicontrol(fig,'Style','pushbutton','FontSize',13,...
    'String','OK','Position',[90,15,70,30],'FontWeight','bold','callback',{@hokay_Callback});
htext2  = uicontrol(fig,'Style','text','String','Number of Lines to Draw:',...
    'FontSize',13,'Position',[5,60,200,30]);
htext  = uicontrol(fig,'Style','edit','Position',[200,65,40,25],'FontSize',13);
fig.Name = 'Number of lines';
jframe=get(fig,'javaframe'); jframe.setFigureIcon(javax.swing.ImageIcon(fullfile(appPath,'icon ROS.gif')));
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
