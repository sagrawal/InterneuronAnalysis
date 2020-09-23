%% analyze swing data 
% 11/20/17: only analyzes data from a single fly
% 2/11/19: now takes into account swing onset and possibility of spiking
% data
% 10/28/19: spiking data and latest version of corrected/aligned swing data
clearvars;

dataDir = 'E:\Sweta to backup\ephysdata\9Aalpha recordings\swings\';
% dataDir = 'G:\My Drive\Sweta to backup\ephysdata\9Aalpha recordings\swings\';
fileTag = 'ss2898*WithSpikes.mat';
dataFiles = dir([dataDir, fileTag]);
nflies = length(dataFiles)


fast_secbefore = 1;
fast_secafter = 0.3;

slow_secbefore = 1;
slow_secafter = 1;

for j = 1:nflies
%     j
    load([dataDir, dataFiles(j).name])
    %% identify which swing is which
    nslowswing = 3;
    nfastswing = 3;
    
    fastswing_on = swingstarts(1:nfastswing);
    slowswing_on = swingstarts((nfastswing+1):(nslowswing+nfastswing));
    
    fastswing_off = swingends(1:nfastswing);
    slowswing_off = swingends((nfastswing+1):(nslowswing+nfastswing));
    
    %% make time vectors, spike vectors (all spike times that fall into
    allon_pre_fastspiketimes{j} = [];
    allon_fastspiketimes{j} = [];
    allon_pre_slowspiketimes{j} = [];
    allon_slowspiketimes{j} = [];
    
    alloff_pre_fastspiketimes{j} = [];
    alloff_fastspiketimes{j} = [];
    alloff_pre_slowspiketimes{j} = [];
    alloff_slowspiketimes{j} = [];
    
    
    for i = 1:nfastswing
        off_pre_fasttrialstart(i) = frame_on(fastswing_off(i))-(fast_secbefore)*SampleRate;
        off_pre_fasttrialend(i) = frame_on(fastswing_off(i)); 
        off_pre_fast_spiketimes = (spikes(spikes>off_pre_fasttrialstart(i) & spikes<off_pre_fasttrialend(i))-off_pre_fasttrialstart(i))./SampleRate;
        alloff_pre_fastspiketimes{j} = [alloff_pre_fastspiketimes{j}, off_pre_fast_spiketimes];
        
        off_fasttrialstart(i) = frame_on(fastswing_off(i));
        off_fasttrialend(i) = frame_on(fastswing_off(i))+(fast_secafter)*SampleRate;
        off_fast_spiketimes = (spikes(spikes>off_fasttrialstart(i) & spikes<off_fasttrialend(i))-off_fasttrialstart(i))./SampleRate;
        alloff_fastspiketimes{j} = [alloff_fastspiketimes{j}, off_fast_spiketimes];
        
        
        on_pre_fasttrialstart(i) = frame_on(fastswing_on(i))-(fast_secbefore)*SampleRate;
        on_pre_fasttrialend(i) = frame_on(fastswing_on(i)); 
        on_pre_fast_spiketimes = (spikes(spikes>on_pre_fasttrialstart(i) & spikes<on_pre_fasttrialend(i))-on_pre_fasttrialstart(i))./SampleRate;
        allon_pre_fastspiketimes{j} = [allon_pre_fastspiketimes{j}, on_pre_fast_spiketimes];
        
        on_fasttrialstart(i) = frame_on(fastswing_on(i));
        on_fasttrialend(i) = frame_on(fastswing_on(i))+(fast_secafter)*SampleRate;
        on_fast_spiketimes = (spikes(spikes>on_fasttrialstart(i) & spikes<on_fasttrialend(i))-on_fasttrialstart(i))./SampleRate;
        allon_fastspiketimes{j} = [allon_fastspiketimes{j}, on_fast_spiketimes];
    end
    
    for i = 1:nslowswing
        on_pre_slowtrialstart(i) = frame_on(slowswing_on(i))-(slow_secbefore)*SampleRate;
        on_pre_slowtrialend(i) = frame_on(slowswing_on(i)); 
        on_pre_slow_spiketimes = (spikes(spikes>on_pre_slowtrialstart(i) & spikes<on_pre_slowtrialend(i))-on_pre_slowtrialstart(i))./SampleRate;
        allon_pre_slowspiketimes{j} = [allon_pre_slowspiketimes{j}, on_pre_slow_spiketimes];
        
        on_slowtrialstart(i) = frame_on(slowswing_on(i));
        on_slowtrialend(i) = frame_on(slowswing_on(i))+(slow_secafter)*SampleRate;
        on_slow_spiketimes = (spikes(spikes>on_slowtrialstart(i) & spikes<on_slowtrialend(i))-on_slowtrialstart(i))./SampleRate;
        allon_slowspiketimes{j} = [allon_slowspiketimes{j}, on_slow_spiketimes];
        
        
        off_pre_slowtrialstart(i) = frame_on(slowswing_off(i))-(slow_secbefore)*SampleRate;
        off_pre_slowtrialend(i) = frame_on(slowswing_off(i)); 
        off_pre_slow_spiketimes = (spikes(spikes>off_pre_slowtrialstart(i) & spikes<off_pre_slowtrialend(i))-off_pre_slowtrialstart(i))./SampleRate;
        alloff_pre_slowspiketimes{j} = [alloff_pre_slowspiketimes{j}, off_pre_slow_spiketimes];
        
        off_slowtrialstart(i) = frame_on(slowswing_off(i));
        off_slowtrialend(i) = frame_on(slowswing_off(i))+(slow_secafter)*SampleRate;
        off_slow_spiketimes = (spikes(spikes>off_slowtrialstart(i) & spikes<off_slowtrialend(i))-off_slowtrialstart(i))./SampleRate;
        alloff_slowspiketimes{j} = [alloff_slowspiketimes{j}, off_slow_spiketimes];
    end
    
    %average spike rate during measured period
    on_pre_fast_spikerate(j) = length(allon_pre_fastspiketimes{j})./(nfastswing*fast_secbefore);
    on_pre_slow_spikerate(j) = length(allon_pre_slowspiketimes{j})./(nslowswing*slow_secbefore);
    on_fast_spikerate(j) = length(allon_fastspiketimes{j})./(nfastswing*fast_secafter);
    on_slow_spikerate(j) = length(allon_slowspiketimes{j})./(nslowswing*slow_secafter);
    
    off_pre_fast_spikerate(j) = length(alloff_pre_fastspiketimes{j})./(nfastswing*fast_secbefore);
    off_pre_slow_spikerate(j) = length(alloff_pre_slowspiketimes{j})./(nslowswing*slow_secbefore);
    off_fast_spikerate(j) = length(alloff_fastspiketimes{j})./(nfastswing*fast_secafter);
    off_slow_spikerate(j) = length(alloff_slowspiketimes{j})./(nslowswing*slow_secafter);
    
    %peak spike rate during measured period
    binsize = 0.05; %in s
    spikerate = histcounts(allon_fastspiketimes{j}, 0:binsize:1)./(nfastswing*binsize);
    on_fast_peakspikerate(j) = max(spikerate);
    
    spikerate = histcounts(allon_slowspiketimes{j}, 0:binsize:1)./(nslowswing*binsize);
    on_slow_peakspikerate(j) = max(spikerate);
    
    spikerate = histcounts(alloff_fastspiketimes{j}, 0:binsize:1)./(nfastswing*binsize);
    off_fast_peakspikerate(j) = max(spikerate);
    
    spikerate = histcounts(alloff_slowspiketimes{j}, 0:binsize:1)./(nslowswing*binsize);
    off_slow_peakspikerate(j) = max(spikerate);
end

%% peak spike rate
fig1 = figure;
hold on

plot([1, 2], [on_fast_peakspikerate', on_slow_peakspikerate'], 'k.-', 'MarkerSize', 15)
xlim([0, 3])

plot([1, 2], [mean(on_fast_peakspikerate), mean(on_slow_peakspikerate)], 'ro', 'MarkerSize', 15);

[h, p] = ttest2(on_fast_peakspikerate, on_slow_peakspikerate)
% export_fig(fig1,[dataDir 'speedcomparison_peakspikerate.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');

%flex spike rate vs ext spike rate for fast swings
fig2 = figure;
hold on

plot(on_fast_peakspikerate, off_fast_peakspikerate, '.', 'MarkerSize', 15)
plot([0, 300], [0, 300], '--')

xlim([0, 300]);
ylim([0, 300]);
box off

% export_fig(fig2,[dataDir 'directiontuning_peakspikerate.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');

%% average spike rate
fig3 = figure;
hold on

plot([1, 2], [on_fast_spikerate', on_slow_spikerate'], 'k.-', 'MarkerSize', 15)
xlim([0, 3])

plot([1, 2], [mean(on_fast_spikerate), mean(on_slow_spikerate)], 'ro', 'MarkerSize', 15);

[h, p] = ttest2(on_fast_spikerate, on_slow_spikerate)
% export_fig(fig3,[dataDir 'speedcomparison_averagespikerate.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');
