function A=Tumor_area(immagine_tumore_binaria,dx,dy)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Funzione per calvolare l'area di un tumore partendo da una sua immagine
%binaria e contanto pixel per pixel quanti sono quelli bianchi!

% Ingressi -->  Immagine Binaria del tumore.
%               Risoluzione dell'immagine RMI.

% Uscite   -->  Area del tumore.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[I,J]=size(immagine_tumore_binaria);

 pixel_counter=0;

for i=1:I

    for j=1:J
        
        if immagine_tumore_binaria(i,j)==1
             pixel_counter=pixel_counter+1;
        end
    end
end

A=pixel_counter*dx*dy;

end
