
clear; clc; close all;


y_folded    = load('out_folded.txt');
y_pipelined = load('out_pipelined.txt');


n = min(length(y_folded), length(y_pipelined));
y_folded    = y_folded(1:n);
y_pipelined = y_pipelined(1:n);


Y1 = abs(fft(y_folded));
Y2 = abs(fft(y_pipelined));

Y1_db = 20*log10(Y1 / (max(Y1) + eps) + eps);
Y2_db = 20*log10(Y2 / (max(Y2) + eps) + eps);


figure('Position', [100 100 900 500]);
plot(Y1_db, 'LineWidth', 1.5); hold on;
plot(Y2_db, '--', 'LineWidth', 1.5);

xlabel('Frequency bin');
ylabel('Magnitude (dB)');
title('Spectral Response Comparison: Folded vs Pipelined');
legend('Folded', 'Pipelined');
grid on;

saveas(gcf, 'fft_compare.png');
fprintf('Plot saved to fft_compare.png\n');


mae = mean(abs(Y1_db - Y2_db));
fprintf('Mean Absolute Error between the two spectral responses: %.4f dB\n', mae);

if mae < 1.0
    fprintf('>> Conclusion: The two architectures produce ALMOST IDENTICAL filter responses (meets project requirements).\n');
else
    fprintf('>> Warning: Significant deviation - check bit width / pipeline latency / sample offset between the two result files.\n');
end


disp('W0 T3 W3 T8 W8 T15');