%Runs KmeansClusterPixels for all the appropriate files in a directory.
%
%Note: Written on 2018/07/06.
function []=KmeansClusterPixels_All(FileTag, NofClusters, BaselineN,Repetition,PixelThreshold, Register)

%Find the '*FilterAndRegisterImages.mat'
FileList=dir([FileTag, '*FilterAndRegisterImages.mat']);
%Find the ManualROI files.
ManualROIFiles=dir([FileTag, '*SelectROIManually.mat']);

%Load number of clusters. For now, specifying number manually.
%Each folder should have one .mat file that contains
%NofClusters.
% load('ClusterNumber.mat');
% NofClusters = 1;

NofExperiments=size(FileList,1);

for n=1:NofExperiments
    KmeansClusterPixels(FileList(n).name,ManualROIFiles(n).name,NofClusters,BaselineN,Repetition,PixelThreshold, Register);
end

clear