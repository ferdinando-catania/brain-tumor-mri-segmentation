%% Tecniche di Segmentazione per la ricera del tumore in immagini T1-W con contrasto  %%

% Il programma si propone di utilizzare le teconiche di segmentazione per
% la ricerca del tumore (Glioblastoma in particolare) nelle immagini
% celebrali di risonanza magnetica in modo da poterne estrare delle
% caratteristiche.

% Parametri di ingresso:     Immagine MRI in scala di grigio.                           
                           
% Paramteri di uscita:       Immagine ripulita dal cranio.

%                        -->Immagine segmentata con Intensity-based method:
%                        
%                            1)Metodo manuale dell'istogramma.
%                            2)Metodo della segmentazione di otsu. 
%                            3)Metodo della soglia adattativa.
%                            4)Metodo MST (multisoglia).
%
%                        -->Metodi di Raggruppamento:                        
%            
%                            5)Region-Growing.
%                            6)Selezione manuale della ROI.
%                            7)Clustering K-Means.    
%     
%                         -->Immagine con il solo tumore estratto. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%8%%%%%%%%%%%%%%%%%%%%%%%
                     %% Sezione 1 : Caricamento Immagini da cartella %%

close all
clear all 
clc

[Brain,path]=uigetfile('*.jpg','Seleziona immagine da analizzare'); %carico le immagini nelle variabili, contengono tre slices.
Brain=strcat(path,Brain); 
Brain=imread(Brain);
Brain=Brain(:,:,1);%prelevo solo una prima slices.
dxdy=0.0025; %[mm^2] %Risoluzione dei pixel quadrati.

                     %% Sezione 2: Pre-Processing %%
% in questa sezione si prepara l'immagine per le elaborazioni successive
% attraverso un filtraggio passa alto e un filtro a mediana, in modo da
% enfatizzare le componenti ad alta frequenza e migliorare l'aspetto
% generale dell'immagine:

B_sharped=imsharpen(Brain,'Radius',2,'Amount',2); %Filtro per enfatizzare le alte frequenze.

B_sharped_median=medfilt2(B_sharped);% filtro a mediana per migliorare la qualità dell'immagine

figure(1)
subplot(1,3,1)
imshow(Brain)
title('Original Image')
axis on 
subplot(1,3,2)
imshow(B_sharped)
title('Sharped Image') 
axis on 
subplot(1,3,3)
imshow(B_sharped_median)
title('Median Filtered ')
axis on 


                       %%  Sezione 3: Skull-Stripping %%
%l'algoritmo proposto dall'articolo è basato su operatori morfologici misti alla 
% segmentazione dell immagine:

T0=graythresh(Brain);%Valuto la soglia con il metodo di ostu, per minimizzare la varianza tra le classi di pixel bianchi e neri.

[Brain_skullfree,Brain_binary,Skull_binary]=Skull_remove(Brain,T0); %Applico la funzione per la rimozione del cranio dall'immagine.

figure(2)
subplot(1,3,1)
imshow(Brain_binary)
title('Binary Image')
axis on 
subplot(1,3,2)
imshow(Skull_binary)
title('Binary Mask')
axis on 
subplot(1,3,3)
imshow(Brain_skullfree)
title('Maskered Image')
axis on 

%% Sezione 4: Segmentazione per la ricerca del tumore e il suo isolamento%%

%% 4.1 Segmentazione a soglia manuale basata sull'istogramma dell'immagine:

%L'operatore manualmente deve andare sull'istogramma delle occorrenze dei
%livelli di grigio per selzionare una soglia che permetta la segmentazione
%dell immagine che suddivida i pixel di diverse classi appartenenti a
%diversi tessuti.

histogram(Brain_skullfree,'Binlimits',[10 255]);
title('Grey-Levels Histogram')
[x,~]=ginput(1);
T1=x/256;  % x1 picco con valori di girgio alti, x2 è il picco a valori di grigio più bassi.
Brain1=imbinarize(Brain_skullfree,T1);

% Assumendo che il tumore sia la macchia più grande nell'immagine posso
% estrarlo e calcolare area dello stesso e la sua lunghezza
binaryTumorImage1 = bwareafilt(Brain1, 1); %estre oggetto etichettato da un immagine binaria per taglia 
A1=tumor_area(binaryTumorImage1)*dxdy; %[cm^2]
L1=sqrt(A1); %Supponendo il tumore come un quadrato ne calcolo il lato {cm]
 
figure(3)
subplot(1,2,1)
imshow(Brain1)
title('Manual Segmentation')
axis on
subplot(1,2,2)
imshow(binaryTumorImage1)
axis on 
title('Extracted tumor')

%% 4.2 Segmentazione a soglia basata sull'intensità dei singoli pixel:

%Questa tipologia di metodi basati sull'intensità dei pixel per la scelta
%della soglia è molto ampia, ci sono infatti diversi metodi che possiamo
%considerare:

   %% 4.2.1 Segmentazione con il metodo di otsu (soglia globale):

   T2=otsuthresh(imhist(Brain_skullfree)); 
   Brain2 =imbinarize(Brain_skullfree,T2);
   binaryTumorImage2 = bwareafilt(Brain2, 1);
   A2=tumor_area(binaryTumorImage2)*dxdy; %[cm^2]
   L2=sqrt(A2); %Supponendo il tumore come un quadrato ne calcolo il lato {cm]

   figure(4)
   subplot(1,2,1)
   imshow(Brain2)
   axis on 
   title('Otsu Segmentation')
   subplot(1,2,2)
   imshow(binaryTumorImage2)
   axis on 
   title('Extracted Tumor')

   %% 4.2.2 Segmentazione addraverso soglia adattativa (soglie Locali) :

   T3=adaptthresh(Brain_skullfree,0.1,"Statistic","median");  % Sceglie una soglia basata sul valore dei pixel vicini.
   Brain3=imbinarize(Brain_skullfree,T3);

   binaryTumorImage3 = bwareafilt(Brain3, 1);
   A3=tumor_area(binaryTumorImage3)*dxdy; %[cm^2]
   L3=sqrt(A1); %Supponendo il tumore come un quadrato ne calcolo il lato {cm]

   figure(5) 
   subplot(1,2,1)
   imshow(Brain3)
   axis on 
   title('Segmentazione a soglia adattativa')
   subplot(1,2,2)
   imshow(binaryTumorImage3)
   axis on 
   title('Tumore estratto')

   %% 4.2.3 Segmentazione MTS Multi-thresholding segmentation (soglie Locali) :

   T4=multithresh(Brain_skullfree,6); %Valuta soglie progressive crescenti per la segmentazione dell immagine
   Brain4=imquantize(Brain_skullfree,T4); %converte l'immagine a livelli discreti pari a 6+1=7 dati dalle soglie 
   RGB=label2rgb(Brain4); %converte le immagini a livelli dicreti in una sola a colori
   binaryTumorImage4=Brain4==5;
   binaryTumorImage4 = bwareafilt(binaryTumorImage4, 1);
   A4=tumor_area(binaryTumorImage4)*dxdy; %[cm^2]
   L4=sqrt(A4); %Supponendo il tumore come un quadrato ne calcolo il lato {cm]

  figure(6)
for i=1:6  
   subplot(2,3,i)  
   imshow(Brain4,[i i+1])
   title(['T=',num2str(T4(i))])
   axis on
end
   figure(7)
   subplot(1,3,1)
   imshow(RGB)
   axis on
   title('RGB-MTS Segmentation')

   subplot(1,3,2)
   imshow(Brain4, [])
   axis on
   title('Grey-Levels MTS Segmentation')

   subplot(1,3,3)
   imshow(binaryTumorImage4)
   axis on
   title('Extracted Tumor')


%% SEZIONE 5: Segmentazione manuale basata sulla ROI
%Apertura del tool selezione della ROI e creazione della maschera 
imageSegmenter(Brain_skullfree)
%%
T6=adaptthresh(maskedImage,0.1,"Statistic","median");
Brain6 =imbinarize(maskedImage,T6);
binaryTumorImage6 = bwareafilt(Brain6, 1);
A6=tumor_area(binaryTumorImage6)*dxdy; %[cm^2]
L6=sqrt(A6); %Supponendo il tumore come un quadrato ne calcolo il lato {cm]

figure(9)
subplot(1,3,1)
imshow(maskedImage)
title('Skull-Free Image')
axis on
subplot(1,3,2)
imshow(Brain6)
title('Adaptative Segmentation')
axis on
subplot(1,3,3)
imshow(binaryTumorImage6)
title('Extracted Tumor')
axis on
%% Sezione 6 : Algoritmo di Region-Growing
Brain_skullfree=im2double(Brain_skullfree);
imshow(Brain_skullfree);
title('Skull-Free Image')
[y,x]=ginput(1);
x=round(x); y=round(y);
T5=0.15;
Brain5=regiongrowing(Brain_skullfree,x,y,T5);
A5=tumor_area(Brain5)*dxdy; %[cm^2]
L5=sqrt(A5); %Supponendo il tumore come un quadrato ne calcolo il lato {cm]


figure(8)
subplot(1,2,1)
imshow((Brain_skullfree+Brain5))
axis on 
title('Region-Growing Segmentation')
subplot(1,2,2)
imshow(Brain5)
axis on 
title('Extracted Tumor')
%% SEZIONE 7: SEGMEENTAZIONE CON K-MEANS CLUSTERING

Brain7=imsegkmeans(Brain_skullfree,5);
binaryTumorImage7=Brain7==4;
RGB1=label2rgb(Brain7);

figure(10)
subplot(1,3,1)
imshow(Brain7,[])
title('GL K-Means Segmentation')
axis on
subplot(1,3,2)
imshow(RGB1,[])
title('RGB K-Means Segmentation')
axis on
subplot(1,3,3)
imshow(binaryTumorImage7)
title('Extracted tumor')
axis on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


