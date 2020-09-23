%% file to analyze velocity tuning

%12/2/19: for each cell, calculate the maximum slope of df/f data, and the corresponding
%average velocity. Only using flex first swing data for now.

%three possibly meaningful variables: slope, peak, integral. For now am
%calculating all three

clear all

fileTag = 'not13e04';
dataDir = 'E:\Sweta to backup\2 photon data\not13e04LexA\swings\';

% framerate = 7.57; %hz, hard coded based on experience
nrep = 3;
speeds = [180, 360, 720, 1440]; %swing speeds tested

%window before and after swing is identified as starting to look for max
%df/f slope
secbefore = 0;
secafter = 1;
thisROI = 2; %ROI of interest, if more than one

%%
for j = 1:length(speeds)
    j
    DffFiles = dir([dataDir, fileTag, '*flexfirst_swings_', num2str(speeds(j)), '*SelectROICalculateDFF.mat']);
    AngleFiles = dir([dataDir, fileTag, '*flexfirst_swings_', num2str(speeds(j)), '*AngleforImagingFrame.mat']);
    TimingFiles = dir([dataDir, fileTag, '*flexfirst_swings_', num2str(speeds(j)), '*DetectCameraAndImagingFrames.mat']);
    
    if length(DffFiles) ~= length(AngleFiles)||length(DffFiles) ~= length(TimingFiles)
        error('mismatch in file number')
    end
   
    
    allMaxExtDffSlope{j} = [];
    allMaxFlxDffSlope{j} = [];
   
    allMaxExtDffPeak{j} = [];
    allMaxFlxDffPeak{j} = [];
    
    allExtDffInt{j} = [];    
    allFlxDffInt{j} = [];    
    
    allAvgExtLegSpeed{j} = [];
    allAvgFlxLegSpeed{j} = [];
    
     for k = 1:length(DffFiles)
%         timingFiles(k).name
        load([dataDir, DffFiles(k).name]);
        load([dataDir, AngleFiles(k).name]);
        load([dataDir, TimingFiles(k).name]);
        
        framerate = 20000./mean(ImageInterval);
        
        %some data files have multiple clusters, want only the "signal"
        %cluster
        if size(DFF1, 1)>1
%             'multiple clusters'
%             [~, signalcluster] = max(var(DFF1'));
            signalDff = DFF1(thisROI, :);
%             plot(signalDff);
        else
%             'single cluster'
            signalDff = DFF1(1, :);
        end
        
        maxExtDffSlope = [];
        maxFlxDffSlope = [];
        maxExtDffPeak = [];
        maxFlxDffPeak = [];
        ExtDffInt = [];
        FlxDffInt = [];
        ExtLegSpeed = [];
        FlxLegSpeed = [];
        
        ImageLegAngle(ImageLegAngle<0) = min(ImageLegAngle(ImageLegAngle>0));
        
        for i = 1:nrep
            ExtSwingDff = signalDff(ceil(StartIF((2*i-1), 1)-secbefore*framerate):ceil(StartIF((2*i-1), 1)+secafter*framerate));
            
            [maxExtDffSlope(i), idx] = max(diff(ExtSwingDff).*framerate); %idx = this frame to the following frame yielded the max dff slope
            idx = idx+ceil(StartIF(2*i-1, 1)-secbefore*framerate)-1; %idx now in terms of DFF1 frame number
            ExtLegSpeed(i) = diff(ImageLegAngle(idx:(idx+1))).*framerate;
            
            maxExtDffPeak(i) = max(ExtSwingDff);
            ExtDffInt(i) = trapz(ExtSwingDff);
            
            
            FlxSwingDff = signalDff(ceil(StartIF((2*i), 1)-secbefore*framerate):ceil(StartIF((2*i), 1)+secafter*framerate));
            
            [maxFlxDffSlope(i), idx] = max(diff(FlxSwingDff).*framerate); %idx = this frame to the following frame yielded the max dff slope
            idx = idx+ceil(StartIF(2*i, 1)-secbefore*framerate)-1; %idx now in terms of DFF1 frame number
            FlxLegSpeed(i) = diff(ImageLegAngle(idx:(idx+1))).*framerate;
            
            maxFlxDffPeak(i) = max(FlxSwingDff);
            FlxDffInt(i) = trapz(FlxSwingDff);
        end
        
        allMaxExtDffSlope{j}(k) = mean(maxExtDffSlope);
        allMaxFlxDffSlope{j}(k) = mean(maxFlxDffSlope);
        allAvgExtLegSpeed{j}(k) = mean(ExtLegSpeed);
        allAvgFlxLegSpeed{j}(k) = mean(FlxLegSpeed);
        allMaxExtDffPeak{j}(k) = mean(maxExtDffPeak);
        allMaxFlxDffPeak{j}(k) = mean(maxFlxDffPeak);
        allExtDffInt{j}(k) = mean(ExtDffInt);
        allFlxDffInt{j}(k) = mean(FlxDffInt);
       
     end

end

%% plot!
fig1 = figure;
hold on

for i = 1:length(speeds)
    plot(i, allMaxExtDffSlope{i}, 'k.')
    plot(i, mean(allMaxExtDffSlope{i}), 'ko')
    plot(i, allMaxExtDffPeak{i}, 'g.')
    plot(i, mean(allMaxExtDffPeak{i}), 'go')
    plot(i, allExtDffInt{i}, 'r.')
    plot(i, mean(allExtDffInt{i}), 'ro')
end

xlim([0.5, length(speeds)+0.5])
% export_fig(fig1,[dataDir, fileTag, '_contralateral_ext_velocitytuning.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');

fig2 = figure;
hold on

for i = 1:length(speeds)
    plot(i, allMaxFlxDffSlope{i}, 'k.')
    plot(i, mean(allMaxFlxDffSlope{i}), 'ko')
%     plot(i, allMaxFlxDffPeak{i}, 'g.')
%     plot(i, mean(allMaxFlxDffPeak{i}), 'go')
%     plot(i, allFlxDffInt{i}, 'r.')
%     plot(i, mean(allFlxDffInt{i}), 'ro')
end

xlim([0.5, length(speeds)+0.5])

export_fig(fig2,[dataDir, fileTag, '_flx_velocitytuning.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');
