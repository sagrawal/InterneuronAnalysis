%Runs FilterAndRegisterImages for all the .tiff files in the folder.
%%Hsize: size of a gaussian filter (Matlab standard). Recommended value 5:
%may be 3?
%GaussianSigma: standard deviation of the Gaussian distribution.
%Recommended value 3, may be 0.5?
%usfac: Upsampling factor (integer). Images will be registered to within
%1/usfac of a pixel. For example usfac = 20 means the images will be
%registered within 1/20 of a pixel. (recommended value: 4)
%
%NofChannels: Number of channels in the recording.
%SignalChannel: A channel that contains the signal.
%ReferenceChannel: Channel to use for the reference.
%LowI: Low range for image display.
%HighI: High range for image display.
%
%Note: written on 2018/07/06.

function []=FilterAndRegisterImages_All(fileTag, Hsize,GaussianSigma,usfac, NofChannels,SignalChannel,ReferenceChannel,LowI,HighI)
%Get file names.
TIFF_Files=dir([fileTag, '*.tif']);
NofFiles=size(TIFF_Files,1)

for n=1:NofFiles
    n
%     TIFF_Files(n).name
    %Run the script.
    FilterAndRegisterImages(TIFF_Files(n).name,Hsize,GaussianSigma,usfac, NofChannels,SignalChannel,ReferenceChannel,LowI,HighI);
    close all
end

clear