%Read the Frame signal file and find the end of the frame for the camera
%and imaging frame.
%
%InFile: RecordFrameSignal* file that contains the camera exposure signal
%and the Y mirror signal.
%
%MPH1 and 2: minimum peak height for the Y mirror (1) and Camera exposure
%(2) signal. Recommended values (0.04 for the mirror and 0.4 for the camera)
%
%MPW 1 and 2: minimum peak width for the Y mirror (1) and Camera exposure
%(2) signal. Recommended values (1 for the mirror and 0.1 for the camera).
%
%MPD 1 and 2: minimum peak distance for the Y mirror (1) and camera
%exposure (2) signal. Recommended values (200 for the Y mirror and 10 for
%the camera).
%
%DSF: downsample factor. The script downsample so that we can get a reliable peak
%for the mirror signal. Y mirror signal goes relatively slow compared to
%the current sampling rate of 20 kHz. 10 seems to work well, if you go down to 20
%sometimes you get one sample point per return, but other times you get
%two. For 10 it seems consistently 2 sample points.
%
%Note: Written on 2018/07/06. Previously MatchCameraToImage4.m

function []=DetectCameraAndImagingFrames(InFile,MPH1,MPW1,MPD1,MPH2,MPW2,MPD2,DSF)

%Open the file and read all the data.
fid2=fopen(InFile,'r');
[data,count]=fread(fid2,[5,inf],'double'); %time and 4 other inputs.
fclose(fid2);

%Now the ordering of the position signals will be different.
%First data (first row is just count, so data(2,:)) is the digital signal
%which shows the camera. 4th data (which is data(5,:)), is the Y position.

%20 kHz is too much for the mirror signal. Need to downsample.
NofData=size(data,2);%number of points.
DataIndex=[1:1:NofData]';%Index for the data.
%get the remainder to make the logical index.
ModIndex=mod(DataIndex,DSF);
DS_Index=ModIndex==0;%For down sampling by a factor of DSF.
DS_Data=data(:,DS_Index);

% size(data)

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
figure,plot(ImageInterval);%Should be a flat line. If not we missed some frames. Except for very first frames.

%Do the same as above, but with camera frames.
ChangeCamera=diff(data(2,:));

[PKS2, LOCS2]=findpeaks(ChangeCamera,'MinPeakHeight',MPH2,'MinPeakWidth',MPW2,'MinPeakDistance',MPD2);

EndOfCameraIndex=LOCS2+1;
%In the camera's case, we have the right end of the frame signal.

CameraInterval=diff(EndOfCameraIndex);%Check the image interval.
figure,plot(CameraInterval);%Should be a flat line. If not we missed some frames. Except for very first frames.

%For now go through each imaging frame and find out the camera frame with
%the closest index. This will mean that that frame is closest to the end of
%the image acquisition.

%size(EndOfCameraIndex)
ImageInCameraIndex=zeros(size(EndOfImageIndex,2),1);
%Also keep track of how far away it was. This will be useful when we need
%to know when the camera started and ended.
CameraMinusImageIndex=zeros(size(ImageInCameraIndex));
for n=1:size(EndOfImageIndex,2)
    DiffWithCamera=abs(EndOfCameraIndex-EndOfImageIndex(n));%Check how far each camera frames are
    %size(DiffWithCamera)
    [~,ImageInCameraIndex(n)]=min(DiffWithCamera);%Get the index for the closest one.
    %There is a possibility that the camera acquisition started later
    %than the image acquisition. In that case, the first camera frame will
    %be closest to the end of the image until the camera acquisition
    %starts.
    CameraMinusImageIndex(n)=EndOfCameraIndex(ImageInCameraIndex(n))-EndOfImageIndex(n);
end

Outfile = strcat(InFile(1:end-4),'DetectCameraAndImagingFrames');
save(Outfile,'*Index','*Interval','PKS*','LOCS*','MP*');

clear
