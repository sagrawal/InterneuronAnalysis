function [] = PiezoCommand(PreDuration,StimDuration,PostDuration,OutputPercentage,StimFreq,RepetitionN)
%
%PreDuration: Pre-stimulus duration in seconds.
%StimDuration: Stimulus duration in seconds.
%PostDuration: Post-stimulus duration in seconds.
%OutputPercentage: Percent of maximum voltage (assumes 10V max).
%StimFreq: Vibration frequency.
%RepetitionN: number of repetition

%Initialize the DAQ sessions.
PiezoOutputSession=daq.createSession('ni');%For National Instrument board.
%Set rate. For the output. May be better to increase to 20 kHz.
PiezoOutputSession.Rate=10000;
%Add analog output channel to the session.
%Set for Dev1, use output channel 1.
addAnalogOutputChannel(PiezoOutputSession,'Dev1',1,'Voltage');


%Specify the TriggerCondition property to RisingEdge.
% c=PiezoOutputSession.Connections(1);
% c.TriggerCondition = 'RisingEdge';
% PiezoOutputSession.ExternalTriggerTimeout=30;

%Set the trial duration.
TrialDuration=PreDuration+(StimDuration+PostDuration)*RepetitionN;

%initialize output data.
outputData=zeros(PiezoOutputSession.Rate*TrialDuration,1);
StimAmp=(OutputPercentage/100)*10;%Assumes 10V max.
%Index for the angles.
PointIndex=1:1:round(StimDuration*PiezoOutputSession.Rate);
AngleRadian=(PointIndex/(PiezoOutputSession.Rate/StimFreq))*2*pi;
%Shift angle by 1/4 cycle (pi/2) to start the sine wave from the minimum
%point.
AngleRadian=AngleRadian-pi/2;

%Calculate the number of points for each period.
PrePoints=PreDuration*PiezoOutputSession.Rate;
StimPoints=size(PointIndex,2);
PostPoints=PostDuration*PiezoOutputSession.Rate;

for n=1:RepetitionN
    
   outputData(PrePoints+1+(n-1)*(StimPoints+PostPoints):PrePoints+(n-1)*(StimPoints+PostPoints)+StimPoints)=...
        sin(AngleRadian)*(StimAmp/2)+(StimAmp/2);
end


%Put the output data in the queue.
queueOutputData(PiezoOutputSession,outputData);
%Put the output session in the background. It will start when triggered.
startForeground(PiezoOutputSession);

% %Take time.
% TimeMatrix=clock;
% %Make output file for the recording.
% OutPutFile=strcat('PiezoCommand',datestr(TimeMatrix(1,:),'yyyymmddTHHMMSS'));
% %Create and open the file.
% fid1=fopen(OutPutFile,'w');
% 
% %Add a listener.
% lh = addlistener(PiezoExpRecordSession,'DataAvailable',@(src,event)logData(src,event,fid1));
% 
% %Acquire everything in background from the moment we start.
% PiezoExpRecordSession.IsContinuous=true;
% PiezoExpRecordSession.startBackground;
% 
% %Pause and wait for the ScanImage (imaging program) to start scanning.
% %Scanning will generate the trigger signal and start the Piezo output.
% pause(TrialDuration+5);%Give 5 seconds for the image acquisition button push.
% 
% %Stop, delete the listener, and close the file.
% PiezoExpRecordSession.stop;
% delete(lh);
% fclose(fid1);

end