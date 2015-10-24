%% Beamforming Simulation File

scrsz = get(0,'ScreenSize');
P1=[300 40 scrsz(3)/2 scrsz(4)/2];
P2=[40 80 scrsz(3)/2 scrsz(4)/2];
% P3=[600 500 scrsz(3)/3 scrsz(4)/3];
% P4=[600 80 scrsz(3)/3 scrsz(4)/3];
% P5=[1000 500 scrsz(3)/3 scrsz(4)/3];
% P6=[1000 80 scrsz(3)/3 scrsz(4)/3];

%% Parameter Settings
beta = 0.7:0.1:1.4;
i = 1;

%% Plotting eata to k Iteration
figure('position', P2);
for b = beta
    [k,eata1(:,i),eata2(:,i)] = TransferFunction(b);
   
    subplot(2,4,i);plot(k,eata1(:,i),'LineStyle','--');
    s=strcat('beta = ',num2str(b));
    text(5,10,{s},'FontSize',12,'HorizontalAlignment','center')
    refline(0,5);
    hold all;plot(k,eata2(:,i));ylim([0 15]);refline(0,3);
    i=i+1;
end

%% Optimum Value Part

[c1,index1]=max(eata1,[],1);
[c2,index2]=max(eata1,[],1);

% Beta values satisfying eata1> 3 and eata2>5
Betaoptimum = beta(c1>3 & c2>5)
Index=[];

for b = Betaoptimum
    Index=[Index find(beta==b)];
end

%% Plotting eata to beta Iteration

k= (0.4:0.1:2.4);
beta = 0:0.01:2;
f     = 1000;
d     = 0.01;
c     = 340;

i=1;
figure('position', P1);
for kin = k;

Hfront      = 1-beta*exp(-1i*2*pi*f*d/c*(1+kin));
Hlateral   = 1-beta*exp(-1i*2*pi*f*d/c*kin);
Hrear      = 1-beta*exp(-1i*2*pi*f*d/c*(kin-1));
keata1      = 20*log10(abs(Hfront./Hlateral));
keata2     = 20*log10(abs(Hfront./Hrear));


subplot(3,7,i);plot(beta,keata1,'LineStyle','--');
s=strcat('k = ',num2str(kin));
text(1,9,{s},'FontSize',12,'HorizontalAlignment','center')
refline(0,5);
hold all;plot(beta,keata2);ylim([0 20]);refline(0,3);
i=i+1;
end

%% End of File
