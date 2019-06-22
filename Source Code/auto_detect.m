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

function auto_detect
global  fflineeq  R t cameraParams Xworld Yworld X Y numframes hwait BI MaskROI XcornersWorld YcornersWorld ffpoints time squareSize resultrow burndarea
global Xcorners Ycorners project_name resultsfolder results imagesUsed drawfront  images  frame  appPath Bnd shape cornersnum detSens Nfires fireLastFrame namedrawfront

if drawfront==1
    namedrawfront=[project_name ' DFF'];folder=fullfile(resultsfolder,namedrawfront);
    if exist(folder)==0
        mkdir(folder)
    end
end

X=cell(Nfires,numframes);
Y=cell(Nfires,numframes);
Xworld=cell(Nfires,numframes);
Yworld=cell(Nfires,numframes);
%% processing the frames
% convert frames to binaries
BI=cell(1,numframes);
fireLastFrame(1,1:Nfires)=numframes;
for i=1:numframes
    BW = rgb2gray(frame{i});
    BI{i} = imbinarize(BW,detSens);
end

MaskROI = roipoly(BI{1},Xcorners(1:(end-1),1),Ycorners(1:(end-1),1)); % determine the region of interest

%process the first frame
Bn=cell(1,numframes);
BI{1} = imclose(BI{1},strel('disk',6));
BI{1} = imfill(BI{1},'holes');
BI{1}(MaskROI == 0) = 0;
BI{1} = imclose(BI{1},strel('disk',6));
BI{1} = imfill(BI{1},'holes');
BI{1}(MaskROI == 0) = 0;
[Bn,~,N] = bwboundaries(BI{1},'noholes',8);
Bnd=cell(Nfires);
if N>1
    SizeDetFires=zeros(1,N);
    for k=1:N
        %SizeDetFires(1,k)=bwarea(Bn{k,1});
        %SizeDetFires(1,k)=numel(Bn{k,1});
        SizeDetFires(1,k)=polyarea(Bn{k}(:,2), Bn{k}(:,1));
    end
    [~,order]=sort(SizeDetFires,'descend');
    PrevSizeDetFires=zeros(1,Nfires);
    for k=1:Nfires
        Bnd{k}=Bn{order(1,k)};
        PrevSizeDetFires(1,k)=SizeDetFires(1,order(1,k));
    end
else
    hW = warndlg(sprintf('No %d fires detected on the first frame',Nfires),'Error!','modal');
    jframe=get(hW,'javaframe'); jframe.setFigureIcon(javax.swing.ImageIcon(fullfile(appPath,'icon ROS.gif')));
    return
end
%saving the coordinates of the fire peramter
for k=1:Nfires
    X{k,1}=Bnd{k}(:,2);
    Y{k,1}=Bnd{k}(:,1);
end
%figure; imshow(BI{1}); C = imfuse(frame{1},BI{1}); figure; imshow(C)

%checking that it detected a fire on the first frame!
if isempty(Bnd{1})==1
    hW = warndlg(sprintf('No fire front detected on the first frame'),'Error!','modal');
    jframe=get(hW,'javaframe'); jframe.setFigureIcon(javax.swing.ImageIcon(fullfile(appPath,'icon ROS.gif')));
    return
end

%process the rest of the frames
for i=2:numframes
    BI{i} = imclose(BI{i},strel('disk',6));
    BI{i} = imfill(BI{i},'holes');
    BI{i}(MaskROI == 0) = 0;
    diff=abs(BI{i}-BI{i-1});
    BI{i}=BI{i-1}+diff;
    BI{i} = imclose(BI{i},strel('disk',6));
    BI{i} = imfill(BI{i},'holes');
    BI{i}(MaskROI == 0) = 0;
    [Bn,L,N] = bwboundaries(BI{i},'noholes',8);
    %figure;
    %imshow(label2rgb(L, @jet, [.5 .5 .5]))
    %hold on
    %for k = 1:length(Bn)
    %    boundary = Bn{k};
    %    plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
    %end
    %hold off
    SizeDetFires=zeros(1,N);
    for s=1:N
        %SizeDetFires(1,s)=numel(Bn{s,1});
        SizeDetFires(1,s)=polyarea(Bn{s}(:,2), Bn{s}(:,1));
    end
    if N<Nfires
        SizeDetFires(1,s+1:Nfires)=0;
    end
    [~,order]=sort(SizeDetFires,'descend');
    
    for k=1:Nfires
        if SizeDetFires(order(1,k))>=PrevSizeDetFires(1,k)&& i<=fireLastFrame(1,k)
            Bnd{k}=Bn{order(1,k)};
        elseif i<=fireLastFrame(1,k)
            fireLastFrame(1,k)=i-1;
        end
    end
    PrevSizeDetFires=zeros(1,Nfires);
    for k=1:Nfires
        PrevSizeDetFires(1,k)=SizeDetFires(1,order(1,k));
    end
    for k=1:Nfires
        if i<=fireLastFrame(1,k)
            X{k,i}=Bnd{k}(:,2);
            Y{k,i}=Bnd{k}(:,1);
        end
    end
    waitbar((numframes+i)/(numframes*3),hwait,sprintf('Detecting fire front on frame %d ...',i))
    %figure; imshow(BI{i})
    %C = imfuse(frame{i},BI{i}); figure; imshow(C)
end


%figure; imshow(frame{end})
%hold on
%for k = 1:numframes
%   plot(Bnd{k}{1}(:,2), Bnd{k}{1}(:,1), 'w', 'LineWidth', 1)
%end
%hold off

for k=1:Nfires
    for i=1:fireLastFrame(1,k)
        imagePoints=[];
        imagePoints(:,1)=X{k,i}(:,1);
        imagePoints(:,2)=Y{k,i}(:,1);
        worldPoints = pointsToWorld(cameraParams, R, t, imagePoints);
        Xworld{k,i}=worldPoints(:,1);
        Yworld{k,i}=worldPoints(:,2);
    end
end

%figure;
%hold on
%for i=1:numframes
%    line(Xworld{i}(:,1),(Yworld{i}(:,1)),'Color','r')
%end
%hold off

%saving the frames with drawn fire front
if drawfront==1
    waitbar((2*numframes)/(numframes*3),hwait,'Saving frames with drawn fire fronts ...')
    fff = figure('visible','off'); haxesff=axes(fff);
    for i=1:numframes
        image(haxesff,frame{i});
        hold on
        for j=1:i
            for k=1:Nfires
                if j<=fireLastFrame(1,k)
                    line(haxesff,X{k,j}(:,1),Y{k,j}(:,1),'Color','g','LineWidth',1.2)
                end
            end
        end
        for j=1:cornersnum
            line(haxesff,[Xcorners(j,1),Xcorners(j+1,1)],([Ycorners(j,1),Ycorners(j+1,1)]),'Color','b','LineWidth',2)
        end
        hold off
        haxesff.Box='off';haxesff.XTick=[];haxesff.YTick=[];haxesff.ZTick=[];haxesff.XColor=[1 1 1];haxesff.YColor=[1 1 1];haxesff.Position=[0 0 1 1];
        FileName = sprintf([namedrawfront,'%d.png'], i);
        frontFrame = getframe(haxesff);
        frontIamge = frame2im(frontFrame);
        frontIamge = imresize(frontIamge, [NaN size(frame{i},2)]) ;
        imwrite(frontIamge,[resultsfolder,'\',namedrawfront,'\',FileName],'png')
        %print(ff, '-r110', '-dpng', [resultsfolder,'\',namedrawfront,'\',FileName]);
    end
    close(fff)
end

%determining the fire front lines equations
fflineeq=cell(Nfires,numframes);
burndarea=cell(Nfires,numframes);
for k=1:Nfires
    for i=1:fireLastFrame(1,k)
        waitbar((2*numframes+i)/(numframes*3),hwait,sprintf('Determining fire front X-Y coordinates for frame %d ...',i))
        for j=1:size(Xworld{k,i},1)-1
            fflineeq{k,i}(j,:) = polyfit([Xworld{k,i}(j,1) Xworld{k,i}(j+1,1)],[Yworld{k,i}(j,1) Yworld{k,i}(j+1,1)],1);
        end
        %determining the area burned on each frame
        burndarea{k,i}=(polyarea(Xworld{k,i},Yworld{k,i}))*10^-6;
    end
end


results{1,1}='Session Name: '; results{1,2}=project_name;
results{2,1}='Number of images used on the calibraion is: ';results{2,2}=[num2str(length(imagesUsed(imagesUsed==1))),' from ',num2str(size(images,2))];
results{3,1}='Number of fire front frames is:'; results{3,2}=numframes;
results{5,1}='Area Burned on each frame'; results{6,1}='frame'; 
for i=1:numframes
results{6,1+i}=num2str(i);
end
for i=1:Nfires
    results{7+i-1,1}=sprintf('Fire%d Area (m^2)',i);
end
for k=1:Nfires
    for i=1:fireLastFrame(1,k)
        results{7+k-1,1+i}= num2str(burndarea{k,i});
    end
end
resultrow=8+Nfires;

save([resultsfolder,'\',project_name],'XcornersWorld', 'YcornersWorld', 'ffpoints', 'fflineeq', 'time', 'R', 't', 'cameraParams', 'Xworld', 'Yworld', 'X', 'Y',...
    'numframes', 'Xcorners', 'Ycorners', 'shape', 'cornersnum', 'Nfires', 'fireLastFrame', 'results', 'resultrow' )

end



