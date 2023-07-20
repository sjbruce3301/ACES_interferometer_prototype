laser_filename = 'nb_camera_2023_06_30_16_06_07_data.seq';
dark_filename = 'nb_camera_2023_06_30_16_09_54_dark.seq';

[l_header, l_seq_data, l_ts] = readSeqSciCam(laser_filename);
[d_header, d_seq_data, d_ts] = readSeqSciCam(dark_filename);

l_ts_sec = (l_ts - l_ts(1)) * 86400;

%l_seq_data = l_seq_data(500:650,:,:); %Change size of data if needed
%d_seq_data = d_seq_data(500:650,:,:);

width = length(l_seq_data(:,1,1));
height = length(l_seq_data(1,:,1));
numframes = length(l_seq_data(1,1,:));
d_numframes = length(d_seq_data(1,1,:));


l_bright = [];

dark_master = zeros(width, height);


for x = 1:width %creates dark master file
    for y = 1:height
        pixels = zeros(1,d_numframes);
        for u = 1:d_numframes
            d_pixel = d_seq_data(x,y,u);
            pixels(1,u) = d_pixel;
        end
        average = mean2(pixels);
        dark_master(x,y) = average;
    end
end
%%
%used this to test/check dark image pixels (not needed anymore)

dark_pix = [];
for f = 1:d_numframes
    pix1 = (d_seq_data(80,6,f));
    dark_pix = [dark_pix, pix1];
end

%%

%This section can calculate intensities & display data

scaled_dat = double(l_seq_data) - dark_master;


singlepix_intensity = [];

b = [];
uns_b = [];
for frames = 1:numframes
    %subplot(8, 2, frames)
    %imagesc(data(:,:,frames))
    %axis image
    %colormap bone
    uns = (l_seq_data(:,:,frames));
    w_image = (scaled_dat(:,:,frames));

    %calculate brightness
    b1 = mean2(w_image(275:350,:));

    %pix = (scaled_dat(80,6,frames));
    %singlepix_intensity = [singlepix_intensity, pix];

    unsb1 = mean2(uns);
    b = [b, b1];
    uns_b = [uns_b, unsb1];
end

figure(1)
%plot(dark_pix)
plot(l_ts_sec,b)
%plot(singlepix_intensity)
%plot(l_ts_sec,b)

%for i = 1:numframes
%    
%    imagesc(scaled_dat(:,:,i))
%    pause(.001)
%end

%hold on
%plot(b, 'LineWidth',1.7)
%plot(uns_b)
%title("3,000hz Framegrab (moving) Set 1")
%xlabel("Frame")
%ylabel("Average Intensity")
%%

%displays intensity plots

subplot(2,2, 1)
hold on
plot(l_ts_sec, b)
title("Intensity Plot (Dark Subtracted)")
hold off

subplot(2,2, 2)
plot(b(16200:17400), color = 'r')
title("Frames 16200 - 17400")

subplot(2,2,3)
plot(b(29160:29300), color = 'b')
title ("Frames 29160 - 29300")

subplot(2,2,4)
plot(b(27050:27300), color = 'k')
title("Frames 27050 - 27300")