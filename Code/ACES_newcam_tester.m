%ACES new camera image reader

[header, data, gains, offsets] = readImgFile("nofilter_moving_1.img");
b = [];

for frames = 1:length(data(10,312,:))
    %subplot(8, 2, frames)
    %imagesc(data(:,:,frames))
    %axis image
    %colormap bone
    image = (data(:,:,frames));

    %Mark Center 
    center = [5, 156];
    %plot(center(1),center(2),'*r')

    %calculate brightness
    brightness1 = mean2(image);
    b = [b, brightness1];
end


plot(b, 'LineWidth',1.7)
title("10,000hz Framegrab (moving) Set 1")
xlabel("Frame")
ylabel("Average Intensity")

fileID = fopen('mimic_log_nofilter_moving_1.bin');

log = fopen('mimic_log_nofilter_moving_1.bin');
log_dat = fread(log);
%plot(log_dat)

%fclose(log);
% Prepare the new file.
vidObj = VideoWriter('trial2_set3.avi');
open(vidObj);

frameset = data(10,312,:);

ims_set = cell(length(frameset), 1);

for u = 1:length(frameset)
    im1 = (data(:,:,frames));
    imwrite(double(im1), "image.png")
    ims_set{u} = imread('image.png');
end

% Create an animation.
% write the frames to the video
for v=1:length(frameset)
    % convert the image to a frame
    frame = im2frame(ims_set{v});
    writeVideo(vidObj, frame);
end
% Close the file.
close(vidObj);