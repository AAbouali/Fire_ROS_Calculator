function dynamic_ROS
global numframes cornersnum Xworld Yworld XcornersWorld YcornersWorld shape results resultrow resultsfolder time
global R t cameraParams ffpoints fflineeq posline nolines handles loudstatuse workpathname work X Y Xcorners Ycorners
if loudstatuse==1
    load([workpathname,work])
end
posline=[];
handles=[];
%% building the GUI
f = figure('Visible','off','Position',[680,193,800,500]);
panel=uipanel(f,'Position',[0,0,1,1]);
htextTitle  = uicontrol(panel,'Style','text','String','Place a line where the ROS will be calcualted along',...
              'FontWeight','bold','FontSize',12,'Units','normalized','Position',[0.05,0.93,0.7,0.05]);
htextName  = uicontrol(panel,'Style','text','String',sprintf('Saving the calculated ROS with name:'),...
              'FontWeight','bold','FontSize',10,'Units','normalized','Position',[0.2,0.09,0.4,0.05]);
heditName  = uicontrol(panel,'Style','edit','Units','normalized','Position',[0.2,0.05,0.4,0.05],'FontSize',10);          
htextStart  = uicontrol(panel,'Style','text','String',sprintf('Calculate ROS throw frames:'),...
              'FontWeight','bold','FontSize',10,'Units','normalized','Position',[0.77,0.78,0.2,0.08]);
heditStart  = uicontrol(panel,'Style','edit','Units','normalized','Position',[0.77,0.74,0.2,0.05],'FontSize',12);
htextEnd    = uicontrol(panel,'Style','text','String','To',...
    'FontWeight','bold','FontSize',10,'Units','normalized','Position',[0.77,0.67,0.2,0.05]);
heditEnd    = uicontrol(panel,'Style','edit','Units','normalized','Position',[0.77,0.63,0.2,0.05],'FontSize',12);
htextResult    = uicontrol(panel,'Style','text','String','Average ROS',...
    'FontWeight','bold','FontSize',11,'Units','normalized','Position',[0.77,0.34,0.2,0.05]);
heditResult    = uicontrol(panel,'Style','edit','Units','normalized','Position',[0.77,0.29,0.2,0.05],'FontWeight','bold','FontSize',12,...
    'Enable','off' );
htextMax    = uicontrol(panel,'Style','text','String','Max.',...
    'FontWeight','bold','FontSize',11,'Units','normalized','Position',[0.78,0.19,0.09,0.05]);
heditMax   = uicontrol(panel,'Style','edit','Units','normalized','Position',[0.85,0.20,0.09,0.05],'FontWeight','bold','FontSize',12,'Enable','off' );
htextMin   = uicontrol(panel,'Style','text','String','Min.',...
    'FontWeight','bold','FontSize',11,'Units','normalized','Position',[0.78,0.13,0.09,0.05]);
heditMin   = uicontrol(panel,'Style','edit','Units','normalized','Position',[0.85,0.14,0.09,0.05],'FontWeight','bold','FontSize',12,'Enable','off' );
hcalculte   = uicontrol(panel,'Style','pushbutton','String','Calculate ROS','Units','normalized',...
              'Position',[0.77,0.45,0.2,0.1],'callback',{@calculate_Callback});
haxis       = axes(panel,'box','off','xtick',[],'ytick',[],'ztick',[],'xcolor',[1 1 1],'ycolor',[1 1 1],...
              'Position',[0.05,0.15,0.70,0.8],'color','white','PlotBoxAspectRatio',[1 1 1]);
c = uicontextmenu;
haxis.UIContextMenu = c;
m1 = uimenu(c,'Label','Add Lines','Callback',@drawLines);
% drawing the propagation map on the axis
hold on
for i=1:numframes
    line(Xworld(:,i),(Yworld(:,i)),'Color','r')
end
if shape~=4
    for i=1:cornersnum
        line([XcornersWorld(i,1),XcornersWorld(i+1,1)],([YcornersWorld(i,1),YcornersWorld(i+1,1)]),'Color','b','LineWidth',2)
    end
end
hold off
axis equal
f.Name = 'Calculate Dynamic ROS';
movegui(f,'center')
f.MenuBar = 'none';
f.ToolBar = 'none';
f.NumberTitle='off';
f.Visible = 'on';

warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jframe=get(f,'javaframe');
jIcon=javax.swing.ImageIcon('icon ROS.gif');
jframe.setFigureIcon(jIcon);
%% callbacks
% getting the postion of the line
    function drawLines(source,callbackdata)
        global line1
        switch source.Label
            case 'Add Lines'
                line1=imline(gca);
        end
    end
% calculating the ROS and saving the result
    function calculate_Callback(src,event)
        global line1
        set(f, 'pointer', 'watch')
        drawnow;
        posline = getPosition(line1);
        Fframe=str2double(get(heditStart,'String'));
        Lframe=str2double(get(heditEnd,'String'));
        resultname=get(heditName,'String');
        localTotframes=Lframe-Fframe+1;
        results{resultrow,1}=resultname;results{resultrow,2}=('(Dynamic ROS)');
        resultrow=resultrow+1;
        %detectingt the intersection between this line and hte fire fronts
        linetime(1,2:localTotframes)=time(1,(Fframe:(Lframe-1)));
        linetime(1,1)=0;%consider the first frame as the 0 refrance 
        if Fframe>1
            linetime(1,2:localTotframes)=linetime(1,2:localTotframes)-time(1,Fframe-1);
        end
        Dist=zeros(1,localTotframes);
        Distadd=zeros(1,localTotframes);
        linelocalRofS=zeros(1,localTotframes-1);
        lineROfS=zeros(2,1);
        line_x_intersect=zeros(1,localTotframes);
        line_y_intersect=zeros(1,localTotframes);
        p1= worldToPoints(cameraParams, R, t, [posline(1,1),posline(1,2)]);
        p2= worldToPoints(cameraParams, R, t, [posline(2,1),posline(2,2)]);
        eqline=polyfit([posline(1,1) posline(2,1)],[posline(1,2) posline(2,2)],1);
        j=1;
        %finding the intersection between the prescribed line and the fire
        %front lines to calculate the passed distances 
        for i=Fframe:Lframe
            for k=1:ffpoints-1
                line_x_intersect(j,i-Fframe+1) = fzero(@(x) polyval(eqline-fflineeq(k,[(2*i-1),2*i]),x),0);
                line_y_intersect(j,i-Fframe+1) = polyval(fflineeq(k,[(2*i-1),2*i]),line_x_intersect(j,i-Fframe+1));
                if ((( line_x_intersect(1,i-Fframe+1)>=Xworld(k,i) && line_x_intersect(j,i-Fframe+1)<=Xworld(k+1,i) && line_y_intersect(j,i-Fframe+1)>=Yworld(k,i) && line_y_intersect(j,i-Fframe+1)<=Yworld(k+1,i))||...
                        (line_x_intersect(j,i-Fframe+1)<=Xworld(k,i) && line_x_intersect(j,i-Fframe+1)>=Xworld(k+1,i) && line_y_intersect(j,i-Fframe+1)<=Yworld(k,i) && line_y_intersect(j,i-Fframe+1)>=Yworld(k+1,i))||...
                        (line_x_intersect(j,i-Fframe+1)<=Xworld(k,i) && line_x_intersect(j,i-Fframe+1)>=Xworld(k+1,i) && line_y_intersect(j,i-Fframe+1)>=Yworld(k,i) && line_y_intersect(j,i-Fframe+1)<=Yworld(k+1,i))||...
                        (line_x_intersect(j,i-Fframe+1)>=Xworld(k,i) && line_x_intersect(j,i-Fframe+1)<=Xworld(k+1,i) && line_y_intersect(j,i-Fframe+1)<=Yworld(k,i) && line_y_intersect(j,i-Fframe+1)>=Yworld(k+1,i))))&&...
                        ((line_x_intersect(j,i-Fframe+1)>=posline(1,1) && line_x_intersect(j,i-Fframe+1)<=posline(2,1))||(line_x_intersect(j,i-Fframe+1)<=posline(1,1) && line_x_intersect(j,i-Fframe+1)>=posline(2,1)))
                    
                    break
                end
            end
        end
        %calculating the distance and RofS
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
        
        %saving the results into the excel sheet
        results{resultrow,1}=('avarage RofS');
        results{resultrow,2}=lineROfS(1,1);
        resultrow=resultrow+1;
        results{resultrow,1}=('the considered frame are from frame:');results{resultrow,2}=Fframe;results{resultrow,3}=('to frame');results{resultrow,4}=Lframe;
        resultrow=resultrow+1;
        if  localTotframes>2
            results{resultrow,1}=('The passed distances');
            resultrow=resultrow+1;
            results(resultrow,1:size(Distadd,2))=num2cell(Distadd(1,:));
            resultrow=resultrow+1;
            results{resultrow,1}=('The local RofS');
            resultrow=resultrow+1;
            results(resultrow,1:size(linelocalRofS,2))=num2cell(linelocalRofS(1,:));
            resultrow=resultrow+2;
        end
        %svaing a figure showing where this ROS was calculated
        figure('Visible','off');
        title('Postion of the lines where the ROS was calculated along them');
        hold on
        for i=1:numframes
            line(Xworld(:,i),(Yworld(:,i)),'Color','r')
        end
        line([posline(1,1),posline(2,1)],[posline(1,2),posline(2,2)],'Color','g','LineWidth',2);
        if shape~=4
            for i=1:cornersnum
                line([XcornersWorld(i,1),XcornersWorld(i+1,1)],([YcornersWorld(i,1),YcornersWorld(i+1,1)]),'Color','b','LineWidth',2)
            end
        end
        hold off
        axis equal
        saveas(gcf,[resultsfolder,'\',resultname,'(Dynamic ROS)'],'jpeg')
        set(heditResult,'String',[num2str(round(lineROfS(1,1))),' mm/s']);
        set(heditMax,'String',[num2str(round(max(linelocalRofS(1,:)))),' mm/s']);
        set(heditMin,'String',[num2str(round(min(linelocalRofS(1,:)))),' mm/s']);
        set(f, 'pointer', 'arrow')
    end
end