%% analyze step data, written 2018/12/02 to take into account finding step onset
% will plot all step data (after averaging two trials), and also data from
% each step, plus a comparison of flexion vs extension

% 2/12/19: added spike raster plot
% 2/4/20: added firing rate plot

clear all

dataDir = 'G:\My Drive\Sweta to backup\ephysdata\9Aalpha recordings\steps\tonic\';

fileTag = 'ss28981_26_extfirst_11steps3sdelay_*WithSpikes.mat';
dataFile = dir([dataDir, fileTag]);

steplength = 3;
nsteps = 11; %number of steps in each direction, 2x this number = one full ramp and hold

%for finding avg potential at step (will average middle 2 seconds)
secstart = 0.5;
secend = 2.5;

%% plot average data from ramp and hold
load([dataDir, dataFile(1).name]);

%assuming 2 rounds of ramp and hold
rampstarts = [LOCS(1), LOCS(1+nsteps*2)];
rampends = [LOCS(nsteps*2), LOCS(nsteps*4)];

ramplength = min(rampends-rampstarts);

framesbefore = ceil(4*FrameRate);
framesafter = ceil(4*FrameRate);

trialstarts = frame_on(rampstarts-framesbefore);
trialends = frame_on((rampstarts+ramplength+framesafter));

all_spiketimes = [];

fig1 = figure;
hold on

for i = 1:2
    trialstart = trialstarts(i);
    trialend = trialends(i);
    triallength = min(trialends-trialstarts);
    
    legangle(i, :) = legangles((rampstarts(i)-framesbefore):(rampstarts(i)+ramplength+framesafter));
    angletime(i, :) = (rampstarts(i)-framesbefore)/FrameRate:1/FrameRate:(rampstarts(i)+ramplength+framesafter)/FrameRate;
    angletime(i, :) = angletime(i, :)-angletime(i,1);
    
    a = voltagedata(trialstart:trialend);
    voltage(i, :) = a(1:triallength);
    b = (trialstart/SampleRate):(1/SampleRate):(trialend/SampleRate);
    sampletime(i, :) = b(1:triallength);
    sampletime(i, :) = sampletime(i, :)-sampletime(i,1);
    
    spiketimes{i} = (spikes(spikes>trialstart & spikes<trialend)-trialstart)./SampleRate;
    all_spiketimes = [all_spiketimes, spiketimes{i}];
end

g = subplot(4, 1, 1);
hold on
plotSpikeRaster(spiketimes,'PlotType','vertline', 'XLimForCell', [0, 80]);
box off
axis off

g = subplot(4, 1, 2);
hold on
binsize = 0.5; %in s
spikerate = histcounts(all_spiketimes, 0:binsize:80)./(2*binsize);
plot((0.5*binsize):binsize:80, spikerate)
xlim([0, 80])
ylim([0, 6])

g = subplot(4, 1, 3);
hold on
plot(sampletime(1, :), voltage(1, :), 'k')
plot(sampletime(1, :), voltage(2, :), 'r')
box off


g = subplot(4, 1, 4);
hold on
plot(angletime(1, :), mean(legangle))
box off
set(gcf,'color', 'w')


export_fig(fig1,[dataDir 'ss28981_26_extfirst_rampandholdsummary.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');

