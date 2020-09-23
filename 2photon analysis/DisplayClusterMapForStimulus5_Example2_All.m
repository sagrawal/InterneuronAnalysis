%2020/09/01: modified to work with manual clusters (instead of kmeans)
%
%Written on 2019/10/09. Runs the DisplayClusterMapForStimulus5_Example2 for
%all the appropriate files in the directory. File names and the matrix
%inside the files have changes slightly, so need to adjust for that.
%
%Written on 2018/06/24, this version also look for a boundary for the
%holes. Supposed to be lower performance, but see if it works OK.
%
%Written on 2018/06/24. Similar to version 5, but just for an example prep,
%where we just have the initial kmeans and original data file.
%
%Written on 2017/10/26. Try to save the outline and the patch. First try to
%save the .eps and see what happens in the illustrator. It should work OK.
%Only question is the holes in the patch. After opening the .eps file,
%ungroup the different clusters and then we can copy and paste the outline
%to make the overlay separate from the outline. ColorOrder specifies which
%color to use for each cluster. For now we will make Flex tonic = Red, Ext
%tonic = Blue, phasic = green, flex selective = orange, ext selective =
%purple.
%
%Written on 2017/10/20. Now tries to overlay on the DFF image with outline
%for the map. We did something simiar long time ago. Check that script
%first. It was called PlotClusterBoundary.m. Now show each of them one at a
%time and save as .jpeg or .tiff.
%
%Transparancy =0.1 may work best.
%
%Written on 2017/10/19, Just use the output from the second version of the
%CollectClusterMapForStimulus. May be for the next version we will color it
%based on certain features. For that we need a feature extracting points
%for each stimulus. Perhaps make them separately.
%
%Written on 20170921, displays the cluster map for the stimulus.
%
%Display in a summarized form with specified number of rows and columns.
%May be 5 rows and 5 columns.

function []=DisplayClusterMapForStimulus5_Example2_All(FileTag, OutFileName,SignalChannel)

%Kmeans files.
DffFile=dir([FileTag,'*SelectROICalculateDFF.mat']);

%Same for the data.
DataFile=dir([FileTag,'*FilterAndRegisterImages.mat']);

NofFiles=size(DffFile,1);

for n=1:NofFiles
    
    %Load the files.
    load(DffFile(n).name)
    load(DataFile(n).name,'FilteredImages');

    %Make the MeanImage.
    MeanImage=mean(FilteredImages(:,:,SignalChannel,:),4);

    %we need new color map. Add two more colors.
    ClusterColorMap=[1 0 0;0 0 1;0 1 0;1 0.5 0;0.5 0 0.5;0 0.5 0;0.5 0 0 ];

    NofClusters=size(DFF1,1);

    figure,imshow(MeanImage,[])
    hold on
    %Plot the boundaries for each cluster. 
    for m=1:NofClusters
        %Find the boundary.
        [B,L]=bwboundaries(ROIMask(:, :, m)==1);
        hold on
        for k=1:length(B)
            boundary = B{k};
            plot(boundary(:,2),boundary(:,1),'Color',ClusterColorMap(m,:),'LineWidth',0.5)
        end
    end

    Outfile2=strcat(OutFileName,'ClusterMap5_Example2_',int2str(n))
    print(Outfile2,'-djpeg','-r300')
    print(Outfile2,'-depsc')
end

clear