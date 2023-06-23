%ACES new camera image reader

[header, data, gains, offsets] = readImgFile("3khz_mov_3.img");
b = [];

for frames = 1:240
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
title("3,000hz Framegrab (motorized) Set 3")
xlabel("Frame")
ylabel("Average Intensity")