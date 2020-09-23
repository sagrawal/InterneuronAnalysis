%% 10/25/2019 Loading and examining ephys data, plotting current inj data + raster
% approximately 10 current injection steps, produce graph comparing current
% injection with voltage values, rasters above

%currentinj step idx already present in .mat file

clearvars;
dataDir = 'G:\My Drive\Sweta to backup\ephysdata\9Aalpha recordings\currentinj\';
fileTag = 'ss28981_36_currentinj_19301006_currentdataWithSpikes.mat';
dataFiles = dir([dataDir, fileTag]);
load([dataDir, dataFiles(1).name]);

%% plot data
prestimlength = 0.50; %s
poststimlength = 0.50; %s
stimlength = 1; %s, hard coded for now
npresamps = prestimlength*SampleRate;
npostsamps = poststimlength*SampleRate;
% 

linecolors = bone(length(inj_on_idxs)+1);
fig1 = figure
hold on

for j = 1:length(inj_on_idxs)
    these_spikes{j} = spikes(spikes<(inj_off_idxs(j)+npostsamps)&spikes>(inj_on_idxs(j)-npresamps))-(inj_on_idxs(j)-npresamps);    
    
    subplot(3, 1, 2)
    hold on
    plot(voltagedata((inj_on_idxs(j)-npresamps):(inj_off_idxs(j)+npostsamps)),'Color', linecolors(j, :))
    
    ylim([-100, -0])
    xlim([0, (stimlength+prestimlength+poststimlength).*SampleRate])
    ax = gca;
    ax.XTickLabel = ax.XTick./20000;
    
    
    subplot(3,1,3)
    hold on
    plot(scaled_currentdata((inj_on_idxs(j)-npresamps):(inj_off_idxs(j)+npostsamps)),'Color', linecolors(j, :))
    
    ylim([-15, 10])
    xlim([0, (stimlength+prestimlength+poststimlength).*SampleRate])
    ax = gca;
    ax.XTickLabel = ax.XTick./20000;    
end
  
subplot(3, 1, 1)
hold on
plotSpikeRaster(these_spikes, 'PlotType', 'vertline', 'XLimForCell', [0, (stimlength+prestimlength+poststimlength).*SampleRate]);
box off
axis off
set(gcf,'color', 'w')

export_fig(fig1,[dataDir, fileTag(1:end-4), '_summary.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');