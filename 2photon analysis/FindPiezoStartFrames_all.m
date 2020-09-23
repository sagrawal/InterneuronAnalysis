%Finds the imaging frames that corresponds to the beginning of the Piezo
%controlled vibration.
%
%InFile: Output file form the PiezoOutputReady....
%
%MPH1, MPW1, MPD1: Minimum peak height, width, and distance for detecting
%the end of the imaging frame. Parameters used for the DetectCameraAndImagingFrames.m
% (0.04, 1, and 200) should work here as well.
%
%ThresS: a value used to detect the Piezo signal (0.05 should work). Any
%value above this value is considered a signal (for controlling piezo) and
%not noise.
%
%StimT: Stimulus time in seconds. (should be 4)
%
%SampRate: Sampling rate of the analog input. (should be 20,000)
%
%Repeat: Number of piezo stimulus repetition (should be 2).
%
%DSF: down sampling factor (10 should work).
%
%Note: Revised on 2018/07/16, based on FindPiezoStartTime3.m

function []=FindPiezoStartFrames_all(fileTag,MPH,MPW,MPD,ThresS,StimT,SampRate,Repeat,DSF)

FileList=dir([fileTag, '*PiezoOutputReady*']);
NofExperiments=size(FileList,1)

for n=1:NofExperiments
    FileList(n).name
    FindPiezoStartFrames(FileList(n).name,MPH,MPW,MPD,ThresS,StimT,SampRate,Repeat,DSF);
end

clear
