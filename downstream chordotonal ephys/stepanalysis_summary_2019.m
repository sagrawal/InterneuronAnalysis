%% analyze step data, written 2019/01 to take into account finding step onset
% will summarize data from many cells altogether
% will plot all step data (after averaging two trials), and also data from
% each step, plus a comparison of flexion vs extension

clearvars

dataDir = 'G:\My Drive\Sweta to backup\ephysdata\13B recordings\steps\';

fileTag = '*extfirst*WithStepOnset.mat';
dataFiles = dir([dataDir, fileTag]);
nflies = length(dataFiles)

steplength = 3;
nsteps = 11; %number of steps in each direction, 2x this number = one full ramp and hold
nreps = 2;

secbefore = 3; % second before overall stim to plot
secafter = 70; % seconds after stim start to plot (includes entire ramp and hold stim)
desiredFrameRate = 75;
framedatalength = desiredFrameRate*(secbefore+secafter);

%for finding avg potential at step (will average middle 2 seconds)
secstart = 1;
secend = 2;

%% pull out average data from ramp and hold
colors = winter(nflies);
set(0,'DefaultAxesColorOrder',colors)
fig1 = figure;
hold on


stepdir1_voltagedata = NaN(nflies, nsteps*nreps);
stepdir1_angledata = NaN(nflies, nsteps*nreps);
stepdir2_voltagedata = NaN(nflies, nsteps*nreps);
stepdir2_angledata = NaN(nflies, nsteps*nreps);

for j = 1:nflies
%     dataFiles(j).name
    load([dataDir, dataFiles(j).name]);
    
    %assuming 2 rounds of ramp and hold
    rampstarts = [LOCS(1), LOCS(1+nsteps*2)];
    rampends = [LOCS(nsteps*2), LOCS(nsteps*4)];
    
    ramplength = round(secafter*FrameRate);
    desiredramplength = round(secafter*desiredFrameRate);
    framesbefore = round(secbefore*FrameRate);
        
    legangle = [];
    angletime = [];
    voltage = [];
    sampletime = [];
    offsetcorr = [];
    
    %step averaging data
    stepdir1 = [LOCS(1:nsteps), LOCS((nsteps*2+1):nsteps*3)];
    stepdir2 = [LOCS((nsteps+1):2*nsteps), LOCS((nsteps*3+1):nsteps*4)];
    
    for i = 1:nreps
        if i == 1
            b = legangles((rampstarts(i)-framesbefore):(rampstarts(i)+ramplength));
            c = resample(b, desiredFrameRate, round(FrameRate));
            legangle(i, :) = c(1:framedatalength);
            
            angletime = (rampstarts(i)-secbefore*desiredFrameRate)/desiredFrameRate:1/desiredFrameRate:(rampstarts(i)+desiredramplength)/desiredFrameRate;
            angletime = angletime(i, :)-angletime(i,1);
            angletime = angletime(1:framedatalength);
            
            voltage(i, :) = voltagedata(frame_on(rampstarts(i)-framesbefore):frame_on(rampstarts(i)+ramplength));
            offsetcorr(i) = mean(voltage(i, 1:secbefore*SampleRate));
            voltage(i, :) = voltage(i, :) - offsetcorr(i);
            sampletime = frame_on(rampstarts(i)-framesbefore)/SampleRate:(1/SampleRate):(frame_on(rampstarts(i)+ramplength)/SampleRate);
            sampletime = sampletime(i, :)-sampletime(i,1);
        else
            b = legangles((rampstarts(i)-framesbefore):(rampstarts(i)+ramplength));
            c = resample(b, desiredFrameRate, round(FrameRate));
            legangle(i, :) = c(1:framedatalength);
            
            a = voltagedata(frame_on(rampstarts(i)-framesbefore):frame_on(rampstarts(i)+ramplength));
            if length(voltage)>length(a)
                voltage = voltage(1, 1:length(a));
                sampletime = sampletime(1, 1:length(a));
            end
            voltage(i, :) = a(1:length(voltage));
            offsetcorr(i) = mean(voltage(i, 1:secbefore*SampleRate));
            voltage(i, :) = voltage(i, :) - offsetcorr(i);
        end
    end
    
    avg_legangles(j, :) = mean(legangle);
    avg_voltages{j} = mean(voltage);
    avg_angletimes(j, :) = angletime;
    avg_sampletimes{j} = sampletime;
    alloffsetcorr(j) = nanmean(offsetcorr);
    
    if j == 1
        minvoltagelength = length(mean(voltage));
        
        allavgvoltages(j, :) = avg_voltages{j}(1:minvoltagelength);
        allsampletimes(j, :) = avg_sampletimes{j}(1:minvoltagelength);
    elseif length(mean(voltage))<minvoltagelength
        minvoltagelength = length(mean(voltage));
        allavgvoltages = allavgvoltages(:, 1:minvoltagelength);
        allsampletimes = allsampletimes(:, 1:minvoltagelength);
        
        allavgvoltages(j, :) = avg_voltages{j}(1:minvoltagelength);
        allsampletimes(j, :) = avg_sampletimes{j}(1:minvoltagelength);
    else
        allavgvoltages(j, :) = avg_voltages{j}(1:minvoltagelength);
        allsampletimes(j, :) = avg_sampletimes{j}(1:minvoltagelength);
    end
    
    subplot(2, 1, 2)
    hold on
    plot(avg_angletimes(j, :), avg_legangles(j, :))
    
    subplot(2, 1, 1)
    hold on
    plot(avg_sampletimes{j}, avg_voltages{j})
    
    %step averaging
    for i = 1:nsteps*nreps
        stepdir1_voltagedata(j, i) = mean(voltagedata(frame_on(round(stepdir1(i)+secstart*FrameRate)):frame_on(round(stepdir1(i)+secend*FrameRate))));
        stepdir1_angledata(j, i) = mean(legangles(round(stepdir1(i)+secstart*FrameRate):round(stepdir1(i)+secend*FrameRate)));
        
        stepdir2_voltagedata(j, i) = mean(voltagedata(frame_on(round(stepdir2(i)+secstart*FrameRate)):frame_on(round(stepdir2(i)+secend*FrameRate))));
        stepdir2_angledata(j, i) = mean(legangles(round(stepdir2(i)+secstart*FrameRate):round(stepdir2(i)+secend*FrameRate)));
    end
    
    %find difference (in mV) between two directions of movement
    
    %normalize step voltage data so it goes from 0 to 1
    allstepdata = [stepdir1_voltagedata(j, 1:11), stepdir2_voltagedata(j, 1:11)];
    minstepdata = min(allstepdata);    
    normstepdir1_voltagedata(j, :) = stepdir1_voltagedata(j, :) - minstepdata;
    normstepdir2_voltagedata(j, :) = stepdir2_voltagedata(j, :) - minstepdata;
    allstepdata = allstepdata - minstepdata;
    
    maxstepdata = max(allstepdata);
    normstepdir1_voltagedata(j, :) = normstepdir1_voltagedata(j, :)./maxstepdata;
    normstepdir2_voltagedata(j, :) = normstepdir2_voltagedata(j, :)./maxstepdata;
    
end

subplot(2, 1, 1)
hold on
plot(allsampletimes(1, :), mean(allavgvoltages), 'k', 'LineWidth', 1.5)

subplot(2, 1, 2)
hold on
plot(avg_angletimes(1, :), mean(avg_legangles), 'k', 'LineWidth', 1.5)

% export_fig(fig1,[dataDir, '10B_flexfirst_rampandhold_summary.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');


%% plot data from individual steps
% for j = 1:nflies
%     fig1 = figure;
%     plot(allsampletimes(j, :), allavgvoltages(j, :), 'k', 'LineWidth', 1.5)
%     
%     fig2 = figure; hold on;
%     plot(stepdir1_angledata(j, 1:11), normstepdir1_voltagedata(j, 1:11), 'b.-')
%     plot(stepdir2_angledata(j, 1:11), normstepdir2_voltagedata(j, 1:11), 'r.-')
%     plot(stepdir1_angledata(j, 12:end), normstepdir1_voltagedata(j, 12:end), 'b.-')
%     plot(stepdir2_angledata(j, 12:end), normstepdir2_voltagedata(j, 12:end), 'r.-')
%     
%     title(dataFiles(j).name, 'Interpreter', 'none')
%     
%     export_fig(fig2,[dataDir fileTag(1:3) '_' num2str(j) '_extfirst_hysteresis.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');
% end

% %% plot voltage vs leg angle
fig3 = figure; hold on;
% plot(stepdir1_angledata(:, 1:11)', normstepdir1_voltagedata(:, 1:11)', 'b.-')
% plot(stepdir2_angledata(:, 1:11)', normstepdir2_voltagedata(:, 1:11)', 'r.-')

%calculate and plot errors for plot envelope, currently using standard
%error
blueerrors = nanstd(normstepdir1_voltagedata(:, 1:11))./sqrt(nflies);
rederrors = nanstd(normstepdir2_voltagedata(:, 1:11))./sqrt(nflies);

h_blue = fill([nanmean(stepdir1_angledata(:, 1:11)), fliplr(nanmean(stepdir1_angledata(:, 1:11)))],...
    [nanmean(normstepdir1_voltagedata(:, 1:11))+blueerrors, fliplr(nanmean(normstepdir1_voltagedata(:, 1:11))-blueerrors)],...
    [0,0,0.8], 'EdgeColor','none');
set(h_blue,'facealpha',.2);

h_red = fill([nanmean(stepdir2_angledata(:, 1:11)), fliplr(nanmean(stepdir2_angledata(:, 1:11)))],...
    [nanmean(normstepdir2_voltagedata(:, 1:11))+rederrors, fliplr(nanmean(normstepdir2_voltagedata(:, 1:11))-rederrors)],...
    [0.8,0,0], 'EdgeColor','none');
set(h_red,'facealpha',.2);

plot(nanmean(stepdir1_angledata(:, 1:11)), nanmean(normstepdir1_voltagedata(:, 1:11)), 'b.-')
plot(nanmean(stepdir2_angledata(:, 1:11)), nanmean(normstepdir2_voltagedata(:, 1:11)), 'r.-')

xlabel('tibia position (deg)')
ylabel('normalized steady state amplitude')

% export_fig(fig3,[dataDir, '10B_preMLAextfirst_hysteresissummary.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');

%% plot difference (in mV) between two directions of movement
% 1 step at end of each direction doesn't directly correlate, then must
% flip lr

% stepdir1_voltagedata_forsubtraction = normstepdir1_voltagedata(:, 1:10);
% stepdir1_angledata_forsubtraction = stepdir1_angledata(:, 1:10);
% stepdir2_voltagedata_forsubtraction = fliplr(normstepdir2_voltagedata(:, 1:10));
% stepdir2_angledata_forsubtraction = fliplr(stepdir2_angledata(:, 1:10));
% 
% stepdiff = abs(stepdir1_voltagedata_forsubtraction - stepdir2_voltagedata_forsubtraction);
% avg_stepdiff = nanmean(stepdiff);
% sd_errors = nanstd(stepdiff)./sqrt(nflies);
% 
% fig4 = figure; hold on;
% 
% h_sd = fill([nanmean(stepdir2_angledata_forsubtraction), fliplr(nanmean(stepdir2_angledata_forsubtraction))],...
%     [avg_stepdiff+sd_errors, fliplr(avg_stepdiff-sd_errors)],[0.8,0,0], 'EdgeColor','none');
% set(h_sd,'facealpha',.2);
% % plot(stepdir2_angledata_forsubtraction', stepdiff', 'k.')
% plot(nanmean(stepdir2_angledata_forsubtraction), avg_stepdiff, 'r.-')


% export_fig(fig4,[dataDir fileTag(1:3), '_extfirst_diffhysteresis.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');

% fig5 = figure;
% plot(stepdir2_angledata_forsubtraction', stepdiff_mV')
% % export_fig(fig5,[dataDir fileTag(1:3), '_flexfirst_hysteresis_mVdiff.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');



