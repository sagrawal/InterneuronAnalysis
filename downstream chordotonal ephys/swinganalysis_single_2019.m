%% analyze swing data, take into account finding swing onset
% will summarize data from many cells altogether
% will plot all swing data (after averaging two trials), integral of voltage during swing movement, 
% plus a comparison of flexion vs extension

% modified 4/23/19 so that there is a slight break between swing start and
% swing end and taking into account the corrected. aligned swing times

clearvars

dataDir = 'G:\My Drive\Sweta to backup\ephysdata\10B recordings\swings\';
fileTag = '04751_22_extfirst*WithSwingOnsetCorr.mat';
dataFiles = dir([dataDir, fileTag]);
nflies = length(dataFiles)

nrep = 3;
nspeeds = 1;

secbefore = 2; %s before and after ramp and hold stim to plot for summary figure
secafter = 3; %s, includes time for swing stim to occur (5 sec+) and after swing

desiredFrameRate = 75;
framedatalength = desiredFrameRate*(secbefore+secafter);

%% pull out average data from ramp and hold

load([dataDir, dataFiles(1).name]);

for k = 1:nspeeds
    swingstarts_frames = swingstarts((1:3)+nrep*(k-1));
    swingends_frames = swingends((1:3)+nrep*(k-1));
    
    swingstarts_samples = frame_on(swingstarts_frames);
    swingends_samples = frame_on(swingends_frames);
    
    swingstart_legangle = [];
    swingstart_angletime = [];
    swingstart_voltage = [];
    swingstart_sampletime = [];
    framecounterror = 0;
    
    swingend_legangle = [];
    swingend_angletime = [];
    swingend_voltage = [];
    swingend_sampletime = [];
    offsetcorr = [];
    
    for i = 1:nrep
        % start with pulling out swing start data
        if (swingstarts_frames(i)-(secbefore*FrameRate)) < 1
            'needmoarframesbefore!'
            framecounterror = 1;
        elseif (swingends_frames(i)+(secafter*FrameRate)) > length(legangles)
            'needmoarframesafter!'
            framecounterror = 1;
        else
            a = legangles((swingstarts_frames(i)-secbefore*FrameRate):(swingstarts_frames(i)+secafter*FrameRate));
            b = resample(a, desiredFrameRate, round(FrameRate));
            swingstart_legangle(i, :) = b(1:framedatalength);
            
            swingstart_angletime = (swingstarts_frames(i)-secbefore*desiredFrameRate)/desiredFrameRate:1/desiredFrameRate:(swingstarts_frames(i)+secafter*desiredFrameRate)/desiredFrameRate;
            swingstart_angletime = swingstart_angletime-swingstart_angletime(1,1);
            swingstart_angletime = swingstart_angletime(1:framedatalength);
            
            swingstart_voltage(i, :) = voltagedata((swingstarts_samples(i)-(secbefore*SampleRate)):(swingstarts_samples(i)+(secafter*SampleRate)));
            offsetcorr(i) = mean(swingstart_voltage(i, 1:(secbefore*SampleRate)));
            swingstart_voltage(i, :) = swingstart_voltage(i, :) - offsetcorr(i);
            
            swingstart_sampletime = (swingstarts_samples(i)-secbefore*SampleRate)/SampleRate:(1/SampleRate):(swingstarts_samples(i)+secafter*SampleRate)/SampleRate;
            swingstart_sampletime = swingstart_sampletime-swingstart_sampletime(1,1);
            
            a = legangles((swingends_frames(i)-secbefore*FrameRate):(swingends_frames(i)+secafter*FrameRate));
            b = resample(a, desiredFrameRate, round(FrameRate));
            swingend_legangle(i, :) = b(1:framedatalength);
            
            swingend_angletime = (swingends_frames(i)-secbefore*desiredFrameRate)/desiredFrameRate:1/desiredFrameRate:(swingends_frames(i)+secafter*desiredFrameRate)/desiredFrameRate;
            swingend_angletime = swingend_angletime-swingend_angletime(1,1);
            swingend_angletime = swingend_angletime(1:framedatalength);
            
            swingend_voltage(i, :) = voltagedata((swingends_samples(i)-(secbefore*SampleRate)):(swingends_samples(i)+(secafter*SampleRate)));
            swingend_voltage(i, :) = swingend_voltage(i, :) - offsetcorr(i);
            
            swingend_sampletime = (swingends_samples(i)-secbefore*SampleRate)/SampleRate:(1/SampleRate):(swingends_samples(i)+secafter*SampleRate)/SampleRate;
            swingend_sampletime = swingend_sampletime-swingend_sampletime(1,1);
        end
        
    end
    
    if framecounterror == 1
        swingstart_legangle(swingstart_legangle == 0) = NaN;
        swingstart_voltage(swingstart_voltage == 0) = NaN;
        
        swingend_legangle(swingend_legangle == 0) = NaN;
        swingend_voltage(swingend_voltage == 0) = NaN;
    end
    
    %         anglelengths(j, k) = length(swingstart_angletime);
    %         voltagelengths(j, k) = length(swingstart_sampletime);
    
    allavgsslegangles{k} = nanmean(swingstart_legangle);
    allavgssvoltages{k} = nanmean(swingstart_voltage);
    allssangletimes{k} = swingstart_angletime;
    allsssampletimes{k} = swingstart_sampletime;
    
    allavgselegangles{k} = nanmean(swingend_legangle);
    allavgsevoltages{k} = nanmean(swingend_voltage);
    allseangletimes{k} = swingend_angletime;
    allsesampletimes{k} = swingend_sampletime;
end

%% plotting
colors = winter(length(dataFiles));
set(0,'DefaultAxesColorOrder',colors)


%% speed 1 swing on fig
fig1 = figure;
hold on

subplot(2, 1, 1)
hold on
plot(allsssampletimes{1}', allavgssvoltages{1}')
% plot(allsssampletimes{1}', swingstart_voltage(1, :))
xlim([0, secbefore+secafter])
ylim([-6, 7])
ylabel('mV')
% title(fileTag(1:end-29))

subplot(2, 1, 2)
hold on
plot(allssangletimes{1}', allavgsslegangles{1}')
xlim([0, secbefore+secafter])
ylim([0, 180])
xlabel('sec')
ylabel('leg angle')

% export_fig(fig1,[dataDir, fileTag(1:17), '_summaryfastswingon.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');

%speed 1 swing off fig
fig2 = figure;
hold on

subplot(2, 1, 1)
hold on
plot(allsesampletimes{1}', allavgsevoltages{1}')
xlim([0, secbefore+secafter])
ylim([-7, 10])
ylabel('mV')
% title(fileTag(1:end-29))

subplot(2, 1, 2)
hold on
plot(allseangletimes{1}', allavgselegangles{1}')
xlim([0, secbefore+secafter])
ylim([0, 180])
xlabel('sec')
ylabel('leg angle')

% export_fig(fig2,[dataDir, fileTag(1:19), '_summaryfastswingoff.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');
% 


