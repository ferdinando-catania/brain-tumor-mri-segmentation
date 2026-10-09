function [Skullfreeimage,Binary_image,Skull_image]=Skull_remove(Graylevels_image,Thereshold)

%l'algoritmo proposto dall'articolo è basato su operatori morfologici misti alla segmentazione dell
%  immagine.Si compone dei seguenti step:

%1. Segmentazione dell'immagine a soglia per evidenziare i pixel bianchi.
%2. Riempimento dei contorni, ovvero tutta l'area del cranio.
%3. Rilevamento dei contorni del teschio.
%4. Dilatazione dei contorni ottenuti e creazione della maschera.
%4. Applicazione della maschera all'immagine per la rimozione del teschio.

%%%Ingressi --> immagine in livelli di grigio
%%%         --> Soglia per la segmentazione 

%%%Uscite   --> Immagine a livelli di grigio senza il teschio.
%%%         --> Immagine binaria del cervello segmentato
%%%         --> Immagine binaria del teschio estratto

Binary_image =imbinarize(Graylevels_image,Thereshold);   %Converti l'immagine in bianco e nero in base alla soglia

Filled_image=imfill(Binary_image>Thereshold,'holes'); %Riempi di bianco tutti i pixel del cervello

Edge_detection=bwmorph(Filled_image,'remove');%Rileva i bordi dell cervello

Skull_image= imdilate(Edge_detection, true(55)); % dilato i bordi ottenuti 

Skullfreeimage = Graylevels_image;  %Inizializzo spazio in memoria

Skullfreeimage(Skull_image) = 0; % applico la maschera dilatata all'immagine originale

end
%% 