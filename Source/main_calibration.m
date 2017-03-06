function main_calibration
global XcornersWorld YcornersWorld answer_rep ffpoints fflineeq time R t cameraParams Xworld Yworld X Y filesim squareSize bwporig numframes framefiles checkf 
global Xcorners Ycorners project_name shape cornersnum localtime resultsfolder results imagesUsed drawfront repeatF images resultrow AngleWorld Lworld frame_corr frame
%% Calibration 
% detect checkboard corners
[imagePoints, boardSize,imagesUsed] = detectCheckerboardPoints(filesim);
%Generate the world coordinates of the checkerboard corners in the
% pattern-centric coordinate system, with the upper-left corner at (0,0).
worldPoints = generateCheckerboardPoints(boardSize, squareSize);
% Calibrate the camera.
cameraParams = estimateCameraParameters(imagePoints, worldPoints);

%remove lens distortion from the image with the fuel bed
im = undistortImage(bwporig, cameraParams,'OutputView', 'full');

%Get the extrinsics (rotation and translation) for fuel bed image
[imagePoints,boardSize] = detectCheckerboardPoints(im);
[R, t] = extrinsics(imagePoints, worldPoints, cameraParams);

%Do the same last two steps to the frames and save them
frame= cell(1,numframes);
for i=1:numframes
    %read the image with the fuel bed
    imframe = imread(framefiles{i});
    %remove lens distortion from the image
    im = undistortImage(imframe, cameraParams);
    frame{i} = im;
end
%% define the world coordinates for some points
XcornersWorld=zeros(4,1);
YcornersWorld=zeros(4,1);
if shape==2
    cornersnum=3;
    %world coordinates for the two points detected by the user
    for i=1:2
        imagePoint(1,1)=Xcorners(i,1);
        imagePoint(1,2)=Ycorners(i,1);
        worldPoint = pointsToWorld(cameraParams, R, t, imagePoint);
        XcornersWorld(i,1)=worldPoint(1,1);
        YcornersWorld(i,1)=worldPoint(1,2);
    end
    %The third point
    %s=atan(-((XcornersWorld(2,1)-XcornersWorld(1,1))/(YcornersWorld(2,1)-XcornersWorld(1,1)))) ;
    s=atan2((YcornersWorld(2,1)-YcornersWorld(1,1)),(XcornersWorld(2,1)-XcornersWorld(1,1)))+pi ;
    Angle=s+degtorad(AngleWorld);
    XcornersWorld(3,1)=Lworld*cos(Angle)+XcornersWorld(2,1);
    YcornersWorld(3,1)=Lworld*sin(Angle)+YcornersWorld(2,1);
    imagePoint= worldToPoints(cameraParams, R, t, [XcornersWorld(3,1),YcornersWorld(3,1)]);
    Xcorners(3,1)= imagePoint(1,1);
    Ycorners(3,1)= imagePoint(1,2);
    
    Xcorners(4,1)=Xcorners(1,1);
    Ycorners(4,1)=Ycorners(1,1);
    XcornersWorld(4,1)=XcornersWorld(1,1); %to finish a closed loop of points
    YcornersWorld(4,1)=YcornersWorld(1,1);
    
   
elseif shape==1
    cornersnum=4;
    %the two detected points by the user
    for i=1:2
        imagePoint(1,1)=Xcorners(i,1);
        imagePoint(1,2)=Ycorners(i,1);
        worldPoint = pointsToWorld(cameraParams, R, t, imagePoint);
        XcornersWorld(i,1)=worldPoint(1,1);
        YcornersWorld(i,1)=worldPoint(1,2);
    end
    %the other two points 
    s=atan2((YcornersWorld(2,1)-YcornersWorld(1,1)),(XcornersWorld(2,1)-XcornersWorld(1,1)))+pi ;
    Angle=s+(pi/2);
    XcornersWorld(4,1)=Lworld*cos(Angle)+XcornersWorld(1,1);
    YcornersWorld(4,1)=Lworld*sin(Angle)+YcornersWorld(1,1);
    XcornersWorld(3,1)=Lworld*cos(Angle)+XcornersWorld(2,1);
    YcornersWorld(3,1)=Lworld*sin(Angle)+YcornersWorld(2,1);
    for i=3:4
        imagePoint= worldToPoints(cameraParams, R, t, [XcornersWorld(i,1),YcornersWorld(i,1)]);
        Xcorners(i,1)= imagePoint(1,1);
        Ycorners(i,1)= imagePoint(1,2);
    end
    Xcorners(5,1)=Xcorners(1,1);
    Ycorners(5,1)=Ycorners(1,1);
    XcornersWorld(5,1)=XcornersWorld(1,1); %to finish a closed loop of points 
    YcornersWorld(5,1)=YcornersWorld(1,1); 
elseif shape==3
    for i=1:cornersnum
        imagePoint(1,1)=Xcorners(i,1);
        imagePoint(1,2)=Ycorners(i,1);
        worldPoint = pointsToWorld(cameraParams, R, t, imagePoint);
        XcornersWorld(i,1)=worldPoint(1,1);
        YcornersWorld(i,1)=worldPoint(1,2);
    end
    Xcorners(cornersnum+1,1)=Xcorners(1,1);
    Ycorners(cornersnum+1,1)=Ycorners(1,1);
    XcornersWorld(cornersnum+1,1)=XcornersWorld(1,1);
    YcornersWorld(cornersnum+1,1)=YcornersWorld(1,1);
end
if shape==1 || shape==2
    check_frame
    waitfor(checkf)
    if frame_corr==2;
        if shape==2
            s=atan2((YcornersWorld(2,1)-YcornersWorld(1,1)),(XcornersWorld(2,1)-XcornersWorld(1,1))) ;
            Angle=s+degtorad(AngleWorld);
            XcornersWorld(3,1)=Lworld*cos(Angle)+XcornersWorld(2,1);
            YcornersWorld(3,1)=Lworld*sin(Angle)+YcornersWorld(2,1);
            imagePoint= worldToPoints(cameraParams, R, t, [XcornersWorld(3,1),YcornersWorld(3,1)]);
            Xcorners(3,1)= imagePoint(1,1);
            Ycorners(3,1)= imagePoint(1,2);
        elseif shape==1
            s=atan2((YcornersWorld(2,1)-YcornersWorld(1,1)),(XcornersWorld(2,1)-XcornersWorld(1,1)))  ;
            Angle=s+(pi/2);
            XcornersWorld(4,1)=Lworld*cos(Angle)+XcornersWorld(1,1);
            YcornersWorld(4,1)=Lworld*sin(Angle)+YcornersWorld(1,1);
            XcornersWorld(3,1)=Lworld*cos(Angle)+XcornersWorld(2,1);
            YcornersWorld(3,1)=Lworld*sin(Angle)+YcornersWorld(2,1);
            for i=3:4
                imagePoint= worldToPoints(cameraParams, R, t, [XcornersWorld(i,1),YcornersWorld(i,1)]);
                Xcorners(i,1)= imagePoint(1,1);
                Ycorners(i,1)= imagePoint(1,2);
            end
        end
    end
end

%% Detect the fire front on each frame
if drawfront==1
namedrawfront=[project_name ' DFF'];
mkdir(resultsfolder,namedrawfront)
end
ffpoints=100; %number of points that will present the fire front as set of straight lines that connecting these points
% ffpoints can be increased if the used is going to detect the fire front
% by nore than 150 lines (which is very hard to happen)
X=zeros(ffpoints,numframes);
Y=zeros(ffpoints,numframes);
imagePoints=zeros(ffpoints,2);
Xworld=zeros(ffpoints,numframes);
Yworld=zeros(ffpoints,numframes);
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
    [X(:,1),Y(:,1),c] = improfile(ffpoints);
    imagePoints(:,1)=X(:,1);
    imagePoints(:,2)=Y(:,1);
    worldPoints = pointsToWorld(cameraParams, R, t, imagePoints);
    Xworld(:,1)=worldPoints(:,1);
    Yworld(:,1)=worldPoints(:,2);
    close
    repeat_selection
    waitfor(repeatF)
end
%saving the first frame with fire front
if drawfront==1
    ff = figure('visible','off'); haxesff=axes(ff);
    image(haxesff,frame{1});
    hold on
    line(haxesff,X(:,1),Y(:,1),'Color','g','LineWidth',1.2)
    hold off
    haxesff.Box='off';haxesff.XTick=[];haxesff.YTick=[];haxesff.ZTick=[];haxesff.XColor=[1 1 1];haxesff.YColor=[1 1 1];haxesff.Position=[0 0 1 1];
    FileName = [namedrawfront,'1.png'];
    frontFrame = getframe(haxesff);
    frontIamge = frame2im(frontFrame);
    frontIamge = imresize(frontIamge, [NaN 640]) ;
    imwrite(frontIamge,[resultsfolder,'\',namedrawfront,'\',FileName],'png')
    %print(ff, '-r110', '-dpng', [resultsfolder,'\',namedrawfront,'\',FileName]);
    close(ff)
end
%for the rest of the frames
for i=2:numframes
    answer_rep=2;
    while answer_rep==2
        figure('units','normalized','outerposition',[0 0 1 1],'NumberTitle','off','MenuBar','none','ToolBar','none')
        imshow(frame{i},'InitialMagnification', 'fit');
        title(sprintf('Detect the Fire Front on Frame no %d' , i));
        hold on
        line(X(:,i-1),Y(:,i-1),'Color','g')
        for j=1:cornersnum
            line([Xcorners(j,1),Xcorners(j+1,1)],([Ycorners(j,1),Ycorners(j+1,1)]),'Color','b','LineWidth',2)
        end
        hold off
        [X(:,i),Y(:,i),c] = improfile(ffpoints);
        imagePoints(:,1)=X(:,i);
        imagePoints(:,2)=Y(:,i);
        worldPoints = pointsToWorld(cameraParams, R, t, imagePoints);
        Xworld(:,i)=worldPoints(:,1);
        Yworld(:,i)=worldPoints(:,2);
        close
        repeat_selection
        waitfor(repeatF)
    end
    %saving the frames with fire front
    if drawfront==1
        ff = figure('visible','off'); haxesff=axes(ff);
        image(haxesff,frame{i});
        hold on
        for j=1:i
            line(X(:,j),Y(:,j),'Color','g','LineWidth',1.5)
        end
        hold off
        haxesff.Box='off';haxesff.XTick=[];haxesff.YTick=[];haxesff.ZTick=[];haxesff.XColor=[1 1 1];haxesff.YColor=[1 1 1];haxesff.Position=[0 0 1 1];
        FileName = sprintf([namedrawfront,'%d.png'], i);
        frontFrame = getframe(haxesff);
        frontIamge = frame2im(frontFrame);
        frontIamge = imresize(frontIamge, [NaN 640]) ;
        imwrite(frontIamge,[resultsfolder,'\',namedrawfront,'\',FileName],'png')
        %print(ff, '-r110', '-dpng', [resultsfolder,'\',namedrawfront,'\',FileName]);
        close(ff) 
    end
end
%making the an accumlating time
time= zeros(1,numframes-1);
time(1,1)=localtime(1,1);
for i=1:numframes-2
    time(1,i+1)=time(1,i)+localtime(1,i+1);
end
fflineeq=zeros(ffpoints-1,numframes*2);
%determining the fire front lines equations
for i=1:numframes
    for j=1:ffpoints-1
        fflineeq(j,[(2*i-1),2*i]) = polyfit([Xworld(j,i) Xworld(j+1,i)],[Yworld(j,i) Yworld((j+1),i)],1);
    end
end

save([resultsfolder,'\',project_name],'XcornersWorld', 'YcornersWorld', 'ffpoints', 'fflineeq', 'time', 'R', 't', 'cameraParams', 'Xworld', 'Yworld', 'X', 'Y',...
       'numframes', 'Xcorners', 'Ycorners', 'shape', 'cornersnum')

results{1,1}='Project Name: '; results{1,2}=project_name;
results{2,1}='Number of images used on the calibraion is: ';results{2,2}=[num2str(length(imagesUsed(imagesUsed==1))),' from ',num2str(size(images,2))];
results{3,1}='Number of fire front frames is:'; results{3,2}=numframes;
end