%% The function to calulate the proposed transfer function

function [k,eata1,eata2] = TransferFunction(beta)

f     = 1000;
d     = 0.01;
c     = 340;
k     = (0:0.01:10)';

Hfront      = 1-beta*exp(-1i*2*pi*f*d/c*(1+k));
Hlateral    = 1-beta*exp(-1i*2*pi*f*d/c*k);
Hrear       = 1-beta*exp(-1i*2*pi*f*d/c*(k-1));

%% Power Ratio Calculation

eata1       = 20*log10(abs(Hfront./Hlateral));
eata2       = 20*log10(abs(Hfront./Hrear));

%% End of Program


