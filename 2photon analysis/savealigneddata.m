%Calculates the average tibia angle for each imaging frame and plot both
%the DFF and tibia angle. Use scale factor to plot DFF and tibia angle at a
%similar scale. (Scale factor multiply the DFF value)
%
%ConvertedTibiaAngleFile: output from the ConvertTibiaAngle_FindMoveOnset.m
%DetectCameraAndImagingFramesFile: output from the
%DetectCameraAndImagingFrames.m
%DFFfile: ouput file from the SelectROICalculateDFF.m or other script that
%shows DFF
%ScaleFactor: Factor to multiply the DFF trace. Should be around 30 to 100.

fileTag = 'n';
dataDir = 'E:\Sweta to backup\2 photon data\not13e04LexA\ramp and hold\';
ScaleFactor = 75;

ConvertedTibiaAngleFiles = dir([dataDir, fileTag, '*ConvertTibiaAngle_FindMoveOnset*']);
DetectCameraAndImagingFramesFiles = dir([dataDir, fileTag, '*DetectCameraAndImagingFrames*']);
DFFfiles = dir([dataDir, fileTag, '*SelectROICalculateDFF*']);

%>>>>>insert some sort of error catcher here>>>>>>>>>
size(ConvertedTibiaAngleFiles)
size(DetectCameraAndImagingFramesFiles)
size(DFFfiles)

for i = 1:length(ConvertedTibiaAngleFiles)
    ConvertedTibiaAngleFile = ConvertedTibiaAngleFiles(i).name;
    DetectCameraAndImagingFramesFile = DetectCameraAndImagingFramesFiles(i).name;
    DFFfile = DFFfiles(i).name;
    
    TibiaAngleForImagingFrame(ConvertedTibiaAngleFile,DetectCameraAndImagingFramesFile,DFFfile,ScaleFactor)
end