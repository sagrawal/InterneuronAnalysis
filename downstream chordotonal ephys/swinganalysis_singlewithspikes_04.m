%% analyze swing data -- 11/20/17: only analyzes data from a single fly
% 2/11/19: now takes into account swing onset and possibility of spiking
% data
% 10/28/19: spiking data and latest version of corrected/aligned swing data
clearvars;

% dataDir = 'C:\Users\swetarr\Google Drive\Sweta to backup\ephysdata\';
dataDir = 'G:\My Drive\Sweta to backup\ephysdata\9Aalpha recordings\post MLA swings\tonic\post\';
fileTag = 'ss28981_26_postMLA_swings_19118018_EphysAngledata_WithSwingOnsetCorrWithSpikes.mat';
dataFile = dir([dataDir, fileTag]);

load([dataDir, dataFile(1).name])

spikedata = 1; %change to 0 if not available
secondsbefore = 3;
secondsafter = 3;
framesbefore = secondsbefore*FrameRate; %number of frames worth of data included pre-swing
framesafter = secondsafter*FrameRate; %amount of frames worth of data included post-swing

%% identify which swing is which
nslowswing = 3;
nfastswing = 3;

fastswing_on = swingstarts(1:nfastswing);
slowswing_on = swingstarts((nfastswing+1):(nslowswing+nfastswing));

fastswing_off = swingends(1:nfastswing);
slowswing_off = swingends((nfastswing+1):(nslowswing+nfastswing));

%% make time vectors, spike vectors (all spike times that fall into 
[nframes, idx] = min(frame_on(fastswing_off) - frame_on(fastswing_on));
all_fastspiketimes = [];
all_slowspiketimes = [];

for i = 1:nfastswing
    fastswing_sampletime{i} = (frame_on(fastswing_on(i))/SampleRate-secondsbefore):(1/SampleRate):((frame_on(fastswing_on(i))+nframes)/SampleRate+secondsafter);
    fastswing_sampletime{i} = fastswing_sampletime{i}-fastswing_sampletime{i}(1);
    
    fasttrialstart(i) = frame_on(fastswing_on(i))-(framesbefore/FrameRate)*SampleRate; %in terms of samples (aka voltagedata timestep)
    fasttrialend(i) = frame_on(fastswing_on(i))+nframes+(framesafter/FrameRate)*SampleRate; %in terms of samples (aka voltagedata timestep)
    fast_spiketimes{i} = (spikes(spikes>fasttrialstart(i) & spikes<fasttrialend(i))-fasttrialstart(i))./SampleRate;
    all_fastspiketimes = [all_fastspiketimes, fast_spiketimes{i}];
    
    fastswing_angletime{i} = frame_on((fastswing_on(i)-framesbefore):(fastswing_off(i)+framesafter))./SampleRate;
    fastswing_angletime{i} = fastswing_angletime{i}-fastswing_angletime{i}(1);
    
    
end

[nframes, idx] = min(frame_on(slowswing_off) - frame_on(slowswing_on));
for i = 1:nslowswing
    slowswing_sampletime{i} = (frame_on(slowswing_on(i))/SampleRate-secondsbefore):(1/SampleRate):((frame_on(slowswing_on(i))+nframes)/SampleRate+secondsafter);
    slowswing_sampletime{i} = slowswing_sampletime{i}-slowswing_sampletime{i}(1);
    
    slowtrialstart(i) = frame_on(slowswing_on(i))-(framesbefore/FrameRate)*SampleRate; %in terms of samples (aka voltagedata timestep)
    slowtrialend(i) = frame_on(slowswing_on(i))+nframes+(framesafter/FrameRate)*SampleRate; %in terms of samples (aka voltagedata timestep)
    slow_spiketimes{i} = (spikes(spikes>slowtrialstart(i) & spikes<slowtrialend(i))-slowtrialstart(i))./SampleRate;
    all_slowspiketimes = [all_slowspiketimes, slow_spiketimes{i}];
    
    slowswing_angletime{i} = frame_on((slowswing_on(i)-framesbefore):(slowswing_off(i)+framesafter))./SampleRate;
    slowswing_angletime{i} = slowswing_angletime{i}-slowswing_angletime{i}(1);
end

%% fast swing fig, added raster plot and spike rate plot on top
fig1 = figure;

g = subplot(4, 1, 1);
hold on
plotSpikeRaster(fast_spiketimes, 'PlotType', 'vertline', 'XLimForCell', [0, 12]);
box off
axis off

g = subplot(4, 1, 2);
hold on
binsize = 0.1; %in s
spikerate = histcounts(all_fastspiketimes, 0:binsize:12)./(nfastswing*binsize);
plot((0.5*binsize):binsize:(12), spikerate)
xlim([0, 12])
ylim([0, 40])

g = subplot(4, 1, 3);
hold on
nframes = min(frame_on(fastswing_off) - frame_on(fastswing_on));
for i = 1:nfastswing
    preswing_mempot = voltagedata((frame_on(fastswing_on(i))-(framesbefore/FrameRate)*SampleRate):frame_on(fastswing_on(i)));
    fastswing_voltagedata(i, :) = (voltagedata(fasttrialstart(i):fasttrialend(i))-mean(preswing_mempot));
    pre_fastswing_MP(i) = mean(preswing_mempot);
    plot(fastswing_sampletime{i}, fastswing_voltagedata(i, :), 'r')
end

plot(fastswing_sampletime{1}, mean(fastswing_voltagedata), 'k')
% ylim([-8, 15]);
ax = gca;
box off


g = subplot(4, 1, 4);
hold on
for i = 1:nfastswing
    plot(fastswing_angletime{i}, legangles((fastswing_on(i)-framesbefore):(fastswing_off(i)+framesafter)), 'r');
end

% ylim([0 180]);
box off
set(gcf,'color', 'w')

% export_fig(fig1,[dataDir fileTag(1:18) '_fastswingsummary.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');

%% slow swing fig
fig2 = figure;

g = subplot(4, 1, 1);
hold on
plotSpikeRaster(slow_spiketimes, 'PlotType', 'vertline', 'XLimForCell', [0, 12]);
box off
axis off

g = subplot(4, 1, 2);
hold on
binsize = 0.1; %in s
spikerate = histcounts(all_slowspiketimes, 0:binsize:12)./(nfastswing*binsize);
plot((0.5*binsize):binsize:(12), spikerate)
xlim([0, 12])
ylim([0, 40])

g = subplot(4, 1, 3);
hold on
nframes = min(frame_on(slowswing_off) - frame_on(slowswing_on));
for i = 1:nslowswing
    preswing_mempot = voltagedata((frame_on(slowswing_on(i))-(framesbefore/FrameRate)*SampleRate):frame_on(slowswing_on(i)));
    slowswing_voltagedata(i, :) = (voltagedata(slowtrialstart(i):slowtrialend(i))-mean(preswing_mempot));
    pre_slowswing_MP(i) = mean(preswing_mempot);
    plot(slowswing_sampletime{i}, slowswing_voltagedata(i, :), 'r')
end

plot(slowswing_sampletime{1}, mean(slowswing_voltagedata), 'k')

% ylim([-8, 15]);
ax = gca;
box off

g = subplot(4, 1, 4);
hold on
for i = 1:nslowswing
    plot(slowswing_angletime{i}, legangles((slowswing_on(i)-framesbefore):(slowswing_off(i)+framesafter)), 'r');
end

% ylim([0 180]);
box off
set(gcf,'color', 'w')

% export_fig(fig2,[dataDir fileTag(1:18) '_slowswingsummary.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');