iP = 'Y:\Data\University stuff\NTU\20160226\matlab';

outputVideo = VideoWriter(fullfile(iP,'magTrap.avi'));
outputVideo.FrameRate = 3;%shuttleVideo.FrameRate;
open(outputVideo);
%Loop through the image sequence, load each image, and then write it to the video.
imageNames = dir(fullfile(iP,'*.tif'));
imageNames = {imageNames.name}';

for ii = 1:length(imageNames(1:end-11))
   img = double(imread(fullfile(iP,imageNames{ii})))./(2^16-1);
   writeVideo(outputVideo,img);
end
%Finalize the video file.

close(outputVideo)