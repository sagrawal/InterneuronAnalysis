%% analyze swing data from application of any pharm agent 4.25.19

% assumes that there is a folder with pre data and post data. will analyse
% first three swings from pre data and last three swings from post data.
clearvars

dataDir = 'E:\Sweta to backup\ephysdata\13B recordings\post PT swings\';
% dataDir = 'G:\My Drive\Sweta to backup\ephysdata\10B recordings\TTX swings\';

fileTag = '13B*WithSwingOnset.mat';
predataFiles = dir([dataDir,'pre\' fileTag]);
postdataFiles = dir([dataDir,'post\' fileTag]);
nflies = length(predataFiles)

%time window for averaging
secbefore = 0.5;
swingduration = 0.75;
secafter = 0.5;

%which swing to average, 0 = swing on (flexing), 1 = swing off (extending)
swingdir = 1;
nswings = 3; %number of swings worth of data to analyse

for j = 1:nflies
    j
    pre = load([dataDir, 'pre\', predataFiles(j).name]);
    post = load([dataDir, 'post\', postdataFiles(j).name]);

    if swingdir == 0 
        pre.swingframes = pre.LOCS(1:2:nswings*2);
%         post.swingframes = post.LOCS(1:2:nswings*2);
        post.swingframes = post.LOCS((end-2*nswings+1):2:end);
    elseif swingdir == 1
        pre.swingframes = pre.LOCS(2:2:nswings*2);
%         post.swingframes = post.LOCS(2:2:nswings*2);
        post.swingframes = post.LOCS((end-2*(nswings-1)):2:end);
    end
    
    pre.swingsamples = pre.frame_on(pre.swingframes);
    post.swingsamples = post.frame_on(post.swingframes);
    pre.beforeswingvoltage = [];
    post.beforeswingvoltage = [];

    for i = 1:nswings
        pre.beforeswingvoltage(i) = nanmean(pre.voltagedata((pre.swingsamples(i)-(secbefore*pre.SampleRate)):pre.swingsamples(i)));
        pre.afterswingvoltage = nanmean(pre.voltagedata((pre.swingsamples(i)+(swingduration*pre.SampleRate)):(pre.swingsamples(i)+((secafter+swingduration)*pre.SampleRate))));
        pre.swingdiffvoltage(i) = abs(pre.afterswingvoltage-pre.beforeswingvoltage(i));
        
        post.beforeswingvoltage(i) = nanmean(post.voltagedata((post.swingsamples(i)-(secbefore*post.SampleRate)):post.swingsamples(i)));
        post.afterswingvoltage = nanmean(post.voltagedata((post.swingsamples(i)+(swingduration*post.SampleRate)):(post.swingsamples(i)+((secafter+swingduration)*post.SampleRate))));
        post.swingdiffvoltage(i) = abs(post.afterswingvoltage-post.beforeswingvoltage(i));
    end
    
    pre_avgswingdiff(j) = nanmean(pre.swingdiffvoltage);
    post_avgswingdiff(j) = nanmean(post.swingdiffvoltage);
    all_preMP(j) = nanmean(pre.beforeswingvoltage(i));
    all_postMP(j) = nanmean(post.beforeswingvoltage(i));
    
end

fig1 = figure;
hold on
plot([1, 2], [pre_avgswingdiff; post_avgswingdiff], '.-')
% plot(2, post_avgswingdiff, '.')
xlim([0.5, 2.5])
xticks([1, 2])
xticklabels({'pre', 'post'})
box off
set(gcf,'color','white')

export_fig(fig1,[dataDir, '13B_extension_PT.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');



[p, h] = signrank(pre_avgswingdiff, post_avgswingdiff)