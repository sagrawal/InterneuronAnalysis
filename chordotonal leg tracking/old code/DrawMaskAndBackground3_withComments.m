%Uses sample video file to specify the area to use for tracking tibia
%angle, and also makes a background image.

%InFile: .avi video file that will be used to specify the area for tracking
%tibia angle.

%StartT1: In seconds. Assuming that the video captures a ramp-and-hold trial, StartT1
%specifies the time when the tibia is at the very beginning (either fully
%extended or flexed). First background image will be taken from this time
%point.

%FrameN1: Number of frames to average for the first background image.

%StartT2: In seconds. Assuming that the video captures a ramp-and-hold trial, StartT2
%specifies the time when the tibia is at the opposite end of the swing from
%the beginning (either fully flexed or extended, depending on which way the
%trial started). Second backgrond image will be taken from this time point.

%FrameN2: Number of frames to average for the second background image.

%SampleS: Sampling interval in seconds, when making average image that we
%use to specify the area of interest.



function []=DrawMaskAndBackground3_withComments(InFile, StartT1,FrameN1,StartT2,FrameN2,SampleS)

%Get the example video
ExampleVid=VideoReader(InFile);


%To make an average image of the trial for specifying the region of
%interest, down sample the entire video with SampleS interval, up to 1
%second before the end of the trial.

FramesToRead=floor((ExampleVid.Duration-1)/SampleS);
AllImage=zeros(ExampleVid.Height, ExampleVid.Width,FramesToRead);
AllImage=uint8(AllImage);

for n=1:FramesToRead
    ExampleVid.CurrentTime=SampleS*(n-1);
    CurrentFrame = readFrame(ExampleVid);
    AllImage(:,:,n)=CurrentFrame(:,:,1);
end

%Caluclate the mean image.
meanImage=mean(AllImage,3);

%Initialize matrix for the first background images.
AllImage2=zeros(ExampleVid.Height, ExampleVid.Width,FrameN1);
AllImage2=uint8(AllImage2);

%Go to time point "StartT1" and take "FrameN1" frames.
ExampleVid.CurrentTime=StartT1;
k=1;
while k<=FrameN1
    CurrentFrame=readFrame(ExampleVid);
    AllImage2(:,:,k)=CurrentFrame(:,:,1);
    k=k+1;
end

Image1=mean(AllImage2,3);

%Take the difference between the overall average and the initial time point
%images.
ExampleImage=Image1-meanImage;

%Plot and ask the user to select the Mask region.
%This region will be used when tracking tibia.

figure,imshow(ExampleImage,[]);
colormap(gca,'parula')

fprintf('Chose the mask region \n')
MaskRegion=roipoly;

%Now chose the background region.
%Avoid the tibia.

fprintf('Chose the background region \n')
Background1=roipoly;


%To find the background for a region initially covered by the tibia, go to a
%time point where the tibia is in the other extreme position.

%Initialize matrix for the second background.

AllImage3=zeros(ExampleVid.Height, ExampleVid.Width,FrameN2);
AllImage3=uint8(AllImage3);

%Go to a time point "StartT2" and gather images.
ExampleVid.CurrentTime=StartT2;
k=1;
while k<=FrameN2
    CurrentFrame = readFrame(ExampleVid);
    AllImage3(:,:,k)= CurrentFrame(:,:,1);
    k=k+1;
end

Image2=mean(AllImage3,3);
ExampleImage2=Image2-meanImage;

%Plot and ask the user to select another background including the region
%that was intially covered by the tibia.
figure,imshow(ExampleImage2,[]);
colormap(gca,'parula')

fprintf('Chose the second background region \n')
Background2=roipoly;

%Clip the background.
BackgroundImage1=Image1.*Background1;%Everything except the background will be zero.
BackgroundImage2=Image2.*Background2;%Everything except the background will be zero.

%Merge them together.
BackgroundImage2Addition=BackgroundImage2.*(~Background1);%Only the parts not selected by Background1.
BackgroundAll=BackgroundImage1+BackgroundImage2Addition;
BackgroundAll=BackgroundAll.*MaskRegion;

figure,imshow(BackgroundAll,[]);

position=strfind(InFile,'.'); %gives the position of the period in the string FileName

NewName=InFile(1:position-1); %string NewName has the file name without the ".avi".

Outfile = strcat(NewName,'DrawMaskAndBackground');

save(Outfile,'Mask*','Background*');

clear