%Cluster the pixels based on the correlation between the DFF values.
%
%InFile: output from the FilterAndRegisterImages. Contains the filtered and
%registered images.
%InFile2: output from the SelectROIManually.m Contains the preselected ROI.
%NofClusters: Number of clusters.
%BaselineN: Number of frames to use for a baseline (recommended value: 10).
%Repetition: Number of repetition for the Kmeans clustering (recommended
%value: 5).
%PixelThreshold: Threshold to select the pixels in the ROI.
%Register: if image used any registration

function []=KmeansClusterPixels(InFile,InFile2,NofClusters,BaselineN,Repetition,PixelThreshold, Register)

%Load the *FilterAndRegisterImages files.
load(InFile);

if Register == 0
    RegisteredImages = FilteredImages;
else
    RegisteredImages = RegisteredImages;
end

NofRows=size(RegisteredImages,1);
NofColumns=size(RegisteredImages,2);
NofPixels=NofRows*NofColumns;
NofFrames=size(RegisteredImages,4);

%Sort the image to get high intensity values and apply threshold.
SortedImage=squeeze(sort(RegisteredImages(:,:,SignalChannel,:),4,'descend'));
%This is hard coded for now, but can be specified.
PercentToUse=10;
FramesToUse=ceil(NofFrames*PercentToUse/100);

MaxMeanImage=mean(SortedImage(:,:,1:FramesToUse),3);
ImageMask=MaxMeanImage>=PixelThreshold;

%Reshape the image.
DataMatrix=double(reshape(RegisteredImages(:,:,SignalChannel,:),[NofPixels, NofFrames]));


%Load the manual mask.
load(InFile2);%It contains ManualROI for each recording.
ManualMask=ManualROI;

%Put the two together.
ImageMask=ImageMask&ManualMask;

[idx1,C1]=kmeans(DataMatrix(ImageMask,:),NofClusters,'Distance','correlation','Replicates',Repetition);

%Go through each pixels and assign cluster number. Background will be zero.
idx3=zeros(NofPixels,1);
m=1;
for n=1:NofPixels
    if ImageMask(n)==0
        idx3(n)=0;
    else
        idx3(n)=idx1(m);
        m=m+1;
    end
end

ClustersInImage=reshape(idx3,[NofRows NofColumns]);
%figure,imshow(ClustersInImage,[])
%colormap(gca,'jet')
TempMap=[0 0 0;1 0 0;0 1 0;0 0 1;1 0 1;1 1 0;0 1 1];
figure,imshow(ClustersInImage,[])
colormap(gca,TempMap(1:NofClusters+1,:));

%Make DFF with the following code.
AvgInt1=zeros(NofClusters,NofFrames);
DFF1=zeros(NofClusters,NofFrames);
BoxAverage1=zeros(NofClusters,NofFrames-BaselineN+1);

figure
hold on
for n=1:NofClusters
    TempCluster=DataMatrix(idx3==n,:);
    AvgInt1(n,:)=mean(TempCluster,1);
    %For each cluster, calculate the running average with BaselineN frames
    %each.
    for m=1:(NofFrames-BaselineN)+1
        BoxAverage1(n,m)=mean(AvgInt1(n,m:m+BaselineN-1));
    end
    %two different ways to calculate baseline. Either the minimum value (original
    %method) or average the first BaselineN frames
%     Baseline=min(BoxAverage1(n,:)); %Akira's original method  
    Baseline=mean(BoxAverage1(n,1:BaselineN)); %new method
    
    DFF1(n,:)=(AvgInt1(n,:)-Baseline)/Baseline;
    %For now we make it so that we will re do the loop one more time if
    %there are more than 4 clusters.Won't be able to have more than 8 for
    %now.
    if n<=size(TempMap,1)-1
       plot(DFF1(n,:)','Color',TempMap(n+1,:))
    else
       plot(DFF1(n,:)','Color',TempMap(mod(n,7)+2,:))
    end
end
hold off



%Correlation before clustering.
%R1=corrcoef(Test(Mask3,:)');
%figure,imshow(R1,[])


%For plotting the correlation matrix.
%Cluster1size=sum(idx3==1);
%Cluster2size=sum(idx3==2);
%Cluster3size=sum(idx3==3);
%Cluster4size=sum(idx3==4);
%Cluster1=Test(idx3==1,:);
%Cluster2=Test(idx3==2,:);
%Cluster3=Test(idx3==3,:);
%Cluster4=Test(idx3==4,:);
%Test3=Cluster1;
%Test3(end+1:end+Cluster2size,:)=Cluster2;
%Test3(end+1:end+Cluster3size,:)=Cluster3;
%Test3(end+1:end+Cluster4size,:)=Cluster4;
%R2=corrcoef(Test3');
%figure,imshow(R2,[])
%colormap(gca,'jet')

position=strfind(InFile,'.'); %gives the position of the period in the string FileName. This is the last of the set of the files from the same region.
NewName=InFile(1:position-1); %string NewName has the file name without the ".tiff".

Outfile = strcat(NewName,'KmeansClusterPixels');
save(Outfile,'BaselineN','BoxAverage*','Clusters*','AvgInt*','DFF*','idx*','C1','TempMap');


clear
