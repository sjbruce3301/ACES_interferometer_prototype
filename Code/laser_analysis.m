%% This is the main file for reading & interpreting ACES FTIR test data

laser_filename = '07_18_ds3.seq'; %input main file name                     %CHANGE THIS PER FILE
dark_filename = '07_18_DARK.seq'; %input dark file name                     %CHANGE THIS PER FILE

[l_header, l_seq_data, l_ts] = readSeqSciCam(laser_filename);
[d_header, d_seq_data, d_ts] = readSeqSciCam(dark_filename);

ts_sec = (l_ts - l_ts(1)) * 86400; %convert time to seconds

l_seq_data = l_seq_data(320:325,1:6,:); %change data size
d_seq_data = d_seq_data(320:325,1:6,:);

width = length(l_seq_data(:,1,1));
height = length(l_seq_data(1,:,1));
numframes = length(l_seq_data(1,1,:));
d_numframes = length(d_seq_data(1,1,:));

%% This section creates a master dark image for subtraction, calculates frame intensities, and reads the keyence log files.

l_bright = [];

dark_master = zeros(width, height);


%create dark image for subtraction
for x = 1:width
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

%calculate intensities of all frames
scaled_dat = double(l_seq_data) - dark_master;
singlepix_intensity = [];
intensity_plot = [];
uns_b = [];
for frames = 1:numframes
    uns = (l_seq_data(:,:,frames));
    w_image = (scaled_dat(:,:,frames));

    %calculate brightness
    b1 = mean2(w_image(:,:)); %can change centering here (200:300,:)

    unsb1 = mean2(uns);
    intensity_plot = [intensity_plot, b1];
    uns_b = [uns_b, unsb1];
end

%Read log file (high res keyence data)
fname = '07_18_ds3.csv';                                                %CHANGE THIS PER FILE

dt = 100e-6;
fid=fopen(fname);
M = textscan(fid,',,%f\r','headerlines',4);
fclose(fid);
x1 = M{1};
t1 = (0:(length(x1)-1))*dt;


%% This section (no longer in use) used the lower resolution mimic files to calculate positions and velocity.


%{
fname_bin = 'mimic_2023_07_07_ds2.bin';                                 %CHANGE THIS PER FILE

fid2 = fopen(fname_bin,'r','b');
data = fread(fid2,inf,'double');
fclose(fid2);

data = reshape(data,7,[])';

time = data(:,1); % Unix time (seconds since 1970)
iter = data(:,2); % iteration through the loop
ov = data(:,3); % want this to be zero otherwise can't trust the data
setpt = data(:,4); % where we command the mirror to go
pos = data(:,5); % where the mirror went
volt = data(:,6); % output of the controller

t = time-time(1);
v = gradient(pos)./gradient(t);

dt = mean(diff(t));
N = round(1/dt);

%}



%% This section displays plots of intensities, position, and cosine.


cos_array = cos(2*pi*x1/.635*5+pi);

%plot intensities wrt time
figure(1)
ax(3) = subplot(3,1,1);
plot(ts_sec + 1.5,intensity_plot, linewidth = 1.5)
xlim([22.2,22.6])
ylabel('Intensity')
xlabel('Time (s)')

ax(2) = subplot(3,1,3);
%hold on
plot(t1,x1, linewidth = 1.5)
xlabel('Time (s)')
ylabel(['Position (',char(956),'m)'])
xlim([22.2,22.6])
grid on
%xlim([7.2,7.4])


ax(1) = subplot(3,1,2);
plot(t1, cos_array, linewidth = 1.5)
ylabel('Cos')
xlim([22.2,22.6])
xlabel('Time (s)') 
%xlim([7.2,7.4])


linkaxes(ax,'x')



%% This section displays a set of 12 laser images visually.


frames = l_seq_data(:,:,10:22); %pick frames to be shown
figure (2)
for frame = 1:12
    subplot(3, 4, frame)
    disp(frame)
    colorbar
    colormap bone
    imagesc(frames(:,:,frame))

    if frame==1
        cl = caxis; %# get color limits from the 1st image
    else
        caxis(cl) %# apply the same color limits to other images

    
    end
end



%% This section performs the data interpolation & Fourier Transform.

timealigned_camera = ts_sec + 1.5;
camera_pos_x = interp1(t1, x1, timealigned_camera);

x_cam_window = camera_pos_x(10000:10200);
i_window = intensity_plot(10000:10200);
i_window = detrend(i_window, 'constant');
x_const = -83.3:.01:-82; %-64

[unique_mtx,indx] = unique(x_cam_window);
useable_intens = i_window(indx);
i_const = interp1(unique_mtx, useable_intens, x_const);

dx = .01*3.57*.0001 * 1.65;
step = linspace(-1/dx/2,1/dx/2,1024);


fourier_original = abs(fftshift(fft(i_window, 1024)));

fourier_t = abs(fftshift(fft(i_const, 1024)));

figure(3)
hold on
plot(step,fourier_t, LineWidth=1)

plot(step, fourier_original, LineWidth = 1)
%xlim([-5000, inf])
colororder(["blue";"red"])


title('Fourier Transform vs Wave Number')
legend('FT after interpolation', 'Original FT')