function man_detect
global XcornersWorld YcornersWorld answer_rep ffpoints fflineeq time R t cameraParams Xworld Yworld X Y squareSize bwporig numframes framefiles checkf calibrationFile
global Xcorners Ycorners project_name shape cornersnum localtime resultsfolder results imagesUsed drawfront repeatF images resultrow AngleWorld Lworld frame_corr frame
%% Detect the fire front on each frame
if drawfront==1
    namedrawfront=[project_name ' DFF'];folder=fullfile(resultsfolder,namedrawfront);
    if exist(folder)==0
        mkdir(folder)
    end
end

ffpoints=100; %number of points that will present the fire front as set of straight lines that connecting these points
% ffpoints can be increased if the used is going to detect the fire front
% by nore than 150 lines (which is very hard to happen)
X=cell(1,numframes);
Y=cell(1,numframes);
Xworld=cell(1,numframes);
Yworld=cell(1,numframes);
%for the first frame
answer_rep=2;
while answer_rep==2
    figure('units','normalized','outerposition',[0 0 1 1],'NumberTitle','off','MenuBar','none','ToolBar','none')
    imshow(frame{1},'InitialMagnification', 'fit');
    title(sprintf('Detect the Fire Front on Frame no %d' , 1));
    if shape~=4
        hold on
        for j=1:cornersnum
            line([Xcorners(j,1),Xcorners(j+1,1)],([Ycorners(j,1),Ycorners(j+1,1)]),'Color','b','LineWidth',2)
        end
        hold off
    end
    [X{1},Y{1},c] = improfile(ffpoints);
    imagePoints(:,1)=X{1};
    imagePoints(:,2)=Y{1};
    worldPoints = pointsToWorld(cameraParams, R, t, imagePoints);
    Xworld{1}=worldPoints(:,1);
    Yworld{1}=worldPoints(:,2);
    close
    repeat_selection
    waitfor(repeatF)
end
%saving the first frame with fire front
if drawfront==1
    ff = figure('visible','off'); haxesff=axes(ff);
    image(haxesff,frame{1});
    hold on
    line(haxesff,X{1},Y{1},'Color','g','LineWidth',1.2)
    hold off
    haxesff.Box='off';haxesff.XTick=[];haxesff.YTick=[];haxesff.ZTick=[];haxesff.XColor=[1 1 1];haxesff.YColor=[1 1 1];haxesff.Position=[0 0 1 1];
    FileName = [namedrawfront,'1.png'];
    frontFrame = getframe(haxesff);
    frontIamge = frame2im(frontFrame);
    frontIamge = imresize(frontIamge, [NaN 640]) ;
    imwrite(frontIamge,[resultsfolder,'\',namedrawfront,'\',FileName],'png')
    %print(ff, '-r110', '-dpng', [resultsfolder,'\',namedrawfront,'\',FileName]);
end

%for the rest of the frames
for i=2:numframes
    answer_rep=2;
    while answer_rep==2
        figure('units','normalized','outerposition',[0 0 1 1],'NumberTitle','off','MenuBar','none','ToolBar','none')
        imshow(frame{i},'InitialMagnification', 'fit');
        title(sprintf('Detect the Fire Front on Frame no %d' , i));
        hold on
        line(X{i-1},Y{i-1},'Color','g')
        for j=1:cornersnum
            line([Xcorners(j,1),Xcorners(j+1,1)],([Ycorners(j,1),Ycorners(j+1,1)]),'Color','b','LineWidth',2)
        end
        hold off
        [X{i},Y{i},c] = improfile(ffpoints);
        imagePoints(:,1)=X{i};
        imagePoints(:,2)=Y{i};
        worldPoints = pointsToWorld(cameraParams, R, t, imagePoints);
        Xworld{i}=worldPoints(:,1);
        Yworld{i}=worldPoints(:,2);
        close
        repeat_selection
        waitfor(repeatF)
    end
    
    %saving the frames with fire front
    if drawfront==1
        image(haxesff,frame{i});
        hold on
        for j=1:i
            line(X{j},Y{j},'Color','g','LineWidth',1.2)
        end
        for j=1:cornersnum
            line(haxesff,[Xcorners(j,1),Xcorners(j+1,1)],([Ycorners(j,1),Ycorners(j+1,1)]),'Color','b','LineWidth',2)
        end
        hold off
        haxesff.Box='off';haxesff.XTick=[];haxesff.YTick=[];haxesff.ZTick=[];haxesff.XColor=[1 1 1];haxesff.YColor=[1 1 1];haxesff.Position=[0 0 1 1];
        FileName = sprintf([namedrawfront,'%d.png'], i);
        frontFrame = getframe(haxesff);
        frontIamge = frame2im(frontFrame);
        frontIamge = imresize(frontIamge, [NaN 640]) ;
        imwrite(frontIamge,[resultsfolder,'\',namedrawfront,'\',FileName],'png')
        %print(ff, '-r110', '-dpng', [resultsfolder,'\',namedrawfront,'\',FileName]);
    end
end
if drawfront==1
    close(ff)
end


%determining the fire front lines equations
fflineeq=cell(1,numframes);
for i=1:numframes
    for j=1:ffpoints-1
        fflineeq{i}(j,:) = polyfit([Xworld{i}(j,1) Xworld{i}(j+1,1)],[Yworld{i}(j,1) Yworld{i}(j+1,1)],1);
    end
end

save([resultsfolder,'\',project_name],'XcornersWorld', 'YcornersWorld', 'ffpoints', 'fflineeq', 'time', 'R', 't', 'cameraParams', 'Xworld', 'Yworld', 'X', 'Y',...
       'numframes', 'Xcorners', 'Ycorners', 'shape', 'cornersnum')

results{1,1}='Session Name: '; results{1,2}=project_name;
results{2,1}='Number of images used on the calibraion is: ';results{2,2}=[num2str(length(imagesUsed(imagesUsed==1))),' from ',num2str(size(images,2))];
results{3,1}='Number of fire front frames is:'; results{3,2}=numframes;
end