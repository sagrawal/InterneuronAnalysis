clearvars

dataDir = 'G:\My Drive\Sweta to backup\2 photon data\28981gal4 28980gal4\swings\';
fileTag = '28980_01_flexfirst_swing_180ds_00008';

cluster = load([dataDir, fileTag, 'FilterAndRegisterImagesKmeansClusterPixels.mat']);
reference = load([dataDir, fileTag, 'FilterAndRegisterImages.mat']);

%make reference image
NofFrames=size(reference.RegisteredImages,4);
SortedImage=squeeze(sort(reference.RegisteredImages(:,:,reference.SignalChannel,:),4,'descend'));
% PercentToUse=10;
% FramesToUse=ceil(NofFrames*PercentToUse/100);
MeanImage=mean(SortedImage(:,:,:),3);

fig1 = figure;
imshow(MeanImage,[0, 250])

export_fig(fig1,[dataDir, '9A_reference.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');

%pull out cluster pixel locations
fig2 = figure;
imshow(cluster.ClustersInImage,[])

export_fig(fig2,[dataDir, '9A_cluster.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');




