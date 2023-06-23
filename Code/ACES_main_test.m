%[header,img, imagestack] = Norpix2MATLAB('ACES_2023_06_08_13_57_38.seq',1);

[header1,img1, ts1] = readSeqSJCam8bit('ACES_2023_06_08_13_57_38.seq');

%27 frames

b = [];

for frames = 1:27
    %subplot(4, 4, frames)
    %colorbar
    %imagesc(img1(:,:,frames), [0, 255])

    image = (img1(:,:,frames));

    %[y,x] = size(image);

    %Mark Center 
    center = [450, 400];
    %plot(center(1),center(2),'*r')

    %calculate brightness
    brightness = mean2(image(center(2)-200:center(2)+200, center(1)-150:center(1)+150));
    disp(brightness)
    b = [b, brightness];
end

plot(b, 'LineWidth',1.7)
xlabel("Frame")
ylabel("Average Intensity")

%header1 = Norpix2MATLAB('ACES_2023_06_08_13_57_38.seq')

%[~,img1] = Norpix2MATLAB('ACES_2023_06_08_13_57_38.seq', 1)