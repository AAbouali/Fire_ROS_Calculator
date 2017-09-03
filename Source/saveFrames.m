function saveFrames
global startTime interval endTime  Savefolder hwait videoObject vidHeight

FrameRate = videoObject.FrameRate;
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