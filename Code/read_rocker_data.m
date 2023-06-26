clear

% fname = 'closed_loop_triangle_mimic_2023_04_19_22_24_22.bin';
fname = 'trial_2/VIBSET3_mimic_2023_06_26_18_24_31.bin';

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



figure(1)
subplot(3,1,1)
hold on
plot(t,pos)
xlabel('Time (s)')
ylabel(['Position (',char(956),'m)'])
grid on

subplot(3,1,2)
hold on
plot(t,v)
xlabel('Time (s)')
ylabel(['Velocity (',char(956),'m/s)'])
ylim([-100 100])
grid on

subplot(3,1,3)
hold on
plot(t,movstd(v,N,1))
xlabel('Time (s)')
ylabel(['1-s RMS Velocity (',char(956),'m/s)'])
ylim([0 30])
legend('4/19 Pre-isolation','5/23 Post-isolation')
grid on