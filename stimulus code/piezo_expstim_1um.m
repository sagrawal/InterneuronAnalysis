%script that runs through all the piezo stim
% 3 repetitions per stim, each 4 seconds long with 8 sec in between
% apply the following scale factors (determined via trial and error 10/11/18:

% ScaleFactor 
% @ 1 um: 1.4992 for 10hz, 1.7 for 100hz, 2.3 for 200hz, 4.28 for
% 400hz, 12 for 800hz, 30 for 1200 hz (not quite as high an amplitude)

% @ .1 um: 1.12 for 100hz, 1.5 for 200hz, 2.83 for 400hz, 7.7 for 800hz,
% 16.35 for 1200hz, 36.7 for 1600hz, 73 for 2000 hz

% @ .05 um: 1 for 100hz, 200hz, 400hz, 2.75 for 800hz, 8.75 for 1200hz, 14.85 for 1600hz, 44
% for 2000hz

% freqs = [100, 200, 400, 800, 1200, 1600, 2000];
freqs = [200, 400, 800, 1200, 1600, 2000];
% sf1 = [1.7, 2.3, 4.28, 12, 30, NaN, NaN];
sf1 = [2.3, 4.28, 12, 30, NaN, NaN];

%% 1um

tic

for i = 1:length(freqs)
    freqs(i)
    if isnan(sf1(i))
    else
        PiezoCommand_microns(8,4,8,1*sf1(i),freqs(i),3)
    end
end

elapsedtime = toc