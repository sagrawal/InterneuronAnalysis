%% uses data from "with wave onset" file, has already found the start of each triangle wave stim.
clear all;

secbefore = 1;
secafter = 2;
nrep = 1;

dataDir = 'G:\My Drive\Sweta to backup\ephysdata\10B recordings\trianglewaves\diffpos\';


fileTag = '04751_22*flex*WithWaveOnset.mat';
dataFile = dir([dataDir, fileTag]);


%% 
load([dataDir, dataFile(1).name]);
% LOCS = LOCS(1:12); %hard coded when necessary

for j = 1:(length(LOCS)/nrep) %make a figure for every stim freq
    fig1 = figure(j)
    clf
    hold on    
    
    for k = 1:nrep
        stimstart(k,j) = ceil(LOCS(j+((k-1)*(length(LOCS)/nrep)))-(secbefore*FrameRate));
        stimend(k,j) = ceil(LOCS(j+((k-1)*(length(LOCS)/nrep)))+(secafter*FrameRate));
        
        voltagestart(k,j) = frame_on(stimstart(k,j));
        voltageend(k,j) = frame_on(stimend(k,j));
        
        if voltageend(k,j)>length(voltagedata)
            voltageend(k,j) = length(voltagedata);
        end
        
        if voltagestart(k,j)<0
            voltagestart(k,j) = 1;
        end
    end

    
    
    g = subplot(2, 1, 1); %plot cell voltage in first plot
    hold on
    
    datalength = min(voltageend(:,j)-voltagestart(:,j));
    allvoltagedata = [];
    
    for k = 1:nrep
        allvoltagedata(k, :) = voltagedata(voltagestart(k,j):voltagestart(k,j)+datalength);
    end
    
    plot(mean(allvoltagedata, 1))
    
    ax = gca;
    ax.XTickLabel = ax.XTick./SampleRate;
    ax.LineWidth = 1;
%     ylim([-45, -20])
    
    
    g = subplot(2, 1, 2); %plot legangle data
    hold on
    plot(legangles(stimstart(1,j):stimend(1,j)))
%     plot(legangles(stimstart(2,j):stimend(2,j)), 'r')
    xlabel('sec')
    
    ax = gca;
    ax.XTickLabel = ax.XTick./FrameRate;
    ax.LineWidth = 1;
    
    
    if j == 1
        export_fig(fig1,[dataDir, fileTag(1:8), '_', num2str(j), '_flex_trianglewave.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');
    elseif j == 2
        export_fig(fig1,[dataDir, fileTag(1:8), '_', num2str(j), '_flex_trianglewave.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');
    elseif j == 4
        export_fig(fig1,[dataDir, fileTag(1:8), '_', num2str(j), '_flex_trianglewave.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');
    end
% %     
end



