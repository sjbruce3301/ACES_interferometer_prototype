laser_filename = 'nb_camera_2023_06_27_18_38_12.seq';
dark_filename = 'nb_camera_2023_06_27_18_40_53.seq';

[l_header, l_seq_data, l_ts] = readSeqSciCam(laser_filename);
[d_header, d_seq_data, d_ts] = readSeqSciCam(dark_filename);

l_seq_data = l_seq_data(90:150,:,:);
d_seq_data = d_seq_data(90:150,:,:);

width = length(l_seq_data(:,1,1));
height = length(l_seq_data(1,:,1));
numframes = length(l_seq_data(1,1,:));


l_bright = [];

dark_master = zeros(width, height);



for x = 1:width
    for y = 1:height
        pixels = zeros(1,numframes);
        for u = 1:numframes
            d_pixel = d_seq_data(x,y,u);
            pixels(1,u) = d_pixel;
        end
        average = mean2(pixels);
        dark_master(x,y) = average;
    end
end
%%

scaled_dat = double(l_seq_data) - dark_master;

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
    b1 = mean2(w_image);
    unsb1 = mean2(uns);
    b = [b, b1];
    uns_b = [uns_b, unsb1];
end

hold on
plot(b, 'LineWidth',1.7)
%plot(uns_b)
title("10,000hz Framegrab (moving) Set 1")
xlabel("Frame")
ylabel("Average Intensity")