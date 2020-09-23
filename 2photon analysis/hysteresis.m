%% plot hysteresis for gcamp data 2020/09/01

% for now, just using a single ramp and hold from each fly

clear all

fileTag = 'not13e04';
dataDir = 'E:\Sweta to backup\2 photon data\not13e04LexA\ramp and hold\';

DffFiles = dir([dataDir, fileTag, '*extfirst_rampandhold01*SelectROICalculateDFF.mat']);
AngleFiles = dir([dataDir, fileTag, '*extfirst_rampandhold01*AngleforImagingFrame.mat']);
TimingFiles = dir([dataDir, fileTag, '*extfirst_rampandhold01*DetectCameraAndImagingFrames.mat']);

if length(DffFiles) ~= length(AngleFiles)||length(DffFiles) ~= length(TimingFiles)
    error('mismatch in file number')
end

%for finding avg potential at step
secstart = 1.5;
secend = 2.5;
nsteps = 18;
%%
nflies = length(DffFiles)

for i = 1:nflies
    load([dataDir, DffFiles(i).name]);
    load([dataDir, AngleFiles(i).name]);
    load([dataDir, TimingFiles(i).name]);
    
    stepstart_I = StartIF(:, 1);
    stepstart_V = StartVF(:, 1);
     
    CameraRate = 20000./mean(CameraInterval);
    ImagingRate = 20000./mean(ImageInterval);
    
    legangles = [];
    mean_norm_DFFs = [];
    for j = 1:nsteps
        all_legangles(i, j) = mean(RealAngle((stepstart_V(j)+secstart*CameraRate):(stepstart_V(j)+secend*CameraRate)));
        all_mean_norm_DFFs(i, j) = mean(DFF1((stepstart_I(j)+secstart*ImagingRate):(stepstart_I(j)+secend*ImagingRate)))./max(DFF1);
    end
    
end

%%
fig1 = figure;
hold on

for i = 1:nflies
    plot(all_legangles(i, 1:9), all_mean_norm_DFFs(i, 1:9), 'k.-')
    plot(all_legangles(i, 10:end), all_mean_norm_DFFs(i, 10:end), 'r.-')
end

plot(mean(all_legangles(:, 1:9)), mean(all_mean_norm_DFFs(:, 1:9)), 'k.-', 'LineWidth', 2)
plot(mean(all_legangles(:, 10:end)), mean(all_mean_norm_DFFs(:, 10:end)), 'r.-', 'LineWidth', 2)

yticks([0, 0.25, 0.5, 0.75, 1])
xticks([0, 45, 90, 135, 180])
box off
set(gcf,'color','white')

% export_fig(fig1,[dataDir, fileTag, '_extfirst_steps.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');

%%
fig2 = figure;
hold on

for i = 1:nflies
    hysteresis_diff(i, :) = all_mean_norm_DFFs(i, 1:8) - fliplr(all_mean_norm_DFFs(i, 10:17));
    plot(all_legangles(i, 1:8), hysteresis_diff(i, :), 'k.-')
end

plot(mean(all_legangles(:, 1:8)), mean(hysteresis_diff), 'k.-', 'LineWidth', 2)

h_error = std(hysteresis_diff)./sqrt(nflies);

h_sd = fill([mean(all_legangles(:, 1:8)), fliplr(mean(all_legangles(:, 1:8)))],...
    [mean(hysteresis_diff)+h_error, fliplr(mean(hysteresis_diff)-h_error)],[0,0,0], 'EdgeColor','none');
set(h_sd,'facealpha',.2);

box off
set(gcf,'color','white')
xlim([0, 180])
xticks([0, 45, 90, 135, 180])
ylim([-0.8, 0.2])
yticks([-0.8, -0.6, -0.4, -0.2, 0, 0.2])


export_fig(fig2,[dataDir, fileTag, '_extfirst_hysteresis.pdf'], '-pdf','-nocrop', '-r600' , '-painters', '-rgb');