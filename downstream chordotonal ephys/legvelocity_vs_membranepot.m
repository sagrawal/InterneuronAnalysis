%% plot leg angle vs. membrane voltage data from active movement trials.

clear all;
% close all;


%% active movement data
dataDir1 = 'G:\My Drive\Sweta to backup\ephysdata\spontaneous and active movement examples\';
fileTag1 = 'ss28981_18_*WithSwingOnset.mat';
dataFile = dir([dataDir1, fileTag1]);
am = load([dataDir1, dataFile(1).name])

am_legangles = am.legangles;
am_legvel = diff(am_legangles)*am.FrameRate;
am_legvel_mps = am.voltagedata(am.frame_on(2:end));
am_legvel_mps = am_legvel_mps(1:length(am_legvel)); %account for the dropped frames....

%% imposed movement data
dataDir2 = 'G:\My Drive\Sweta to backup\ephysdata\9Aalpha recordings\swings\';
fileTag2 = 'ss28981_18*extfirst_*WithSwingOnset.mat';
dataFile = dir([dataDir2, fileTag2]);
im = load([dataDir2, dataFile(1).name])

im_legangles = im.legangles;
im_legvel = diff(im_legangles)*im.FrameRate;
im_legvel_mps = im.voltagedata(im.frame_on(2:end));
im_legvel_mps = im_legvel_mps(1:length(im_legvel)); %account for the dropped frames....

%% 
fig1 = figure;
hold on


plot(am_legvel, am_legvel_mps, '.b')
plot(im_legvel, im_legvel_mps, '.k')

xlim([-1000, 1000])
% ylim([-55, -30])

export_fig(fig1, [dataDir1, fileTag1(1:end-19), '_legvelocity_vs_mp_comparison.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');
