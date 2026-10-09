%% Valutazione del Gold Standard :
%Per confrontare l'immagine del tumore segmentato con i diversi metodi ed
%il tumore reale abbiamo estratto manualmente il tumore più volte nelle
%diverse immagini , realizzandone una maschera binaria con cui confrontare
%il tumore !
clc
clear all
close all

IM=dicomread('IMG2.dcm');
imageSegmenter(IM) %comando da eseguire singolarmente
ROI=BW-BW1;
figure 
imshow(ROI)

%% Caricamento ROI e creazione del Gold STD
 
 R1=load("roi1_img3.mat",'-mat');
 R2=load("roi2_img3.mat",'-mat');
 R3=load("roi3_img3.mat",'-mat');
 R4=load("roi4_img3.mat",'-mat');
 R5=load("roi5_img3.mat",'-mat');
 R1=struct2cell(R1);
 R1=cell2mat(R1);
 R2=struct2cell(R2);
 R2=cell2mat(R2);
 R3=struct2cell(R3);
 R3=cell2mat(R3);
 R4=struct2cell(R4);
 R4=cell2mat(R4);
 R5=struct2cell(R5);
 R5=cell2mat(R5);

 Gold_std3=R1&R2&R3&R4&R5; %intersezione tra le immagini per avere il Gold standard

 figure
 imshow(Gold_std3)
