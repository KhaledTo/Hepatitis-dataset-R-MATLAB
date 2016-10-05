

help glmfit;
load ../../analyse/hepatite;
hepatite;
survie = categorical(hepatite(:,1));
[b,dev,stats] = glmfit(hepatite(:,2:5),survie,'binomial','link','logit');

%obtenir les odd ratio
odd_ratios = exp(b);

%evaluer performance 
%les probabilités estimées
n = 149;
yfit = glmval(b, hepatite(:,2:5), 'probit', 'size', n);
plot(hepatite(:,2:5), hepatite(:,1)./n, 'o',hepatite(:,2:5), yfit./n, '-');

%scores = stats.p;
%[X,Y,T,AUC] = perfcurve(hepatite(:,1),yfit,'deces');

mdl = fitglm(hepatite(:,2:5),hepatite(:,1),'Distribution','binomial','Link','logit');

scores = mdl.Fitted.Probability;
[X,Y,T,AUC] = perfcurve(survie,scores,'1');

%la performance de notre modèle est équivalent à un modèle aléatoire :
%autrement dit il est sans interêt

plot(X,Y)
xlabel('Taux de Faux Positif')
ylabel('Taux de vrai positif')
title('ROC - Regression Logistique')
