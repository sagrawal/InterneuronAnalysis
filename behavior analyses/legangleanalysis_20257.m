%% 4/21/20 code to look at leg angle before/after 720 ms of 7V light (or no light) in 9A flies -- 20257
% 5/30 added Evyn's bootstrapping analysis

% relevant frames are 150 for the start and 369 for the end
% two types of data: one set of flies that only received 4 stimulations,
% and 1 set of flies that received 6 stimulations

clearvars
% dataDir = '/Volumes/Evyn SSD/Evyn UW work/9A data/9A data/';
dataDir = 'C:\Users\swetarr\Documents\MATLAB\behavior gui files\';
fileTag = '9A-20257*onball';
dataFiles = dir([dataDir, fileTag, '*tracking data.mat']);

%% first we'll pull out data from the 4 stim flies data set
load([dataDir, dataFiles(2).name])
nflies = length(tracking);

bframen = 150;
aframen = 369;
nrep = 4;

for i = 1:nflies
    for j = 1:nrep       
        if isempty(tracking(i).Left_Front(j*7-6, 1).frame(bframen).CoFe)
            tracking(i).Left_Front(j*7-6, 1).frame(bframen).CoFe = NaN;
            tracking(i).Left_Front(j*7-6, 1).frame(aframen).CoFe = NaN;
            tracking(i).Left_Front(j*7-6, 1).frame(bframen).FeTi = NaN;
            tracking(i).Left_Front(j*7-6, 1).frame(aframen).FeTi = NaN;
            tracking(i).Left_Front(j*7-6, 1).frame(bframen).TiTa = NaN;
            tracking(i).Left_Front(j*7-6, 1).frame(aframen).TiTa = NaN;
        elseif isempty(tracking(i).Left_Front(j*7-1, 1).frame(bframen).CoFe)
            tracking(i).Left_Front(j*7-1, 1).frame(bframen).CoFe = NaN;
            tracking(i).Left_Front(j*7-1, 1).frame(aframen).CoFe = NaN;
            tracking(i).Left_Front(j*7-1, 1).frame(bframen).FeTi = NaN;
            tracking(i).Left_Front(j*7-1, 1).frame(aframen).FeTi = NaN;
            tracking(i).Left_Front(j*7-1, 1).frame(bframen).TiTa = NaN;
            tracking(i).Left_Front(j*7-1, 1).frame(aframen).TiTa = NaN;
        end     
        
        nolight_before_CoFe(i, j) = tracking(i).Left_Front(j*7-6, 1).frame(bframen).CoFe;
        nolight_after_CoFe(i, j) = tracking(i).Left_Front(j*7-6, 1).frame(aframen).CoFe;
        light_before_CoFe(i, j) = tracking(i).Left_Front(j*7-1, 1).frame(bframen).CoFe;
        light_after_CoFe(i, j) = tracking(i).Left_Front(j*7-1, 1).frame(aframen).CoFe;
        
        nolight_before_FeTi(i, j) = tracking(i).Left_Front(j*7-6, 1).frame(bframen).FeTi;
        nolight_after_FeTi(i, j) = tracking(i).Left_Front(j*7-6, 1).frame(aframen).FeTi;
        light_before_FeTi(i, j) = tracking(i).Left_Front(j*7-1, 1).frame(bframen).FeTi;
        light_after_FeTi(i, j) = tracking(i).Left_Front(j*7-1, 1).frame(aframen).FeTi;
        
        nolight_before_TiTa(i, j) = tracking(i).Left_Front(j*7-6, 1).frame(bframen).TiTa;
        nolight_after_TiTa(i, j) = tracking(i).Left_Front(j*7-6, 1).frame(aframen).TiTa;
        light_before_TiTa(i, j) = tracking(i).Left_Front(j*7-1, 1).frame(bframen).TiTa;
        light_after_TiTa(i, j) = tracking(i).Left_Front(j*7-1, 1).frame(aframen).TiTa;
    end    

end




%% pull out data from the other 6 stim flies: 4 reps of 7 but 6/7 are the same light condition
load([dataDir, dataFiles(1).name])
nflies = length(tracking);

bframen = 150;
aframen = 369;
nrep = 4;
light_on = [0, ones(1, 6)];

for i = 1:nflies
    for j = 1:nrep
        for k = 1:length(light_on)
            
            if isempty(tracking(i).Left_Front((j-1)*7+k).frame(bframen).CoFe)
%                 'empty'
                tracking(i).Left_Front((j-1)*7+k).frame(bframen).CoFe = NaN;
                tracking(i).Left_Front((j-1)*7+k).frame(aframen).CoFe = NaN;
                tracking(i).Left_Front((j-1)*7+k).frame(bframen).FeTi = NaN;
                tracking(i).Left_Front((j-1)*7+k).frame(aframen).FeTi = NaN;
                tracking(i).Left_Front((j-1)*7+k).frame(bframen).TiTa = NaN;
                tracking(i).Left_Front((j-1)*7+k).frame(aframen).TiTa = NaN;
            end
            
            if light_on(k) == 0
                nolight_before_CoFe_2(i, j) = tracking(i).Left_Front((j-1)*7+k).frame(bframen).CoFe;
                nolight_after_CoFe_2(i, j) = tracking(i).Left_Front((j-1)*7+k).frame(aframen).CoFe;
                nolight_before_FeTi_2(i, j) = tracking(i).Left_Front((j-1)*7+k).frame(bframen).FeTi;
                nolight_after_FeTi_2(i, j) = tracking(i).Left_Front((j-1)*7+k).frame(aframen).FeTi;
                nolight_before_TiTa_2(i, j) = tracking(i).Left_Front((j-1)*7+k).frame(bframen).TiTa;
                nolight_after_TiTa_2(i, j) = tracking(i).Left_Front((j-1)*7+k).frame(aframen).TiTa;
                
            elseif light_on(k) == 1
                light_before_CoFe_2(i, (j-1)*6+k-1) = tracking(i).Left_Front((j-1)*7+k).frame(bframen).CoFe;
                light_after_CoFe_2(i, (j-1)*6+k-1) = tracking(i).Left_Front((j-1)*7+k).frame(aframen).CoFe;
                light_before_FeTi_2(i, (j-1)*6+k-1) = tracking(i).Left_Front((j-1)*7+k).frame(bframen).FeTi;
                light_after_FeTi_2(i, (j-1)*6+k-1) = tracking(i).Left_Front((j-1)*7+k).frame(aframen).FeTi;
                light_before_TiTa_2(i, (j-1)*6+k-1) = tracking(i).Left_Front((j-1)*7+k).frame(bframen).TiTa;
                light_after_TiTa_2(i, (j-1)*6+k-1) = tracking(i).Left_Front((j-1)*7+k).frame(aframen).TiTa;
            end
        end
    end
end


%% make a plot of change in angle averaged per fly

% first calculate the change in joint angle
nolight_change_CoFe = nolight_after_CoFe - nolight_before_CoFe;
nolight_change_CoFe_2 = nolight_after_CoFe_2 - nolight_before_CoFe_2;
light_change_CoFe = light_after_CoFe - light_before_CoFe;
light_change_CoFe_2 = light_after_CoFe_2 - light_before_CoFe_2;

% % find the change in joint angle for each trial and then bootstrap
% % CONTROL (no laser)
% CONTROL(1).pre = [(nolight_before_CoFe); nolight_before_CoFe_2];
% CONTROL(1).post = [nolight_after_CoFe; nolight_after_CoFe_2];
% 
% CONTROL(2).pre = [nolight_before_FeTi; nolight_before_FeTi_2];
% CONTROL(2).post = [nolight_after_FeTi; nolight_after_FeTi_2];
% 
% CONTROL(3).pre = [nolight_before_TiTa; nolight_before_TiTa_2];
% CONTROL(3).post = [nolight_after_TiTa; nolight_after_TiTa_2];
% % STIM (with light)
% STIM(1).pre = [light_before_CoFe; light_before_CoFe_2];
% STIM(1).post = [light_after_CoFe; light_after_CoFe_2];
% 
% STIM(2).pre = [light_before_FeTi; light_before_FeTi_2];
% STIM(2).post = [light_after_FeTi; light_after_FeTi_2];
% 
% STIM(3).pre = [light_before_TiTa; light_before_TiTa_2];
% STIM(3).post = [light_after_TiTa; light_after_TiTa_2];


% NEED THE CHANGE

nolight_change_FeTi = nolight_after_FeTi - nolight_before_FeTi;
nolight_change_FeTi_2 = nolight_after_FeTi_2 - nolight_before_FeTi_2;
light_change_FeTi = light_after_FeTi - light_before_FeTi;
light_change_FeTi_2 = light_after_FeTi_2 - light_before_FeTi_2;

nolight_change_TiTa = nolight_after_TiTa - nolight_before_TiTa;
nolight_change_TiTa_2 = nolight_after_TiTa_2 - nolight_before_TiTa_2;
light_change_TiTa = light_after_TiTa - light_before_TiTa;
light_change_TiTa_2 = light_after_TiTa_2 - light_before_TiTa_2;


% then average
avgchange_nolight_CoFe = [nanmean(nolight_change_CoFe, 2); nanmean(nolight_change_CoFe_2, 2)];
avgchange_light_CoFe = [nanmean(light_change_CoFe, 2); nanmean(light_change_CoFe_2, 2)];

avgchange_nolight_FeTi = [nanmean(nolight_change_FeTi, 2); nanmean(nolight_change_FeTi_2, 2)];
avgchange_light_FeTi = [nanmean(light_change_FeTi, 2); nanmean(light_change_FeTi_2, 2)];

avgchange_nolight_TiTa = [nanmean(nolight_change_TiTa, 2); nanmean(nolight_change_TiTa_2, 2)];
avgchange_light_TiTa = [nanmean(light_change_TiTa, 2); nanmean(light_change_TiTa_2, 2)];

%% then plot!
figure

subplot(1, 3, 1)
hold on
plot([1, 2], [avgchange_nolight_CoFe';avgchange_light_CoFe'], '.-', 'MarkerSize', 10)
xlim([0.75, 2.25])
ylim([-15, 25])
title('CoFe')
xticks([1, 2])
xticklabels({'no light' 'light'})
ylabel('degrees')

subplot(1, 3, 2)
hold on
plot([1, 2], [avgchange_nolight_FeTi';avgchange_light_FeTi'], '.-', 'MarkerSize', 10)
xlim([0.75, 2.25])
ylim([-15, 25])
title('FeTi')
xticks([1, 2])
xticklabels({'no light' 'light'})

subplot(1, 3, 3)
hold on
plot([1, 2], [avgchange_nolight_TiTa';avgchange_light_TiTa'], '.-', 'MarkerSize', 10)
xlim([0.75, 2.25])
ylim([-15, 25])
title('TiTa')
xticks([1, 2])
xticklabels({'no light' 'light'})

%% make a plot of change in angle not averaged per fly

% first rearrange matrices for change in joint angle, remove all NaN
all_nolight_change_CoFe = [reshape(nolight_change_CoFe, [1, numel(nolight_change_CoFe)]), reshape(nolight_change_CoFe_2, [1, numel(nolight_change_CoFe_2)])];
all_nolight_change_CoFe(isnan(all_nolight_change_CoFe)) = [];
all_nolight_change_FeTi = [reshape(nolight_change_FeTi, [1, numel(nolight_change_FeTi)]), reshape(nolight_change_FeTi_2, [1, numel(nolight_change_FeTi_2)])];
all_nolight_change_FeTi(isnan(all_nolight_change_FeTi)) = [];
all_nolight_change_TiTa = [reshape(nolight_change_TiTa, [1, numel(nolight_change_TiTa)]), reshape(nolight_change_TiTa_2, [1, numel(nolight_change_TiTa_2)])];
all_nolight_change_TiTa(isnan(all_nolight_change_TiTa)) = [];

all_light_change_CoFe = [reshape(light_change_CoFe, [1, numel(light_change_CoFe)]), reshape(light_change_CoFe_2, [1, numel(light_change_CoFe_2)])];
all_light_change_CoFe(isnan(all_light_change_CoFe)) = [];
all_light_change_FeTi = [reshape(light_change_FeTi, [1, numel(light_change_FeTi)]), reshape(light_change_FeTi_2, [1, numel(light_change_FeTi_2)])];
all_light_change_FeTi(isnan(all_light_change_FeTi)) = [];
all_light_change_TiTa = [reshape(light_change_TiTa, [1, numel(light_change_TiTa)]), reshape(light_change_TiTa_2, [1, numel(light_change_TiTa_2)])];
all_light_change_TiTa(isnan(all_light_change_TiTa)) = [];


%% RELEVANT VALUES

%data not grouped by fly
all_nolight_change_CoFe;
all_nolight_change_FeTi;
all_nolight_change_TiTa;

all_light_change_CoFe;
all_light_change_FeTi;
all_light_change_TiTa;

%data grouped by fly
avgchange_nolight_CoFe;
avgchange_nolight_FeTi;
avgchange_nolight_TiTa;

avgchange_light_CoFe;
avgchange_light_FeTi;
avgchange_light_TiTa;

%% Rearrange the data (in order to bootstrap)
% % CoFe joint angle data
JA(1).controlNum = length(avgchange_nolight_CoFe);
JA(1).control = avgchange_nolight_CoFe';
JA(1).stimNum = length(avgchange_light_CoFe);
JA(1).stim = avgchange_light_CoFe';

% % FeTi joint angle data
JA(2).controlNum = length(avgchange_nolight_FeTi);
JA(2).control = avgchange_nolight_FeTi';
JA(2).stimNum = length(avgchange_light_FeTi);
JA(2).stim = avgchange_light_FeTi';

% TiTa joint angle data
JA(3).controlNum = length(avgchange_nolight_TiTa);
JA(3).control = avgchange_nolight_TiTa';
JA(3).stimNum = length(avgchange_light_TiTa);
JA(3).stim = avgchange_light_TiTa';

% Bootstrap the data:
% find the original difference in the change in joint angle between the
% control trial and the stimulus trials:
Joints = {'CoFe', 'FeTi', 'TiTa'};
fig = figure;
for iJoint = 1:3
    stats(iJoint).OG_diff = nanmean(JA(iJoint).stim) - nanmean(JA(iJoint).control);
end

% randomly assign the inital change in joint angle data and select a new
% distribution
N = 10E3;
% combine the control (no laser) and stim (laser) data
for iJ = 1:3
    mixed_data = [JA(iJ).control, JA(iJ).stim];
    test = [];
    cNum = JA(iJ).controlNum;
    sNum = JA(iJ).stimNum;
    
  for n = 1:N

    % draw 'new' data:
    randLoc = randperm(cNum+sNum);
    C_loc = randLoc(1:cNum);
%     randLoc = randperm(cNum+sNum); % with replacement
    S_loc = randLoc(cNum+1:end);
    
    % calc the change in speed for the control:
    a = [];
    a = mixed_data(:,C_loc);
    diff = nanmean(a);
    test.C(n) = diff;
    
    % calc the change in speed for IN:
    a = [];
    a = mixed_data(:,S_loc);
    diff = nanmean(a);
    test.S(n) = diff;
    % calc the diff between SH and IN:
    test.diff(n) = test.S(n)-test.C(n);
  end
  % 'save' the data into the test struct
    stats(iJ).distrb = test;
    rdistrb = test.diff;
    subplot(1,3,iJ); hold all
    histogram(rdistrb)
    vline(stats(iJ).OG_diff, 'r-')
    p = sum(abs(rdistrb)>=abs(stats(iJ).OG_diff))/length(rdistrb);
    disp(p);
    title({['Joint: ' Joints{iJ}]; ['p = ' num2str(p)]})
    stats(iJ).p = p;
end

% save(fig, ['/Volumes/Evyn SSD/Evyn UW work/matlabroot/' fileTag(4:8) ' 10E3 bootstrap distb']);

% multiple comparisons test:
for iJ = 1:3
    p_val(iJ) = stats(iJ).p;
end
 p_err = p_val;
 [P_err,loc] = sort(p_err);
 fprintf('\n All:')
for idx = 1:length(p_val)
    q = (P_err((idx)) > 0.05/(length(P_err) +1 - idx));
    r = (P_err((idx)) > (idx/length(P_err))*.05);
    fprintf(['\nInsignificant change: ' num2str(q) ' vs ' num2str(r) ' Joint: ' Joints{loc(idx)}])
end
fprintf('\n Done\n')

% find the number of trials:
fprintf('\n N''s by trial')
for iJ = 1:3
    fprintf(['\n' Joints{iJ} ':'])
    fprintf(['\ncontrol trials: ' num2str(JA(iJ).controlNum)])
    fprintf(['\nstimulus trials: ' num2str(JA(iJ).stimNum)])
    fprintf(['\n p Value: ' num2str(p_val(iJ))])
end




