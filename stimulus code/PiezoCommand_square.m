function [] = PiezoCommand_square(PreDuration,StimDuration,PostDuration,OutputGoal,RepetitionN)
%
%PreDuration: Pre-stimulus duration in seconds.
%StimDuration: Stimulus duration in seconds.
%PostDuration: Post-stimulus duration in seconds.
%OutputGoal: voltage we want signal to be at (assume 0V-10V with 5V offset).
%StimFreq: Vibration frequency.
%RepetitionN: number of repetition
Offset = 0; %5v, assumed to be zero point

%Initialize the DAQ sessions.
PiezoOutputSession=daq.createSession('ni');%For National Instrument board.
%Set rate. For the output. May be better to increase to 20 kHz.
PiezoOutputSession.Rate=10000;
%Add analog output channel to the session.
%Set for Dev1, use output channel 1.
addAnalogOutputChannel(PiezoOutputSession,'Dev1',1,'Voltage');

%Set the trial duration.
TrialDuration=PreDuration+(StimDuration+PostDuration)*RepetitionN;

%initialize output data.
outputData=ones(PiezoOutputSession.Rate*TrialDuration,1)*Offset;
StimAmp=Offset + OutputGoal;%Assumes 10V max.
if StimAmp >10
    error('stim amp too high')
end

%Calculate the number of points for each period.
PrePoints=PreDuration*PiezoOutputSession.Rate;
StimPoints=StimDuration*PiezoOutputSession.Rate;
PostPoints=PostDuration*PiezoOutputSession.Rate;

for n=1:RepetitionN
    outputData(PrePoints+1+(n-1)*(StimPoints+PostPoints):PrePoints+(n-1)*(StimPoints+PostPoints)+StimPoints)=...
        StimAmp;
end


%Put the output data in the queue.
queueOutputData(PiezoOutputSession,outputData);
%Put the output session in the background. It will start when triggered.
startForeground(PiezoOutputSession);

end