% He so Q2.28 cho IIR Elliptic bac 4 (2 biquad cascade)
% fs = 35511 Hz, fc = 200 Hz, Rp = 0.1 dB, Rs = 40 dB
%   A1_C = round(a1 * 2^28),  A2_C = round(a2 * 2^28)
%   DF1 : y[n]  = B0*x[n] + B1*x[n-1] + B2*x[n-2] - A1*y[n-1] - A2*y[n-2]
%   TDF2: y[n]  = (B0*x[n] + w1[n-1]) >> 28
%         w1[n] = B1*x[n] - A1*y[n] + w2[n-1]
%         w2[n] = B2*x[n] - A2*y[n]
fs = 35511; fc = 200;
Wc = fc/(fs/2);
%% DF1 single biquad 2nd-order
[z1,p1,k1] = ellip(2,0.1,40,Wc);
sos_df1 = zp2sos(z1,p1,k1);
fprintf('\n DF1 SINGLE BIQUAD Q2.28 \n');
B = sos_df1(1,1:3);
A = sos_df1(1,4:6);
scale = 28;
DF1_B0 = round(B(1)*2^scale);
DF1_B1 = round(B(2)*2^scale);
DF1_B2 = round(B(3)*2^scale);

DF1_A1 = round(A(2)*2^scale);
DF1_A2 = round(A(3)*2^scale);

fprintf('B0 = %d\n',DF1_B0);
fprintf('B1 = %d\n',DF1_B1);
fprintf('B2 = %d\n',DF1_B2);
fprintf('A1 = %d\n',DF1_A1);
fprintf('A2 = %d\n',DF1_A2);
%% DF1 Cascade
[z,p,k] = ellip(4,0.1,40,Wc);
[sos,g] = zp2sos(z,p,k);
% dua gain vao stage 1
sos(1,1:3)=sos(1,1:3)*g;
fprintf('\n CASCADE ORDER 4 Q2.28 \n');
coeffs=zeros(2,5);
for s=1:2
    Bs=sos(s,1:3);
    As=sos(s,4:6);
    B0=round(Bs(1)*2^scale);
    B1=round(Bs(2)*2^scale);
    B2=round(Bs(3)*2^scale);
    A1=round(As(2)*2^scale);
    A2=round(As(3)*2^scale);
    coeffs(s,:)=[B0 B1 B2 A1 A2];
    fprintf('\n// Stage %d\n',s);
    fprintf('B0=%d\n',B0);
    fprintf('B1=%d\n',B1);
    fprintf('B2=%d\n',B2);
    fprintf('A1=%d\n',A1);
    fprintf('A2=%d\n',A2);
end

%% kiểm tra lượng tử
fprintf('\n Quantization error \n');
Bq1=coeffs(1,1:3)/2^scale;
Aq1=[1 coeffs(1,4:5)/2^scale];
Bq2=coeffs(2,1:3)/2^scale;
Aq2=[1 coeffs(2,4:5)/2^scale];
fprintf('Stage1 B error %.2e\n',max(abs(sos(1,1:3)-Bq1)));
fprintf('Stage2 B error %.2e\n',max(abs(sos(2,1:3)-Bq2)));

%% poles & zeros
figure;
% single biquad
[z_df1,p_df1,k_df1] = sos2zp(sos_df1);
zplane(z_df1,p_df1);
grid on;
title('Pole-Zero DF1 Single Biquad');

figure;
% cascade order 4
[z_cas,p_cas,k_cas] = sos2zp(sos);
zplane(z_cas,p_cas);
grid on;
title('Pole-Zero Elliptic Order 4 Cascade');