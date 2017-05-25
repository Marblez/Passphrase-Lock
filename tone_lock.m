function tone_lock(target_freq)

% Default target frequency.
if nargin < 1
    target_freq = 200;
end

% Sampling frequency, number of quantization bits, and number of channels.
fs = 8000;
quant_bits = 16;
num_chans = 1;
% Create audiorecorder object 
rec = audiorecorder(fs,quant_bits,num_chans);

% Create callback function.  It automatically gets passed the audiorecorder
% object and the triggering event, along with an extra parameter, in this
% case the target frequency.
rec.TimerFcn = {@showFFT, target_freq};
% The callback function gets called every 0.05 seconds.
rec.TimerPeriod = 0.05;

% We can use the UserData field in the audiorecorder object to store some
% values that we can pass back and forth between the callback function and
% this workspace, since the callback function has no return values.
rec.UserData = 0;

% Start the recording.
record(rec);
% Keep on recording until our goal is reached, at which point the callback
% function changes the UserData field to "1".
while ~rec.UserData
    fprintf('No Go\n');
    pause(.5);
end
fprintf('SUCCESS!!!\n');
stop(rec);
soundsc(audioread('unlocked.wav'));

function showFFT(obj,event,target_freq)

% Store recorded data in "y".
y = getaudiodata(obj);
% Let's make "y" be the 5 most recent seconds of recording (or everything
% we have until "y" is 5 seconds long).
if length(y) > 40000
    y = y(end-40000+1:end);
end

% Find the Fourier transform of "y" and plot it.
L = length(y);
NFFT = 2^nextpow2(L);
Y = fft(y,NFFT)/L;
f = 8000/2*linspace(0,1,NFFT/2+1);
Y = 2*abs(Y(1:NFFT/2+1));
figure(1);plot(f,Y)


[~, index] = max(Y);

if f(index) > target_freq && length(y) > 20000
    obj.UserData = 1;
end



