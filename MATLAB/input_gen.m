clc;
clear;
close all;

% CONFIG
TEST_CASE = 'th3';          % th1 / th2(150) / th2(250)/th2(350) cho df1 / th3

fs = 35511;
N = 3000;
Ts = 1/fs;
n = (0:N-1)';
t = n * Ts;

Vref = 3.3;
DC = 1.65;

A1 = 0.999;
A2 = 0.357;
A3 = 0.214;

% CREATE INPUT
switch TEST_CASE

    case 'th1'
        % 50 Hz + 2000 Hz + 3000 Hz
        sig = A1*sin(2*pi*50*t) + A2*sin(2*pi*2000*t) + A3*sin(2*pi*3000*t);

        Vin = DC + sig;
        plot_title = 'TH1: 50 Hz + 2000 Hz + 3000 Hz';

    case 'th2(150)'
        % Single-tone 150 Hz
        sig = A1*sin(2*pi*150*t);

        Vin = DC + sig;
        plot_title = 'TH2: Single-tone 150 Hz';

    case 'th2(250)'
        % Single-tone 250 Hz
        sig = A1*sin(2*pi*250*t);

        Vin = DC + sig;
        plot_title = 'TH2: Single-tone 250 Hz';

    case 'th2(350)'%riêng cho trường hợp df1 
        % Single-tone 350 Hz
        sig = A1*sin(2*pi*350*t);

        Vin = DC + sig;
        plot_title = 'TH2: Single-tone 350 Hz';
    case 'th3'
        % DC test
        DC_CODE = 2048;

        Vin = ones(N,1) * (DC_CODE / 4095 * Vref);
        sig = Vin - DC;
        plot_title = 'TH3: DC input';

    otherwise
        error('TEST_CASE khong hop le');
end

% CONVERT TO ADC
Vin = max(0, min(Vref, Vin));
ADC_value = round(Vin / Vref * 4095);
ADC_value = max(0, min(4095, ADC_value));

% SAVE HEX FILE
file_name = sprintf('input_12bit(%s).txt', TEST_CASE);
fid = fopen(file_name, 'w');

for i = 1:length(ADC_value)
    fprintf(fid, '%03X\n', ADC_value(i));
end

fclose(fid);
fprintf('Da tao file: %s\n', file_name);
fprintf('ADC min = %d\n', min(ADC_value));
fprintf('ADC max = %d\n', max(ADC_value));
fprintf('ADC mean = %.2f\n', mean(ADC_value));

% PLOT
figure;
plot(t*1e3, Vin, 'LineWidth', 1.2);
grid on;
xlabel('Time (ms)');
ylabel('Voltage (V)');
title(plot_title);
xlim([0 85]);
ylim([0 3.3]);