%% file to analyze effects of ramp and hold on cell activity

% 1/15/18: summary of ramp and hold stim, creating a few
% different figures:

% waveform of dff response
% response at each flexion or extension step 

% must make figures for each flexfirst and extfirst sets of data

clear all

fileTag = '13e04';
dataDir = 'E:\Sweta to backup\2 photon data\13e04LexA\ramp and hold\';

% framerate = 7.57; %hz, hard coded based on experience
nrep = 2; %in separate files, assuming 2 max per fly (could be just 1 rep)
nsteps = 18; %per rep
which_ROI = 2; %idx for the ROI of interest

framesbefore = 8; %frames before and after ramp and hold stim to plot for summary figure

%% ext first data

for i = 1:nrep
    extDFFFiles{i} = dir([dataDir, fileTag, '*extfirst_rampandhold0', num2str(i), '*SelectROICalculateDFF.mat']);
    extLegAngleFiles{i} = dir([dataDir, fileTag, '*extfirst_rampandhold0', num2str(i), '*AngleForImagingFrame.mat']);
    extTimingFiles{i} = dir([dataDir, fileTag, '*extfirst_rampandhold0', num2str(i), '*DetectCameraAndImagingFrames.mat']);
    
    flxDFFFiles{i} = dir([dataDir, fileTag, '*flexfirst_rampandhold0', num2str(i), '*SelectROICalculateDFF.mat']);
    flxLegAngleFiles{i} = dir([dataDir, fileTag, '*flexfirst_rampandhold0', num2str(i), '*AngleForImagingFrame.mat']);
    flxTimingFiles{i} = dir([dataDir, fileTag, '*flexfirst_rampandhold0', num2str(i), '*DetectCameraAndImagingFrames.mat']);
    
    if length(extDFFFiles{i}) ~= length(extLegAngleFiles{i})||length(extDFFFiles{i}) ~= length(extTimingFiles{i})
        error('mismatch in number of extension files')
    end
    
    if length(flxDFFFiles{i}) ~= length(flxLegAngleFiles{i})||length(flxDFFFiles{i}) ~= length(flxTimingFiles{i})
        error('mismatch in number of flexion files')
    end
    
    extfilelengths(i) = length(extDFFFiles{i});
    flxfilelengths(i) = length(flxDFFFiles{i});
end

for j = 1:(max(extfilelengths))
    extDFFdata = [];
    extLegAngles = [];
    
    for i = 1:nrep
        if extfilelengths(i) < j %assumes that rep 2 is what would be lacking, never rep 1. If rep 1 is lacking, then will get an averaging error
        else
            data = load([dataDir, extDFFFiles{i}(j).name]);
            angles = load([dataDir, extLegAngleFiles{i}(j).name]);
            timing = load([dataDir, extTimingFiles{i}(j).name]);
            
%             extDFFFiles{i}(j).name
            
            framerate = 20000./mean(timing.ImageInterval);
            if j == 1
                desired_framerate = framerate;
            end
            
            %some data files have multiple clusters, want only the "signal"
            %cluster (defined for now as the cluster having max variance)
%             if size(data.DFF1, 1)>1
%                 'multiple clusters'
%                 extDFFFiles{i}(j).name
%                 [~, signalcluster] = max(var(data.DFF1'));
%                 signalDFF = data.DFF1(signalcluster, :);
%             else
% %                 'single cluster'
              signalDFF = data.DFF1(which_ROI, :);
%             end
            
            angles.ImageLegAngle(angles.ImageLegAngle<0) = min(angles.ImageLegAngle(angles.ImageLegAngle>0));
            
            ALLextDFFdata{i} = signalDFF((angles.StartIF(1, 1)-framesbefore):(angles.StartIF(nsteps, 1)+framesbefore));
            ALLextLegAngles{i} = angles.ImageLegAngle((angles.StartIF(1, 1)-framesbefore):(angles.StartIF(nsteps, 1)+framesbefore));            
            
            ctp = (1:length(ALLextDFFdata{i}))./framerate;
            dtp = (1/desired_framerate):(1/desired_framerate):(length(ALLextDFFdata{i})/framerate);
                       
            ALLextDFFdata{i} = interp1(ctp, ALLextDFFdata{i}, dtp);
            ALLextLegAngles{i} = interp1(ctp, ALLextLegAngles{i}, dtp);
%             
            ALLextLengths(i) = length(ALLextDFFdata{i});
            
        end
    end
    
    for i = 1:nrep
        extDFFdata(i, :) = ALLextDFFdata{i}(1:min(ALLextLengths));
        extLegAngles(i, :) = ALLextLegAngles{i}(1:min(ALLextLengths));
    end
    
        if size(extDFFdata, 1) < 2
            try
                extavgDFFdata(j, :) = extDFFdata;
                extavgLegAngles(j, :) = extLegAngles;
            catch
                if length(extavgLegAngles)>length(extLegAngles)
                    extavgDFFdata = extavgDFFdata(:, 1:length(extLegAngles));
                    extavgLegAngles = extavgLegAngles(:, 1:length(extLegAngles));
                    
                    extavgDFFdata(j, :) = extDFFdata(1:length(extavgDFFdata));
                    extavgLegAngles(j, :) = extLegAngles(1:length(extavgLegAngles));
                else
                    extavgDFFdata(j, :) = extDFFdata(1:length(extavgDFFdata));
                    extavgLegAngles(j, :) = extLegAngles(1:length(extavgLegAngles));
                end
            end
        else
            try
                extavgDFFdata(j, :) = mean(extDFFdata);
                extavgLegAngles(j, :) = mean(extLegAngles);
            catch
                if length(extavgLegAngles)>length(extLegAngles)
                    extavgDFFdata = extavgDFFdata(:, 1:length(extLegAngles));
                    extavgLegAngles = extavgLegAngles(:, 1:length(extLegAngles));
                    
                    extavgDFFdata(j, :) = mean(extDFFdata(:, 1:length(extavgDFFdata)));
                    extavgLegAngles(j, :) = mean(extLegAngles(:, 1:length(extavgLegAngles)));
                else
                    extavgDFFdata(j, :) = mean(extDFFdata(:, 1:length(extavgDFFdata)));
                    extavgLegAngles(j, :) = mean(extLegAngles(:, 1:length(extavgLegAngles)));
                end
            end
        end
        
    end



for j = 1:(max(flxfilelengths))
    j
    flxDFFdata = [];    
    flxLegAngles = [];
    
    for i = 1:nrep
        if flxfilelengths(i) < j %assumes that rep 2 is what would be lacking, never rep 1. If rep 1 is lacking, then will get an averaging error
        else
            data = load([dataDir, flxDFFFiles{i}(j).name]);
            angles = load([dataDir, flxLegAngleFiles{i}(j).name]);
            timing = load([dataDir, flxTimingFiles{i}(j).name]);
            
            framerate = 20000./mean(timing.ImageInterval);
            if j == 1
                desired_framerate = framerate;
            end
            
            
            %some data files have multiple clusters, want only the "signal"
            %cluster
%             if size(data.DFF1, 1)>1
%                 'multiple clusters'
% %                 flxDFFFiles{i}(j).name
%                 [~, signalcluster] = max(var(data.DFF1'));
%                 signalDFF = data.DFF1(signalcluster, :);
%                 
%                 figure; hold on; 
%                 for a = 1:size(data.DFF1, 1)
%                     plot(data.DFF1(a, :), 'k');
%                 end
%                 plot(signalDFF, 'r');
%             else
%                 'single cluster'
              signalDFF = data.DFF1(which_ROI, :);
%             end
            
            angles.ImageLegAngle(angles.ImageLegAngle<0) = min(angles.ImageLegAngle(angles.ImageLegAngle>0));
            
            ALLflxDFFdata{i} = signalDFF((angles.StartIF(1, 1)-framesbefore):(angles.StartIF(nsteps, 1)+framesbefore));
            ALLflxLegAngles{i} = angles.ImageLegAngle((angles.StartIF(1, 1)-framesbefore):(angles.StartIF(nsteps, 1)+framesbefore));            
            
            ctp = (1:length(ALLflxDFFdata{i}))./framerate;
            dtp = (1/desired_framerate):(1/desired_framerate):(length(ALLflxDFFdata{i})/framerate);
                       
            ALLflxDFFdata{i} = interp1(ctp, ALLflxDFFdata{i}, dtp);
            ALLflxLegAngles{i} = interp1(ctp, ALLflxLegAngles{i}, dtp);
%             
            ALLflxLengths(i) = length(ALLflxDFFdata{i});
       
        end
    end
    
    for i = 1:nrep
        flxDFFdata(i, :) = ALLflxDFFdata{i}(1:min(ALLflxLengths));
        flxLegAngles(i, :) = ALLflxLegAngles{i}(1:min(ALLflxLengths));
    end
    
    if size(flxDFFdata, 1) < 2
        try
            flxavgDFFdata(j, :) = flxDFFdata;
            flxavgLegAngles(j, :) = flxLegAngles;
        catch
            if length(flxavgLegAngles)>length(flxLegAngles)
                flxavgDFFdata = flxavgDFFdata(:, 1:length(flxLegAngles));
                flxavgLegAngles = flxavgLegAngles(:, 1:length(flxLegAngles));
                
                flxavgDFFdata(j, :) = flxDFFdata(1:length(flxavgDFFdata));
                flxavgLegAngles(j, :) = flxLegAngles(1:length(flxavgLegAngles));
            else
                flxavgDFFdata(j, :) = flxDFFdata(1:length(flxavgDFFdata));
                flxavgLegAngles(j, :) = flxLegAngles(1:length(flxavgLegAngles));
            end
        end
    else
        try
            flxavgDFFdata(j, :) = mean(flxDFFdata);
            flxavgLegAngles(j, :) = mean(flxLegAngles);
        catch
            if length(flxavgLegAngles)>length(flxLegAngles)
                flxavgDFFdata = flxavgDFFdata(:, 1:length(flxLegAngles));
                flxavgLegAngles = flxavgLegAngles(:, 1:length(flxLegAngles));
                
                flxavgDFFdata(j, :) = mean(flxDFFdata(:, 1:length(flxavgDFFdata)));
                flxavgLegAngles(j, :) = mean(flxLegAngles(:, 1:length(flxavgLegAngles)));
            else
                flxavgDFFdata(j, :) = mean(flxDFFdata(:, 1:length(flxavgDFFdata)));
                flxavgLegAngles(j, :) = mean(flxLegAngles(:, 1:length(flxavgLegAngles)));
            end
        end
    end

end

%% plot time!

% first make a summary plot, extension data
fig1 = figure;
hold on

subplot(2, 1, 1)
hold on
plot(extavgDFFdata')
plot(mean(extavgDFFdata), 'k', 'LineWidth', 1.5)
xlim([0, length(extavgDFFdata)])
ax = gca;
xticks(ax, 0:framerate*10:length(extavgDFFdata))
ax.XTickLabel = ax.XTick./framerate;


subplot(2, 1, 2)
hold on
% plot(mean(extavgLegAngles))
plot(extavgLegAngles(1, :))
xlim([0, length(extavgDFFdata)])
ylim([0, 180])
ax = gca;
xticks(ax, 0:framerate*10:length(extavgDFFdata))
ax.XTickLabel = ax.XTick./framerate;

export_fig(fig1,[dataDir, fileTag, '_extfirst_rampandholdsummary.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');


% flexion data
fig2 = figure;
hold on

subplot(2, 1, 1)
hold on
plot(flxavgDFFdata')
plot(mean(flxavgDFFdata), 'k', 'LineWidth', 1.5)
xlim([0, length(flxavgDFFdata)])
ax = gca;
xticks(ax, 0:framerate*10:length(flxavgDFFdata))
ax.XTickLabel = ax.XTick./framerate;

subplot(2, 1, 2)
hold on
% plot(mean(flxavgLegAngles))
plot(flxavgLegAngles(1, :))
xlim([0, length(flxavgDFFdata)])
ylim([0, 180])
ax = gca;
xticks(ax, 0:framerate*10:length(flxavgDFFdata))
ax.XTickLabel = ax.XTick./framerate;

export_fig(fig2,[dataDir, fileTag, '_flexfirst_rampandholdsummary.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');



% % plot step onset data
% 
% % extfirst
% fig3 = figure;
% hold on
% for i = 1:9 %number of steps in each direction
%     subplot(9, 1, i)
%     hold on
%     
%     for j = 1:size(extavgDFFdata, 1)
%         DFFdata = extavgDFFdata(ceil(ext_avgFlxOnsets(j, i)-onsetwindow*framerate):ceil(ext_avgFlxOnsets(j, i)+onsetwindow*framerate));
%         plot(DFFdata)
%     end
%     
% end
%     
% fig4 = figure;
% hold on
% for i = 1:9
%     subplot(9, 1, i)
%     hold on
%     
%     for j = 1:size(extavgDFFdata, 1)
%         DFFdata = extavgDFFdata(ceil(ext_avgExtOnsets(j, i)-onsetwindow*framerate):ceil(ext_avgExtOnsets(j, i)+onsetwindow*framerate));
%         plot(DFFdata)
%     end
%     
% end





