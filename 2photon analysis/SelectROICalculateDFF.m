%InFile1: File that contains the output from the filtering and registration
%script.
%NofROI: Number of ROIs.
%BaselineN: Number of frames to use for baseline.
%PixelThreshold: Use pixels with intensity above this threshold.
%MinI: Minimum intensity when showing the average image.
%MaxI: Maximum intensity when showing the aveage image.

% 2020/07: added variable "register" which is a 0 or 1. 1: resgitration was
% used, 0: no registration was used
%
%Note: Written on 2018/07/06.

function []=SelectROICalculateDFF(InFile,NofROI,BaselineN,PixelThreshold,MinI,MaxI, Register)

%Load the *FilterAndRegisterImages.mat
load(InFile);

if Register == 0
    RegisteredImages = FilteredImages;
else
    RegisteredImages = RegisteredImages;
end

NofRows=size(RegisteredImages,1);
NofColumns=size(RegisteredImages,2);
NofPixels=NofRows*NofColumns;
NofFrames=size(RegisteredImages,4);

%Sort the image to get high intensity values and apply threshold.
SortedImage=squeeze(sort(RegisteredImages(:,:,SignalChannel,:),4,'descend'));
%This is hard coded for now, but can be specified.
PercentToUse=10;
FramesToUse=ceil(NofFrames*PercentToUse/100);

MaxMeanImage=mean(SortedImage(:,:,1:FramesToUse),3);
ThresholdMask=MaxMeanImage>=PixelThreshold;

%Select the ROI.
%For the mask.
ROIMask=zeros(NofRows,NofColumns,NofROI);
%For the index to go through.
ROIIndex=zeros(NofPixels,NofROI);
for n=1:NofROI
    figure,imshow(MaxMeanImage,[MinI, MaxI])
    ManualMask=roipoly;
    %Combine the manually selected region with thresholded region.
    ROIMask(:,:,n)=ThresholdMask&ManualMask;
    clf,imshow(ROIMask(:,:,n),[]);
    %make it into an index.
    ROIIndex(:,n)=reshape(ROIMask(:,:,n),[NofPixels,1]);
end

%Reshape the image.
DataMatrix=reshape(RegisteredImages(:,:,SignalChannel,:),[NofPixels, NofFrames]);

%Make DFF with the following code.
AvgInt1=zeros(NofROI,NofFrames);
DFF1=zeros(NofROI,NofFrames);
BoxAverage1=zeros(NofROI,NofFrames-BaselineN+1);
TempMap=[0 0 0;1 0 0;0 1 0;0 0 1;1 1 0;1 0 1;0 1 1;1 0.5 0;1 0 0.5;0.5 1 0;0.5 0 1;0 0.5 1;0 1 0.5];
ROIIndex=logical(ROIIndex);
figure
hold on
title(InFile)
for n=1:NofROI
    TempCluster=DataMatrix(ROIIndex(:,n),:);
    AvgInt1(n,:)=mean(TempCluster,1);
    %For each cluster, calculate the running average with BaselineN frames
    %each.
    for m=1:(NofFrames-BaselineN)+1
        BoxAverage1(n,m)=mean(AvgInt1(n,m:m+BaselineN-1));
    end
    Baseline=min(BoxAverage1(n,:))
    DFF1(n,:)=(AvgInt1(n,:)-Baseline)/Baseline;
    
    if Baseline <0
        'negative baseline'
        Baseline
        DFF1(n,:) = -DFF1(n,:);
    end
    %For now we make it so that we will re do the loop one more time if
    %there are more than 4 clusters.Won't be able to have more than 8 for
    %now.
    if n<=size(TempMap,1)
        plot(DFF1(n,:)','Color',TempMap(n,:))
    else
        plot(DFF1(n,:)','Color',TempMap(mod(n,13),:))
    end
end
hold off


position=strfind(InFile,'.'); %gives the position of the period in the string FileName. 
NewName=InFile(1:position-1); %string NewName has the file name without the ".tiff".

Outfile = strcat(NewName,'SelectROICalculateDFF');
save(Outfile,'BaselineN','BoxAverage*','AvgInt*','DFF*','ROI*');


clear
