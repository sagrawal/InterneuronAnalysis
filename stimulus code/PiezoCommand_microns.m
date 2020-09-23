function [] = PiezoCommand_microns(PreDuration,StimDuration,PostDuration,microns,StimFreq,RepetitionN)
%
%PreDuration: Pre-stimulus duration in seconds.
%StimDuration: Stimulus duration in seconds.
%PostDuration: Post-stimulus duration in seconds.
%microns: amplitude of movement, in microns. 60um total travel range (-30
%to + 30), over about 10 V
%StimFreq: Vibration frequency.
%RepetitionN: number of repetition
Offset = 5; %5v, assumed to be zero point around which oscillation will occur

% ScaleFactor 
% @ 1 um: 1.4992 for 10hz, 1.7 for 100hz, 2.3 for 200hz, 4.28 for
% 400hz, 12 for 800hz, 30 for 1200 hz (not quite as high an amplitude)

% @ .1 um: 1.12 for 100hz, 1.5 for 200hz, 2.83 for 400hz, 7.7 for 800hz,
% 16.35 for 1200hz, 36.7 for 1600hz, 73 for 2000 hz

% @ .05 um: 1 for 100hz, 200hz, 400hz, 2.75 for 800hz, 14.85 for 1600hz, 44
% for 2000hz

%Initialize the DAQ sessions.
PiezoOutputSession=daq.createSession('ni');
PiezoOutputSession.Rate=10000;
addAnalogOutputChannel(PiezoOutputSession,'Dev1',1,'Voltage');

%Set the trial duration.
TrialDuration=PreDuration+(StimDuration+PostDuration)*RepetitionN;

%initialize output data.
outputData=ones(PiezoOutputSession.Rate*TrialDuration,1)*Offset;
OutputPercentage = microns/60; %60 micron piezo
StimAmp=OutputPercentage*10; %Assumes 10V max.

%Index for the angles.
PointIndex=1:1:round(StimDuration*PiezoOutputSession.Rate);
AngleRadian=(PointIndex/(PiezoOutputSession.Rate/StimFreq))*2*pi;
rampon = 0:(StimAmp/2)/((PiezoOutputSession.Rate/1000)*40-1):(StimAmp/2);
multiplyingramp = [rampon, ones(1, length(AngleRadian)-2*length(rampon))*(StimAmp/2), fliplr(rampon)];

%Shift angle by 1/4 cycle (pi/2) to start the sine wave from the min point.
AngleRadian=AngleRadian-pi/2;
% length(AngleRadian)

%Calculate the number of points for each period.
PrePoints=PreDuration*PiezoOutputSession.Rate;
StimPoints=size(PointIndex,2);
PostPoints=PostDuration*PiezoOutputSession.Rate;

for n=1:RepetitionN 
   outputData(PrePoints+1+(n-1)*(StimPoints+PostPoints):PrePoints+(n-1)*(StimPoints+PostPoints)+StimPoints)=...
        sin(AngleRadian).*multiplyingramp+Offset;
end

if max(outputData) >10
    error('stim amp too high')
end


%Put the output data in the queue.
queueOutputData(PiezoOutputSession,outputData);
%Put the output session in the background. It will start when triggered.
startForeground(PiezoOutputSession);
stop(PiezoOutputSession);
end