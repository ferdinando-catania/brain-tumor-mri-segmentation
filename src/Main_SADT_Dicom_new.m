%%                      Main Tesina SADT

% Il programma si propone di utilizzare le teconiche di segmentazione per
% la ricerca del tumore (Glioblastoma in particolare) nelle immagini
% celebrali di risonanza magnetica (dicom) in modo da poterne estrare delle
% caratteristiche come ad esempio l'area del tumore stesso e la sua forma.

% Parametri di ingresso: -->Immagine DICOM in scala di grigio.                           
                           
% Paramteri di uscita:   -->Immagine ripulita dal cranio.

%                        -->Immagine segmentata con Intensity-based method:
%                                Metodo MST (multisoglia).
%
%                        -->Metodi di Raggruppamento:                        
%                                Region-Growing.
%                             
%                         -->Immagine con il solo tumore estratto. 


% Rilascio :        08/12/21 V.M.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%8%%%%%%%%%%%%%%%%%%%%%%%
%% Caricamento Immagini Dicom %%

close all 
clear all
clc

% Caricamento immagine Dicom e dei Gold Standard generati in precedenza:

%Basta avviare il run della sezione,la finestra di input ti chiederà quale
%immagine vuoi analizzare

%IMPOSTARE I SEGUENTI PARAMETRI IN BASE ALL I'MMAGINE SCELTA: 
%1)T soglia Region Growing:  |0.10 IMG1,IMG3,IMG4,IMG5,IMG8| |0.13 IMG6||0.08 IMG7|
%2)Label Tumore prelevata da MTS( BW_tumor1):  

IM1=dicomread("IMG1.dcm");
IM2=dicomread("IMG2.dcm");
IM3=dicomread("IMG3.dcm");
IM4=dicomread("IMG4.dcm");
IM5=dicomread("IMG5.dcm");
IM6=dicomread("IMG6.dcm");
IM7=dicomread("IMG7.dcm");
IM8=dicomread("IMG8.dcm");

disp('Select a Image number between 1 to 8...')
select=input('Image selected=');


if select==1
IM=IM1;
IM=mat2gray(IM); %converte l'immagine in livello di grigio double, compresi tra [0 1]
info=dicominfo("IMG1.dcm");
dx=info.PixelSpacing(1);
dy=info.PixelSpacing(2);
Gold_std=load("Gold_std1.mat");
Gold_std=struct2cell(Gold_std);
Gold_std=cell2mat(Gold_std);

elseif select==2
IM=IM2;
IM=mat2gray(IM);
info=dicominfo("IMG2.dcm");
dx=info.PixelSpacing(1);
dy=info.PixelSpacing(2);
Gold_std=load("Gold_std2.mat");
Gold_std=struct2cell(Gold_std);
Gold_std=cell2mat(Gold_std);

elseif select==3
IM=IM3;
IM=mat2gray(IM); 
info=dicominfo("IMG3.dcm");
dx=info.PixelSpacing(1);
dy=info.PixelSpacing(2);
Gold_std=load("Gold_std3.mat");
Gold_std=struct2cell(Gold_std);
Gold_std=cell2mat(Gold_std);

elseif select==4
IM=IM4;
IM=mat2gray(IM);
info=dicominfo("IMG4.dcm");
dx=info.PixelSpacing(1);
dy=info.PixelSpacing(2);
Gold_std=load("Gold_std4.mat");
Gold_std=struct2cell(Gold_std);
Gold_std=cell2mat(Gold_std);

elseif select==5
IM=IM5;
IM=mat2gray(IM); 
info=dicominfo("IMG5.dcm");
dx=info.PixelSpacing(1);
dy=info.PixelSpacing(2);
Gold_std=load("Gold_std5.mat");
Gold_std=struct2cell(Gold_std);
Gold_std=cell2mat(Gold_std);

elseif select==6
IM=IM6;
IM=mat2gray(IM);
info=dicominfo("IMG6.dcm");
dx=info.PixelSpacing(1);
dy=info.PixelSpacing(2);
Gold_std=load("Gold_std6.mat");
Gold_std=struct2cell(Gold_std);
Gold_std=cell2mat(Gold_std);

elseif select==7
IM=IM7;
IM=mat2gray(IM); 
info=dicominfo("IMG7.dcm");
dx=info.PixelSpacing(1);
dy=info.PixelSpacing(2);
Gold_std=load("Gold_std7.mat");
Gold_std=struct2cell(Gold_std);
Gold_std=cell2mat(Gold_std);

elseif select==8
IM=IM8;
IM=mat2gray(IM); 
info=dicominfo("IMG8.dcm");
dx=info.PixelSpacing(1);
dy=info.PixelSpacing(2);
Gold_std=load("Gold_std8.mat");
Gold_std=struct2cell(Gold_std);
Gold_std=cell2mat(Gold_std);

else 
disp('Error: Number must be between 1-8!!!!') 

end

clear IM1 IM2 IM3 IM4 IM5 IM6 IM7 IM8
A=Tumor_area(Gold_std,dx,dy); %Area reale del tumore dal Gold standard.


%% Pre-Processing %%
% in questa sezione si prepara l'immagine per le elaborazioni successive
% attraverso un filtraggio passa alto e un filtro a mediana, in modo da
% enfatizzare le componenti ad alta frequenza e migliorare l'aspetto
% generale dell'immagine:

IM_m=medfilt2(IM);% filtro a mediana per migliorare la qualità dell'immagine
IM_ms=imsharpen(IM,'Radius',2,'Amount',1.58); %Filtro per enfatizzare le alte frequenze.

figure(1)
subplot(1,3,1)
imshow(IM)
title('Original Image')
axis on 
subplot(1,3,2)
imshow(IM_m)
title('Median-Filtered Image') 
axis on 
subplot(1,3,3)
imshow(IM_ms);
title('Sharped Image')
axis on 


                       %%  Sezione 3: Skull-Stripping %%
%l'algoritmo proposto dall'articolo è basato su operatori morfologici misti alla 
% segmentazione dell immagine:


T0=graythresh(IM_ms); %Valuto la soglia con il metodo di ostu, per minimizzare la varianza tra le classi di pixel bianchi e neri.
[IM_skullfree,IM_segm,IM_skull]=Skull_remove(IM_ms,T0);

figure()
imshow(IM_skullfree)
title('Skull-Free Image')
axis on 

%% 4.2.3 Segmentazione MTS Multi-thresholding segmentation (soglie Locali) :

T=multithresh(IM_skullfree,4); %Valuta soglie progressive crescenti per la segmentazione dell immagine
B1=IM_skullfree>T(1);
B2=IM_skullfree>T(2);
B3=IM_skullfree>T(3);
B4=IM_skullfree>T(4);

BW_tumor1=B4; %Selezione dell'immagine da cui estrarre il tumore
BW_tumor1 =bwareafilt(BW_tumor1,2); %preleva solo la macchia di pixel connessi più grande
A1=Tumor_area(BW_tumor1,dx,dy);  %[mm^2]

Q_IM=imquantize(IM_skullfree,T); %Creazione di una mappa sovrapposta delle varie immagini segmentate.
RGB_IM=label2rgb(Q_IM); % Conversione della mappa sovrapposta ma a colori.

% Compariamo i risultati ottenuti con il Gold Standard del tumore tramite i
% due coefficienti presi dalla letteratura, Dice e Tanimoto:

num1=2*nnz(BW_tumor1&Gold_std);
den1= nnz(BW_tumor1)+nnz(Gold_std);
Dice1=(num1/den1)*100; %valore percentuale

num2=num1/2;
den2= den1-nnz(BW_tumor1 & Gold_std);
Tanimoto1=(num2/den2)*100; %valore percentuale

clear num1 den1 num2 den2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grafici:

figure()
subplot(2,2,1)
imshow(B1)
title(['T=',num2str(T(1))])
axis on
subplot(2,2,2)
imshow(B2)
title(['T2=',num2str(T(2))])
axis on
subplot(2,2,3)
imshow(B3)
title(['T3=',num2str(T(3))])
axis on
subplot(2,2,4)
imshow(B4)
title(['T4=',num2str(T(4))])
axis on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure() 
subplot(1,2,1)
imshow(BW_tumor1)
title('Tumor by MTS-Segmentation')
axis on 
subplot(1,2,2)
imshow(Gold_std)
title('Gold Standard')
axis on 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure()
subplot(1,2,1)
imshow(RGB_IM,[])
title('RGB-MTS Segmentation')
axis on
subplot(1,2,2)
imshow(Q_IM,[])
title('GreyLevels-MTS Segmentation')
axis on 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Sezione 6 : Algoritmo di Region-Growing
figure()
imshow(IM_skullfree);
title('Skull-Free Image')
axis on 
[y,x]=ginput(1);
x=round(x); y=round(y);
T2=0.10;   
BW_tumor2=Region_growing(IM_skullfree,x,y,T2);
A2=Tumor_area(BW_tumor2,dx,dy); %[mm^2]
figure()
subplot(1,2,1)
imshow((IM_skullfree+BW_tumor2))
axis on 
title('Region-Growing Segmentation')
subplot(1,2,2)
imshow(BW_tumor2)
axis on 
title('Extracted Tumor')

%Compariamo anche in questo caso i risultati ottenuti con il Gold standard

num1=2*nnz(BW_tumor2&Gold_std);
den1= nnz(BW_tumor2)+nnz(Gold_std);
Dice2=(num1/den1)*100; %valore percentuale

num2=num1/2;
den2= den1-nnz(BW_tumor2 & Gold_std);
Tanimoto2=(num2/den2)*100; %valore percentuale

clear num1 den1 num2 den2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
