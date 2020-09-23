%% file to discover any spatial shifts in vibration-responding activity
% 1/14/19

clear all

fileTag = '2898';
dataDir = 'G:\My Drive\Sweta to backup\2 photon data\28981gal4 28980gal4\piezo 005 um\';

freqstims = [100, 200, 400, 800, 1600, 2000];
framerate = 7.57; %hz, hard coded based on experience
nrep = 2;
pxthresh = 50; %threshold for which pixels to grab data from, will only use pixels with average fluoresence above this threshold

begwindow = 0.5; %for avgeraging window of stim onset

midwindowstart = 1.25; %for averaging middle window of stim, sec from stim onset
midwindowend = 2.5;   %for averaging middle window of stim, sec from stim onset

for j = 1:length(freqstims)
    DFFFiles = dir([dataDir, fileTag, '*piezo_', num2str(freqstims(j)), 'hz*FilterAndRegisterImages.mat']);
    timingFiles = dir([dataDir, fileTag, '*piezo_', num2str(freqstims(j)), 'hz*FindPiezoStartFrames.mat']);
    
    if length(DFFFiles) ~= length(timingFiles)
        error('mismatch in file number')
    end
    
    length(DFFFiles)
    avgbegImages{j} = nan(128, 256, length(DFFFiles));
    avgmidImages{j} = nan(128, 256, length(DFFFiles));
    avg_bls_begImages{j} = nan(128, 256, length(DFFFiles));
    avg_bls_midImages{j} = nan(128, 256, length(DFFFiles));
    
    for k = 1:length(DFFFiles)
%         DFFFiles(k).name
        load([dataDir, DFFFiles(k).name]);
        load([dataDir, timingFiles(k).name]);
        Images=squeeze(RegisteredImages(:,:,SignalChannel,:));
        
        if size(Images, 1) ~= 128
        else
            begImages = [];
            midImages = [];
            baseline = [];
            
            threshedimage = int16(repmat(mean(Images, 3)>pxthresh,[1, 1, size(Images, 3)])); %thresholded so that pixels at less than average 50 fluor aren't being counted
            Images = Images.*threshedimage;
            
            for i = 1:nrep
                baseline = mean(Images(:, :, (StimStartFrameAndOffset(i, 1)-10):StimStartFrameAndOffset(i, 1)), 3);
                begImages(:, :, i) = mean(Images(:, :, ceil(StimStartFrameAndOffset(i, 1)):ceil(StimStartFrameAndOffset(i, 1)+begwindow*framerate)), 3);
                baselinesub_begImages(:, :, i) = (mean(Images(:, :, ceil(StimStartFrameAndOffset(i, 1)):ceil(StimStartFrameAndOffset(i, 1)+begwindow*framerate)), 3)-baseline)./baseline;
                midImages(:, :, i) = mean(Images(:, :, ceil(StimStartFrameAndOffset(i, 1)+midwindowstart*framerate):ceil(StimStartFrameAndOffset(i, 1)+midwindowend*framerate)), 3);
                baselinesub_midImages(:, :, i) = (mean(Images(:, :, ceil(StimStartFrameAndOffset(i, 1)+midwindowstart*framerate):ceil(StimStartFrameAndOffset(i, 1)+midwindowend*framerate)), 3)-baseline)./baseline;
            end
            
            avgbegImages{j}(:, :, k) = mean(begImages, 3);
            avgmidImages{j}(:, :, k) = mean(midImages, 3);
            
            avg_bls_begImages{j}(:, :, k) = mean(baselinesub_begImages, 3);
            avg_bls_midImages{j}(:, :, k) = mean(baselinesub_midImages, 3);
        end
    end
end

%% plot!

for i = 1:length(freqstims)
    fig1 = figure
    hold on
    
    montage(avg_bls_begImages{i}, 'Size', [size(avg_bls_begImages{i}, 3), 1]);%, 'DisplayRange', [50 300])
    
    export_fig(fig1,[dataDir, fileTag, '_', num2str(freqstims(i)), 'hz_begspatialsummary.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');
end

for i = 1:length(freqstims)
    fig2 = figure
    hold on
    
    montage(avg_bls_midImages{i}, 'Size', [size(avg_bls_midImages{i}, 3), 1]);%, 'DisplayRange', [50 300])
    
%     export_fig(fig2,[dataDir, fileTag, '_', num2str(freqstims(i)), 'hz_midspatialsummary.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');
end
    
    
    
    
    
    
    
    
    
    
    