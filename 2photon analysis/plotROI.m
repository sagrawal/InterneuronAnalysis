FilterandRegister_FName = 'not13e04lexa_01_extfirst_swings_1440ds_00008FilterAndRegisterImages.mat';
ROI_FName = 'not13e04lexa_01_extfirst_swings_1440ds_00008FilterAndRegisterImagesSelectROICalculateDFF.mat';

PixelThreshold = 300;
MinI = 0;
MaxI = 500;
TempMap=[0 0 0;1 0 0;0 1 0;0 0 1;1 1 0;1 0 1;0 1 1;1 0.5 0;1 0 0.5;0.5 1 0;0.5 0 1;0 0.5 1;0 1 0.5];

load(FilterandRegister_FName);
load(ROI_FName);
NofROI = size(ROIMask, 3);

%% create max mean image
RegisteredImages = FilteredImages;

NofRows=size(RegisteredImages,1);
NofColumns=size(RegisteredImages,2);
NofPixels=NofRows*NofColumns;
NofFrames=size(RegisteredImages,4);

SortedImage=squeeze(sort(RegisteredImages(:,:,SignalChannel,:),4,'descend'));
PercentToUse=10;
FramesToUse=ceil(NofFrames*PercentToUse/100);

MaxMeanImage=mean(SortedImage(:,:,1:FramesToUse),3);

MaxMeanImage(MaxMeanImage<=MinI) = MinI;
MaxMeanImage(MaxMeanImage>=MaxI) = MaxI;

MaxMeanImage = MaxMeanImage./max(MaxMeanImage, [], 'all');


reffig = figure;
mask = ROIMask(:, :, 1);

B = labeloverlay(MaxMeanImage,mask);
imshow(B, [MinI, MaxI])

export_fig(reffig,'ROI1_image.pdf', '-pdf','-nocrop', '-r600' , '-painters', '-rgb');








