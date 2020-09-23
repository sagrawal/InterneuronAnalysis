%% plot leg angle vs. membrane voltage data from active movement trials.

clear all;
close all;


%% active movement data
dataDir1 = 'G:\My Drive\Sweta to backup\ephysdata\spontaneous and active movement examples\';
fileTag1 = '13b_08_*WithSwingOnset.mat';
dataFile = dir([dataDir1, fileTag1]);
load([dataDir1, dataFile(1).name])

am_legangles = legangles;
am_leg_mps = voltagedata(frame_on);
am_leg_mps = am_leg_mps(1:length(am_legangles)); %account for the dropped frames....

%% imposed movement data
dataDir2 = 'G:\My Drive\Sweta to backup\ephysdata\13B recordings\steps\';
fileTag2 = '13b_08_*flexfirst_*WithStepOnset.mat';
dataFile = dir([dataDir2, fileTag2]);
load([dataDir2, dataFile(1).name])

im_legangles = legangles;
im_leg_mps = voltagedata(frame_on);
im_leg_mps = im_leg_mps(1:length(im_legangles)); %account for the dropped frames....

%% 
fig1 = figure;
hold on

plot(am_legangles, am_leg_mps, '.b')
plot(im_legangles, im_leg_mps, '.k')

% export_fig(fig1, [dataDir1, fileTag1(1:end-19), '_legangle_vs_mp_comparison.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');
