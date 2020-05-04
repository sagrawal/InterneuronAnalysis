%% 8/30/2019 edited to accomodate ephys rig data, active movement examples

%InFile: Output from the Tibia tracking script.
%
%MPW and MPD: Minimum peak width and distance used to detect the tibia
%movement. (1 and 100 should work well)
%
%FrameB: number of frames to go back from the peak of the tibia movement to
%find the start of the tibia movement. (100 should be enough).
%
%ThresP: Peak of the tibia movement multiplied by this number will be used
%as the threshold for the movement detetion. (0.15 seems to work well)

function []=FindMoveOnset(InFile,MPW,MPD,FrameB,ThresP)

%We will get the original leg angle from *TrackLegAngle4.mat file.
load(InFile);
RealAngle=legangles;%This is the angle. 

%Look at how the tibia angle changes from frame to frame.
AbsDiffRealAngle=abs(diff(RealAngle));

%Set the min peak height. May need to change this value.
MinPeakHeight=1*nanstd(AbsDiffRealAngle);

figure;
findpeaks(AbsDiffRealAngle,'MinPeakHeight',MinPeakHeight,'MinPeakWidth',MPW,'MinPeakDistance',MPD);
hold on


%Run the same peak finding algorithms as above, this time get the peaks (PKS),
%peak location index number (LOCS), peak width (WDTH), and the prominance
%of the peak (PHeight).
[PKS,LOCS,WDTH,PHeight]=findpeaks(AbsDiffRealAngle,'MinPeakHeight',MinPeakHeight,'MinPeakWidth',MPW,'MinPeakDistance',MPD);
length(LOCS)

%Within FrameB from the peak position, find a point where the movement
%becomes smaller than mean(PKS)*ThresP and select that time point as the
%starting point of the tibia movement.

%Initialize the matrix.
StartVF=zeros(size(PKS));

%For this version the threshold is calculated for each peak.
%Get the threshold.
%ThresValue=mean(PKS)*ThresP;

figure
plot(legangles)
hold on

%Do the following for each peak
for n=1:size(PKS,2)
    plot([LOCS(n) LOCS(n)],[0, 130],'m--','LineWidth',1)
    if LOCS(n)<FrameB
    else
        TempSpeed=AbsDiffRealAngle(LOCS(n):-1:LOCS(n)-FrameB+1);
        ThresValue=PKS(n)*ThresP;
        PositivePosition=TempSpeed-ThresValue>=0;
        %Find where the sign changes. "-1" is where it changes from positive to
        %negative. It will be "1" if it changed from negative to positive.
        SignChange=diff(PositivePosition);
        %Index for negative to positive change if any.
        Reverse=SignChange==1;
        %Remove cases where the speed dipped below the threshold for just one
        %data point.
        Reverse(end+1)=0;
        Reverse(1)=[];
        SignChange(Reverse)=0;
        Reverse(end+1)=0;
        Reverse(1)=[];
        SignChange(Reverse)=0;
        [Y,I]=min(SignChange);
        %IF the sign change happened in the nth interval, than n+1 st value is
        %the first number below the threshold.
        I=I+1;
        %Because we took values starting from LOCS(n), LOCS(n)-I+1 is the first
        %value that went below the threshold. In the original trace this is the
        %interval where the move occured.
        StartVF(n)=LOCS(n)-I+1;
        %plot a line at that point.
%         plot([StartVF(n) StartVF(n)],[0, 130],'m--','LineWidth',1) 
    end
    
end

if ~logical(exist('currentinjectiondata', 'var'))
    currentinjectiondata = [];
end

if ~logical(exist('stimcommanddata', 'var'))
    stimcommanddata = [];
end

hold off

% figure(2)
% plot(legangles)
%Save the peak position, height, etc.
position=strfind(InFile,'.'); %gives the position of the period in the string FileName
NewName=InFile(1:position-1); 
Outfile = strcat(NewName,'_WithSwingOnset');
save(Outfile,'PKS','LOCS', 'WDTH','currentinjectiondata', 'frame_on', 'FrameRate', 'legangles', 'movieFiles', 'SampleRate', 'stimcommanddata', 'voltagedata')
% save(Outfile,'PKS','LOCS', 'WDTH','frame_on', 'FrameRate', 'legangles', 'movieFiles', 'SampleRate', 'voltagedata')

clear