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

%%
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