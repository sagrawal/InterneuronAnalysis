%Finds the imaging frames that corresponds to the beginning of the Piezo
%controlled vibration.
%
%InFile: Output file form the PiezoOutputReady....
%
%MPH1, MPW1, MPD1: Minimum peak height, width, and distance for detecting
%the end of the imaging frame. Parameters used for the DetectCameraAndImagingFrames.m
% (0.04, 1, and 200) should work here as well.
%
%ThresS: a value used to detect the Piezo signal (0.05 should work). Any
%value above this value is considered a signal (for controlling piezo) and
%not noise.
%
%StimT: Stimulus time in seconds. (should be 4)
%
%SampRate: Sampling rate of the analog input. (should be 20,000)
%
%Repeat: Number of piezo stimulus repetition (should be 2).
%
%DSF: down sampling factor (10 should work).
%
%Note: Revised on 2018/07/16, based on FindPiezoStartTime3.m

function []=FindPiezoStartFrames(InFile,MPH1,MPW1,MPD1,ThresS,StimT,SampRate,Repeat,DSF)

%Open the file and read all the data.
fid2=fopen(InFile,'r');
[data,count]=fread(fid2,[5,inf],'double'); %Because time and 4 other inputs.
fclose(fid2);

%Now the ordering of the position signals will be different.
%First data (first row is just count, so data(2,:)) is the digital signal
%which shows the camera. 4th data (which is data(5,:)), is the Y position.

%Try downsample by 10.
NofData=size(data,2);%number of points.
DataIndex=[1:1:NofData]';%Index for the data.
%get the remainder to make the logical index.
ModIndex=mod(DataIndex,DSF);
DS_Index=ModIndex==0;%For down sampling by a factor of DSF.
DS_Data=data(:,DS_Index);
size(DS_Data);


ChangeMirror=diff(DS_Data(5,:));
[PKS, LOCS]=findpeaks(ChangeMirror,'MinPeakHeight',MPH1,'MinPeakWidth',MPW1,'MinPeakDistance',MPD1);

%Now we need to consider the downsampling as well. If the LOCS is m then
%the actual end point for the image was m*DSF(th) point. 
%
%If the Nth interval is the peak, then the peak move occured on the N+1 th
%point.
EndOfImageIndex=LOCS+1;
EndOfImageIndex=EndOfImageIndex*DSF;
%We know that the first move is actually not the end of the image, but the
%start of the trial so remove this.
EndOfImageIndex(1)=[];

ImageInterval=diff(EndOfImageIndex);%Check the image interval.
figure,plot(ImageInterval);%Should be a flat line. 

%data(3,:) contains the analog output for the Piezo.
%Find where the stimuls started.
AboveT=data(3,:)>=ThresS;

%Go through for the number of stimulus repetition.
m=1;
StartT=zeros(Repeat,1);
for n=1:Repeat
    %Find the first place where it goes above Threshold.
    [Y I]=max(AboveT(m:end));
    StartT(n)=m+I-1;
    m=StartT(n)+SampRate*(StimT+1);%We assume that the interval is more than 1 seconds.
    
end

%For now go through each StartT and find out the ImageEnd that's closest to
%the start time. If the ImageEnd is before the start time, than the next
%image is the first image of the stimulus. Also save the offset (with sign
%in case we want them later).

StimStartFrameAndOffset=zeros(Repeat,2);
for n=1:Repeat
    DiffWithStim=abs(EndOfImageIndex-StartT(n));%Check how far away each image's end is from the start time.
    [Y,I]=min(DiffWithStim);%Get the index for the closest image end.
    Offset=EndOfImageIndex(I)-StartT(n);%How much time (points) did the stimulus occur in that frame.
    
    StimStartFrameAndOffset(n,2)=Offset;
    %Now check if the image ended before the stimulus start and adjust the
    %index accordingly. Now negative Offset means the stimulus started that
    %time after the image acquisition. Positive offset means how much time
    %the stimulus was on during that image.
    if Offset<0
        StimStartFrameAndOffset(n,1)=I+1;
    else
        StimStartFrameAndOffset(n,1)=I;
    end
end

NewName=InFile(1:end-36); 
Outfile = strcat(NewName,'FindPiezoStartFrames');
save(Outfile,'*Index','Thres*','*Interval','StartT','StimT','SampRate','Repeat','StimStartFrameAndOffset');

clear
