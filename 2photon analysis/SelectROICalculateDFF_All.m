%Runs SelectROICalculateDFF for all the *FilterAndRegisterImages.m files.
%
%Note: Written on 2018/07/06.

% 2020/07: added variable "register" which is a 0 or 1. 1: resgitration was
% used, 0: no registration was used
function []=SelectROICalculateDFF_All(fileTag, NofROI,BaselineN,PixelThreshold,MinI,MaxI, Register)

%Find the '*FilterAndRegisterImages.mat'
FileList=dir([fileTag, '*FilterAndRegisterImages.mat']);

NofExperiments=size(FileList,1)

for n=1:NofExperiments
    FileList(n).name
    SelectROICalculateDFF(FileList(n).name,NofROI,BaselineN,PixelThreshold,MinI,MaxI, Register);
end

clear