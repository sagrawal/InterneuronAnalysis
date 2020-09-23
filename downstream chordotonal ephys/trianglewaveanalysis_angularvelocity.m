%% modified 1/27/2020 to summarize all the 10B trianglewave data altogether. 
% will plot membrane potential against angular velocity
%
% I am only using the data from the first presentation of the
% stimulus. Often I presented a given stimulus twice, but will ignore the
% second presentation for now.

clearvars;

dataDir = 'G:\My Drive\Sweta to backup\ephysdata\10B recordings\trianglewaves\diffpos\';
flexfileTag = '*flex*WithWaveOnset.mat';
extfileTag = '*ext*WithWaveOnset.mat';

flex_dataFiles = dir([dataDir, flexfileTag]);
ext_dataFiles = dir([dataDir, extfileTag]);

nflies = length(flex_dataFiles);
nstim = 4;
stimlength = 4; %in s
secbefore = 1; %in s, to establish a baseline

%% 
for i = 1:nflies
    flx = load([dataDir, flex_dataFiles(i).name]);
    ext = load([dataDir, ext_dataFiles(i).name]);
    
    figure
    hold on
    
    for j = 1:nstim 
        % pulling out start/stop and data
        fframestart(j) = flx.LOCS(j);
        fframeend(j) = ceil(flx.LOCS(j)+(stimlength*flx.FrameRate));
        fvoltagestart(j) = flx.frame_on(fframestart(j));
        fvoltageend(j) = flx.frame_on(fframeend(j));
        
        fangles{j}(i, :) = flx.legangles(fframestart(j):fframeend(j));
        fmp = flx.voltagedata(fvoltagestart(j):fvoltageend(j));
        
        
        
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
        
        %calculate angular velocity
        fangvel{j}(i, :) = [NaN, diff(fangles{j}(i, :)).*flx.FrameRate];
        eangvel{j}(i, :) = [NaN, diff(eangles{j}(i, :)).*ext.FrameRate];
        
        subplot(2, 2, j)
        hold on
        plot(fangvel{j}(i, :), f_ds_mp{j}(i, :), 'k.')
        plot(eangvel{j}(i, :), e_ds_mp{j}(i, :), 'r.')
        ylim([-50, -20])
        xlim([-800, 800])
        

    end
        
end

%% plot membrane potential relative to angular velocity at each leg position, frequency
% 4 frequencies, 4 subplots


% figure
% hold on
% 
% for j = 1:nstim
%     subplot(2, 2, j)
% %     fN = hist3([reshape(flx.angvel{j}, [], 1), reshape(flx.ds_mp{j}, [], 1)], 'Nbins', [50, 50]);
% % 
% %     fN_pcolor = fN';
% %     fN_pcolor(size(fN_pcolor,1)+1,size(fN_pcolor,2)+1) = 0;
% %     fxl = linspace(min(reshape(flx.angvel{j}, [], 1)),max(reshape(flx.angvel{j}, [], 1)),size(fN_pcolor,2)); % Columns of N_pcolor
% %     fyl = linspace(min(reshape(flx.ds_mp{j}, [], 1)),max(reshape(flx.ds_mp{j}, [], 1)),size(fN_pcolor,1)); % Rows of N_pcolor
% %     
% %     h = pcolor(fxl,fyl,fN_pcolor);
% %     colormap('hot') % Change color scheme
% %     colorbar % Display colorbar
% %     h.ZData = -max(fN_pcolor(:))*ones(size(fN_pcolor));
% %     ax = gca;
% %     ax.ZTick(ax.ZTick < 0) = [];
% 
% %     
% % 
% 
%         plot(fangvel{j}, f_ds_mp{j}, '.')
% 
%     xlim([-800, 800])
% end