%Pre-select the overall ROI manually.
%To be used together with the Kmeans script, so we don't have to select the
%ROI during Kmeans calculation.
%
%Note: Written on 2018/07/06.
function []=SelectROIManually(InFile, Register)

%Load the *FilterAndRegisterImages.mat files.
load(InFile);

if Register == 0
    RegisteredImages = FilteredImages;
else
    RegisteredImages = RegisteredImages;
end

NofFrames=size(RegisteredImages,4);
%Sort the image to get high intensity values and apply threshold.
SortedImage=squeeze(sort(RegisteredImages(:,:,SignalChannel,:),4,'descend'));
%This is hard coded for now, but can be specified.
PercentToUse=10;
FramesToUse=ceil(NofFrames*PercentToUse/100);

MaxMeanImage=mean(SortedImage(:,:,1:FramesToUse),3);
figure,imshow(MaxMeanImage,[])

%Manual selection of the responding region.
ManualROI=roipoly;

position=strfind(InFile,'.'); %gives the position of the period in the string FileName. This is the last of the set of the files from the same region.
NewName=InFile(1:position-1); %string NewName has the file name without the ".tiff".

Outfile = strcat(NewName,'SelectROIManually');
save(Outfile,'ManualROI');


clear
