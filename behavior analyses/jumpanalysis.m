%% 4.13.2020 script to analyze jumping data
% plot 1: number of jumps per fly for each of two genotypes

clearvars

dataDir = 'C:\Users\swetarr\Documents\MATLAB\behavior gui files\';
fileTag1 = '10B';
fileTag2 = 'SH';

%% reformat data so that it is a 3D matrix of 1 (jump) and 0 (no jump)
% dim 1: condition, dim 2: reps, dim 3: flies
dataFiles = dir([dataDir, fileTag1, '*response data.mat']);
GenoA_cell = load([dataDir, dataFiles.name]);
GenoA_cell = GenoA_cell.ResponseData;

for i = 1:length(GenoA_cell)
    idx = strfind(GenoA_cell(i).behavior, 'jump');
    GenoA(:, :, i) = ~cellfun(@isempty, idx);
end

dataFiles = dir([dataDir, fileTag2, '*response data.mat']);
GenoB_cell = load([dataDir, dataFiles.name]);
GenoB_cell = GenoB_cell.ResponseData;

for i = 1:length(GenoB_cell)
    idx = strfind(GenoB_cell(i).behavior, 'jump');
    GenoB(:, :, i) = ~cellfun(@isempty, idx);
end

%% make plot of #jumps per fly for each genotype, ignoring condition
totaljumps{1} = squeeze(sum(sum(GenoA)));
totaljumps{2} = squeeze(sum(sum(GenoB)));

figure
hold on

for i = 1:2
   xnoise = .05*randn(1, length(totaljumps{i}));
   plot(xnoise+i, totaljumps{i}, '.', 'MarkerSize', 10, 'MarkerEdgeColor', 'k')
   
   line([i - 0.1, i + 0.1], [mean(totaljumps{i}), mean(totaljumps{i})]);
end

xlim([0, 3])



    
