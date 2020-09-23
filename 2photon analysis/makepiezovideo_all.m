function []=makepiezovideo_all(FileTag,LowI,HighI)

a = dir([FileTag, '*.tif']);
length(a)

for i = [1:length(a)]
    makepiezovideo(a(i).name(1:end-4), LowI, HighI);
end

clear
