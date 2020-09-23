%% analyze swing data
% will only consider data from fast swings (first three swings generally)
clearvars

dataDir = 'G:\My Drive\Sweta to backup\ephysdata\13B recordings\diffpotswings\';

fileTag1 = '13b_29*_diffpotswings_RMP04_*WithSwingOnsetCorr.mat';
dataFile1 = dir([dataDir, fileTag1]);
fileTag2 = '13b_29*_diffpotswings_neg60*WithSwingOnsetCorr.mat';
dataFile2 = dir([dataDir, fileTag2]);
fileTag3 = '13b_29*_diffpotswings_neg10*WithSwingOnsetCorr.mat';
dataFile3 = dir([dataDir, fileTag3]);

extfirst = 1; %change to 0 if starting with flexion first

secondsbefore = 1;
secondsafter = 1;

nfastswing = 3;

%% load RMP data
rmp = load([dataDir, dataFile1(1).name]);

RMPframesbefore = floor(secondsbefore*rmp.FrameRate); %number of frames worth of data included pre-swing
RMPframesafter = floor(secondsafter*rmp.FrameRate); %amount of frames worth of data included post-swing

RMPswing_on = rmp.swingstarts(1:3); %in terms of frame # from leg video
RMPswing_off = rmp.swingends(1:3);

[nframes, idx] = min(rmp.frame_on(RMPswing_off) - rmp.frame_on(RMPswing_on));
for i = 1:nfastswing
    RMPswing_sampletime{i} = (rmp.frame_on(RMPswing_on(i))/rmp.SampleRate-secondsbefore):(1/rmp.SampleRate):((rmp.frame_on(RMPswing_on(i))+nframes)/rmp.SampleRate+secondsafter);
    RMPswing_sampletime{i} = RMPswing_sampletime{i}-RMPswing_sampletime{i}(1);
    
    RMPtrialstart(i) = rmp.frame_on(RMPswing_on(i))-(RMPframesbefore/rmp.FrameRate)*rmp.SampleRate; %in terms of samples (aka voltagedata timestep)
    RMPtrialend(i) = rmp.frame_on(RMPswing_on(i))+nframes+(RMPframesafter/rmp.FrameRate)*rmp.SampleRate; %in terms of samples (aka voltagedata timestep)
    
    preswing_mempot(2) = mean(rmp.voltagedata((rmp.frame_on(RMPswing_on(i))-(RMPframesbefore/rmp.FrameRate)*rmp.SampleRate):rmp.frame_on(RMPswing_on(i))));
    RMPswing_voltagedata(i, :) = (rmp.voltagedata(RMPtrialstart(i):RMPtrialend(i))-(preswing_mempot(2)));
    
    RMPswing_angletime{i} = rmp.frame_on((RMPswing_on(i)-RMPframesbefore):(RMPswing_off(i)+RMPframesafter))./rmp.SampleRate;
    RMPswing_angletime{i} = RMPswing_angletime{i}-RMPswing_angletime{i}(1);
    
end


%% load hyperpolarized data
hyp = load([dataDir, dataFile2(1).name]);

HYPframesbefore = secondsbefore*hyp.FrameRate; %number of frames worth of data included pre-swing
HYPframesafter = secondsafter*hyp.FrameRate; %amount of frames worth of data included post-swing

HYPswing_on = hyp.swingstarts(1:3); %in terms of frame # from leg video
HYPswing_off = hyp.swingends(1:3);

[nframes, idx] = min(hyp.frame_on(HYPswing_off) - hyp.frame_on(HYPswing_on));
for i = 1:nfastswing
    HYPswing_sampletime{i} = (hyp.frame_on(HYPswing_on(i))/hyp.SampleRate-secondsbefore):(1/hyp.SampleRate):((hyp.frame_on(HYPswing_on(i))+nframes)/hyp.SampleRate+secondsafter);
    HYPswing_sampletime{i} = HYPswing_sampletime{i}-HYPswing_sampletime{i}(1);
    
    HYPtrialstart(i) = hyp.frame_on(HYPswing_on(i))-(HYPframesbefore/hyp.FrameRate)*hyp.SampleRate; %in terms of samples (aka voltagedata timestep)
    HYPtrialend(i) = hyp.frame_on(HYPswing_on(i))+nframes+(HYPframesafter/hyp.FrameRate)*hyp.SampleRate; %in terms of samples (aka voltagedata timestep)
    
    preswing_mempot(1) = mean(hyp.voltagedata((hyp.frame_on(HYPswing_on(i))-(HYPframesbefore/hyp.FrameRate)*hyp.SampleRate):hyp.frame_on(HYPswing_on(i))));
    HYPswing_voltagedata(i, :) = (hyp.voltagedata(HYPtrialstart(i):HYPtrialend(i))-preswing_mempot(1));
    
    HYPswing_angletime{i} = hyp.frame_on((HYPswing_on(i)-HYPframesbefore):(HYPswing_off(i)+HYPframesafter))./hyp.SampleRate;
    HYPswing_angletime{i} = HYPswing_angletime{i}-HYPswing_angletime{i}(1);
end

%% load depolarized data
dep = load([dataDir, dataFile3(1).name]);

DEPframesbefore = secondsbefore*dep.FrameRate; %number of frames worth of data included pre-swing
DEPframesafter = secondsafter*dep.FrameRate; %amount of frames worth of data included post-swing

DEPswing_on = dep.swingstarts(1:3); %in terms of frame # from leg video
DEPswing_off = dep.swingends(1:3);

[nframes, idx] = min(dep.frame_on(DEPswing_off) - dep.frame_on(DEPswing_on));
for i = 1:nfastswing
    DEPswing_sampletime{i} = (dep.frame_on(DEPswing_on(i))/dep.SampleRate-secondsbefore):(1/dep.SampleRate):((dep.frame_on(DEPswing_on(i))+nframes)/dep.SampleRate+secondsafter);
    DEPswing_sampletime{i} = DEPswing_sampletime{i}-DEPswing_sampletime{i}(1);
    
    DEPtrialstart(i) = dep.frame_on(DEPswing_on(i))-(DEPframesbefore/dep.FrameRate)*dep.SampleRate; %in terms of samples (aka voltagedata timestep)
    DEPtrialend(i) = dep.frame_on(DEPswing_on(i))+nframes+(DEPframesafter/dep.FrameRate)*dep.SampleRate; %in terms of samples (aka voltagedata timestep)
    
    preswing_mempot(3) = mean(dep.voltagedata((dep.frame_on(DEPswing_on(i))-(DEPframesbefore/dep.FrameRate)*dep.SampleRate):dep.frame_on(DEPswing_on(i))));
    DEPswing_voltagedata(i, :) = (dep.voltagedata(DEPtrialstart(i):DEPtrialend(i))-(preswing_mempot(3)));
    
    DEPswing_angletime{i} = dep.frame_on((DEPswing_on(i)-DEPframesbefore):(DEPswing_off(i)+DEPframesafter))./dep.SampleRate;
    DEPswing_angletime{i} = DEPswing_angletime{i}-DEPswing_angletime{i}(1);
end


%% plot mean potentials on graph altogether
% fig1 = figure;
% hold on
% 
% g = subplot(2, 1, 1);
% hold on
% 
% plot(RMPswing_sampletime{1}, mean(RMPswing_voltagedata), 'k')
% plot(HYPswing_sampletime{1}, mean(HYPswing_voltagedata), 'g')
% plot(DEPswing_sampletime{1}, mean(DEPswing_voltagedata), 'b')
% 
% % ylim([-12, 5]);
% title(fileTag1(1:end-25), 'Interpreter', 'None')
% 
% g = subplot(2, 1, 2);
% hold on
% plot(RMPswing_angletime{1}, rmp.legangles((RMPswing_on(1)-RMPframesbefore):(RMPswing_off(1)+RMPframesafter)), 'k');
% plot(HYPswing_angletime{1}, hyp.legangles((HYPswing_on(1)-HYPframesbefore):(HYPswing_off(1)+HYPframesafter)), 'g');
% plot(DEPswing_angletime{1}, dep.legangles((DEPswing_on(1)-DEPframesbefore):(DEPswing_off(1)+DEPframesafter)), 'b');

% ylim(legangle_ylim);



% export_fig(fig1,[dataDir fileTag1(1:6) '_diffpotsummary.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');

%% plot integral of response half second after flexion/extension movements, with half second gap during movement phase
avg_voltages{1} = mean(HYPswing_voltagedata);
avg_voltages{2} = mean(RMPswing_voltagedata);
avg_voltages{3} = mean(DEPswing_voltagedata);

%absolute value of mV amplitude due to swing

fig2 = figure;
fig3 = figure;

for i = 1:3
    flx_preswing(i) = mean(avg_voltages{i}(1:(secondsbefore*rmp.SampleRate)));
    flx_postswing(i) = mean(avg_voltages{i}(((secondsbefore+0.5)*rmp.SampleRate):((secondsbefore+1)*rmp.SampleRate)));
    flx_swing_amp(i) = abs(flx_postswing(i)-flx_preswing(i));
    
    ext_preswing(i) = mean(avg_voltages{i}((end-(secondsafter+secondsafter)*rmp.SampleRate):(end-secondsafter*rmp.SampleRate)));
    ext_postswing(i) = mean(avg_voltages{i}((end-((secondsafter-0.5)*rmp.SampleRate)):(end-(secondsafter-1)*rmp.SampleRate)));
    ext_swing_amp(i) = abs(ext_postswing(i)-ext_preswing(i));
end

 figure(fig2)
 hold on
 plot(preswing_mempot, flx_swing_amp, '.-')
 xlabel('membrane potential')
 ylabel('amplitude of flexion response')
 ylim([1, 15])
 xlim([-70, 0])
 export_fig(fig2,[dataDir fileTag1(1:6) '_flexionamp02.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');
 
 figure(fig3)
 hold on
 plot(preswing_mempot, ext_swing_amp, '.-')
 ylabel('amplitude of extension response')
 ylim([1, 15])
 xlim([-70, 0])
 xlabel('membrane potential')
 export_fig(fig3,[dataDir fileTag1(1:6) '_extensionamp02.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');


% %integral of data
% for i = 1:3
%     flxint(i) = trapz(avg_voltages{i}(1, (secondsbefore*rmp.SampleRate):((secondsbefore+0.5)*rmp.SampleRate)));
%     extint(i) = trapz(avg_voltages{i}(1, (end-(secondsafter*rmp.SampleRate)):(end-((secondsafter-0.5)*rmp.SampleRate))));
% end
% 
% fig2 = figure
% hold on
% 
% plot(flxint, 'r.--', 'MarkerSize', 20)
% plot(extint, 'b.--', 'MarkerSize', 20)

% title(fileTag1(1:end-25), 'Interpreter', 'None')
% 
% xlim([0.5, 3.5])
% ax = gca;
% ax.XTick = [1:3];
% ax.XTickLabel = {'hyp', 'RMP', 'dep'};

% export_fig(fig2,[dataDir fileTag1(1:6) '_diffpotintegral.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');