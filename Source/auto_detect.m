function auto_detect
global  fflineeq  R t cameraParams Xworld Yworld X Y numframes hwait BI MaskROI XcornersWorld YcornersWorld ffpoints time squareSize
global Xcorners Ycorners project_name resultsfolder results imagesUsed drawfront  images  frame  appPath Bnd shape cornersnum detSens

if drawfront==1
    namedrawfront=[project_name ' DFF'];folder=fullfile(resultsfolder,namedrawfront);
    if exist(folder)==0
        mkdir(folder)
    end
end

X=cell(1,numframes);
Y=cell(1,numframes);
Xworld=cell(1,numframes);
Yworld=cell(1,numframes);
%% processing the frames
% convert frames to binaries
BI=cell(1,numframes);
for i=1:numframes
    BW = rgb2gray(frame{i});
    BI{i} = imbinarize(BW,detSens);
end

MaskROI = roipoly(BI{1},Xcorners(1:(end-1),1),Ycorners(1:(end-1),1)); % determine the region of interest

%process the first frame
Bnd=cell(1,numframes);
BI{i} = imclose(BI{i},strel('disk',6));
BI{i} = imfill(BI{i},'holes');
BI{1}(MaskROI == 0) = 0;
BI{1} = imclose(BI{1},strel('disk',6));
BI{1} = imfill(BI{1},'holes');
BI{1}(MaskROI == 0) = 0;
[Bnd{1},L,N] = bwboundaries(BI{1},'noholes',8);
if N>1
    hW = warndlg(sprintf('More than one fire parameter was detected on frame %d',1),'Warning!','modal');
    jframe=get(hW,'javaframe'); jframe.setFigureIcon(javax.swing.ImageIcon(fullfile(appPath,'icon ROS.gif')));
    SizeN=zeros(1,N);
    for k=1:N
        SizeN(1,k)=size(Bnd{1}{k},1);
    end
    Bnd{1}{1}=Bnd{1}{find(SizeN==max(SizeN))};
end
if isempty(Bnd{1})==0
    X{1}=Bnd{1}{1}(:,2);
    Y{1}=Bnd{1}{1}(:,1);
    %figure; imshow(BI{1}); C = imfuse(frame{1},BI{1}); figure; imshow(C)
    
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
        [Bnd{i},L,N] = bwboundaries(BI{i},'noholes',8);
        if N>1
            hW = warndlg(sprintf('More than one fire parameter was detected on frame %d',i),'Warning!','modal');
            jframe=get(hW,'javaframe'); jframe.setFigureIcon(javax.swing.ImageIcon(fullfile(appPath,'icon ROS.gif')));
            SizeN=zeros(1,N);
            for k=1:N
                SizeN(1,k)=size(Bnd{i}{k},1);
            end
            Bnd{i}{1}=Bnd{i}{find(SizeN==max(SizeN))};
        end
        X{i}=Bnd{i}{1}(:,2);
        Y{i}=Bnd{i}{1}(:,1);
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
    
    
    for i=1:numframes
        imagePoints=[];
        imagePoints(:,1)=X{i}(:,1);
        imagePoints(:,2)=Y{i}(:,1);
        worldPoints = pointsToWorld(cameraParams, R, t, imagePoints);
        Xworld{i}=worldPoints(:,1);
        Yworld{i}=worldPoints(:,2);
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
                line(haxesff,X{j}(:,1),Y{j}(:,1),'Color','g','LineWidth',1.2)
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
    
    fflineeq=cell(1,numframes);
    %determining the fire front lines equations
    for i=1:numframes
        waitbar((2*numframes+i)/(numframes*3),hwait,sprintf('Determining fire front X-Y coordinates for frame %d ...',i))
        for j=1:size(Xworld{i},1)-1
            fflineeq{i}(j,:) = polyfit([Xworld{i}(j,1) Xworld{i}(j+1,1)],[Yworld{i}(j,1) Yworld{i}(j+1,1)],1);
        end
    end
    
    save([resultsfolder,'\',project_name],'XcornersWorld', 'YcornersWorld', 'ffpoints', 'fflineeq', 'time', 'R', 't', 'cameraParams', 'Xworld', 'Yworld', 'X', 'Y',...
        'numframes', 'Xcorners', 'Ycorners', 'shape', 'cornersnum')
    
    results{1,1}='Session Name: '; results{1,2}=project_name;
    results{2,1}='Number of images used on the calibraion is: ';results{2,2}=[num2str(length(imagesUsed(imagesUsed==1))),' from ',num2str(size(images,2))];
    results{3,1}='Number of fire front frames is:'; results{3,2}=numframes;
else
    hW = warndlg(sprintf('No fire front detected on the first frame'),'Error!','modal');
    jframe=get(hW,'javaframe'); jframe.setFigureIcon(javax.swing.ImageIcon(fullfile(appPath,'icon ROS.gif')));
end
end



