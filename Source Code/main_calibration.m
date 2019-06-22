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

function main_calibration
global XcornersWorld YcornersWorld answer_rep ffpoints fflineeq time R t cameraParams Xworld Yworld X Y squareSize bwporig numframes framefiles checkf calibrationFile hwait man_mod
global Xcorners Ycorners project_name shape cornersnum localtime resultsfolder results imagesUsed drawfront repeatF images resultrow AngleWorld Lworld CLworld frame 
%% Calibration 
% detect checkboard corners
load(calibrationFile)
%remove lens distortion from the image with the fuel bed
im = undistortImage(bwporig, cameraParams,'OutputView', 'full');

%Get the extrinsics (rotation and translation) for fuel bed image
[imagePoints,boardSize] = detectCheckerboardPoints(im);
worldPoints = generateCheckerboardPoints(boardSize, squareSize);
[R, t] = extrinsics(imagePoints, worldPoints, cameraParams);

%Do the same last two steps to the frames and save them
frame= cell(1,numframes);
for i=1:numframes
    %read the image with the fuel bed
    imframe = imread(framefiles{i});
    %remove lens distortion from the image
    %im = undistortImage(imframe, cameraParams);
    frame{i} = imframe;
end
if man_mod==0
waitbar((numframes*0.5)/(numframes*3),hwait,'Calibrating...')
end
%% define the world coordinates for some points
if shape==2
    cornersnum=3;
    XcornersWorld=zeros(cornersnum+1,1);
    YcornersWorld=zeros(cornersnum+1,1);
    %world coordinates for the two points detected by the user
    for i=1:2
        imagePoint(1,1)=Xcorners(i,1);
        imagePoint(1,2)=Ycorners(i,1);
        worldPoint = pointsToWorld(cameraParams, R, t, imagePoint);
        XcornersWorld(i,1)=worldPoint(1,1);
        YcornersWorld(i,1)=worldPoint(1,2);
    end
    %correcting the length of the detected edge according to the entered length
    %CCLworld=sqrt((XcornersWorld(1,1)-XcornersWorld(2,1))^2+(YcornersWorld(1,1)-YcornersWorld(2,1))^2);
    %Ldiff=CLworld-CCLworld;
    %newX(1,1)=XcornersWorld(2,1)+(XcornersWorld(2,1)-XcornersWorld(1,1))/CCLworld*Ldiff;
    %newY(1,1)=YcornersWorld(2,1)+(YcornersWorld(2,1)-YcornersWorld(1,1))/CCLworld*Ldiff;
    %newX(1,2)=XcornersWorld(1,1)-(XcornersWorld(2,1)-XcornersWorld(1,1))/CCLworld*Ldiff;
    %newY(1,2)=YcornersWorld(1,1)-(YcornersWorld(2,1)-YcornersWorld(1,1))/CCLworld*Ldiff;
    %XcornersWorld(1,1)=newX(1,1);XcornersWorld(2,1)=newX(1,2);YcornersWorld(1,1)=newY(1,1);YcornersWorld(2,1)=newY(1,2);
    %imagePoint= worldToPoints(cameraParams, R, t, [XcornersWorld(1,1),YcornersWorld(1,1)]);
    %Xcorners(1,1)= imagePoint(1,1); Ycorners(1,1)= imagePoint(1,2);
    %imagePoint= worldToPoints(cameraParams, R, t, [XcornersWorld(2,1),YcornersWorld(2,1)]);
    %Xcorners(2,1)= imagePoint(1,1); Ycorners(2,1)= imagePoint(1,2);
    
    %The third point
    %s=atan(-((XcornersWorld(2,1)-XcornersWorld(1,1))/(YcornersWorld(2,1)-XcornersWorld(1,1)))) ;
    s=atan2((YcornersWorld(2,1)-YcornersWorld(1,1)),(XcornersWorld(2,1)-XcornersWorld(1,1)))+pi ;
    Angle=s+deg2rad(AngleWorld);
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
    XcornersWorld=zeros(cornersnum+1,1);
    YcornersWorld=zeros(cornersnum+1,1);
    %the two detected points by the user
    for i=1:2
        imagePoint(1,1)=Xcorners(i,1);
        imagePoint(1,2)=Ycorners(i,1);
        worldPoint = pointsToWorld(cameraParams, R, t, imagePoint);
        XcornersWorld(i,1)=worldPoint(1,1);
        YcornersWorld(i,1)=worldPoint(1,2);
    end
    %correcting the length of the detected edge according to the entered length
    %CCLworld=sqrt((XcornersWorld(1,1)-XcornersWorld(2,1))^2+(YcornersWorld(1,1)-YcornersWorld(2,1))^2);
    %Ldiff=CLworld-CCLworld;
    %newX(1,1)=XcornersWorld(2,1)+(XcornersWorld(2,1)-XcornersWorld(1,1))/CCLworld*Ldiff;
    %newY(1,1)=YcornersWorld(2,1)+(YcornersWorld(2,1)-YcornersWorld(1,1))/CCLworld*Ldiff;
    %newX(1,2)=XcornersWorld(1,1)-(XcornersWorld(2,1)-XcornersWorld(1,1))/CCLworld*Ldiff;
    %newY(1,2)=YcornersWorld(1,1)-(YcornersWorld(2,1)-YcornersWorld(1,1))/CCLworld*Ldiff;
    %XcornersWorld(1,1)=newX(1,1);XcornersWorld(2,1)=newX(1,2);YcornersWorld(1,1)=newY(1,1);YcornersWorld(2,1)=newY(1,2);
    %imagePoint= worldToPoints(cameraParams, R, t, [XcornersWorld(1,1),YcornersWorld(1,1)]);
    %Xcorners(1,1)= imagePoint(1,1); Ycorners(1,1)= imagePoint(1,2);
    %imagePoint= worldToPoints(cameraParams, R, t, [XcornersWorld(2,1),YcornersWorld(2,1)]);
    %Xcorners(2,1)= imagePoint(1,1); Ycorners(2,1)= imagePoint(1,2);
    
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
    XcornersWorld=zeros(cornersnum+1,1);
    YcornersWorld=zeros(cornersnum+1,1);
    for i=1:cornersnum+1
        imagePoint(1,1)=Xcorners(i,1);
        imagePoint(1,2)=Ycorners(i,1);
        worldPoint = pointsToWorld(cameraParams, R, t, imagePoint);
        XcornersWorld(i,1)=worldPoint(1,1);
        YcornersWorld(i,1)=worldPoint(1,2);
    end
end

if shape==1 || shape==2
    check_frame
    waitfor(checkf)
end

%making the an accumlating time
time= zeros(1,numframes-1);
time(1,1)=localtime(1,1);
for i=1:numframes-2
    time(1,i+1)=time(1,i)+localtime(1,i+1);
end
if man_mod==0
waitbar((numframes)/(numframes*3),hwait,'Detecting fire front on frame 1 ...')
end
end