%% modified 1/27/2020 to summarize all the 10B trianglewave data altogether. 
% will do two things:
% % 1. peak finder and then compute the average difference between peaks
%
% I am only using the data from the first presentation of the
% stimulus. Often I presented a given stimulus twice, but will ignore the
% second presentation for now.

clearvars;

dataDir = 'E:\Sweta to backup\ephysdata\10B recordings\trianglewaves\diffpos\';
% dataDir = 'G:\My Drive\Sweta to backup\ephysdata\10B recordings\trianglewaves\diffpos\';
flexfileTag = '*flex*WithWaveOnset.mat';
extfileTag = '*ext*WithWaveOnset.mat';

flex_dataFiles = dir([dataDir, flexfileTag]);
ext_dataFiles = dir([dataDir, extfileTag]);

nflies = length(flex_dataFiles);
nstim = 4;
stimlength = 4; %in s
secbefore = 1; %in s, to establish a baseline

minpeakdistances = [60, 28, 13, 4];
otherminpeakdistances = [46, 28, 13, 4];

%% 
for i = 1:nflies
    flx = load([dataDir, flex_dataFiles(i).name]);
    ext = load([dataDir, ext_dataFiles(i).name]);
    
    for j = 1:nstim 
        % pulling out start/stop and data
        % flexion data
        fframestart(j) = flx.LOCS(j);
        fframeend(j) = ceil(flx.LOCS(j)+(stimlength*flx.FrameRate));
        fvoltagestart(j) = flx.frame_on(fframestart(j));
        fvoltageend(j) = flx.frame_on(fframeend(j));
        
        fangles{j}(i, :) = flx.legangles(fframestart(j):fframeend(j));
        fmp = flx.voltagedata(fvoltagestart(j):fvoltageend(j));
        
        %extension data
        eframestart(j) = ext.LOCS(j);
        eframeend(j) = ceil(ext.LOCS(j)+(stimlength*ext.FrameRate));
        evoltagestart(j) = ext.frame_on(eframestart(j));
        evoltageend(j) = ext.frame_on(eframeend(j));
        
        eangles{j}(i, :) = ext.legangles(eframestart(j):eframeend(j));
        emp = ext.voltagedata(evoltagestart(j):evoltageend(j));
        
        %resample membrane potential so that it is at the same sampling
        %rate as leg angle
        fcurrenttimepoints = 0:1/flx.SampleRate:(length(fmp)/flx.SampleRate);
        fcurrenttimepoints = fcurrenttimepoints(1:length(fmp));
        fdesiredtimepoints = 0:1/flx.FrameRate:(length(fangles{j}(i, :))/flx.FrameRate);
        fdesiredtimepoints = fdesiredtimepoints(1:length(fangles{j}(i, :)));
        
        f_ds_mp{j}(i, :) = interp1(fcurrenttimepoints, fmp, fdesiredtimepoints);
        
        
        ecurrenttimepoints = 0:1/ext.SampleRate:(length(emp)/ext.SampleRate);
        ecurrenttimepoints = ecurrenttimepoints(1:length(emp));
        edesiredtimepoints = 0:1/ext.FrameRate:(length(eangles{j}(i, :))/ext.FrameRate);
        edesiredtimepoints = edesiredtimepoints(1:length(eangles{j}(i, :)));
        
        e_ds_mp{j}(i, :) = interp1(ecurrenttimepoints, emp, edesiredtimepoints);

        %% find peaks within leg angle data
        %first, normalize leg angle data, membrane potential data
        norm_fangles{j}(i, :) = fangles{j}(i, :) - min(fangles{j}(i, :));
        norm_fangles{j}(i, :) = norm_fangles{j}(i, :)./max(norm_fangles{j}(i, :));
        norm_fmp{j}(i, :) = f_ds_mp{j}(i, :) - min(f_ds_mp{j}(i, :));
        norm_fmp{j}(i, :) = norm_fmp{j}(i, :)./max(norm_fmp{j}(i, :));
        
        
        norm_eangles{j}(i, :) = eangles{j}(i, :) - min(eangles{j}(i, :));
        norm_eangles{j}(i, :) = (norm_eangles{j}(i, :)./max(norm_eangles{j}(i, :)));
        norm_emp{j}(i, :) = e_ds_mp{j}(i, :) - min(e_ds_mp{j}(i, :));
        norm_emp{j}(i, :) = norm_emp{j}(i, :)./max(norm_emp{j}(i, :));
        
        %next, find peaks within leg angle data, membrane potential data
        [~, fangle_peaklocs] = findpeaks(norm_fangles{j}(i, :), 'MinPeakDistance', minpeakdistances(j), 'MinPeakHeight', 0.75);
        [~, eangle_peaklocs] = findpeaks(norm_eangles{j}(i, :), 'MinPeakDistance', minpeakdistances(j), 'MinPeakHeight', 0.6);

        [~, fmp_peaklocs] = findpeaks(norm_fmp{j}(i, :), 'MinPeakDistance', minpeakdistances(j), 'MinPeakHeight', 0.15);%         length(fangle_peaklocs) - length(fmp_peaklocs)
        [~, emp_peaklocs] = findpeaks(norm_emp{j}(i, :), 'MinPeakDistance', otherminpeakdistances(j));
        
        %find which mp peak is closest to the leg angle peak, and then
        %calculate phase shift.
        
        ext_phaseshift(j, i) = mean(min(abs(repmat(emp_peaklocs, length(eangle_peaklocs), 1) - eangle_peaklocs')'))./mean(diff(eangle_peaklocs))*2*pi;
        flx_phaseshift(j, i) = mean(min(abs(repmat(fmp_peaklocs, length(fangle_peaklocs), 1) - fangle_peaklocs')'))./mean(diff(fangle_peaklocs))*2*pi;
        
        %% calculate angular velocity
        fangvel(j, i) = mean(abs(diff(fangles{j}(i, :)).*flx.FrameRate));
        eangvel(j, i) = mean(abs(diff(eangles{j}(i, :)).*ext.FrameRate));
        
    end
        
end

%% plot phase shift

fig1 = figure;
hold on

%speeds 40, 80, 160, 320
errorbar(1:4, mean(ext_phaseshift'), std(ext_phaseshift')./sqrt(length(ext_phaseshift)))
plot(1:4, mean(ext_phaseshift'), 'b.-', 'MarkerSize', 10)

errorbar(1:4, mean(flx_phaseshift'), std(flx_phaseshift')./sqrt(length(flx_phaseshift)))
plot(1:4, mean(flx_phaseshift'), 'r.-', 'MarkerSize', 10)

xlim([0.5, 4.5]); xticks(1:4); xticklabels([40, 80, 160, 320]);
ylim([0, pi]); yticks([0:(pi/2):(pi)]); yticklabels({'0', '\pi/2', '\pi'});

% export_fig(fig1,[dataDir, 'trianglewave_phaseshift.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');

for j = 1:nstim
    [p, h] = signrank(flx_phaseshift(j, :), ext_phaseshift(j, :))
end
