%Runs SelectROIManually for all the *FilterAndRegisterImages.m files.
%
%Note: Written on 2018/07/06.

% AutoFlag value = 1 or 0. 1 = ROI auto determined, no manual selection. 0
% = ROI manually selected
function []=SelectROIManually_All(AutoFlag)

%Find the '*FilterAndRegisterImages.mat'
FileList=dir('*FilterAndRegisterImages.mat');

NofExperiments=size(FileList,1)

if AutoFlag == 0
    for n=1:NofExperiments
        SelectROIManually(FileList(n).name);
    end
elseif AutoFlag == 1
    for n=1:NofExperiments
        SelectROIAuto(FileList(n).name);
    end
end

clear