movieDir = 'G:\My Drive\Sweta to backup\ephysdata\spontaneous and active movement examples\stuff\';
fileTag = 'ss28981_36*';
movieFiles = dir([movieDir, fileTag, '.avi']);
dataFiles = dir([movieDir, fileTag, 'TrackLegAngle4.mat']);

movieFile = movieFiles(1).name;
dataFile = dataFiles(1).name;

%% import data
load(dataFile);
MajorAxisLengths = LegAngleArea(:, 6);
Orientations = LegAngleArea(:, 5);
Centroids = [LegAngleArea(:, 3), LegAngleArea(:, 4)];           


%% import movie
mov = VideoReader(movieFile);
framerate = mov.FrameRate;

%% plot lines on movie frames, make new movie
fig = figure;
v = VideoWriter('ss28981_36.avi');
v.FrameRate = framerate;
open(v);

for i = 1:mov.NumberOfFrames
    if i>length(MajorAxisLengths)
    else
    image(read(mov, i));
    MajorAxisLength = MajorAxisLengths(i);
    Orientation = Orientations(i);
    Centroidx = Centroids(i, 1);
    Centroidy = Centroids(i, 2);
    
    xdiff = MajorAxisLength*cosd(-Orientation);
    ydiff = MajorAxisLength*sind(-Orientation);
    
    line([Centroidx-(0.5*xdiff), Centroidx+(0.5*xdiff)], [Centroidy-(0.5*ydiff), Centroidy+(0.5*ydiff)])
    
    f = getframe(fig);
    writeVideo(v, f)
    end
end

close(v)
    
