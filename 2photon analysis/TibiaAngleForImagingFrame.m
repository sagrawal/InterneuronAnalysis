%Calculates the average tibia angle for each imaging frame and plot both
%the DFF and tibia angle. Use scale factor to plot DFF and tibia angle at a
%similar scale. (Scale factor multiply the DFF value)
%
%ConvertedTibiaAngleFile: output from the ConvertTibiaAngle_FindMoveOnset.m
%DetectCameraAndImagingFramesFile: output from the
%DetectCameraAndImagingFrames.m
%DFFfile: ouput file from the SelectROICalculateDFF.m or other script that
%shows DFF
%ScaleFactor: Factor to multiply the DFF trace. Should be around 30 to 100.
function []=TibiaAngleForImagingFrame(ConvertedTibiaAngleFile,DetectCameraAndImagingFramesFile,DFFfile,ScaleFactor)
load(ConvertedTibiaAngleFile);
load(DetectCameraAndImagingFramesFile);

%use the CameraMinusImageIndex and get the last camera frame before each
%end of the imaging frame.
PositiveIndex=CameraMinusImageIndex>0;
ImageInCameraIndex(PositiveIndex)=ImageInCameraIndex(PositiveIndex)-1;
%Now ImageInCameraIndex shows the camera frame that was right before the
%end of the image acquisition.

%Go through each StartVF and convert it to the imaging frame where the move
%occured and the offset measured from the end of the frame.

%Initialize matrix.
StartIF=zeros(size(StartVF,1),2);
for n=1:size(StartVF,1)
    TimeDifference=ImageInCameraIndex-StartVF(n);
    %Find the point closest to zero.
    [Y,I]=min(abs(TimeDifference));
    StartIF(n,1)=I;
    StartIF(n,2)=TimeDifference(I);
    %The above positive number shows how many video frames have past since
    %the beginning of the move and the end of the image.
    
end

%Calculate the mean leg angle for each image.
%If there is no camera image that corresponds to the calcium imaging frame,
%the tibia angle will be set to -100 and we will have an index to show the
%invalid point.

ImageLegAngle=ones(size(ImageInCameraIndex,1),1);
ImageLegAngle=ImageLegAngle*-100;%Set to -100 so we know the missing values.

%If ImageInCameraIndex is 0 for few frames (as when the imaging starts
%earlier than the camera), skip those frames.
ExtraFrames=ImageInCameraIndex==0;
[Y,StartFrame]=min(ExtraFrames);

%We also have times when the video stops before the imaging.
if ImageInCameraIndex(end)>size(RealAngle,1)
    
    ExtraFramesBack=ImageInCameraIndex>size(RealAngle,1);
    [Y,EndFrame]=max(ExtraFramesBack);
    EndFrame=EndFrame-1;
else
    EndFrame=size(ImageInCameraIndex,1);
end


%Put the angles in radian for the use of circ_mean.
RealAngleR=deg2rad(RealAngle);


%First frame will be calculated differently.
if StartFrame==1
    if ImageInCameraIndex(1)>=22
        ImageLegAngle(1)=circ_mean(RealAngleR(ImageInCameraIndex(1)-21:ImageInCameraIndex(1)));
    else
        ImageLegAngle(1)=circ_mean(RealAngleR(1:ImageInCameraIndex(1)));
    end
    StartFrame=StartFrame+1;
end

for n=StartFrame:EndFrame%This can only go as long as we have ImageInCameraIndex.
    
    ImageLegAngle(n)=circ_mean(RealAngleR(ImageInCameraIndex(n-1)+1:ImageInCameraIndex(n)));
end

%Put it back to the degrees.
ImageLegAngle=rad2deg(ImageLegAngle);

%In case it wraps around (for angles larger than 180), we need to unwrap
%it. May need to change this value in some prep but for now we keep it at
%0.
NIndexAll=ImageLegAngle<0;
ImageLegAngle(NIndexAll)=ImageLegAngle(NIndexAll)+360;

load(DFFfile);

%some data files have multiple clusters, want only the "signal"
%cluster
if size(DFF1, 1)>1
    [~, signalcluster] = max(var(DFF1'));
    signalDFF = DFF1(signalcluster, :);
else
    signalDFF = DFF1(1, :);
end

figure('position',[400 400 800 400])
plot(ImageLegAngle)
pbaspect([2.5 1 1])
hold on
plot(signalDFF*ScaleFactor','k')


for n=1:size(StartIF,1)
    
    plot([StartIF(n,1) StartIF(n,1)],[0 180],'m--','LineWidth',1)
end
ylim([-10 190]);
set(gca,'box','off');
set(gcf,'Color','w');
title(DFFfile(1:end-48),'Interpreter','none')
% ylim([-10, 150])
hold off  

position=strfind(ConvertedTibiaAngleFile,'.'); 
NewName=ConvertedTibiaAngleFile(1:position-46);
Outfile = strcat(NewName,'AngleForImagingFrame');

%print(Outfile,'-djpeg','-r300')


save(Outfile,'ImageLegAngle','RealAngle*','Start*','Abs*')


clear