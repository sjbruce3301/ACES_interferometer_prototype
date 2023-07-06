laser_filename = '07_06_closedloop_ds5.seq'; %input main file name
dark_filename = '07_06_DARK.seq'; %input dark file name

[l_header, l_seq_data, l_ts] = readSeqSciCam(laser_filename);
[d_header, d_seq_data, d_ts] = readSeqSciCam(dark_filename);

ts_sec = (l_ts - l_ts(1)) * 86400; %convert time to seconds

l_seq_data = l_seq_data(250:350,1:6,:); %change data size
d_seq_data = d_seq_data(250:350,1:6,:);

width = length(l_seq_data(:,1,1));
height = length(l_seq_data(1,:,1));
numframes = length(l_seq_data(1,1,:));
d_numframes = length(d_seq_data(1,1,:));
%%

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
fname = '07_06_closedloop_ds5.csv';

dt = 100e-6;
fid=fopen(fname);
M = textscan(fid,',,%f\r','headerlines',4);
fclose(fid);
x1 = M{1};
t1 = (0:(length(x1)-1))*dt;
%%

%read low-res log file & calc velocity 
fname_bin = 'mimic_2023_07_06_closedloop_ds5.bin';

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

%%
%cosine calc

cos_array = cos(2*pi*x1/.635*5+pi);

%%

%plot intensities wrt time
figure(1)
ax(4) = subplot(4,1,1);
plot(ts_sec + 1.982,intensity_plot, linewidth = 1.3)
%xlim([8.8,8.9])
ylabel('Intensity')
xlabel('Time (s)')

ax(3) = subplot(4,1,4);
%hold on
plot(t1,x1, linewidth = 1.3)
xlabel('Time (s)')
ylabel(['Position (',char(956),'m)'])
xlim([0,30])
grid on

ax(2) = subplot(4,1,3);
%hold on
plot(t,v, linewidth = 1.3)
xlabel('Time (s)')
ylabel(['Velocity (',char(956),'m/s)'])
ylim([-100 100])
%xlim([8.8,8.9])
grid on

ax(1) = subplot(4,1,2);
plot(t1, cos_array, linewidth = 1.3)
ylabel('Cos')
xlim([0,30])
xlabel('Time (s)') 

linkaxes(ax,'x')

%%

%display visual laser images
frames = l_seq_data(280:340,:,[9,14,19,24,29,34,39,44,49,54,70,80]); %pick frames to be shown

for frame = 1:12
    subplot(3, 4, frame)
    colorbar
    colormap bone
    imagesc(frames(:,:,frame))

    if frame==9
        cl = caxis; %# get color limits from the 1st image
    else
        caxis(cl) %# apply the same color limits to other images

    
    end
end



