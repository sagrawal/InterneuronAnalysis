%% file to analyze effects of vibration stimulus on cell activity

% rewritten 1/11/18 to be a summary of vibration stim, creating a few
% different figures:

% max df/f across stim presentation, avg of first 500 ms, average of middle
% 2 sec, plotting all the waveforms

clear all

fileTag = '18h03';
dataDir = 'E:\Sweta to backup\2 photon data\18h03LexA\piezo 005 um\';
freqstims = [100, 200, 400, 800, 1600, 2000];
% framerate = 7.57; %hz, hard coded based on experience
nrep = 2;
secbefore = 2;
secafter = 2;
stimlength = 4;
which_ROI = 2; %idx for the ROI of interest


begwindow = 1; %for avgeraging window of stim onset
midwindowstart = 1; %for averaging middle window of stim, sec from stim onset
midwindowend = 3;   %for averaging middle window of stim, sec from stim onset


for j = 1:length(freqstims)
    DFFFiles = dir([dataDir, fileTag, '*piezo_', num2str(freqstims(j)), 'hz*FilterAndRegisterImagesSelectROICalculateDFF.mat']);
    timingFiles = dir([dataDir, fileTag, '*piezo_', num2str(freqstims(j)), 'hz*FindPiezoStartFrames.mat']);
    
    if length(DFFFiles) ~= length(timingFiles)
        error('mismatch in file number')
    end
    
    avgDFFdata{j} = [];    
    maxDFF{j} = []; 
    avgbegDFF{j} = []; 
    avgmidDFF{j} = []; 
    DFF_filenames{j} = [];
    
    for k = 1:length(DFFFiles)
        load([dataDir, DFFFiles(k).name]);
        load([dataDir, timingFiles(k).name]);
        
        framerate = 20000./mean(ImageInterval);
        signalDFF = DFF1(which_ROI, :);
        
        vibrationDFF = [];
        
        for i = 1:nrep
            vibrationDFF(i, :) = signalDFF(ceil(StimStartFrameAndOffset(i, 1)-secbefore*framerate):ceil(StimStartFrameAndOffset(i, 1)+(stimlength+secafter)*framerate));
        end
        
        avgDFFdata{j}(k, :)  = mean(vibrationDFF);
        maxDFF{j}(k) = max(avgDFFdata{j}(k, ceil(secbefore*framerate):ceil((secbefore+stimlength)*framerate)));
%         avgbegDFF{j}(k) = mean(avgDFFdata{j}(k, ceil(secbefore*framerate):ceil((secbefore+begwindow)*framerate)));
        avgmidDFF{j}(k) = mean(avgDFFdata{j}(k, ceil((secbefore+midwindowstart)*framerate):ceil((secbefore+midwindowend)*framerate)));        
        DFF_filenames{j}{k} = DFFFiles(k).name;
        
%         if j==1 && k>2
%             avgbegDFF{j}(k+1) = mean(avgDFFdata{j}(k, ceil(secbefore*framerate):ceil((secbefore+begwindow)*framerate)));
%             avgbegDFF{j}(3) = NaN;
%         elseif j==6 && k>1
%             avgbegDFF{j}(k+1) = mean(avgDFFdata{j}(k, ceil(secbefore*framerate):ceil((secbefore+begwindow)*framerate)));
%             avgbegDFF{j}(2) = NaN;
%         else
            avgbegDFF{j}(k) = mean(avgDFFdata{j}(k, ceil(secbefore*framerate):ceil((secbefore+begwindow)*framerate)));
%         end
                
    end
end

%% plot making time!
colors = bone(5);
% set(0,'DefaultAxesColorOrder',colors)
% fig1 = figure;
% hold on
% for i = 1:length(freqstims)
%     plot(i, maxDFF{i}, 'Marker', '.', 'MarkerSize', 15)
% end
% 
% ylabel('DFF')
% title('maximum DFF after stim onset')
% xticks(gca, 1:length(freqstims))
% export_fig(fig1,[dataDir, fileTag, '_maxsummary.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');


set(0,'DefaultAxesColorOrder',colors)
fig2 = figure;
hold on
for i = 1:length(freqstims)
    plot(i, avgbegDFF{i}, 'Marker', '.', 'MarkerSize', 15)
end

ylabel('DFF')
title('average DFF during 1 s after stim onset')
xticks(gca, 1:length(freqstims))
ylim([0, 100])
export_fig(fig2,[dataDir, fileTag, '_contralateralFULLRANGE_begsummary.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');

% set(0,'DefaultAxesColorOrder',colors)
% fig3 = figure;
% hold on
% for i = 1:length(freqstims)
%     plot(i, avgmidDFF{i}, 'Marker', '.', 'MarkerSize', 15)
% end
% 
% ylabel('DFF')
% title('average DFF during middle 2 sec of stim presentation')
% xticks(gca, 1:length(freqstims))
% export_fig(fig3,[dataDir, fileTag, '_midsummary.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');


% set(0,'DefaultAxesColorOrder',colors)
% fig4 = figure;
% hold on
% for i = 1:length(freqstims)
%     for j = 1:size(avgDFFdata{i}, 1)
%         subplot(1, length(freqstims), i)
%         hold on
%         ylim([-0.2, 50])
%         xlim([0, framerate*(secbefore+stimlength+secafter)])
%         ax = gca;
%         xticks(ax, 0:framerate*2:framerate*(secbefore+stimlength+secafter))
%         ax.XTickLabel = ax.XTick./framerate;
%         plot(avgDFFdata{i}(j, :))
%     end
% end
% subplot(1, length(freqstims), 1)
% ylabel('DFF')
% set(gcf, 'Position',  [100, 100, 1800, 400])
% export_fig(fig4,[dataDir, fileTag, '_ipsilateral_waveformsummary.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');