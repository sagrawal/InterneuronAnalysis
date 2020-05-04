clear all; 

movieDir = 'G:\My Drive\Sweta to backup\chordotonal videos\';
dataDir = 'G:\My Drive\Sweta to backup\ephysdata\';

fileTag = 'ss28981_02*';

trackedmovieFiles = dir([movieDir, fileTag, '*TrackLegAngle4.mat']);
dataFiles = dir([dataDir, fileTag, '*EphysAngle*.mat']);

for i = 1:length(dataFiles)
    dataFiles(i).name
    load([dataDir, dataFiles(i).name]);
    ExampleVid=VideoReader([movieDir, movieFiles(1).name]);
    FrameRate = ExampleVid.FrameRate;
    
    SampleRate = 20000;
    
%     trackedfile = load(trackedmovieFiles(i).name);
    
    
%     save([moviedir, trackedfile],'Threshold','LegAngleArea', 'FrameRate', 'SampleRate');
    save([dataDir, dataFiles(i).name],'voltagedata', 'frame_on', 'legangles', 'movieFiles', 'SampleRate','FrameRate' );
end