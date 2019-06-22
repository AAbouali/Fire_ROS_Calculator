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

function saveFrames
global startTime interval endTime  Savefolder hwait videoObject vidHeight frame
%%
FrameRate = round(videoObject.FrameRate);
vidDuration = videoObject.Duration;

startTimeSec=startTime(1,1)*60+startTime(1,2);
startTimeFrames=startTimeSec*FrameRate;
endTimeSec=endTime(1,1)*60+endTime(1,2);
saveDuration=endTimeSec-startTimeSec;
NumSaveFrames=ceil(saveDuration/interval);

saveFrame=read(videoObject,1);
FileName = '0ref.png';
saveFrame=imresize(saveFrame,[vidHeight NaN]);
imwrite(saveFrame,[Savefolder,'\',FileName],'png')

for i=0:NumSaveFrames-1
    waitbar((i+1)/NumSaveFrames,hwait,sprintf('Saving frame %d ...',i+1))
    frame=i*FrameRate*interval+startTimeFrames;
    if frame==0
        saveFrame=read(videoObject,1);
    else
        saveFrame=read(videoObject,frame);
    end
    FileName = [sprintf('%d', i+1),sprintf('(%ds).png', i*interval)];
    saveFrame=imresize(saveFrame,[vidHeight NaN]);
    imwrite(saveFrame,[Savefolder,'\',FileName],'png')
end

fid = fopen([Savefolder,'\time.txt'],'wt');
ref=['Time Lap:  ',num2str(interval),' s']; fprintf(fid,'%s\n',ref);
ref=['Start extraction time:  ',num2str(startTime(1,1)),':',num2str(startTime(1,2))]; fprintf(fid,'%s\n',ref);
ref=['End extraction time:  ',num2str(endTime(1,1)),':',num2str(endTime(1,2))]; fprintf(fid,'%s\n',ref);
fclose(fid);
end