clear

% fname = 'mimic_2023_06_30_12_53_10.bin';
fname = 'mimic_2023_06_30_16_04_05.bin';

fid = fopen(fname,'r','b');
data = fread(fid,inf,'double');
fclose(fid);

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



figure(2)
%subplot(3,1,1)
%hold on
plot(t,pos)
xlabel('Time (s)')
ylabel(['Position (',char(956),'m)'])
xlim([0,30])
grid on

%%
figure(3)
%subplot(3,1,2)
%hold on
plot(t,v)
xlabel('Time (s)')
ylabel(['Velocity (',char(956),'m/s)'])
ylim([-100 100])
grid on

