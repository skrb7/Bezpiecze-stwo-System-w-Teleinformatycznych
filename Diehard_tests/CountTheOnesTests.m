 %Odczytywanie liczb z pliku, generator iris-detector
         fid = fopen('dane.bin', 'r');
         data = fread(fid, 'ubit1');
         fclose(fid);
         flag = 300000 ;
         data_bin_ran = reshape(data,8,[]).';

% ponizej odkomentować aby użyć z liczb z generatora systemowego
%            data_bin = rand(10000000,1)*(2^8);    
%            data_bin = uint8(data_bin);
%            data_bin_ran = de2bi(data_bin);
%            flag = 300000 ;

 for iterator = 1 : 24

         slowa = data_bin_ran(((iterator-1)*flag)+1:(iterator*flag),1:8);
       
        for i=1:300000 
            zliczone(i)= sum(slowa(i,1:8));
            switch zliczone(i)
                case {0,1,2}
                letters(i)='a';
                case 3
                letters(i)='b';
                case 4
                letters(i)='c';
                case 5
                letters(i)='d';
                case {6,7,8}
                letters(i)='e';
            end
        end


            %Słowa 5 Literowe
            for i = 1 : 256000-4
              words_five(i) = cellstr(letters((1+i)-1:(5+i)-1));
            end;

              words_five(255997) = strcat(cellstr(letters(255997:256000)),letters(1:1));
              words_five(255998) = strcat(cellstr(letters(255998:256000)),letters(1:2));
              words_five(255999) = strcat(cellstr(letters(255999:256000)),letters(1:3));
              words_five(256000) = strcat(cellstr(letters(256000:256000)),letters(1:4));
              words_five = string(words_five);


            %Słowa 4 Literowe
            for i = 1 : 256000-4
              words_four(i) = cellstr(letters(1+i:4+i));
            end;
              words_four(255997) = cellstr(letters(255997:256000));
              words_four(255998) = strcat(cellstr(letters(255998:256000)),letters(1:1));
              words_four(255999) = strcat(cellstr(letters(255999:256000)),letters(1:2));
              words_four(256000) = strcat(cellstr(letters(256000:256000)),letters(1:3));

              words_four = string(words_four);


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Unikalne słowa o długosci 4
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        no_wds = 256000; 
        ltrspwd = 4;
        wdspos = 5^ltrspwd; 
        prob = [37/256 56/256 70/256 56/256 37/256]; 
        x = '';
        for k=0:wdspos-1
              Ef = no_wds;
              wd  = k;
              for l=1:ltrspwd 
                ltr = mod(wd,5)+1;
                switch ltr
                    case 1
                        x = strcat(x,'a');
                    case 2
                        x = strcat(x,'b');
                    case 3
                        x = strcat(x,'c');
                    case 4
                        x = strcat(x,'d');
                    case 5
                        x = strcat(x,'e');
                end
                wd = floor( wd/5); 
              end

              unique_four(k+1) = string(x);
              x = '';
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Unikalne słowa o długosci 4
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        no_wds = 256000; 
        ltrspwd = 5;
        wdspos = 5^ltrspwd; 
        prob = [37/256 56/256 70/256 56/256 37/256]; 
        x = '';
        for k=0:wdspos-1
              Ef = no_wds;
              wd  = k;
              for l=1:ltrspwd 
                ltr = mod(wd,5)+1;
                switch ltr
                    case 1
                        x = strcat(x,'a');
                    case 2
                        x = strcat(x,'b');
                    case 3
                        x = strcat(x,'c');
                    case 4
                        x = strcat(x,'d');
                    case 5
                        x = strcat(x,'e');
                end
                wd = floor( wd/5); 
              end

              unique_five(k+1) = string(x);
              x = '';
        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Przewidywane wartosci dla słowa o długosci 4
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        no_wds = 256000; 
        ltrspwd = 4;
        wdspos = 5^ltrspwd; 
        prob = [37/256 56/256 70/256 56/256 37/256]; 

        for k=0:wdspos-1
              Ef = no_wds;
              wd  = k;
              for l=1:ltrspwd 
                ltr = mod(wd,5)+1;
                Ef = Ef*prob(ltr); 
                wd = floor( wd/5);
              end
             e_four(k+1)=Ef;
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Przewidywane wartosci dla słowa o długosci 5
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        no_wds = 256000; 
        ltrspwd = 5;
        wdspos = 5^ltrspwd; 
        prob = [37/256 56/256 70/256 56/256 37/256]; 

        for k=0:wdspos-1
              Ef = no_wds;
              wd  = k;
              for l=1:ltrspwd 
                ltr = mod(wd,5)+1;
                Ef = Ef*prob(ltr); 
                wd = floor( wd/5);
              end
             e_five(k+1)=Ef;
        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Zliczanie słów o długosci 4
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

           for i = 1 : 625
            temp = count(words_four,unique_four(i));
            occurrence_four(i) = sum(temp(:));
            end;

            figure;
            plot(occurrence_four);
            title('Słowa o długosci 4');


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Zliczanie słów o długosci 5
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           for i = 1 : 3125
            temp = count(words_five,unique_five(i));
            occurrence_five(i) = sum(temp(:));
            end;

            figure
            plot(occurrence_five);
            title('Słowa o długosci 5');


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Porówanie wartosci wykresów
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

        for i = 1 : 625

            diff_four(i) = ((occurrence_four(i) - e_four(i)).^2) / e_four(i);

        end

        for i = 1 : 3125

            diff_five(i) = ((occurrence_five(i) - e_five(i)).^2) / e_five(i);

        end

        diff_general = sum(diff_five) - sum(diff_four);

        z = (diff_general - 2500) / (sqrt(5000)); 
        Value = 1 -  normcdf(z);
        pValueTab(iterator) = Value; 
end        
    
cdf = makedist('uniform'); 
[h,q] = kstest(pValueTab,cdf)
