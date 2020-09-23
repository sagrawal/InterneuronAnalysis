%%make movie that plots ephys data while leg moves

clear all;

voltagechannel = 1;
triggerchannel = 4;


%% init file and paths
% dataDir = 'E:\Dropbox (Tuthill Lab)\ephysdata\';
dataDir = 'C:\Users\Tuthill Lab\Google Drive\Sweta to backup\ephysdata\';
movieDir = 'C:\Users\Tuthill Lab\Google Drive\Sweta to backup\chordotonal videos\';

fileTag = '25g05_08_spontaneous*'; %analyzing trials with stimuli of differing heights
dataFiles = dir([dataDir, fileTag]);

moviefileTag = '*25g05_08_spontaneous02*';
movieFiles = dir([movieDir, moviefileTag]);


%% import data
[data,si,h]=abfload([dataDir dataFiles.name]);

voltagedata = data(5.4e06:0.8e7, voltagechannel)';
triggerdata = data(5.4e06:0.8e7, triggerchannel)';
roundtriggerdata = round(triggerdata);



%% import movie
mov = VideoReader(movieFiles.name);

%% find where each frame is triggered
trigger_on = diff(roundtriggerdata>2);
idxs_on = find(trigger_on == 1)+1;
idxs_on = idxs_on(1:2:end);

%% plot data together with video frames, then export as movie
framerate = 50;
voltage_ylim = [-35, -30];
voltage_xlim = [0, idxs_on(500) - idxs_on(1)];
fig = figure;
hold on

v = VideoWriter('C:\Users\Tuthill Lab\Google Drive\Sweta to backup\ephysdata\chordvideos\25g05_spontaneous.avi', 'Uncompressed AVI');
v.FrameRate = framerate;
open(v);

posVec1 = [0.13, 0.5, 0.7, 0.9];
posVec2 = [0.13, 0.25, 0.7, 0.2]; 

for i = 1:500
    g = subplot(2, 1, 1, 'Position', posVec1);
    image(read(mov, i));
    set(g, 'Xtick', [], 'YTick', []);
    box off
    
    h = subplot(2, 1, 2, 'Position', posVec2);
    plot(voltagedata(idxs_on(1):idxs_on(i)));
    ylim(voltage_ylim);
    ylabel('mV')
    xlim(voltage_xlim);
   
    xlabel('sec')
    set(h,'color', 'k')
    
    set(gcf,'color', 'k')
    box off
    
     ax = gca;
    ax.XTickLabel = ax.XTick./20000;
    ax.LineWidth = 1;
    ax.XColorMode = 'manual';
    ax.XColor = 'w';
    ax.YColor = 'w';
   
%     f(i) = getframe(fig);
       f = getframe(fig);
    writeVideo(v, f)
end
    
close(v)
    