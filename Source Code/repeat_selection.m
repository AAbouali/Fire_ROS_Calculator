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

function repeat_selection
global repeatF answer_rep
%%
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