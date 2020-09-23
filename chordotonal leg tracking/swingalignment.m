%% script to align leg swings, 4/23/2019

clearvars

dataDir = 'E:\Sweta to backup\ephysdata\13B recordings\swings\';
fileTag = '13b_33_flexfirst_swings*WithSwingOnset.mat';
dataFiles = dir([dataDir, fileTag]);
extfirst = 0; %0 means leg starts flexed

nflies = length(dataFiles)

nrep = 6;
secbefore = 2;
secafter = 2;
flxthreshold = 0.92;
extthreshold = 0.05;

%% 
for j = 1:nflies
%     dataFiles(j).name
    load([dataDir, dataFiles(j).name]);
    swingstarts = LOCS(1:2:end);
    swingends = LOCS(2:2:end);
        
    for i = 1:nrep
        if swingstarts(i) < secbefore*FrameRate
            newswingstart(i) = swingstarts(i);
        else
            testdata = legangles((swingstarts(i)-(secbefore*FrameRate)):swingstarts(i)+(secafter*FrameRate));
            testdata = testdata - min(testdata);
            testdata = testdata./max(testdata);
            
            if extfirst == 1
                a = find(testdata<flxthreshold, 1);
            elseif extfirst == 0
                a = find(testdata>extthreshold, 1);
            end
            
            correction = 1+secbefore*FrameRate - a;
            newswingstart(i) = round(swingstarts(i)-correction);
        end

        testdata = legangles((swingends(i)-(secbefore*FrameRate)):swingends(i)+(secafter*FrameRate));
        testdata = testdata - min(testdata);
        testdata = testdata./max(testdata);
        
        if extfirst == 1
            a = find(testdata>extthreshold, 1);
        elseif extfirst == 0
            a = find(testdata<flxthreshold, 1);
        end
        
        correction = 1+secbefore*FrameRate - a;
        newswingend(i) = round(swingends(i)-correction);
        
    end
    
    swingstarts = newswingstart;
    swingends = newswingend;
    
    if ~logical(exist('currentinjectiondata', 'var'))
        currentinjectiondata = [];
    end
    
    if ~logical(exist('stimcommanddata', 'var'))
        stimcommanddata = [];
    end
            
    position=strfind(dataFiles(j).name,'.'); %gives the position of the period in the string FileName
    NewName=dataFiles(j).name(1:position-1);
    Outfile = strcat(NewName,'Corr');
    save([dataDir, Outfile], 'swingstarts', 'swingends','currentinjectiondata', 'frame_on', 'FrameRate', 'legangles', 'movieFiles', 'SampleRate', 'stimcommanddata', 'voltagedata')
        
end
     
           