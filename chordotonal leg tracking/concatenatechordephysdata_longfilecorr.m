%%match ephys data to leg tracking

clearvars;

voltagechannel = 1;
currentinjectionchannel = 3;
stimuluscommandchannel = 4;
piezosensorchannel = 5;
triggerchannel = 6;


%% init file and paths
abfDir = 'G:\My Drive\Sweta to backup\ephysdata\';
dataDir = 'G:\My Drive\Sweta to backup\ephysdata\';
movieDir = 'G:\My Drive\Sweta to backup\ephysdata\chordotonal stim videos\';
legtrackDir = 'G:\My Drive\Sweta to backup\ephysdata\chordotonal stim videos\';

fileTag = '04751_26_picro';
% FrameRate = 50;

abffileTag = [fileTag, '*.abf'];
dataFiles = dir([abfDir, abffileTag]);
size(dataFiles)

moviefileTag = [fileTag, '*.avi'];
movieFiles = dir([movieDir, moviefileTag]);
size(movieFiles)

legtrackingfileTag = [fileTag, '*TrackLegAngle4.mat'];
legtrackingFiles = dir([legtrackDir, legtrackingfileTag]);
size(legtrackingFiles)

%% import data
SampleRate = 20000;

[data,si,h]=abfload([abfDir dataFiles.name]);

if size(data, 2) ~=triggerchannel
    error('double check channel assignments')
end

voltagedata = data(:, voltagechannel)';
triggerdata = data(:, triggerchannel)';
currentinjectiondata = data(:, currentinjectionchannel)';
stimcommanddata = data(:, stimuluscommandchannel)';


roundtriggerdata = round(triggerdata);

%% find where each frame is triggered
trigger_on = diff(roundtriggerdata<2);
frame_on = find(trigger_on == 1)+1;

%% find where there are breaks in frame_on, presumably this is where each new video will start
MinPeakHeight=2*std(diff(frame_on));

[PKS,LOCS] = findpeaks(diff(frame_on),'MinPeakHeight',MinPeakHeight);

LOCS = LOCS + 1;
LOCS = [1, LOCS];

% if length(LOCS)~=length(legtrackingFiles)
%     error('missing files?')
% else
%     'all files present!'
% end

LOCS = [LOCS, length(frame_on)]
new_frame_on = frame_on;

%% create struct that will have voltage data, triggers, and leg angle data
legangles = [];
for j = 1:length(legtrackingFiles)
    load([legtrackDir, legtrackingFiles(j).name]);
    videolengths(j) =length(LegAngleArea(:, 1)');
    legangles = [legangles, LegAngleArea(:, 1)'];

    if videolengths(j)<(LOCS(j+1) - LOCS(j))
        new_frame_on((LOCS(j)+videolengths(j)):(LOCS(j+1)-1)) = NaN;
    end
end
videolengths
totalmissingframes = sum(isnan(new_frame_on));
frame_on = rmmissing(new_frame_on);

% if length(frame_on) <= length(legangles)
%     frame_on(isnan(legangles(1:length(frame_on)))) = [];
%     legangles(isnan(legangles)) = [];
% else
%     frame_on(isnan(legangles)) = [];
%     legangles(isnan(legangles)) = [];
% end

position=strfind(dataFiles.name,'.'); %gives the position of the "period" in the string FileName
NewName=dataFiles.name(1:position-1);

% movieFiles

% FrameRate = 75;

Outfile=strcat(NewName,'_EphysAngledata.mat');
save([dataDir, Outfile],'voltagedata', 'currentinjectiondata', 'stimcommanddata', 'frame_on', 'legangles', 'movieFiles', 'SampleRate','FrameRate' );
    