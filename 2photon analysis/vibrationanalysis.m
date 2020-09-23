%% file to analyze effects of vibration stimulus on cell activity
% start by loading all files related to a particular cell type (using
% FileTag). Segment files into relevant for 50% analysis versus 3%
% analysis. segment files based on frequency tested. average across
% specified window, and average the two traces per cell type.

%currently averaging across entire window of stimulus

fileTag = '04751';
dataDir = 'G:/My Drive/Sweta to backup/2 photon data/04751gal4/piezo 1 um/';

freqstims = [100, 200, 400, 800, 1600, 2000];
n = 7; %hard code this in for now
% framerate = 7.57; %hz, hard coded based on experience

HighAmp_data = NaN(n, length(freqstims));
LowAmp_data = NaN(n, length(freqstims));

for k = 1:n
    for j = 1:length(freqstims)
        HighAmp_DFFFiles = dir([dataDir, fileTag, '*0', num2str(k), '*piezo*', num2str(freqstims(j)), '*_50_*FilterAndRegisterImagesKmeansClusterPixels.mat']);
        LowAmp_DFFFiles = dir([dataDir, fileTag, '*', num2str(k), '*piezo*', num2str(freqstims(j)), '*_3_*FilterAndRegisterImagesKmeansClusterPixels.mat']);
                
        HighAmp_timingFiles = dir([dataDir, fileTag, '*', num2str(k), '*piezo_', num2str(freqstims(j)), '*_50_*FindPiezoStartFrames.mat']);
        LowAmp_timingFiles = dir([dataDir, fileTag, '*', num2str(k), '*piezo_', num2str(freqstims(j)), '*_3_*FindPiezoStartFrames.mat']);
    
        if isempty(HighAmp_DFFFiles)
        else
            HighAmp_DFFFiles(1).name
            vibrationDFF = [];
            load(HighAmp_DFFFiles(1).name);
            load(HighAmp_timingFiles(1).name);
            for i = 1:2
                vibrationDFF(i) = mean(DFF1(StimStartFrameAndOffset(i, 1):ceil(StimStartFrameAndOffset(i, 1)+1*framerate)));
            end
            HighAmp_data(k, j) = mean(vibrationDFF);
        end
        
        if isempty(LowAmp_DFFFiles)
        else
            vibrationDFF = [];
            load(LowAmp_DFFFiles(1).name);
            load(LowAmp_timingFiles(1).name);
            for i = 1:2
                vibrationDFF(i) = mean(DFF1(StimStartFrameAndOffset(i, 1):ceil(StimStartFrameAndOffset(i, 1)+4*framerate)));
            end
            LowAmp_data(k, j) = mean(vibrationDFF);
        end  
        
    end
end

fig1 = figure
hold on
for i = 1:n
    plot(HighAmp_data(i, :), '.-r', 'MarkerSize', 15)
    plot(LowAmp_data(i, :), '.-b', 'MarkerSize', 15)
end

ax = gca;
ax.XTick = 0:length(freqstims);
ax.XTickLabel = [0, freqstims];
ylabel('DF/F')
xlabel('frequency')

% export_fig(fig1,[dataDir, fileTag, '_vibrationanalysis.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');
% 