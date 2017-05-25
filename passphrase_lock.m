function passphrase_lock

% Sampling frequency, number of quantization bits, and number of channels.
fs = 8000;
quant_bits = 16;
num_chans = 1;
% Create audiorecorder object 
rec = audiorecorder(fs,quant_bits,num_chans);

% Record 5 second passphrases until the user is satisfied.
satisfied = 0;
while ~(strcmpi(satisfied,'y') || strcmpi(satisfied,'yes'))
    fprintf('Get ready to record your passphrase!\n'); pause(1);
    fprintf('3\n');pause(1);fprintf('2\n');pause(1);fprintf('1\n');pause(1);
    fprintf('GO!\n');
    recordblocking(rec,5);
    y_pass = getaudiodata(rec);
    % Find the Fourier transform of "y".
    L = length(y_pass);
    NFFT = 2^nextpow2(L);
    Y_pass = fft(y_pass,NFFT)/L;
    f = fs/2*linspace(0,1,NFFT/2+1);
    Y_pass = 2*abs(Y_pass(1:NFFT/2+1));
    figure(1);
    subplot(2,1,1);plot((1:L)/fs,y_pass);
    title('Passphrase Time Domain');
    xlabel('Time (s)');
    subplot(2,1,2);plot(f,Y_pass);
    title('Passphrase Frequency Domain');
    xlabel('Frequency (Hz)');
    satisfied = input('Are you satisfied with your passphrase? (Y/N) ','s');
end

count = 0;
pause on;
correct_phrase = 0;

while ~correct_phrase
    if count == 1
        fprintf('Paused: press any key to continue.\n');
        pause;
    end
    fprintf('Get ready to record your attempt!\n'); pause(1);
    fprintf('3\n');pause(1);fprintf('2\n');pause(1);fprintf('1\n');pause(1);
    fprintf('GO!\n');
    recordblocking(rec,5);
    y_attempt = getaudiodata(rec);
    % Find the Fourier transform of "y".
    L = length(y_attempt);
    NFFT = 2^nextpow2(L);
    Y_attempt = fft(y_attempt,NFFT)/L;
    f = fs/2*linspace(0,1,NFFT/2+1);
    Y_attempt = 2*abs(Y_attempt(1:NFFT/2+1));
    figure(2);
    subplot(2,1,1);plot(f,Y_pass);
    title('Passphrase Spectrum');
    subplot(2,1,2);plot(f,Y_attempt);
    title('Attempt Spectrum');
    
    if count == 0
        count = 1;
    end
    
%Store Top 5 Frequencies
    Y_pass(1:14) = 0;
    Y(1:14) = 0;
    [M, index] = max(Y_pass);
    [M_a, index_a] = max(Y_attempt);
    Y_p=Y_pass./M;
    Y_a=Y_attempt./M_a;
    topFreqs = zeros(1,0);
    topFreqs(1) = f(index);
    topFreqs_a = zeros(1,0);
    topFreqs_a(1) = f(index_a);
    Y_p(index-13:index+13)=0;
    Y_a(index-13:index+13)=0;
    for i=2:5
       [~, index] = max(Y_p);
       topFreqs(i) = f(index);
       Y_p(index-13:index+13)=0;
       [~, index_a] = max(Y_a);
       topFreqs_a(i) = f(index_a);
       Y_a(index-13:index+13)=0;
    end
    
   %Compare
   count = 0;
   for i=1:5
      for j=1:5
         if abs(f(index_a)-f(index)) < 10
            count = count + 1;
            break;
         end
      end
   end
   if count >= 3
       correct_phrase=1;
   end
    
   
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
fprintf('SUCCESS!!!\n');
stop(rec);
soundsc(audioread('unlocked.wav'));