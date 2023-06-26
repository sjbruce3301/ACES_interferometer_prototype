%ACES new camera image reader

[header, data, gains, offsets] = readImgFile("trial_2/trial2_vib_set3.img");
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

x = randi([0, 255], 600, 600, 28, 'uint8');
v = VideoWriter('myvideo_grayscale.avi', 'Grayscale AVI');
open(v);
writeVideo(v, x);
close(v)