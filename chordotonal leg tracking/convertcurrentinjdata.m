%%get ephys data, find current inj data, save all as .mat file

clearvars;

voltagechannel = 1;
currentinjchannel = 3;
pclamp_gain = 400; %400 pA/V
stimdur = 1;  % sec, duration of current pulse
interstim = 1;    %sec, time between current pulses, was 0.5s until 2/15/19
numsteps = 10;

%% init file and paths
abfDir = 'G:\My Drive\Sweta to backup\ephysdata\10B recordings\currentinj\';
dataDir = 'G:\My Drive\Sweta to backup\ephysdata\10B recordings\currentinj\';

fileTag = '04751_02_currentinj01_';

abffileTag = [fileTag, '*.abf'];
dataFiles = dir([abfDir, abffileTag]);
size(dataFiles)
%% import data
SampleRate = 20000;

for i = 1:length(dataFiles)
    [data,si,h]=abfload([abfDir dataFiles(i).name]);
    
    voltagedata = data(:, voltagechannel)';
    
    currentdata = data(:, currentinjchannel)';    
    scaled_currentdata = currentdata.*pclamp_gain; %puts current data in terms of pA
    scaled_currentdata = scaled_currentdata-mode(scaled_currentdata);
    diffcurrentdata = diff(abs(scaled_currentdata));

    firstonset = find(diffcurrentdata>5, 1);

    inj_on_idxs = [firstonset:((stimdur+interstim)*SampleRate):length(currentdata)];
    inj_on_idxs = inj_on_idxs(1:numsteps);
    inj_off_idxs = [firstonset+(stimdur*SampleRate):((stimdur+interstim)*SampleRate):length(currentdata)];
    inj_off_idxs = inj_off_idxs(1:numsteps);
    
    %% plot data
    prestimlength = 0.50; %s
    poststimlength = 0.50; %s
    npresamps = prestimlength*SampleRate;
    npostsamps = poststimlength*SampleRate;
    
    linecolors = bone(length(inj_on_idxs)+1);
    fig1 = figure
    hold on
    
    for j = 1:length(inj_on_idxs)
        subplot(2, 1, 1)
        hold on
        plot(voltagedata((inj_on_idxs(j)-npresamps):(inj_off_idxs(j)+npostsamps)),'Color', linecolors(j, :))
        
        ylim([-100, -0])
        ax = gca;
        ax.XTickLabel = ax.XTick./20;
        
        subplot(2,1,2)
        hold on
        plot(scaled_currentdata((inj_on_idxs(j)-npresamps):(inj_off_idxs(j)+npostsamps)),'Color', linecolors(j, :))
        
        ylim([-15, 10])
        ax = gca;
        ax.XTickLabel = ax.XTick./20; 
    end
    
    export_fig(fig1,[dataDir, fileTag(1:end-4), '_summary.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');
    
    position=strfind(dataFiles(i).name,'.'); %gives the position of the "period" in the string FileName
    NewName=dataFiles(i).name(1:position-1);
    Outfile=strcat(NewName,'_currentdata.mat');
    save([dataDir, Outfile],'voltagedata', 'scaled_currentdata', 'diffcurrentdata', 'SampleRate', 'inj_on_idxs', 'inj_off_idxs');
end
    