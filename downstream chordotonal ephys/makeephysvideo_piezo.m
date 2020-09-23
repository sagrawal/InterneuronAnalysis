function []=makeephysvideo_piezo(FileTag)

FileList=dir([FileTag, '*EphysPiezodata.mat']);
load(FileList.name);

% we'll plot the second-to-last grouping of three piezo stim at 2nd highest frequency, 3 second before and then 10
% sec after stim onset
% des_FR = 10; %desired frame rate for plotting data/making video, will have to downsample everything to this.
secbefore = 3;
secafter = 10;
stimlength = 4;

% pull out start of swing and create matrix of the relevant data -- joint
% angle and membrane potential

mempot_data = voltagedata((piezoframeon(13)-secbefore*SampleRate):(piezoframeon(13)+SampleRate*secafter));
NofFrames = length(mempot_data); 
piezo_on = zeros(1, NofFrames);
piezo_on(secbefore*SampleRate:(secbefore*SampleRate+stimlength*SampleRate)) = 1;


fig = figure;
v = VideoWriter(['E:\Sweta to backup\ephysdata\Agrawal 2020 vids\', FileTag, 'slowed.avi'], 'Uncompressed AVI');
v.FrameRate = SampleRate./1000;
open(v);

for i = 1:SampleRate/4:NofFrames
    clf;
    hold on;
    %mem pot data
    plot(mempot_data(1:i), 'c', 'LineWidth', 1)
   
    if piezo_on(i) == 1
        plot(NofFrames-SampleRate, max(mempot_data), '.r', 'MarkerSize', 40)
    end
    
    
   
    ylim([min(mempot_data)-1, max(mempot_data)+1]);
    ylabel('Vm')
    xlim([0, NofFrames]);
    xlabel('sec')
    set(fig,'color', 'k')
    
    set(gcf,'color', 'k')
    box off
    
    set(gca, 'color', 'k')
    
    ax = gca;
    xticks(ax, 0:SampleRate:NofFrames)
    ax.XTickLabel = ax.XTick./(SampleRate);
    ax.LineWidth = 2;
    ax.XColorMode = 'manual';
    ax.XColor = 'w';
    ax.YColor = 'w';
    
%     set(gcf, 'Position',  [488, 342, 560, 420])
    
    %calculate leg diagram coordinates, plot
    
%     hsp1 = get(gca, 'Position');

    
%     plot(x3, y3, '.r', 'MarkerSize', 20)
%     hsp2 = get(gca, 'Position');
%     set(gca, 'Position', [hsp1(1), 0.8*hsp2(2), hsp1(3), 1.5*hsp2(4)])
    
    f = getframe(fig);
    writeVideo(v, f)
end

close(v)


clear
