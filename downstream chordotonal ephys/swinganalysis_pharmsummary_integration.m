%% analyze swing data from application of any pharm agent 4.25.19

% assumes that there is a folder with pre data and post data. will analyse
% first three swings from pre data and last three swings from post data (or
% first three from post data)

%this version will integrate data post swing instead of substracting pre
%from post
clearvars

dataDir = 'E:\Sweta to backup\ephysdata\9Aalpha recordings\post PT swings\';
% dataDir = 'G:\My Drive\Sweta to backup\ephysdata\9Aalpha recordings\post MLA swings\';

fileTag = 'ss28*WithSwingOnset.mat';
predataFiles = dir([dataDir,'pre\' fileTag]);
postdataFiles = dir([dataDir,'post\' fileTag]);
nflies = length(predataFiles)

%time window for integrating once swing starts
secbefore = 2;
secafter = 0.5;

%which swing to average, 0 = swing on (flexing), 1 = swing off (extending)
swingdir = 0;
nswings = 3; %number of swings worth of data to analyse

for j = 1:nflies
    j
    pre = load([dataDir, 'pre\', predataFiles(j).name]);
    post = load([dataDir, 'post\', postdataFiles(j).name]);

    if swingdir == 0 
        pre.swingframes = pre.LOCS(1:2:nswings*2);
        post.swingframes = post.LOCS(1:2:nswings*2);
%         post.swingframes = post.LOCS((end-2*nswings+1):2:end);
    elseif swingdir == 1
        pre.swingframes = pre.LOCS(2:2:nswings*2);
        post.swingframes = post.LOCS(2:2:nswings*2);
%         post.swingframes = post.LOCS((end-2*(nswings-1)):2:end);
    end
    
    pre.swingsamples = pre.frame_on(pre.swingframes);
    post.swingsamples = post.frame_on(post.swingframes);

    for i = 1:nswings
        prevoltage = pre.voltagedata(pre.swingsamples(i):(pre.swingsamples(i)+(secafter*pre.SampleRate)));
        postvoltage = post.voltagedata(post.swingsamples(i):(post.swingsamples(i)+(secafter*post.SampleRate)));
        
        preoffset = nanmean(pre.voltagedata((pre.swingsamples(i)-secbefore*pre.SampleRate):pre.swingsamples(i)));
        postoffset = nanmean(post.voltagedata((post.swingsamples(i)-secbefore*post.SampleRate):post.swingsamples(i)));
        
        pre.integratedswingvoltage(i) = trapz(prevoltage - preoffset);
        post.integratedswingvoltage(i) = trapz(postvoltage - postoffset);
    end
    
    pre_integratedswingvoltage(j) = nanmean(pre.integratedswingvoltage);
    post_integratedswingvoltage(j) = nanmean(post.integratedswingvoltage);
    
end

fig1 = figure;
hold on
plot([1, 2], [pre_integratedswingvoltage; post_integratedswingvoltage], '.-')
% plot(2, post_avgswingdiff, '.')
xlim([0.5, 2.5])

% export_fig(fig1,[dataDir '9Aalpha_PTXswing_summary.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');



[p, h] = signrank(pre_integratedswingvoltage, post_integratedswingvoltage)