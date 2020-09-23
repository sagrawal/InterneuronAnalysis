%InFile: Output from the Tibia tracking script.
%
%MPW and MPD: Minimum peak width and distance used to detect the tibia
%movement. (1 and 200 should work well)
%
%LegAngleScale: For display purposes only. Divide the leg angle with this
%value to display the leg angle on top of the Leg movement (change in leg
%angle from the previous time point). (100 should work well)
%
%FrameB: number of frames to go back from the peak of the tibia movement to
%find the start of the tibia movement. (250 should be enough).
%
%ThresP: Peak of the tibia movement multiplied by this number will be used
%as the threshold for the movement detetion. (0.15 seems to work well)

function []=ConvertTibiaAngle_FindMoveOnset_all(fileTag,MPW,MPD,LegAngleScale,FrameB,ThresP)

FileList=dir([fileTag, '*TrackLegAngle4.mat']);
NofExperiments=size(FileList,1)

for n=1:NofExperiments
    FileList(n).name
    ConvertTibiaAngle_FindMoveOnset(FileList(n).name,MPW,MPD,LegAngleScale,FrameB,ThresP);
end



clear