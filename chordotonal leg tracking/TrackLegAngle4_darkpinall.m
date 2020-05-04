%Track tibia angle for each frame in the .avi file.

%InFile: .avi file that contains the tibia image.
%Threshold: Pixels greater (lighter) than this value will be used to fit the angle.

%It also reads in "...DrawMaskAndBackground.mat" file made by another
%script, "DrawMaskAndBackground3". This file specifies the area in the image
%that will be used for tracking (in case there are dark or bright spots in
%the image that you want to ignore), and the background image.

%FemurAngle is measured (in degrees) using MB Ruler and from the top horizontal line of
%the image. 0 degrees is the left corner, 180 degrees is the right corner.

%code has been adjusted to somewhat filter out jitter, likely due to errors
%in image processing. Once I start looking at high frequency leg movements,
%I will have to re-adjust code accordingly. Have biased against movements
%that last only 1 frame and against movements that are greater than 30
%degrees/frame

function []=TrackLegAngle4_darkpinall(FileTag,Threshold, FemurAngle)

%Find the output file from DrawMaskAndBackground and load it.
MaskFile=dir([FileTag,'*DrawMaskAndBackground.mat']);
load(MaskFile(1).name);

%find all the videos associated with FileTag
DataFiles = dir([FileTag, '*.avi']);
length(DataFiles)

for i = 1:length(DataFiles)
    i
    %Specify the input video file
    ExampleVid=VideoReader(DataFiles(i).name);
    position=strfind(DataFiles(i).name,'.'); %gives the position of the "period" in the string FileName
    NewName=DataFiles(i).name(1:position-1)
      
    FramesToRead=ExampleVid.NumberOfFrames; %#ok<*VIDREAD>
    
    ExampleVid=VideoReader(DataFiles(i).name);
    LegAngleArea=zeros(FramesToRead,4);
    
    FrameRate = ExampleVid.FrameRate;
    k=1;
    while k<=FramesToRead
        currentFrame=readFrame(ExampleVid);
        vidFrame = currentFrame(:,:,1);
        
        %Chose the area of the video image previously selected in MaskRegion and
        %subtract the Background from them. If not using MaskRegion and
        %Background image, just keep vidFrame.
        MaskedBGImage=double(vidFrame).*MaskRegion-BackgroundAll;
        
        %Select the pixels that are darker than "Threshold".
        Mask=MaskedBGImage<Threshold;
        TestRegion=regionprops(Mask,'orientation','area','centroid', 'majoraxislength');
        
        %"regionprops" will provide the specified properties for each group of
        %contiguous pixels. Depending on the threshold setting, there may be
        %mulitple pixel groups, but the tibia should be the biggest one.
        %Find the group with largest area and use its orientation as "tibia
        %orientation" in the image.
        
        if isempty(TestRegion)
            LegAngleArea(k, :) = NaN;
        else
            allArea=[TestRegion.Area];%Concatinate all the area information.
            [MaxArea, Index]=max(allArea);
            
            
            LegAngleArea(k,1)=FemurAngle - TestRegion(Index).Orientation;
            
            %Also save the area, and the centroid of the tibia.
            LegAngleArea(k,2)=MaxArea;
            LegAngleArea(k,3)=TestRegion(Index).Centroid(1);
            LegAngleArea(k,4)=TestRegion(Index).Centroid(2);
            LegAngleArea(k, 5) = TestRegion(Index).Orientation;
            LegAngleArea(k, 6) = TestRegion(Index).MajorAxisLength;
            
            LegAngleArea(LegAngleArea(:,1)>190, 1) = LegAngleArea(LegAngleArea(:,1)>190, 1)-180;
            LegAngleArea(:,5) = FemurAngle-LegAngleArea(:, 1);
        end
        
        k=k+1;
    end
        
    Outfile=strcat(NewName,'TrackLegAngle4');
    save(Outfile,'Threshold','LegAngleArea', 'FrameRate');
    
    figure
    hold on
    plot(LegAngleArea(:, 1));
    title(NewName);
end

clear