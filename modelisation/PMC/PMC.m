global options
% addpath : pour ajouter le chemin d’accès aux fonctions Netlab
addpath netlab3
load ../../analyse/hepatite;
%on decompose le jeu de données en deux trois bases selon la règle des 
%

[n, p] = size(hepatite);
%taille des différents échantillons

%constitution des différentes bases : on aurait pû échantillonner les
%données de manière plus élaborée ; aléatoire, représentation plus grande 
%des valeurs rares etc

% 40 % des données 
%DAppTaille = 60;
% 60 % des données 
%DTestTaille = n - 60;

% Base d’apprentissage
XApp=hepatite(1:60,2:5); 
YApp=hepatite(1:60,1:1); 

% Base de test
XTest = hepatite(61:149,2:5); 
YTest = hepatite(61:149,1:1); 

hepatite_output=zeros(149,2);
hepatite_output(find(hepatite(:,1)==1),1)=1;
hepatite_output(find(hepatite(:,1)==0),2)=1;

net = mlp(4,1,1,'softmax');

options = foptions; % vecteur contenant les param`etres d’apprentissage
options(1) = 1; % on active l’affichage des erreurs
options(14) = 200; % nombre de cycles d’apprentissage
options(18) = 0.8; % le pas d’apprentissage

% Apprentissage
Ycal = mlpfwd(net, XApp);

options = foptions; % vecteur contenant les param`etres d’apprentissage
options(1) = 1; % on active l’affichage des erreurs
options(14) = 100; % nombre de cycles d’apprentissage
options(18) = 0.001; % le pas d’apprentissage
% Apprentissage
[Net options errlog] = netopt(net, options, XApp, YApp, 'graddesc');

%Test 

%Calcul de l'ARV
    YTestCalc = mlpfwd(BestNet, XTest);
    save YTestCalc;
    num = ((sum((YTest - YTestCalc) .^2)) / size(YTest,1));
    den = ((sum((output - mean(output)) .^2)) / size(output,1));
    ARV(nhidden, :) = num / den;
 % Afficher l'ARV    
fprintf('ARV : %d\n', ARV(nhidden,:));



