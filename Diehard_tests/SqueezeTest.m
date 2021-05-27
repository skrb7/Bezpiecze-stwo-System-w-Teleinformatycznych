%Odczytywanie liczb z pliku, generator iris-detector
         fid = fopen('dane.bin', 'r');
         data = fread(fid, 'ubit1');
         fclose(fid);
         flag = 5000000 ;
         data_bin_ran = reshape(data,32,[]).';
         data_bin_ran = bi2de(data_bin_ran);
         data_bin_ran = data_bin_ran ./ 2^32;

% ponizej odkomentowaæ aby u¿yæ z liczb z generatora systemowego
%            data_bin = rand(20000000,1)*(2^32);    
%            data_bin_ran = data_bin ./ 2^32;
%            flag = 5000000 ;


for iterator = 1 : 1
    
Ef = [21.03 57.79 175.54 467.32 1107.83  2367.84 4609.44 8241.16 13627.81 20968.49 30176.12 40801.97 52042.03 62838.28 72056.37 78694.51 82067.55 81919.35 78440.08 72194.12 63986.79 54709.31 45198.52 36136.61 28000.28 21055.67 15386.52 10940.20 7577.96 5119.56 3377.26 2177.87 1374.39 849.70 515.18 306.66  179.39  103.24  58.51  32.69  18.03  9.82  11.21];
 
no_trials=100000;
ratio=no_trials/1000000; 
std = sqrt(84);

    
for i = 1 : 43
    f(i) = 0;
    Ef(i) = Ef(i) * ratio;
end
  
data_ran = data_bin_ran(((iterator-1)*flag)+1:(iterator*flag));


c = 1;
for i = 1 : no_trials
    k = 2147483647;
    j = 1;
    
    while ( (k ~= 1) && (j < 48) )
      k = ceil(k * data_ran(c)); 
      j = j + 1;
      c = c+1;
    end
    
    if( j > 6) 
     j = j-6; 
    
    
    elseif j < 6 
     j = 6; 
     
    
    elseif j > 48 
     j = 48; 
       
    end
    f(j) = f(j) + 1;
end


 chsq = 0;
 tmp = 0;
 p = 0;

 chi = (((f - Ef)).^2) ./ Ef;
 chsq = sum(chi);

 pvalue = 1 - chi2cdf(chsq,42);
 pValueTab(iterator) = pvalue;

end

plot(Ef);
title('Oczekiwane');
figure
plot(f);
title('Otrzymane');

cdf = makedist('uniform'); 
[h,q] = kstest(pValueTab,cdf)
 
