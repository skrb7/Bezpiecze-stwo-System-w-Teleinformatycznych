%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 n = 2^24;
 m = 2^10;
 lambda = m^3/(4*n);

 %Odczytywanie liczb z pliku, generator iris-detector
 fid = fopen('dane.bin', 'r');
 data = fread(fid, 'ubit1');
 fclose(fid);
 
 data_bin = reshape(data,32,[]).';
 data_hist = bi2de(data_bin);
     
% ponizej odkomentować aby użyć z liczb z generatora systemowego
%    data_bin = rand(500*1024,1)*(2^32);    
%    data_bin = uint32(data_bin);
%    data_bin = de2bi(data_bin);

  
 for k = 1 : 9
         suma=0;
         for x = 1 : 500

               tab_m = data_bin(((x-1)*m)+1:m*x,1:32);
               tab_bin = tab_m(1:m,k:23+k);
               tab24dec = bi2de(tab_bin,'left-msb');
               afterSort = sort(tab24dec);


             for i = 1024 : -1 : 2

                    afterSpace(i) = afterSort(i) - afterSort(i-1);
                    
             end;

             afterSpaceSort = sort(afterSpace);
            
             no_dup=0;
         
             for i = 2 : m
                if(afterSpaceSort(i) == afterSpaceSort(i-1))
                    no_dup = no_dup + 1 ;
                end;
             end;
               
                  endTab(x) = no_dup;
                
          end;
          
         
%%%%%%%%%%%%%%%%%%%%% Test chi^2
    
                    obs = 500;
                    
                    bins = 0:35;

                    %expected
                    pd = makedist('Poisson','lambda',16);
                    expCounts = obs * pdf (pd,bins);

                    %observed random or test results r
                    obsCounts = hist(endTab,bins);

                    %test
                    [h,p,st] = chi2gof(bins,'Ctrs',bins,...
                                            'Frequency',obsCounts, ...
                                            'Expected',expCounts,...
                                            'NParams',1); 

                   tab_pValue(k) = p;
           

 end;
 
 %%%%%%%%%%%%%%%%%%%% Wykresy
 cd = histogram(endTab, 'Normalization', 'probability')
%  hist(endTab,100);
 figure('NumberTitle', 'off', 'Name', ['p-value ', num2str(p) ]);
 subplot(1,2,1);plot(expCounts);title('oczekiwane');subplot(1,2,2);plot(obsCounts);title('wylosowane');  

%%%%%%%%%%%%%%%%%%%%% KStest
cdf = makedist('uniform'); 
[h,q] = kstest(tab_pValue,cdf)

