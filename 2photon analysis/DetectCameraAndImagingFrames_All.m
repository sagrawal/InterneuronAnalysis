%Runs DetectCameraAndImagingFrames for all the appropriate files in a
%folder.
%
%Example:
%DetectCameraAndImagingFrames_All(0.04,1,200,0.4,0.1,10,10)
%
%Note: Written on 2018/07/06. Previously MatchCameratToImage4_All
function []=DetectCameraAndImagingFrames_All(MPH1,MPW1,MPD1,MPH2,MPW2,MPD2,DSF)

%Find the MoveMagnet files
FrameSignalFileList=dir('*RecordFrameSignal*');
        
NofExperiments=size(FrameSignalFileList,1)

for n=[1:NofExperiments]
    n
%     FrameSignalFileList(n).name
    DetectCameraAndImagingFrames(FrameSignalFileList(n).name,MPH1,MPW1,MPD1,MPH2,MPW2,MPD2,DSF);
end

    

clear