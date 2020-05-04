%Track tibia angle for each frame in the .avi file.

%

%InFile: .avi file that contains the tibia image.

%Threshold: Pixels less (darker) than this value will be used to fit the angle.

%

%It also reads in "...DrawMaskAndBackground.mat" file made by another

%script, "DrawMaskAndBackground3". This file specifies the area in the image

%that will be used for tracking (in case there are dark or bright spots in

%the image that you want to ignore), and the background image.

%



function []=TrackLegAngle4_withComments(InFile,Threshold)



%Find the output file from DrawMaskAndBackground and load it.

%Thre should be only one file in the directory.

MaskFile=dir('*DrawMaskAndBackground.mat');

load(MaskFile(1).name);



%Specify the input video file

ExampleVid=VideoReader(InFile);



%Read up till 1 second (in video replay time) before the end of the video

%to avoid possible artifact at the end.

FramesToRead=floor((ExampleVid.Duration-1)*ExampleVid.FrameRate);

LegAngleArea=zeros(FramesToRead,4);



k=1;

while k<=FramesToRead

    vidFrame=readFrame(ExampleVid);

    %Chose the area of the video image previously selected in MaskRegion and

    %subtract the Background from them. If not using MaskRegion and

    %Background image, just keep vidFrame.

    MaskedBGImage=double(vidFrame).*MaskRegion-BackgroundAll;



    %Select the pixels that are darker than "Threshold".

    Mask=MaskedBGImage<Threshold;

    

    TestRegion=regionprops(Mask,'orientation','area','centroid');

    %"regionprops" will provide the specified properties for each group of

    %contiguous pixels. Depending on the threshold setting, there may be

    %mulitple pixel groups, but the tibia should be the biggest one.

    %Find the group with largest area and use its orientation as "tibia

    %orientation" in the image.

    allArea=[TestRegion.Area];%Concatinate all the area information.

    [MaxArea, Index]=max(allArea);

    LegAngleArea(k,1)=TestRegion(Index).Orientation;

    %Also save the area, and the centroid of the tibia.

    LegAngleArea(k,2)=MaxArea;

    LegAngleArea(k,3)=TestRegion(Index).Centroid(1);

    LegAngleArea(k,4)=TestRegion(Index).Centroid(2);

    

    k=k+1;

end





position=strfind(InFile,'.'); %gives the position of the "period" in the string FileName

NewName=InFile(1:position-1); %string NewName has the file name without the ".avi".

Outfile=strcat(NewName,'TrackLegAngle4');



save(Outfile,'Threshold','LegAngleArea');



clear