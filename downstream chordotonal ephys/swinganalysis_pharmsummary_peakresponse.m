%% analyze swing data from application of any pharm agent 4.25.19

% assumes that there is a folder with pre data and post data. will analyse
% first three swings from pre data and last three swings from post data.

% will find and plot peak, positive response after swing (baseline
% subtracted from average membrane potential before swing)

%extfirst trials, for now assuming that we will only be looking at the
%flexion (swing on) data
clearvars

dataDir = 'E:\Sweta to backup\ephysdata\10B recordings\PT swings\';
% dataDir = 'G:\My Drive\Sweta to backup\ephysdata\10B recordings\TTX swings\';

fileTag = '047*OnsetCorr.mat';
predataFiles = dir([dataDir,'pre\' fileTag]);
postdataFiles = dir([dataDir,'post\' fileTag]);
nflies = length(predataFiles)

%time window for averaging
secbefore = 0.5;
secafter = 0.5;
nswings = 3; %number of swings worth of data to analyse

for j = 1:nflies
    pre = load([dataDir, 'pre\', predataFiles(j).name]);
    post = load([dataDir, 'post\', postdataFiles(j).name]);
    
    pre.swingframes = pre.swingstarts;
    post.swingframes = post.swingstarts;
    pre.swingsamples = pre.frame_on(pre.swingframes);
    post.swingsamples = post.frame_on(post.swingframes);

    for i = 1:nswings
        pre.beforeswingvoltage = nanmean(pre.voltagedata((pre.swingsamples(i)-(secbefore*pre.SampleRate)):pre.swingsamples(i)));
        pre.afterswingvoltage = nanmax(pre.voltagedata(pre.swingsamples(i):(pre.swingsamples(i)+(secafter*pre.SampleRate))));
        pre.swingdiffvoltage(i, :) = abs(pre.afterswingvoltage-pre.beforeswingvoltage);
        
        post.beforeswingvoltage = nanmean(post.voltagedata((post.swingsamples(i)-(secbefore*post.SampleRate)):post.swingsamples(i)));
        post.afterswingvoltage = nanmax(post.voltagedata(post.swingsamples(i):(post.swingsamples(i)+(secafter*post.SampleRate))));
        post.swingdiffvoltage(i, :) = abs((post.afterswingvoltage)-(post.beforeswingvoltage));
    end
    
    pre_avgswingdiff(j) = nanmean(pre.swingdiffvoltage);
    post_avgswingdiff(j) = nanmean(post.swingdiffvoltage);
end

fig1 = figure;
hold on
plot([1, 2], [pre_avgswingdiff; post_avgswingdiff], '.-')
% plot(2, post_avgswingdiff, '.')
xlim([0.5, 2.5])

% export_fig(fig1,[dataDir, '10B_MLApeakresponse.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');



[p, h] = signrank(pre_avgswingdiff, post_avgswingdiff)