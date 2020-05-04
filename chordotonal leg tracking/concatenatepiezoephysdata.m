%%get ephys data, find piezo command starts

clearvars;

voltagechannel = 1;
currentinjchannel = 3;
piezocommandchannel = 4;
piezosensorchannel = 5;

%% init file and paths
abfDir = 'G:\My Drive\Sweta to backup\ephysdata\';
dataDir = 'G:\My Drive\Sweta to backup\ephysdata\10B recordings\piezo + atr and mla\';

fileTag = '04751_29_piezo_01um_20203007';

abffileTag = [fileTag, '*.abf'];
dataFiles = dir([abfDir, abffileTag]);
size(dataFiles)
%% import data
SampleRate = 20000;

for i = 1:length(dataFiles)
    [data,si,h]=abfload([abfDir dataFiles(i).name]);
    
    voltagedata = data(:, voltagechannel)';
    
    piezocommanddata = data(:, piezocommandchannel)';
    piezosensordata = data(:, piezosensorchannel)';

    %find starts of piezo command
%     piezocommanddata(piezocommanddata>5.6) = 5;
    AbsDiffCommand=abs(diff(piezocommanddata>5.015));    
    MinPeakHeight=2*std(AbsDiffCommand);
%     MinPeakHeight=5.011;
    
    figure;
    findpeaks(AbsDiffCommand, 'MinPeakHeight',MinPeakHeight, 'MinPeakDistance', 100000);
    title(dataFiles(i).name)
    [PKS,piezoframeon,WDTH,PHeight] = findpeaks(AbsDiffCommand, 'MinPeakHeight',MinPeakHeight, 'MinPeakDistance', 100000);
    
    
    
    position=strfind(dataFiles(i).name,'.'); %gives the position of the "period" in the string FileName
    NewName=dataFiles(i).name(1:position-1);
    
    Outfile=strcat(NewName,'_EphysPiezodata.mat');
    save([dataDir, Outfile],'voltagedata', 'piezocommanddata', 'piezosensordata', 'SampleRate', 'PKS', 'piezoframeon' );
end
    