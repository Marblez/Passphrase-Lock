function audio_fft()

t = (1/8000:1/8000:5)';
rec = audiorecorder(8000,16,1);
% f = @(obj,event)showFFT(obj,event,t);
% set(rec, 'TimerFcn', f);
rec.TimerFcn = {@showFFT, t};
rec.TimerPeriod = 0.05;

rec.UserData = 0;
record(rec);
while ~rec.UserData
    fprintf('No Go\n');
    pause(.5);
end
fprintf('SUCCESS!!!\n');
stop(rec);

% recordblocking(rec,5);

function showFFT(obj,event,t)

y = getaudiodata(obj);
%figure(1);plot(t(1:length(y)),y);
if length(y) > 40000
    y = y(end-40000+1:end);
end

L = length(y);
NFFT = 2^nextpow2(L);
Y = fft(y,NFFT)/L;
f = 8000/2*linspace(0,1,NFFT/2+1);
Y = 2*abs(Y(1:NFFT/2+1));
figure(1);plot(f,Y)

[~,loc] = max(Y);
if f(loc) > 500 && L == 40000
    obj.UserData = 1;
end