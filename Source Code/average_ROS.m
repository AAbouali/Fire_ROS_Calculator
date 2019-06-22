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

function average_ROS 
global numframes cornersnum Xworld Yworld XcornersWorld YcornersWorld shape results resultrow resultsfolder time appPath 
global fflineeq posline nolines handles Nfires fireLastFrame 
posline=[];
handles=[];
%% building the GUI
f = figure('Visible','off','Position',[680,193,800,500]);
panel=uipanel(f,'Position',[0,0,1,1]);
htextTitle  = uicontrol(panel,'Style','text','String','Place the lines where the ROS will be calcualted along',...
              'FontWeight','bold','FontSize',12,'Units','normalized','Position',[0.05,0.93,0.7,0.05]);
htextName  = uicontrol(panel,'Style','text','String',sprintf('Saving the calculated ROS with name:'),...
              'FontWeight','bold','FontSize',10,'Units','normalized','Position',[0.2,0.09,0.4,0.05]);
heditName  = uicontrol(panel,'Style','edit','Units','normalized','Position',[0.2,0.05,0.4,0.05],'FontSize',10);         
htextStart  = uicontrol(panel,'Style','text','String',sprintf('Calculate ROS throw frames:'),...
              'FontWeight','bold','FontSize',10,'Units','normalized','Position',[0.77,0.78,0.2,0.08]);
heditStart  = uicontrol(panel,'Style','edit','Units','normalized','Position',[0.77,0.74,0.2,0.05],'FontSize',12,'callback',{@start_Callback});
htextEnd    = uicontrol(panel,'Style','text','String','To',...
              'FontWeight','bold','FontSize',10,'Units','normalized','Position',[0.77,0.67,0.2,0.05]);
heditEnd    = uicontrol(panel,'Style','edit','Units','normalized','Position',[0.77,0.63,0.2,0.05],'FontSize',12,'callback',{@end_Callback});
htextResult    = uicontrol(panel,'Style','text','String','Average ROS',...
              'FontWeight','bold','FontSize',10,'Units','normalized','Position',[0.77,0.34,0.2,0.05]);
heditResult    = uicontrol(panel,'Style','edit','Units','normalized','Position',[0.77,0.29,0.2,0.05],'FontWeight','bold','FontSize',12,...
              'Enable','off' );
hcalculte   = uicontrol(panel,'Style','pushbutton','String','Calculate ROS','Units','normalized',...
              'Position',[0.77,0.45,0.2,0.1],'callback',{@calculate_Callback});
haxis       = axes(panel,'box','off','xtick',[],'ytick',[],'ztick',[],'xcolor',[1 1 1],'ycolor',[1 1 1],...
              'Position',[0.05,0.15,0.70,0.8],'color','white','PlotBoxAspectRatio',[1 1 1]);
          
c = uicontextmenu;
haxis.UIContextMenu = c;
m1 = uimenu(c,'Label','Add Lines','Callback',@drawLines);
% drawing the propagation map on the axis
hold on
for k=1:Nfires
    for i=1:fireLastFrame(1,k)
        line(Xworld{k,i},Yworld{k,i},'Color','r','LineWidth',1);
    end
end
for i=1:cornersnum
    line([XcornersWorld(i,1),XcornersWorld(i+1,1)],([YcornersWorld(i,1),YcornersWorld(i+1,1)]),'Color','b','LineWidth',2)
end

axis equal
f.Name = 'Calculate Average ROS';
movegui(f,'center')
f.MenuBar = 'none';
f.ToolBar = 'none';
f.NumberTitle='off';


warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jframe=get(f,'javaframe');
jIcon=javax.swing.ImageIcon(fullfile(appPath,'icon ROS.gif'));
jframe.setFigureIcon(jIcon);
f.Visible = 'on';
PFframe=0;PLframe=0;lineError=0;

%% callbacks
% getting the postion of the line
    function drawLines(source,callbackdata)
        global  fig
        switch source.Label
            case 'Add Lines'
                lines_number
                waitfor(fig)
                handles.line = cell(nolines,1);
                for k=1:nolines
                    handles.line{k} = imline(haxis);
                end
        end
    end
% calculating the ROS and saving the result
    function start_Callback(src,event)
        global CPFframe
        Fframe=str2double(get(heditStart,'String'));
        for k=1:Nfires
            if Fframe<=fireLastFrame(1,k)
                line(haxis,Xworld{k,Fframe},(Yworld{k,Fframe}),'Color','g','LineWidth',1)
            end
        end
        if PFframe~=0 && Fframe~=PFframe
            for k=1:Nfires
                if PFframe<=fireLastFrame(1,k)
                    line(haxis,Xworld{k,PFframe},(Yworld{k,PFframe}),'Color','r','LineWidth',1)
                end
            end
        end
        CPFframe=PFframe; PFframe=Fframe;
    end
    function end_Callback(src,event)
        global CPLframe
        Lframe=str2double(get(heditEnd,'String'));
        for k=1:Nfires
            if Lframe<=fireLastFrame(1,k)
                line(haxis,Xworld{k,Lframe},(Yworld{k,Lframe}),'Color','g','LineWidth',1)
            end
        end
        if PLframe~=0 && Lframe~=PLframe
            for k=1:Nfires
                if PLframe<=fireLastFrame(1,k)
                    line(haxis,Xworld{k,PLframe},(Yworld{k,PLframe}),'Color','r','LineWidth',1)
                end
            end
        end
        CPLframe=PLframe; PLframe=Lframe;
    end
    function calculate_Callback(src,event)
        set(f, 'pointer', 'watch')
        drawnow;
        if lineError~=0 && size(handles.line,1)>=lineError
            setColor(handles.line{lineError},'b')
            drawnow;
        end
        for i=1:nolines
            posline{1,i} = getPosition(handles.line{i});
        end
        Fframe=str2double(get(heditStart,'String'));
        Lframe=str2double(get(heditEnd,'String'));
        resultname=get(heditName,'String');
        localTotframes=Lframe-Fframe+1;
        %detectingt the intersection between this line and hte fire fronts
        linetime(1,2:localTotframes)=time(1,(Fframe:(Lframe-1)));
        linetime(1,1)=0;%consider the first frame as the 0 refrance
        if Fframe>1
            linetime(1,2:localTotframes)=linetime(1,2:localTotframes)-time(1,Fframe-1);
        end
        Dist=zeros(nolines,localTotframes);
        Distadd=zeros(nolines,localTotframes);
        linelocalRofS=zeros(nolines,localTotframes-1);
        lineROfS=zeros(2,nolines);
        line_x_intersect=zeros(nolines,localTotframes);
        line_y_intersect=zeros(nolines,localTotframes);
        %finding the intersection between the prescribed lines and the fire
        %front lines to calculate the passed distances
        for j=1:nolines
            %p1= worldToPoints(cameraParams, R, t, [posline{1,j}(1,1),posline{1,j}(1,2)]);
            %p2= worldToPoints(cameraParams, R, t, [posline{1,j}(2,1),posline{1,j}(2,2)]);
            %eqline=polyfit([posline{1,j}(1,1) posline{1,j}(2,1)],[posline{1,j}(1,2) posline{1,j}(2,2)],1);
            for i=Fframe:Lframe
                no_inter=1;
                for w=1:Nfires
                    if i<=fireLastFrame(1,w) && no_inter==1
                        xi=[]; yi=[];
                        [xi,yi] = polyxpoly(posline{1,j}(:,1),posline{1,j}(:,2),Xworld{w,i},Yworld{w,i});
                        if isempty(xi) || isempty(yi)
                            no_inter=1;
                        else
                            plot(haxis,xi,yi,'o')
                            line_x_intersect(j,i)=xi(1,1);
                            line_y_intersect(j,i)=yi(1,1);
                            no_inter=0; lineError=0;
                            break
                        end
                    end
                end
                if no_inter==1
                    break
                end
            end
            %calculating the distance and RofS
            if no_inter==0
                for i=1:localTotframes-1
                    Dist(j,i+1) = ((line_x_intersect(j,i) - line_x_intersect(j,(i+1))) ^ 2 + (line_y_intersect(j,i) - line_y_intersect(j,(i+1))) ^ 2) ^ 0.5;
                end
                Dist(j,1)=0; %consider the first frame as the 0 refrance
                Distadd(j,1)=Dist(j,1);
                for i=2:localTotframes
                    Distadd(j,i)=Distadd(j,i-1)+Dist(j,i);
                end
                for i=1:localTotframes-1
                    linelocalRofS(j,i)=(Distadd(j,i+1)-Distadd(j,i))/(linetime(1,i+1)-linetime(1,i));
                end
                lineROfS(:,j)=polyfit(linetime,Distadd(j,:),1);
            else
                lineError=j;
                break
            end
        end
        %saving the results into the excel sheet
        if no_inter==0
            results{resultrow,1}=resultname;results{resultrow,2}=('(Average ROS)');
            resultrow=resultrow+1;
            results{resultrow,1}=('the considered frame are from frame:');results{resultrow,2}=Fframe;results{resultrow,3}=('to frame');results{resultrow,4}=Lframe;
            resultrow=resultrow+1;
            results{resultrow,1}=('Avarage ROS (cm/s)');
            results{resultrow,2}=mean(lineROfS(1,:))/10;
            resultrow=resultrow+1;
            results{resultrow,1}=('Max ROS (cm/s)');
            results{resultrow,2}=max(lineROfS(1,:))/10;
            resultrow=resultrow+1;
            results{resultrow,1}=('The lines ROS (cm/s)');
            resultrow=resultrow+1;
            results(resultrow,1:size(lineROfS,2))=num2cell(lineROfS(1,:)/10);
            resultrow=resultrow+2;
            %svaing a figure showing where this ROS was calculated
            figure('Visible','off');
            hf2=figure('Visible','off','Position',[28,66,700,540]); haxesROS=axes(hf2);
            haxesROS.Box='off';haxesROS.XTick=[];haxesROS.YTick=[];haxesROS.ZTick=[];haxesROS.XColor='none';haxesROS.YColor='none';
            title('Postion of the lines where the ROS was calculated along them');
            hold on
            for k=1:Nfires
                for i=1:fireLastFrame(1,k)
                    line(haxesROS,Xworld{k,i},Yworld{k,i},'Color','r','LineWidth',1);
                end
            end
            for i=1:nolines
                line(haxesROS,[posline{1,i}(1,1),posline{1,i}(2,1)],[posline{1,i}(1,2),posline{1,i}(2,2)],'Color','g','LineWidth',2);
            end
            if shape~=4
                for i=1:cornersnum
                    line(haxesROS,[XcornersWorld(i,1),XcornersWorld(i+1,1)],([YcornersWorld(i,1),YcornersWorld(i+1,1)]),'Color','b','LineWidth',2)
                end
            end
            hold off
            axis equal
            figg=gcf;
            print(figg,[resultsfolder,'/',resultname],'-dpng','-r300')
            %saveas(gcf,[resultsfolder,'\',resultname,'(Average ROS)'],'jpeg')
            set(heditResult,'String',[num2str(round(mean(lineROfS(1,:)))/10),' cm/s']);
        else
            hW = warndlg(sprintf('The indicated line in black is not intersecting with one of the fire front lines \n Tip: Change the line location and/or check the considered frames range'),'Error!','modal');
            jframe=get(hW,'javaframe'); jframe.setFigureIcon(javax.swing.ImageIcon(fullfile(appPath,'icon ROS.gif')));
            setColor(handles.line{lineError},'k')
        end
        set(f, 'pointer', 'arrow');drawnow;
    end
end