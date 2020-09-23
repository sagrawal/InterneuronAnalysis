function []=makeephysvideo_steps(FileTag)

FileList=dir([FileTag, '*WithStepOnset.mat']);
load(FileList.name);

% we'll plot a single ramp and hold stimulus, 3 second before and then 70
% sec after stim onset (includes a swing back in the other direction)
% des_FR = 10; %desired frame rate for plotting data/making video, will have to downsample everything to this.
secbefore = 3;
secafter = 70;

% pull out start of swing and create matrix of the relevant data -- joint
% angle and membrane potential

legangle_start = LOCS(1);
legangle_end = LOCS(1)+ceil(FrameRate*secafter);
legangle_data = legangles(legangle_start:legangle_end);
mempot_data = voltagedata(frame_on(legangle_start:legangle_end));

NofFrames = length(mempot_data); 

fig = figure;
v = VideoWriter(['E:\Sweta to backup\ephysdata\Agrawal 2020 vids\', FileTag, 'slowed.avi'], 'Uncompressed AVI');
v.FrameRate = FrameRate./2;
open(v);

for i = 1:10:NofFrames
    clf;
    hold on;
    %mem pot data
    plot(mempot_data(1:i), 'c', 'LineWidth', 1)
    
    %leg angle data
    x3 = (NofFrames-10*FrameRate) + 5*FrameRate*cos(deg2rad(180-legangle_data(i)));
    y3 = (max(mempot_data)+1) + (((max(mempot_data)+1)-(min(mempot_data)-1))./NofFrames)*10*FrameRate*sin(deg2rad(180+legangle_data(i)));
    line([NofFrames-FrameRate*15, NofFrames-FrameRate*10, x3], [max(mempot_data)+1, max(mempot_data)+1, y3], 'Color', 'red', 'LineWidth', 3)
    plot(x3, y3, '.r', 'MarkerSize', 20)
    
    ylim([min(mempot_data)-1, max(mempot_data)+1]);
    ylabel('Vm')
    xlim([0, NofFrames+FrameRate]);
    xlabel('sec')
    set(fig,'color', 'k')
    
    set(gcf,'color', 'k')
    box off
    
    set(gca, 'color', 'k')
    
    ax = gca;
    xticks(ax, 0:10*FrameRate:NofFrames)
    ax.XTickLabel = ax.XTick./(FrameRate);
    ax.LineWidth = 2;
    ax.XColorMode = 'manual';
    ax.XColor = 'w';
    ax.YColor = 'w';
    
    set(gcf, 'Position',  [488, 342, 560*1.5, 420])
    
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
