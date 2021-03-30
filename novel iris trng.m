tic
% Usuniêcie szumów/ wy³agodzenie i rozmazanie obrazu ->
% Szukanie krawêdzi pod odpowiednimi k¹tami ->
% Pocienianie krawêdzi ->
% Usuwanie nieistotnych krawêdzi

clear all;
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%Redukcja szumu %%%%%%%%%%%%%%%%%%%%

final_y=[];
final_x=[];
final_ynn=[];
final_ynp=[];
final_xnn=[];
final_xnp=[];


for zdj = 1:1:8
filename =  [num2str(zdj) '.jpg'];
img = imread(filename);

        img = rgb2gray(img);
        img = double (img);

       yn_end=0;
       yn=0;
       xn=0;
       xn1=0;
       xnn=0;
       xnp=0;
       ynn=0;
       ynp=0;

        %Zmienne do progowania
        T_Low = 0.075;
        T_High = 0.175;

        %Filtr Gaussa
        B = [2, 4, 5, 4, 2; 4, 9, 12, 9, 4;5, 12, 15, 12, 5;4, 9, 12, 9, 4;2, 4, 5, 4, 2 ];
        B = 1/159.* B;

        %Splot obrazu wed³ug wspó³czynnika Gaussa. Efektem tego dzia³ania jest lekko rozmazany obraz, 
        %który nie jest dotkniêty pojedynczymi zak³óceniami w ¿aden znacz¹cy sposób.
        A=conv2(img, B, 'same');

        %%%%%%%%%%%%%%%%%%%%%%%%% Szukanie natê¿enia gradientu obrazu %%%%%%%%%%%%%%%%%%%%

        % KrawêdŸ na obrazie mo¿e byæ skierowana w ró¿nych kierunkach. Algorytm Canny’ego 
        % wykorzystuje wiêc cztery filtry do detekcji poziomych, pionowych oraz przek¹tnych krawêdzi na wyg³adzonym obrazie.
        %Filtr wed³ug kierunku poziomego i pionowego
        KGx = [-1, 0, 1; -2, 0, 2; -1, 0, 1];
        KGy = [1, 2, 1; 0, 0, 0; -1, -2, -1];

        %Splot obrazu poziomy i pionowy
        Filtered_X = conv2(A, KGx, 'same');
        Filtered_Y = conv2(A, KGy, 'same');

        %Obliczanie kierunku / orientacji
        arah = atan2 (Filtered_Y, Filtered_X);
        arah = arah*180/pi;
        pan=size(A,1);
        leb=size(A,2);

        %Dostosowanie do ujemnych kierunków, dziêki czemu wszystkie kierunki s¹ dodatnie
        for i=1:pan
            for j=1:leb
                if (arah(i,j)<0) 
                    arah(i,j)=360+arah(i,j);
                end;
            end;
        end;
        arah2=zeros(pan, leb);

        %Dostosowywanie kierunków do najbli¿szego 0, 45, 90 lub 135 stopni
        for i = 1  : pan
            for j = 1 : leb
                if ((arah(i, j) >= 0 ) && (arah(i, j) < 22.5) || (arah(i, j) >= 157.5) && (arah(i, j) < 202.5) || (arah(i, j) >= 337.5) && (arah(i, j) <= 360))
                    arah2(i, j) = 0;
                elseif ((arah(i, j) >= 22.5) && (arah(i, j) < 67.5) || (arah(i, j) >= 202.5) && (arah(i, j) < 247.5))
                    arah2(i, j) = 45;
                elseif ((arah(i, j) >= 67.5 && arah(i, j) < 112.5) || (arah(i, j) >= 247.5 && arah(i, j) < 292.5))
                    arah2(i, j) = 90;
                elseif ((arah(i, j) >= 112.5 && arah(i, j) < 157.5) || (arah(i, j) >= 292.5 && arah(i, j) < 337.5))
                    arah2(i, j) = 135;
                end;
            end;
        end;


        %%%%%%%%%%%%%%%%%%%%%%%%% Usuwanie niemaksymalnych pikseli %%%%%%%%%%%%%%%%%%%%
        %Obliczanie amplitudy
        magnitude = (Filtered_X.^2) + (Filtered_Y.^2);
        magnitude2 = sqrt(magnitude);
        BW = zeros (pan, leb);


        %Usuwanie niemaksymalnych pikseli
        for i=2:pan-1
            for j=2:leb-1
                if (arah2(i,j)==0)
                    BW(i,j) = (magnitude2(i,j) == max([magnitude2(i,j), magnitude2(i,j+1), magnitude2(i,j-1)]));
                elseif (arah2(i,j)==45)
                    BW(i,j) = (magnitude2(i,j) == max([magnitude2(i,j), magnitude2(i+1,j-1), magnitude2(i-1,j+1)]));
                elseif (arah2(i,j)==90)
                    BW(i,j) = (magnitude2(i,j) == max([magnitude2(i,j), magnitude2(i+1,j), magnitude2(i-1,j)]));
                elseif (arah2(i,j)==135)
                    BW(i,j) = (magnitude2(i,j) == max([magnitude2(i,j), magnitude2(i+1,j+1), magnitude2(i-1,j-1)]));
                end;
            end;
        end;
        BW = BW.*magnitude2;


        %%%%%%%%%%%%%%%%%%%%%%%%% Progowanie histerez¹ %%%%%%%%%%%%%%%%%%%%
        T_Low = T_Low * max(max(BW));
        T_High = T_High * max(max(BW));
        T_res = zeros (pan, leb);
        for i = 1  : pan
            for j = 1 : leb
                if (BW(i, j) < T_Low)
                    T_res(i, j) = 0;
                elseif (BW(i, j) > T_High)
                    T_res(i, j) = 1;
                elseif ( BW(i+1,j)>T_High || BW(i-1,j)>T_High || BW(i,j+1)>T_High || BW(i,j-1)>T_High || BW(i-1, j-1)>T_High || BW(i-1, j+1)>T_High || BW(i+1, j+1)>T_High || BW(i+1, j-1)>T_High)
                    T_res(i,j) = 1;
                end;
            end;
        end;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%Program G³owny%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        wiersze=size(T_res,1);
        kolumny=length(T_res);
        %Wykrywanie wspolrzednych '1'
        z=0;
        for i = 1  : wiersze
            for j = 1 : kolumny
                if (T_res(i,j)== 1)
                    z=z+1;
                end;
            end;
        end



         v=1;
         for i = 1  : wiersze
             for j = 1 : kolumny
                 if (T_res(i,j)== 1)
                     xn(v)=i;
                     v=v+1;
                     xn(v)=j;
                     v=v+1;
                 end;
             end;
         end;       

         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         %Mnozenie cos(an*bn)
        x=1;
        for i = 1 : 2 : z
            xn1(x)=cos(xn(i)* xn(i+1));
            x=x+1;
        end;


        if(mod(z,2)==0)
            w=z;
        else
            w=z-1;
        end;
        
        
        x=1;
        for i = 1 : 2 : w/2
            xnn(x)=xn1(i);
            x=x+1;
        end;


        x=1;
        for i = 2 : 2 : w/2 
               xnp(x)=xn1(i);
               x=x+1;
         end;
        
        
         
        xnn=abs(xnn*255);
        xnp=abs(xnp*255);


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Mnozenie yn=(1/pi)*arcos(x)
        
            for i = 1 : w/2 
              yn(i) = (1/pi)*acos(xn1(i));
            end;
       

        x=1;
        for i = 1 : 2 : w/2
            ynn(x)=yn(i);
            x=x+1;
        end;

        
             x=1;
            for i = 2 : 2 : w/2 
                ynp(x)=yn(i);
                x=x+1;
            end;
       
            

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Wyniki
        ynn=abs(ynn*255);
        ynp=abs(ynp*255);


        yn=abs(yn*255);
        xn1=abs(xn1*255);

        xn_end=floor(xn1);
        yn_end=floor(yn);
        
        final_y=cat(2,final_y,yn_end);
        final_x=cat(2,final_x,xn_end);
        final_xnn=cat(2,final_xnn,xnn);
        final_xnp=cat(2,final_xnp,xnp);
        final_ynn=cat(2,final_ynn,ynn);
        final_ynp=cat(2,final_ynp,ynp);
        
  
   
end;
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(length(final_xnn) > length(final_xnp))
 
    figure
    subplot(1,2,1)
    plot(final_xnn(1:length(final_xnp)),final_xnp,'rs')
    title('Liczby Losowe przed normalizacj¹');
    subplot(1,2,2)
    plot(final_ynn(1:length(final_ynp)),final_ynp,'rs');
    title('Liczby Losowe po normalizacji');  
    
   
else
    figure
    subplot(1,2,1)
    plot(final_xnn,final_xnp(1:length(final_xnn)),'rs')
    title('Liczby Losowe przed normalizacj¹');
    subplot(1,2,2)
    plot(final_ynn,final_ynp(1:length(final_ynn)),'rs');
    title('Liczby Losowe po normalizacji');  
end;

    
figure
subplot(1,2,1)
h = histogram(final_x,255,'Normalization','probability')
xlabel("Wartosc próbki");
ylabel("Prawdopodobieñsto wystêpowania");
title('Liczby Losowe po normalizacji');

subplot(1,2,2)
title('Liczby Losowe przed normalizacj¹');
h = histogram(final_y,255,'Normalization','probability') 
xlabel("Wartosc próbki");
ylabel("Prawdopodobieñsto wystêpowania");
title('Liczby Losowe po normalizacji');


   temp = xn1/max(abs(xn1));
   Entropia_Przed_Post_Processingiem  = entropy(temp);
   Entropia_Przed_Post_Processingiem 
    
   temp = final_y/max(abs(final_y));
   Entropia_Pp_Post_Processingu  = entropy(temp);
   Entropia_Pp_Post_Processingu
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Wpisywanie do pliku
a = de2bi(final_y);
c = reshape(a,[],1);  


file = fopen('dane.bin','w');
z=fwrite(file,c,'ubit1');
fclose(file);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Odczytywanie
 fid = fopen('dane.bin', 'r');
 data = fread(fid, 'ubit1');
 fclose(fid);
 
 y = reshape(data,[],8);  
 s = bi2de(y);
 
 
 %Czas wykonywania Programu
 timeElapsed = toc
