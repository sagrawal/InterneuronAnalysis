%Filter the images using Gaussian filter (size: Hsize, sigma:
%GaussianSigma), then register the images using previously written
%function: dftregistration.
%
%FileName: a name of the .tiff file from scanimage.
%Hsize: size of a gaussian filter (Matlab standard). Recommended value 5:
%may be 3?
%GaussianSigma: standard deviation of the Gaussian distribution.
%Recommended value 3, may be 0.5?
%usfac: Upsampling factor (integer). Images will be registered to within
%1/usfac of a pixel. For example usfac = 20 means the images will be
%registered within 1/20 of a pixel. (recommended value: 4)
%
%NofChannels: Number of channels in the recording.
%SignalChannel: A channel that contains the signal. (2)
%ReferenceChannel: Channel to use for the reference.
%LowI: Low range for image display. (0?)
%HighI: High range for image display. (300?)
%
%Note: Written on 2018/07/06, based on ReadAndAdjustImages9.m


function []=FilterAndRegisterImages(FileName,Hsize,GaussianSigma,usfac, NofChannels,SignalChannel,ReferenceChannel,LowI,HighI)

%Get the image information.
ImageInfo=imfinfo(FileName);

%Check the number of images in a file.
FrameN=length(ImageInfo);

%Get row (Height) and column (Width) number from the structure InfoSize
SizeOfImage(1)=ImageInfo(1).Height;
SizeOfImage(2)=ImageInfo(1).Width;

%Initialize the matrix for the entire image.
ImageData=int16(zeros(SizeOfImage(1),SizeOfImage(2),FrameN));

%Code to read TIFF using TIFF library.
FileLink = Tiff(FileName,'r');
for n=1:FrameN
    FileLink.setDirectory(n);
    ImageData(:,:,n)=FileLink.read();
end
FileLink.close();

%Find frames per channel.
FrameN=FrameN/NofChannels;

[SizeOfImage(1),SizeOfImage(2),NofChannels,FrameN]

%Initialize the matrix
FilteredImages=int16(zeros(SizeOfImage(1),SizeOfImage(2),NofChannels,FrameN));

figure;%Make new figure
for frame=1:FrameN
    %Filter the image using gaussian filter.
    FilteredImages(:,:,:,frame)=imgaussfilt(ImageData(:,:,(frame-1)*NofChannels+1:frame*NofChannels),GaussianSigma,'FilterSize',Hsize);
    %Display the image for the SignalChannel.
    imshow(FilteredImages(:,:,SignalChannel,frame),[LowI,HighI]);
end

%Register to the mean image of the reference channel.
ReferenceImage=mean(FilteredImages(:,:,ReferenceChannel,:),4);

%Initialize the matrix for the registered image.
RegisteredImages=int16(zeros(size(FilteredImages,1),size(FilteredImages,2),size(FilteredImages,3),size(FilteredImages,4)));

%From here on use dftregistration.m
%Initialize output.
outputMatrix=zeros(FrameN,4);
fft2_ReferenceImage=fft2(ReferenceImage);
%The parameters below are necessary for shifting all images.
%nr=size(FilteredImages,1);
%nc=size(FilteredImages,2);
%Nr = ifftshift([-fix(nr/2):ceil(nr/2)-1]);
%Nc = ifftshift([-fix(nc/2):ceil(nc/2)-1]);
%[Nc,Nr] = meshgrid(Nc,Nr);

%For displaying the registered image.
figure;

for n=1:FrameN
%     n
%     a = FilteredImages(:,:,ReferenceChannel,n);
    [outputMatrix(n,:), Greg] = dftregistration(fft2_ReferenceImage,fft2(FilteredImages(:,:,ReferenceChannel,n)),usfac);
    RegisteredImages(:,:,ReferenceChannel,n)=abs(ifft2(Greg));
    %Move the other channel by the same amount
   
    %Outputmatrix 3rd column is the row shift, 4th column is the column
    %shift.
    
    %First upsample by the factor.
    UpImage=imresize(FilteredImages(:,:,SignalChannel,n),usfac);
    %Then shift that image by the correct amount.
    %First shift in row direction.
    RowShift=outputMatrix(n,3)*usfac;
    if RowShift>=0
        %Just make the unknown shifted image to zero.
        %UpImageTemp=UpImage(end-RowShift+1:end,:);
        UpImage(RowShift+1:end,:)=UpImage(1:end-RowShift,:);
        UpImage(1:RowShift,:)=0;
    else
        %UpImageTemp=UpImage(1:1-RowShift+1,:);
        UpImage(1:end+RowShift,:)=UpImage(-RowShift+1:end,:);
        UpImage(end+RowShift+1:end,:)=0;
    end
    
    %Do the same of the column shift.
    ColShift=outputMatrix(n,4)*usfac;
    if ColShift>=0
        %Just make the unknown part 0.
        %UpImageTemp=UpImage(:,end-ColShift+1:end);
        UpImage(:,ColShift+1:end)=UpImage(:,1:end-ColShift);
        UpImage(:,1:ColShift)=0;
    else
        %UpImageTemp=UpImage(:,1:1-ColShift+1);
        UpImage(:,1:end+ColShift)=UpImage(:,-ColShift+1:end);
        UpImage(:,end+ColShift+1:end)=0;
    end
    %Now we down sample.
    DownImage=imresize(UpImage,1/usfac);
    %Find minimum value in each image and remove the offset.
    DownImage=DownImage-min(min(DownImage));
    RegisteredImages(:,:,SignalChannel,n)=DownImage;
    
    
    
    imshow(DownImage,[LowI,HighI]);
end

%Find the minimum value in the RegistedImages and
%subtract that value to remove the offset.
%MinReference=min(min(min(min(RegisteredImages(:,:,ReferenceChannel,:)))));
%MinSignal=min(min(min(min(RegisteredImages(:,:,SignalChannel,:)))));

%RegisteredImages(:,:,ReferenceChannel,:)=RegisteredImages(:,:,ReferenceChannel,:)-MinReference;
%RegisteredImages(:,:,SignalChannel,:)=RegisteredImages(:,:,SignalChannel,:)-MinSignal;




position=strfind(FileName,'.'); %gives the position of the period in the string FileName
NewName=FileName(1:position-1); %string NewName has the file name without the ".tiff".
Outfile = strcat(NewName,'FilterAndRegisterImages');
save(Outfile,'RegisteredImages','outputMatrix','SignalChannel');
clear
