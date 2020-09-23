%plot piezo data
clear all

dataDir = 'G:\My Drive\Sweta to backup\ephysdata\10B recordings\rT2lT1\';
fileTag = '04751_rT2lT1_01_piezo_005um';

dataFiles = dir([dataDir, fileTag, '*EphysPiezodata.mat']);

nrep = 3;

secbefore = 1;
secafter = 1;
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
        
        for k = 1:nrep
            stimstart = piezoframeon((j-1)*3+k)-(secbefore*SampleRate);
            stimend = piezoframeon((j-1)*3+k)+((stimlength+secafter)*SampleRate);
            
            if stimend>length(voltagedata)
            else
%                 'hullo'
                celldata(k, :) = voltagedata(stimstart:stimend);
                sensordata(k, :) = piezosensordata(stimstart:stimend);
                piezoamp_um(j, k) = (max(sensordata(k, :))-min(sensordata(k, :)))./umpiezosensor;
            end
        end
            
        
        g = subplot(2, 1, 1); %plot cell voltage in first plot
        hold on
        plot(celldata')
        plot(mean(celldata), 'k')
        xlim([0, length(celldata(1, :))])
        title(['amplitude: ', num2str(mean( piezoamp_um(j, :))), ' um']);
        
        ax = gca;
        xticks(ax, 0:SampleRate*2:length(celldata(1, :)))
        ax.XTickLabel = ax.XTick./SampleRate;
        ax.LineWidth = 1;
        
        
        g = subplot(2, 1, 2); %plot sensor data
        hold on
        plot(sensordata')
        plot(mean(sensordata), 'k')
        xlim([0, length(celldata(1, :))])
        xlabel('sec')
       
        
        ax = gca;
        xticks(ax, 0:SampleRate*2:length(celldata(1, :)))
        ax.XTickLabel = ax.XTick./SampleRate;
        ax.LineWidth = 1;
        
        
%         g = subplot(4, 1, 3); %plot fft of cell voltage
%         hold on
%         fs = 20000;
%         data = celldata(:)';
%         ts = (1:length(data))/fs;
%         periodogram(data,rectwin(length(data)),length(data),fs);xlim([0 2.5])
%         ylabel('dB/Hz', 'Interpreter', 'None')
%         title('spec of cell recording')
%         xlabel('')
%         
%         g = subplot(4, 1, 4); %plot fft of sensor data
%         hold on
%         fs = 20000;
%         data = sensordata(:)';
%         ts = (1:length(data))/fs;
%         periodogram(data,rectwin(length(data)),length(data),fs);xlim([0 2.5])
%         ylabel('dB/Hz', 'Interpreter', 'None')
%         title('spec of piezo stim')
        
%         export_fig(fig1,[dataDir, NewName, '_', num2str(j), '_summary.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');
        
    end    
    
end
    