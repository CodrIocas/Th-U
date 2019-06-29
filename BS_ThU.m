function ave()

T=xlsread('Dataset_ThU.xlsx','J2:BE29497');

AGE=T(:,1);
SiO2=T(:,3);
ThU=T(:,42);

Lg_NbTh=T(:,43);
Lg_Th=T(:,44);
LOI=T(:,16);

sampleN=length(AGE);

low = 2900;       % lower limit of window
high = 3100;       % upper limit of window
movestep = 50;
sampleN=length(AGE);

for i = 1:1:sampleN
    if SiO2(i) >= 54;   %remove continental basalts
        ThU(i)=ThU(i);
        SiO2(i)=SiO2(i);
    else
        ThU(i)=nan;
        SiO2(i)=nan;
    end
end

for i = 1:1:sampleN
    if Lg_NbTh(i) <= 0.7;   %remove intracratonic granites
        ThU(i)=ThU(i);
        SiO2(i)=SiO2(i);
    else
        ThU(i)=nan;
        SiO2(i)=nan;
    end
end

for i = 1:1:sampleN
    if Lg_Th(i) <= 1.1;     %remove orogenic granites
        ThU(i)=ThU(i);
        SiO2(i)=SiO2(i);
    else
        ThU(i)=nan;
        SiO2(i)=nan;
    end
end

for i = 1:1:sampleN
    if LOI(i) > 4;
        ThU(i)=nan;
        SiO2(i)=nan;
    end
end

for i = 1:1:sampleN
    if AGE(i) <= 100;
        ThU(i)=nan;
        SiO2(i)=nan;
    end
end

OutlierH=quantile(ThU(~isnan(ThU)),0.975);
OutlierL=quantile(ThU(~isnan(ThU)),0.025);

for i = 1:1: sampleN;   % remove the outliers
    if ThU(i)>OutlierH | ThU(i)<OutlierL
        ThU(i)=nan;
        SiO2(i)=nan;
    end
end

n=[];

for j = 1:1:((low+high)/2/movestep+1)
    
    Step = j
    dataAB=[];
    BinAB=[];
    AB_mean=0;
    AB_sigma=0;
    
    for i = 1:1:sampleN
        if AGE(i) >= low & AGE(i) <= high
            BinAB(i)=ThU(i);
        else
            BinAB(i)=nan;
        end
    end
    
    dataAB=BinAB(~isnan(BinAB));
    n(j)=length(dataAB);
    
    if n(j)>=5       % less than 3 samples will not be calculated.
        BSmean_AB = bootstrp(10000, @mean, dataAB);
    else
        BSmean_AB = [];
    end
    
    result(j,1)=(low+high)/2;    %age
    result(j,2)=mean(BSmean_AB);       %mean
    result(j,3)=2*std(BSmean_AB);      %standard errors
    result(j,4)=n(j);
    
    low = low - movestep;
    high = high - movestep;
    
end

figure(1)
errorbar(result(:,1),result(:,2),result(:,3));

csvwrite('BS_interfel_arc_ThU.csv',result);

end

