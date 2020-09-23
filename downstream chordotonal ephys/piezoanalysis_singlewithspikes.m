%plot piezo data, include spiking rasters
clearvars

dataDir = 'G:\My Drive\Sweta to backup\ephysdata\9Aalpha recordings\piezo 01 um\';
fileTag = 'ss28981_27_piezo_01um_';

dataFiles = dir([dataDir, fileTag, '*EphysPiezodataWithSpikes.mat']);

nrep = 3;

secbefore = 2;
secafter = 2;
stimlength = 4;
umpiezosensor = 0.1667; %about how much, in V, 1 um of movement  

for i = 1:length(dataFiles)
    load([dataDir, dataFiles(i).name]);
    position=strfind(dataFiles(i).name,'EphysPiezo');
    NewName=dataFiles(i).name(1:position-11);
    
    for j = 1:(length(piezoframeon)/nrep) %make a figure for every stim freq
    
        fig1 = figure(j)
        clf
        hold on
        
        celldata = [];
        sensordata = [];
        
        allspiketimes = [];
        
        for k = 1:nrep
            stimstart = piezoframeon((j-1)*3+k)-(secbefore*SampleRate);
            stimend = piezoframeon((j-1)*3+k)+((stimlength+secafter)*SampleRate);
            spiketimes{k} = (spikes(spikes>stimstart(i) & spikes<stimend(i))-stimstart(i))./SampleRate;
            allspiketimes = [allspiketimes, spiketimes{k}];
            
            if stimend>length(voltagedata)
            else
%                 'hullo'
                celldata(k, :) = voltagedata(stimstart:stimend);
                sensordata(k, :) = piezosensordata(stimstart:stimend);
                piezoamp_um(j, k) = (max(sensordata(k, :))-min(sensordata(k, :)))./umpiezosensor;
            end
        end
            
        
        g = subplot(4, 1, 1);
        hold on
        plotSpikeRaster(spiketimes, 'PlotType', 'vertline', 'XLimForCell', [0, 8]);
        box off
        axis off

        g = subplot(4, 1, 2);
        hold on
        binsize = 0.1; %in s
        spikerate = histcounts(allspiketimes, 0:binsize:8)./(nrep*binsize);
        plot((0.5*binsize):binsize:8, spikerate)
        xlim([0, 8])
        ylim([0, 180])
        box off
        
        
        
        g = subplot(4, 1, 3); %plot cell voltage in first plot
        hold on
        plot(celldata', '--')
        plot(mean(celldata), 'k')
        xlim([0, length(celldata(1, :))])
        title(['amplitude: ', num2str(mean( piezoamp_um(j, :))), ' um']);
        
        ax = gca;
        xticks(ax, 0:SampleRate*2:length(celldata(1, :)))
        ax.XTickLabel = ax.XTick./SampleRate;
        ax.LineWidth = 1;
        ylim([-40, -25])
        
        
        g = subplot(4, 1, 4); %plot sensor data
        hold on
        plot(sensordata', '--')
        plot(mean(sensordata), 'k')
        xlim([0, length(celldata(1, :))])
        xlabel('sec')
       
        
        ax = gca;
        xticks(ax, 0:SampleRate*2:length(celldata(1, :)))
        ax.XTickLabel = ax.XTick./SampleRate;
        ax.LineWidth = 1;
        
        export_fig(fig1,[dataDir, NewName, '_', num2str(j), '_summary.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');
        
    end    
    
end
    