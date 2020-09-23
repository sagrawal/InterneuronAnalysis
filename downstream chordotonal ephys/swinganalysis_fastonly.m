%% analyze swing data -- 11/20/17: only analyzes data from a single fly
clear all;

% dataDir = 'C:\Users\swetarr\Google Drive\Sweta to backup\ephysdata\';
dataDir = 'G:\My Drive\Sweta to backup\ephysdata\13B recordings\swings\';

fileTag = '13B_32_flexfirst_swings_*WithSwingOnset.mat';
dataFile = dir([dataDir, fileTag]);

load([dataDir, dataFile(1).name])

extfirst = 0; %change to 0 if starting with flexion first
secondsbefore = 3;
secondsafter = 3;

%% look at leg angle data, find onsets of swing

%specify numbers of each swing type, assume fast goes first followed by
%slow
nfastswing = 3;
flexion_thresh = 50;
ext_thresh = 150;

framesbefore = secondsbefore*FrameRate; %number of frames worth of data included pre-swing
framesafter = secondsafter*FrameRate; %amount of frames worth of data included post-swing


if extfirst == 1
    threshedangles = round(legangles)<flexion_thresh;
    
    swingdiffs = diff(threshedangles);
    swing_on = find(swingdiffs == 1)+1;
    swing_off = find(swingdiffs == -1)+1;
else
    threshedangles = round(legangles)>ext_thresh;
    
    swingdiffs = diff(threshedangles);
    swing_on = find(swingdiffs == 1)+1;
    swing_off = find(swingdiffs == -1)+1;
end

fastswing_on = frame_on(swing_on);
fastswing_off = frame_on(swing_off);

[nframes, idx] = min(fastswing_off - fastswing_on);
for i = 1:nfastswing
    fastswing_sampletime{i} = (fastswing_on(i)/SampleRate-secondsbefore):(1/SampleRate):((fastswing_on(i)+nframes)/SampleRate+secondsafter);
    fastswing_sampletime{i} = fastswing_sampletime{i}-fastswing_sampletime{i}(1);
    
    [~, idx1] = find(frame_on== fastswing_on(i));
    [~, idx2] = find(frame_on== fastswing_off(i));
    fastswing_angletime{i} = frame_on((idx1-framesbefore):(idx2+framesafter))./SampleRate;
    fastswing_angletime{i} = fastswing_angletime{i}-fastswing_angletime{i}(1);
end


%% combo fig
fig3 = figure;
hold on

g = subplot(2, 1, 1);
hold on

nframes = min(fastswing_off - fastswing_on);
for i = 1:nfastswing
    preswing_mempot = voltagedata((fastswing_on(i)-(framesbefore/FrameRate)*SampleRate):fastswing_on(i));
    fastswing_voltagedata(i, :) = (voltagedata((fastswing_on(i)-(framesbefore/FrameRate)*SampleRate):(fastswing_on(i)+nframes+(framesafter/FrameRate)*SampleRate))-mean(preswing_mempot));
    plot(fastswing_sampletime{i}, fastswing_voltagedata(i, :), 'r')
end

% plot(mean(fastswing_voltagedata), 'r')

% ylim([-3, 8]);
ax = gca;
% ax.XTickLabel = ax.XTick./20000;

g = subplot(2, 1, 2);
hold on
for i = 1:nfastswing
    [~, idx1] = find(frame_on== fastswing_on(i));
    [~, idx2] = find(frame_on== fastswing_off(i));
    plot(fastswing_angletime{i}, legangles((idx1-framesbefore):(idx2+framesafter)), 'r');
end

ax = gca;
% ax.XTick = [0:framerate:1000];
% ax.XTickLabel = ax.XTick./.075;
% ylim(legangle_ylim);

% export_fig(fig3,[dataDir fileTag(1:end-5) '_singletrialsummary.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');

%% averaged fig
fig4 = figure;
hold on

g = subplot(2, 1, 1);
hold on

plot(fastswing_sampletime{1}, mean(fastswing_voltagedata), 'r')

% ylim([-12, 5]);
ax = gca;
% ax.XTickLabel = ax.XTick./20000;

g = subplot(2, 1, 2);
hold on
[~, idx1] = find(frame_on== fastswing_on(1));
[~, idx2] = find(frame_on== fastswing_off(1));
plot(fastswing_angletime{1}, legangles((idx1-framesbefore):(idx2+framesafter)), 'r');

ax = gca;
% ax.XTick = [0:framerate:1000];
% ax.XTickLabel = ax.XTick./.075;
% ylim(legangle_ylim);
ylim([0 180])

% export_fig(fig4,[dataDir fileTag(1:10) '_averagedsummary.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');


