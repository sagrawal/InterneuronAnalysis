%% analyze swing data from application of any pharm agent 4.25.19

% assumes that there is a folder with pre data and post data. will analyse
% first three swings from pre data and last three swings from post data.
clearvars

dataDir = 'E:\Sweta to backup\ephysdata\9Aalpha recordings\post MLA swings\';
% dataDir = 'G:\My Drive\Sweta to backup\ephysdata\10B recordings\TTX swings\';

fileTag = 'ss*OnsetCorr.mat';
predataFile = dir([dataDir,'pre\' fileTag]);
postdataFile = dir([dataDir,'post\' fileTag]);

pre = load([dataDir, 'pre\', predataFile(1).name]);
post = load([dataDir, 'post\', postdataFile(1).name]);

pre.SampleRate
post.SampleRate

secbefore = 2;
secafter = 8;
nswings = 3; %number of swings worth of data to analyse

desiredFrameRate = 75;
framedatalength = desiredFrameRate*(secbefore+secafter);

%% load in pre and post pharm data

pre.swingstarts_frames = pre.swingstarts;
post.swingstarts_frames = post.swingstarts;
% post.swingstarts_frames = post.LOCS((end-2*nswings+1):2:end);

pre.swingstarts_samples = pre.frame_on(pre.swingstarts_frames);
post.swingstarts_samples = post.frame_on(post.swingstarts_frames);

%% pre pharm data
pre.swingstart_legangle = [];
pre.swingstart_angletime = [];
pre.swingstart_voltage = [];
pre.swingstart_sampletime = [];
framecounterror = 0;

for i = 1:nswings
    if (pre.swingstarts_frames(i)-(secbefore*pre.FrameRate)) < 1
        'needmoarframesbefore!'
        framecounterror = 1;
    elseif (pre.swingstarts_frames(i)+(secafter*pre.FrameRate)) > length(pre.legangles)
        'needmoarframesafter!'
        framecounterror = 1;
    else
        a = pre.legangles((pre.swingstarts_frames(i)-secbefore*pre.FrameRate):(pre.swingstarts_frames(i)+secafter*pre.FrameRate));
        b = resample(a, desiredFrameRate, round(pre.FrameRate));
        pre.swingstart_legangle(i, :) = b(1:framedatalength);
        
        pre.swingstart_angletime = (pre.swingstarts_frames(i)-secbefore*desiredFrameRate)/desiredFrameRate:1/desiredFrameRate:(pre.swingstarts_frames(i)+secafter*desiredFrameRate)/desiredFrameRate;
        pre.swingstart_angletime = pre.swingstart_angletime-pre.swingstart_angletime(1,1);
        pre.swingstart_angletime = pre.swingstart_angletime(1:framedatalength);
        
        pre.swingstart_voltage(i, :) = pre.voltagedata((pre.swingstarts_samples(i)-(secbefore*pre.SampleRate)):(pre.swingstarts_samples(i)+(secafter*pre.SampleRate)));
        pre.swingstart_voltage(i, :) = pre.swingstart_voltage(i, :) - mean(pre.swingstart_voltage(i, 1:(secbefore*pre.SampleRate)));
        
        pre.swingstart_sampletime = (pre.swingstarts_samples(i)-secbefore*pre.SampleRate)/pre.SampleRate:(1/pre.SampleRate):(pre.swingstarts_samples(i)+secafter*pre.SampleRate)/pre.SampleRate;
        pre.swingstart_sampletime = pre.swingstart_sampletime-pre.swingstart_sampletime(1,1);
    end
    
end

if framecounterror == 1
    pre.swingstart_legangle(pre.swingstart_legangle == 0) = NaN;
    pre.swingstart_voltage(pre.swingstart_voltage == 0) = NaN;
end

pre.avg_legangles = nanmean(pre.swingstart_legangle);
pre.avg_voltages = nanmean(pre.swingstart_voltage);

%% post pharm data
post.swingstart_legangle = [];
post.swingstart_angletime = [];
post.swingstart_voltage = [];
post.swingstart_sampletime = [];
framecounterror = 0;

for i = 1:nswings
    if (post.swingstarts_frames(i)-(secbefore*post.FrameRate)) < 1
        'needmoarframesbefore!'
        framecounterror = 1;
    elseif (post.swingstarts_frames(i)+(secafter*post.FrameRate)) > length(post.legangles)
        'needmoarframesafter!'
        framecounterror = 1;
    else
        a = post.legangles((post.swingstarts_frames(i)-secbefore*post.FrameRate):(post.swingstarts_frames(i)+secafter*post.FrameRate));
        b = resample(a, desiredFrameRate, round(post.FrameRate));
        post.swingstart_legangle(i, :) = b(1:framedatalength);
        
        post.swingstart_angletime = (post.swingstarts_frames(i)-secbefore*desiredFrameRate)/desiredFrameRate:1/desiredFrameRate:(post.swingstarts_frames(i)+secafter*desiredFrameRate)/desiredFrameRate;
        post.swingstart_angletime = post.swingstart_angletime-post.swingstart_angletime(1,1);
        post.swingstart_angletime = post.swingstart_angletime(1:framedatalength);
        
        post.swingstart_voltage(i, :) = post.voltagedata((post.swingstarts_samples(i)-(secbefore*post.SampleRate)):(post.swingstarts_samples(i)+(secafter*post.SampleRate)));
        post.swingstart_voltage(i, :) = post.swingstart_voltage(i, :) - mean(post.swingstart_voltage(i, 1:(secbefore*post.SampleRate)));
        
        post.swingstart_sampletime = (post.swingstarts_samples(i)-secbefore*post.SampleRate)/post.SampleRate:(1/post.SampleRate):(post.swingstarts_samples(i)+secafter*post.SampleRate)/post.SampleRate;
        post.swingstart_sampletime = post.swingstart_sampletime-post.swingstart_sampletime(1,1);
    end
    
end

if framecounterror == 1
    post.swingstart_legangle(post.swingstart_legangle == 0) = NaN;
    post.swingstart_voltage(post.swingstart_voltage == 0) = NaN;
end

post.avg_legangles = nanmean(post.swingstart_legangle);
post.avg_voltages = nanmean(post.swingstart_voltage);


%% pre pharm fig
colors = winter(nswings);
set(0,'DefaultAxesColorOrder',colors)

fig1 = figure;
hold on

subplot(2, 1, 1)
hold on
plot(pre.swingstart_sampletime, pre.swingstart_voltage')
plot(pre.swingstart_sampletime, pre.avg_voltages, 'k', 'LineWidth', 2)
xlim([0, secbefore+secafter])
% ylim([-10, 10])
ylabel('mV')
% title(fileTag(1:end-29))

subplot(2, 1, 2)
hold on
plot(pre.swingstart_angletime,  pre.swingstart_legangle')
plot(pre.swingstart_angletime, pre.avg_legangles, 'k', 'LineWidth', 2)
xlim([0, secbefore+secafter])
% ylim([0, 180])
xlabel('sec')
ylabel('leg angle')

% export_fig(fig1,[dataDir fileTag(1:8), '_preTTXswings.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');

%% post pharm fig
colors = winter(nswings);
set(0,'DefaultAxesColorOrder',colors)

fig2 = figure;
hold on

subplot(2, 1, 1)
hold on
plot(post.swingstart_sampletime, post.swingstart_voltage')
plot(post.swingstart_sampletime, post.avg_voltages, 'k', 'LineWidth', 2)
xlim([0, secbefore+secafter])
% ylim([-5, 15])
ylabel('mV')
% title(fileTag(1:end-29))

subplot(2, 1, 2)
hold on
plot(post.swingstart_angletime,  post.swingstart_legangle')
plot(post.swingstart_angletime, post.avg_legangles, 'k', 'LineWidth', 2)
xlim([0, secbefore+secafter])
% ylim([0, 180])
xlabel('sec')
ylabel('leg angle')

% export_fig(fig2,[dataDir fileTag(1:8), '_postTTXswings.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');

%% combo fig

fig3 = figure;
hold on

subplot(2, 1, 1)
hold on
plot(pre.swingstart_sampletime, pre.avg_voltages, 'b')
plot(post.swingstart_sampletime, post.avg_voltages, 'r')
xlim([0, secbefore+secafter])
% ylim([-10, 10])
ylabel('mV')
% title(fileTag(1:end-29))

subplot(2, 1, 2)
hold on
plot(pre.swingstart_angletime, pre.avg_legangles, 'b')
plot(post.swingstart_angletime, post.avg_legangles, 'r')
xlim([0, secbefore+secafter])
% ylim([0, 180])
xlabel('sec')
ylabel('leg angle')

% export_fig(fig3,[dataDir fileTag(1:8), '_preandpostTTXswings.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');