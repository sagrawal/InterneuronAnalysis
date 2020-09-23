%plot piezo data
%plot peak voltage reached during vibration stim
%plot average voltage in first 500 ms
%plot average voltage in middle 2 sec
%plot average waveforms in response to vibration stim per cell

clearvars

dataDir = 'E:\Sweta to backup\ephysdata\9Aalpha recordings\piezo PT 01 um\pre\';
fileTag = 'ss';

dataFiles = dir([dataDir, fileTag, '*EphysPiezodata.mat']);
ncells = length(dataFiles)

nrep = 3;

secbefore = 2;
secafter = 2;
stimlength = 4;
umpiezosensor = 0.1667; %about how much, in V, 1 um of movement  

for i = 1:ncells
%     i
    load([dataDir, dataFiles(i).name]);
        avgcelldata{i} = [];
        avgsensordata{i} = [];
        avgpiezoamp_um{i} = [];
        baselinevalue{i} = [];
    
    for j = 1:(length(piezoframeon)/nrep)
        celldata = [];
        sensordata = [];
        piezoamp_um = [];
        
        for k = 1:nrep
            stimstart = piezoframeon((j-1)*3+k)-(secbefore*SampleRate);
            stimend = piezoframeon((j-1)*3+k)+((stimlength+secafter)*SampleRate);
            
            if stimstart < 1
                piezoamp_um(j, k) = nan;
            elseif stimend>length(voltagedata)
                celldata(k, :) = nan(1, length(celldata));
                sensordata(k, :) = nan(1, length(sensordata));
                piezoamp_um(j, k) = nan;
            else
                celldata(k, :) = voltagedata(stimstart:stimend);
                sensordata(k, :) = piezosensordata(stimstart:stimend);
                piezoamp_um(j, k) = (max(sensordata(k, :))-min(sensordata(k, :)))./umpiezosensor;
            end
        end
        
        celldata(celldata == 0) = NaN;
        sensordata(sensordata == 0) = NaN;
            
        avgcelldata{i}(j, :) = nanmean(celldata);
        avgsensordata{i}(j, :) = nanmean(sensordata);
        avgpiezoamp_um{i}(j) = nanmean(piezoamp_um(j, :));
        baselinevalue{i}(j) = mean(avgcelldata{i}(j, 1:secbefore*SampleRate));
        
        avgcelldata{i}(j, :) = avgcelldata{i}(j, :) - baselinevalue{i}(j);
        avgsensordata{i}(j, :) = avgsensordata{i}(j, :)- mean(avgsensordata{i}(j, 1:secbefore*SampleRate));
    end
    if length(piezoframeon)/nrep < 6
        avgcelldata{i}(6, :) = nan(1, length(avgcelldata{i}));
        avgsensordata{i}(6, :) = nan(1, length(avgsensordata{i}));
        avgpiezoamp_um{i}(6) = NaN;
        baselinevalue{i}(6) = NaN;
    end       
        
end

%% things to pull out: max voltage reached during vibration stim, average
% voltage in first 500 msec, average voltage in middle 2 sec (all baseline
% corrected)

begwindow = 0.5; %for avgeraging window of stim onset
midwindowstart = 1; %for averaging middle window of stim, sec from stim onset
midwindowend = 3;   %for averaging middle window of stim, sec from stim onset

maxvoltage = nan(ncells, (length(piezoframeon)/nrep));
avgbegvoltage = nan(ncells, (length(piezoframeon)/nrep));
minendvoltage = nan(ncells, (length(piezoframeon)/nrep));

for i = 1:ncells
%     i
    for j = 1:(length(piezoframeon)/nrep)
%         j
        maxvoltage(i, j) = nanmax(avgcelldata{i}(j,secbefore*SampleRate:(stimlength+secbefore)*SampleRate));
        avgbegvoltage(i,j) = nanmean(avgcelldata{i}(j,secbefore*SampleRate:(begwindow+secbefore)*SampleRate));
        minendvoltage(i,j) = nanmean(avgcelldata{i}(j,(secbefore+stimlength)*SampleRate:(secbefore+stimlength+begwindow)*SampleRate));
    end
end

nstim = length(piezoframeon)/nrep;

%% plot making time!
colors = winter(10);
set(0,'DefaultAxesColorOrder',colors)
stimhz = {'200hz', '400hz', '800hz', '1200hz', '1600hz', '2000hz'};

fig1 = figure;
hold on;

for i = 1
    plot(avgbegvoltage(i, :)', 'Marker', '.', 'MarkerSize', 15)
end
ylabel('mV')
title('average voltage during 500 ms after stim onset')
xlim([0.5, nstim+0.5])
xticks(gca, 1:nstim)
xticklabels(gca, stimhz)
ylim([-2, 14])

% export_fig(fig1,[dataDir, 'postpharmsummary.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');

% fig5 = figure;
% hold on;
% plot(minendvoltage', 'Marker', '.', 'MarkerSize', 15)
% ylabel('mV')
% title('mean voltage during 500 ms after stim offset')
% xlim([0.5, nstim+0.5])
% xticks(gca, 1:nstim)
% xticklabels(gca, stimhz)

% export_fig(fig5,[dataDir, fileTag, '_offsetsummary.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');



% fig2 = figure;
% hold on;
% ylabel('mV')
% title('average voltage during 500 ms after stim onset')
% xlim([0.5, nstim+0.5])
% xticks(gca, 1:nstim)
% xticklabels(gca, stimhz)
% 
% errors = nanstd(avgbegvoltage)./sqrt(ncells);
% errorbar(nanmean(avgbegvoltage), errors, 'k.-', 'MarkerSize', 15);

% export_fig(fig2,[dataDir, '10B_begavg.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');



% fig1 = figure;
% plot(maxvoltage', 'Marker', '.', 'MarkerSize', 15)
% ylabel('mV')
% title('maximum voltage after stim onset')
% xlim([0.5, nstim+0.5])
% xticks(gca, 1:nstim)
% xticklabels(gca, stimhz)
% % export_fig(fig1,[dataDir, fileTag, '_maxsummary.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');


% fig3 = figure;
% plot(avgmidvoltage', 'Marker', '.', 'MarkerSize', 15)
% ylabel('mV')
% title('average voltage during middle 2 sec of stim presentation')
% xlim([0.5, nstim+0.5])
% xticks(gca, 1:nstim)
% xticklabels(gca, stimhz)
% % export_fig(fig3,[dataDir, fileTag, '_midsummary.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');


% fig4 = figure;
% hold on
% for i = 1:ncells
%     for j = 1:nstim
%         subplot(1, nstim, j)
%         hold on
%         ylim([-10, 15])
%         xlim([0, SampleRate*(secbefore+stimlength+secafter)])
%         ax = gca;
%         xticks(ax, 0:SampleRate*2:SampleRate*(secbefore+stimlength+secafter))
%         ax.XTickLabel = ax.XTick./SampleRate;
%         plot(avgcelldata{i}(j, :))
%         
%         title(stimhz{j})
%     end
% end
% subplot(1, nstim, 1)
% ylabel('mV')
% set(gcf, 'Position',  [100, 100, 1800, 400])
% export_fig(fig4,[dataDir, fileTag, '_waveformsummary.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');






% fig5 = figure
% hold on
% stimtype = [1, nstim];
% for i = 1:ncells
%     for j = 1:2
%         subplot(2, 2, j)
%         hold on
%         ylim([-2, 16])
%         ax = gca;
%         plot(avgcelldata{i}(stimtype(j), (secbefore-0.25)*SampleRate:(secbefore+0.25)*SampleRate))
%         xticks(ax, 0:SampleRate*0.125:SampleRate*0.5)
%         ax.XTickLabel = ax.XTick./SampleRate-0.25;
%         xlim([0, SampleRate*0.5])
%         title(stimhz{stimtype(j)})
%         
%         subplot(2, 2, 2+j)
%         hold on
%         plot(avgsensordata{i}(stimtype(j), (secbefore-0.25)*SampleRate:(secbefore+0.25)*SampleRate))
%         ax = gca;
%         xticks(ax, 0:SampleRate*0.125:SampleRate*0.5)
%         ax.XTickLabel = ax.XTick./SampleRate-0.25;
%         xlim([0, SampleRate*0.5])
%     end
% end
% 
% set(gcf, 'Position',  [100, 100, 1600, 800])
% export_fig(fig5,[dataDir, fileTag(1:end-7), '_prePTstimonsetsummary.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');


% for i = 1:ncells
%     figure
%     hold on
%     for j = 1:nstim
%         g = subplot(nstim, 1, j); %plot fft of sensor data
%         hold on
%         fs = 20000;
%         data = avgsensordata{i}(j, :);
%         ts = (1:length(data))/fs;
%         periodogram(data,rectwin(length(data)),length(data),fs);xlim([0 2.5])
%     end
%     set(gcf, 'Position',  [10, 10, 800, 1400])
% end
% 
% for i = 1:ncells
%     figure
%     hold on
%     for j = 1:nstim
%         g = subplot(nstim, 1, j); %plot fft of sensor data
%         hold on
%         fs = 20000;
%         data = avgcelldata{i}(j, :);
%         ts = (1:length(data))/fs;
%         periodogram(data,rectwin(length(data)),length(data),fs);xlim([0 2.5])
%     end
%     set(gcf, 'Position',  [10, 10, 800, 1400])
% end
        
        
        
        
        
        
        