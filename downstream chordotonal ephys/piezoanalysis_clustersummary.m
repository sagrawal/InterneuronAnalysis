%plot piezo data
%plot peak voltage reached during vibration stim
%plot average voltage in first 500 ms
%plot average voltage in middle 2 sec
%plot average waveforms in response to vibration stim per cell

clearvars

dataDir = 'G:\My Drive\Sweta to backup\ephysdata\9Aalpha recordings\piezo 01 um\';
cluster{1}.dataFiles = {'ss28981_17_piezo_01um_18o24004_EphysPiezodata.mat',
                        'ss28981_23_piezo_01um_18n14005_EphysPiezodata.mat',
                        'ss28981_33_piezo_01um_19212009_EphysPiezodata.mat',
                        'ss28981_39_piezo_01um_19305017_EphysPiezodata.mat'};

cluster{2}.dataFiles = {'ss28981_19_piezo_01um_18n05007_EphysPiezodata.mat',
                        'ss28981_24_piezo_01um_18n16004_EphysPiezodata.mat',
                        'ss28981_27_piezo_01um_19128008_EphysPiezodata.mat',
                        'ss28981_37_piezo_01um_19301024_EphysPiezodata.mat'};

cluster{3}.dataFiles = {'ss28981_25_piezo_01um_18n21012_EphysPiezodata.mat',
                        'ss28981_29_piezo_01um_19130009_EphysPiezodata.mat',
                        'ss28981_32_piezo_01um_19208008_EphysPiezodata.mat',
                        'ss28981_34_piezo_01um_19213006_EphysPiezodata.mat',
                        'ss28981_36_piezo_01um_19301009_EphysPiezodata.mat'};
                 

nrep = 3;
secbefore = 2;
secafter = 2;
stimlength = 4;
umpiezosensor = 0.1667; %about how much, in V, 1 um of movement 
begwindow = 0.5; %for avgeraging window of stim onset
nstim = 6;

for a = 1:length(cluster)
%     a
    ncells(a) = length(cluster{a}.dataFiles);
    avgbegvoltage{a} = nan(ncells(a), 6);
    
    for i = 1:ncells(a)
%         i
        load([dataDir, cluster{a}.dataFiles{i}]);
        avgcelldata{a}{i} = [];
        avgsensordata{a}{i} = [];
        avgpiezoamp_um{a}{i} = [];
        baselinevalue{a}{i} = [];
        
        if a == 1 && i == 1
            piezoframeon = piezoframeon(4:end);
        end
        
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
            
            avgcelldata{a}{i}(j, :) = nanmean(celldata);
            avgsensordata{a}{i}(j, :) = nanmean(sensordata);
            avgpiezoamp_um{a}{i}(j) = nanmean(piezoamp_um(j, :));
            baselinevalue{a}{i}(j) = mean(avgcelldata{a}{i}(j, 1:secbefore*SampleRate));
            
            avgcelldata{a}{i}(j, :) = avgcelldata{a}{i}(j, :) - baselinevalue{a}{i}(j);
            avgsensordata{a}{i}(j, :) = avgsensordata{a}{i}(j, :)- mean(avgsensordata{a}{i}(j, 1:secbefore*SampleRate));
        end
        if length(piezoframeon)/nrep < 6
            avgcelldata{a}{i}(6, :) = nan(1, length(avgcelldata{a}{i}));
            avgsensordata{a}{i}(6, :) = nan(1, length(avgsensordata{a}{i}));
            avgpiezoamp_um{a}{i}(6) = NaN;
            baselinevalue{a}{i}(6) = NaN;
        end
        
        % pull out: average voltage in first 500 msec (baseline corrected)
        for j = 1:(length(piezoframeon)/nrep)
            avgbegvoltage{a}(i,j) = nanmean(avgcelldata{a}{i}(j,secbefore*SampleRate:(begwindow+secbefore)*SampleRate));
        end
        
    end

    
end

%% plot making time!

colors = winter(6);
set(0,'DefaultAxesColorOrder',colors)
stimhz = {'200hz', '400hz', '800hz', '1200hz', '1600hz', '2000hz'};

for a = 1:length(cluster)
    figure(a);
    hold on
    for i = 1:ncells(a)
        for j = 1:nstim
            subplot(1, nstim, j)
            hold on
            ylim([-10, 18])
            xlim([0, SampleRate*(secbefore+stimlength+secafter)])
            ax = gca;
            xticks(ax, 0:SampleRate*2:SampleRate*(secbefore+stimlength+secafter))
            ax.XTickLabel = ax.XTick./SampleRate;
            plot(avgcelldata{a}{i}(j, :))
            
            title(stimhz{j})
        end
    end
    subplot(1, nstim, 1)
    ylabel('mV')
    title(['cluster ', num2str(a)])
    set(gcf, 'Position',  [100, 100, 1800, 400])

    export_fig(gcf,[dataDir, 'cluster_' num2str(a), '_3clusterwaveforms.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');
end



fig1 = figure;
hold on;
ylabel('mV')
title('average voltage during 500 ms after stim onset')
xlim([0.5, nstim+0.5])
xticks(gca, 1:nstim)
xticklabels(gca, stimhz)

colors = prism(6);
colors = colors(2:end, :);

for a = 1:length(cluster)
    errors = nanstd(avgbegvoltage{a})./sqrt(ncells(a));
    errorbar(nanmean(avgbegvoltage{a}), errors, '.-', 'Color', colors(a, :), 'MarkerSize', 15);
end
export_fig(fig1,[dataDir, '3cluster_summary.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');




