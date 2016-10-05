%charger la toolbox
addpath 'somtoolbox';
%charger le dataset avec les coordonnées des individus
load ../hepatite;
help som_data_struct;

%la première variable correspond à la variable à expliquer
struct_Data = som_data_struct(hepatite(:,2:5), 'name', 'hepatite');
msize = [6, 6];
%nous avons quatre variables
insize = size(struct_Data.data, 2);

%{
lattice = treillis 
%}
lattice = 'rect';
shape = 'sheet';
som_map = som_map_struct(insize, 'msize', msize, lattice, shape);
help som_map_struct;

%initialisation des poids de la carte (aléatoire au début)
som_map = som_randinit(struct_Data, som_map);
%autre possibilité d'initialisation : 
help som_lininit;
%lininit 

%au cas ou on voudrait reinitialiser le graph
hold off;
%redessinerle graph
%preparer le canvas
figure;

%on représente les individus sur les deux premiers facteurs
plot(hepatite(:,2), hepatite(:,3), 'b+');
%ne pas effacer le tracé précédent 
hold on;
%parametre defaut : correspond à coord lattice
%codebook = poids de chaque neurone ; on retient uniquement les deux
%premiers facteurs
som_grid(som_map,'Coord',som_map.codebook(:,1:2));
help som_grid;
axis on
title('Données et structure de la grille');



%deux phases dans l'entrainement de la carte :
%1)approcher les données : peut être passé si linéaire : radius élevé
%2)ajuster la carte radius plus faible

%entrainement de la carte
epochs = 50;
radius_ini = 5;
radius_fin = 1;
Neigh = 'gaussian'; % Neigh = 'gaussian', 'cutgauss', 'bubble' ou 'ep'
tr_lev = 3;
%epochs = 100; radius_ini = 1; radius_fin = 0.1;
figure
%la structure de la map est en sortie -> update des coordonnées
[som_map,sT] = som_batchtrain(som_map, struct_Data,'trainlen',epochs,... 
'radius_ini',radius_ini,'radius_fin',radius_fin, 'neigh',Neigh,'tracking',tr_lev);

%seconde phase : convergence
epochs = 100;
radius_ini = 1;
radius_fin = 0.1;
Neigh = 'gaussian'; % Neigh = 'gaussian', 'cutgauss', 'bubble' ou 'ep'
tr_lev = 3;
%epochs = 100; radius_ini = 1; radius_fin = 0.1;
figure
%la structure de la map est en sortie -> update des coordonnées
[som_map,sT] = som_batchtrain(som_map, struct_Data,'trainlen',epochs,... 
'radius_ini',radius_ini,'radius_fin',radius_fin, 'neigh',Neigh,'tracking',tr_lev);

help som_batchtrain;

figure
plot(hepatite(:,2),hepatite(:,3),'b+')
hold on
som_grid(som_map,'Coord',som_map.codebook(:,1:2)), hold off, axis on
%title('Phase 1 : auto organisation');
title('Phase 2 : convergence');

[qe_conv,te_conv]=som_quality(som_map,struct_Data);
%difficulté évaluation qualité som

%representation par U-Matrix
U = som_umat(som_map);
c=som_colorcode(som_map,'rgb1');
som_show(som_map,'comp',[1 2],'umat',{1:2,'1,2 only'},'umat','all', ...
  'color',{c,'Color code'},'bar','vert','norm','n','comp',3)

