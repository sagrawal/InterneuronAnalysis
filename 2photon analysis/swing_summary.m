%% file to analyze effects of swing stimuli on cell activity

% 1/15/18: summary of different speeds of swing stim, creating a few
% different figures:

% waveform of dff response to different speeds of swing
% integral of swing response
% peak of swing response?

% must make figures for each flexfirst and extfirst sets of data

clear all

fileTag = '14B11lexA_05';
dataDir = 'E:\Sweta to backup\2 photon data\14b11LexA\swings\';

% framerate = 7.57; %hz, hard coded based on experience
nrep = 3;
speeds = [180, 360, 720, 1440]; %swing speeds tested

secbefore = 2; %s before and after ramp and hold stim to plot for summary figure
secafter = 2;
stimlength = 7;
which_ROI = 1; %idx for the ROI of interest

%% 
for j = 1:length(speeds)
    DFFFiles = dir([dataDir, fileTag, '*extfirst_swings_', num2str(speeds(j)), '*SelectROICalculateDFF.mat']);
    AngleFiles = dir([dataDir, fileTag, '*extfirst_swings_', num2str(speeds(j)), '*AngleforImagingFrame.mat']);
    TimingFiles = dir([dataDir, fileTag, '*extfirst_swings_', num2str(speeds(j)), '*DetectCameraAndImagingFrames.mat']);
    
%     length(DFFFiles)
%     length(AngleFiles)
%     length(TimingFiles)
    
    if length(DFFFiles) ~= length(AngleFiles)||length(DFFFiles) ~= length(TimingFiles)
        error('mismatch in file number')
    end
    
    avgDFFdata{j} = [];
    avgLegAngle{j} = [];
    avgExtInt{j} = [];
    avgFlxInt{j} = [];
    avgExtPk{j} = [];
    avgFlxPk{j} = [];
    
     for k = 1:length(DFFFiles)
%         AngleFiles(k).name
        load([dataDir, DFFFiles(k).name]);
        load([dataDir, AngleFiles(k).name]);
        load([dataDir, TimingFiles(k).name]);
        
        framerate = 20000./mean(ImageInterval);
        if k == 1
            desired_framerate = framerate;
        end
        
        %some data files have multiple clusters, want only the "signal"
        %cluster
%         if size(DFF1, 1)>1
%             'multiple clusters'
%             [~, signalcluster] = max(var(DFF1'));
%             signalDFF = DFF1(signalcluster, :);
%         else
%             'single cluster'
          signalDFF = DFF1(which_ROI, :);
%         end
        
        swingDFF = [];
        LegAngle = [];
        ImageLegAngle(ImageLegAngle<0) = min(ImageLegAngle(ImageLegAngle>0));
        
        for i = 1:nrep
            if ceil(StartIF((2*i-1), 1)-secbefore*framerate) < 0
                swingDFF(i, :) = [nan(1,abs(ceil(StartIF((2*i-1), 1)-secbefore*framerate))+1), signalDFF(1:ceil(StartIF((2*i-1), 1)+(stimlength+secafter)*framerate))];
                LegAngle(i, :) = [nan(abs(ceil(StartIF((2*i-1), 1)-secbefore*framerate))+1, 1); ImageLegAngle(1:ceil(StartIF((2*i-1), 1)+(stimlength+secafter)*framerate))];    
            elseif ceil(StartIF((2*i-1), 1)+(stimlength+secafter)*framerate)>length(signalDFF)
                'error!'
            else
                swingDFF(i, :) = signalDFF(ceil(StartIF((2*i-1), 1)-secbefore*framerate):ceil(StartIF((2*i-1), 1)+(stimlength+secafter)*framerate));
                LegAngle(i, :) = ImageLegAngle(ceil(StartIF((2*i-1), 1)-secbefore*framerate):ceil(StartIF((2*i-1), 1)+(stimlength+secafter)*framerate));            
            end
        end
        
        avgDFF = mean(swingDFF);
        avgAngles = mean(LegAngle);
        
        ctp = (1:length(avgDFF))./framerate;
        dtp = (1/desired_framerate):(1/desired_framerate):(length(avgDFF)/framerate);
        
        avgDFF = interp1(ctp, avgDFF, dtp);
        %shift baseline so that lowest value is 0
        avgDFF = avgDFF - min(avgDFF);
        avgAngles = interp1(ctp, avgAngles, dtp);
        
        try
            avgDFFdata{j}(k, :)  = avgDFF;
            avgLegAngle{j}(k, :)  = avgAngles;
        catch
            if length(avgLegAngle{j})>length(avgAngles)
                avgDFFdata{j} = avgDFFdata{j}(:, 1:length(avgDFF));
                avgLegAngle{j} =  avgLegAngle{j}(:, 1:length(avgAngles));
                
                avgDFFdata{j}(k, :)  = avgDFF;
                avgLegAngle{j}(k, :)  = avgAngles;
            else
                avgDFFdata{j}(k, :) = avgDFF(1:length(avgDFFdata{j}));
                avgLegAngle{j}(k, :) = avgAngles(1:length(avgLegAngle{j}));
            end
        end
     end

end

%% plot!
colors = winter(6);
set(0,'DefaultAxesColorOrder',colors)

for i = 1:length(speeds)
    fig1 = figure;
    
    subplot(2, 1, 1)
    hold on
    plot(avgDFFdata{i}')
    plot(mean(avgDFFdata{i}), 'k', 'LineWidth', 1.5)
%     ylim([-0.4, 0.5])
    xlim([0, length(avgDFFdata{i})])
    ax = gca;
    xticks(ax, 0:framerate*2:length(avgDFFdata{i}))
    ax.XTickLabel = ax.XTick./framerate;
    
    subplot(2, 1, 2)
    hold on
    plot(avgLegAngle{i}')
    plot(mean(avgLegAngle{i}), 'k', 'LineWidth', 1.5)
    xlim([0, length(avgLegAngle{i})])
    ylim([0, 180])
    ax = gca;
    xticks(ax, 0:framerate*2:length(avgLegAngle{i}))
    ax.XTickLabel = ax.XTick./framerate;
    
%     export_fig(fig1,[dataDir, fileTag, '_', num2str(speeds(i)), 'ds_ipsilateral_extfirstswingsummary.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');
    
end

