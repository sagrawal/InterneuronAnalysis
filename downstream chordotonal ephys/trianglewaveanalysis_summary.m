%% modifies 1/7/2020 to summarize all the 10B trianglewave data altogether. 
% Creates a zoomed in overlay of all triangle wave responses grouped by leg
% position, as well as a series of radar plots

% will only look at the first rep of triangle wave stimuli, and for
% radarplots will currently consider the first 2s of stimulus. radarplot
% amplitude will be normalized for now.
clearvars;

dataDir = 'G:\My Drive\Sweta to backup\ephysdata\10B recordings\trianglewaves\diffpos\';
fileTag = '*flex*WithWaveOnset.mat';
dataFiles = dir([dataDir, fileTag]);

nflies = length(dataFiles);
nstim = 6;

% for overlay plots
secbefore = 1;
secafter = 2;

% for polar plots
polarstart = 0; %in s, 0 means right when wave begins
polarend = 2;

%% 
for i = 1:nflies
    load([dataDir, dataFiles(i).name]);
    
    voltagestart = [];
    voltageend = [];
    stimstart = [];
    stimend = [];
    
    polar_stimstart = [];
    polar_stimend = [];
    polar_voltagestart = [];
    polar_voltageend = [];
    
    for j = 1:nstim 
        % pulling out start/stop for the overlay plots, unfortuantely fly 4 is weird
        stimstart(j) = ceil(LOCS(j)-(secbefore*FrameRate));
        stimend(j) = ceil(LOCS(j)+(secafter*FrameRate));
        voltagestart(j) = frame_on(stimstart(j));
        voltageend(j) = frame_on(stimend(j));
        
        %pulling out start/stop for the polar plots
        polar_stimstart(j) = ceil(LOCS(j)+(polarstart*FrameRate));
        polar_stimend(j) = ceil(LOCS(j)+(polarend*FrameRate));
        polar_voltagestart(j) = frame_on(polar_stimstart(j));
        polar_voltageend(j) = frame_on(polar_stimend(j));
        
        %pull out the data for the overlay plots
        wavelegangles{i}(j, :) = legangles(stimstart(j):stimend(j));
        offsetcorr(i) = mean(voltagedata(voltagestart(j):voltagestart(j)+secbefore*SampleRate));
        dataholder = voltagedata(voltagestart(j):voltageend(j))- offsetcorr(i);
        if j == 1
            wavevoltages{i}(j, :) = dataholder;
        elseif length(wavevoltages{i})<length(dataholder)
            wavevoltages{i}(j, :) = dataholder(1:length(wavevoltages{i}));
        elseif length(wavevoltages{i})>length(dataholder)
            wavevoltages{i} = wavevoltages{i}(:, 1:length(dataholder));
            wavevoltages{i}(j, :) = dataholder;
        else
            wavevoltages{i}(j, :) = dataholder;
        end
        
        angletime{i} = (0:1/FrameRate:(length(wavelegangles{i}(j, :))/FrameRate))-secbefore;
        voltagetime{i} = (0:1/SampleRate:(length(wavevoltages{i}(j, :))/SampleRate))-secbefore;
        
        %pull out data for the polar plots, normalize and scale both angle and voltage data
        dataholder = voltagedata(polar_voltagestart(j):polar_voltageend(j));
        dataholder = dataholder - min(dataholder);
        dataholder = dataholder./(max(dataholder));
        
        angles = legangles(polar_stimstart(j):polar_stimend(j));
        angles = angles - min(angles);
        angles = (angles./max(angles))*pi; %phase goes from 0 to pi radians for now
        
        %need to re-interpolate angle data so that it matches up with the
        %voltage data
        currenttimepoints = 0:1/FrameRate:(length(angles)/FrameRate);
        currenttimepoints = currenttimepoints(1:length(angles));
        
        desiredtimepoints = 0:1/SampleRate:(length(dataholder)/SampleRate);
        desiredtimepoints = desiredtimepoints(1:length(dataholder));
        
        angledataholder = interp1(currenttimepoints, angles, desiredtimepoints);
        
        if j == 1
            polar_voltages{i}(j, :) = dataholder;
            polar_legangles{i}(j, :) = angledataholder;
        elseif length(polar_voltages{i})<length(dataholder)
            polar_voltages{i}(j, :) = dataholder(1:length(polar_voltages{i}));
            polar_legangles{i}(j, :) = angledataholder(1:length(polar_legangles{i}));
        elseif length(polar_voltages{i})>length(dataholder)
            polar_voltages{i} = polar_voltages{i}(:, 1:length(dataholder));
            polar_legangles{i} = polar_legangles{i}(:, 1:length(angledataholder));
            
            polar_voltages{i}(j, :) = dataholder;
            polar_legangles{i}(j, :) = angledataholder;
        else
            polar_voltages{i}(j, :) = dataholder;
            polar_legangles{i}(j, :) = angledataholder;
        end  
    end
    
    %unfortunately fly 4 is weird
    if i == 4
        wavelegangles{i} = [wavelegangles{i}(2:end, :); nan(1, length(wavelegangles{i}))];
        wavevoltages{i} = [wavevoltages{i}(2:end, :); nan(1, length(wavevoltages{i}))];
        
        polar_legangles{i} = [polar_legangles{i}(2:end, :);nan(1, length(polar_legangles{i}))];
        polar_voltages{i} = [polar_voltages{i}(2:end, :); nan(1, length(polar_voltages{i}))];
    end
        
end

%% overlay plots
for j = 1:nstim
    figure
    hold on
    
    fig1 = gcf;
    
    for i = 1:nflies
        g = subplot(2, 1, 1);
        hold on
        plot(voltagetime{i}(1:end-1), wavevoltages{i}(j, :))
        
        g = subplot(2, 1, 2);
        hold on
        plot(angletime{i}(1:end-1), wavelegangles{i}(j, :))
    end
    
%     export_fig(fig1,[dataDir, '10B_trianglewavesummary_90deg_speed', num2str(j), '.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');
end

%% polar plots
for j = 1:nstim
    figure
    fig1 = gcf;
%     hold on
    
    for i = 1:nflies
        dataFiles(i).name
        polarplot(polar_legangles{i}(j, :), polar_voltages{i}(j, :))
        hold on
    end
    
%     export_fig(fig1,[dataDir, '10B_polarplot_flex_speed', num2str(j), '.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');
end
