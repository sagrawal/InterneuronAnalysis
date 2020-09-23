function []=makeephysvideo(FileTag)

FileList=dir([FileTag, '*WithSwingOnsetCorr.mat']);
load(FileList.name);

% we'll plot a single fast swing, 5 second before and then 10 sec after swing
% onset (includes a swing back in the other direction)
% des_FR = 10; %desired frame rate for plotting data/making video, will have to downsample everything to this.
secbefore = 3;
secafter = 8;

% pull out start of swing and create matrix of the relevant data -- joint
% angle and membrane potential

legangle_start = swingstarts(1)-floor(FrameRate*secbefore);
legangle_end = swingstarts(1)+ceil(FrameRate*secafter);
legangle_data = legangles(legangle_start:legangle_end);
mempot_data = voltagedata(frame_on(legangle_start:legangle_end));

NofFrames = length(mempot_data); 

fig = figure;
v = VideoWriter(['E:\Sweta to backup\ephysdata\Agrawal 2020 vids\', FileTag, '.avi'], 'Uncompressed AVI');
v.FrameRate = FrameRate./5;
open(v);

for i = 1:10:NofFrames
    clf;
    hold on;
    %mem pot data
    plot(mempot_data(1:i), 'c', 'LineWidth', 2)
    
    %leg angle data
    x3 = (NofFrames-FrameRate) + 1.5*FrameRate*cos(deg2rad(180-legangle_data(i)));
    y3 = (max(mempot_data)+3) + (((max(mempot_data)+5)-(min(mempot_data)-2))./NofFrames)*1.5*FrameRate*sin(deg2rad(180+legangle_data(i)));
    line([NofFrames-FrameRate*3, NofFrames-FrameRate, x3], [max(mempot_data)+3, max(mempot_data)+3, y3], 'Color', 'red', 'LineWidth', 3)
    plot(x3, y3, '.r', 'MarkerSize', 20)
    
    ylim([min(mempot_data)-2, max(mempot_data)+5]);
    ylabel('Vm')
    xlim([0, NofFrames+FrameRate]);
    xlabel('sec')
    set(fig,'color', 'k')
    
    set(gcf,'color', 'k')
    box off
    
    set(gca, 'color', 'k')
    
    ax = gca;
    xticks(ax, 0:FrameRate:NofFrames)
    ax.XTickLabel = ax.XTick./FrameRate;
    ax.LineWidth = 2;
    ax.XColorMode = 'manual';
    ax.XColor = 'w';
    ax.YColor = 'w';
    
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
