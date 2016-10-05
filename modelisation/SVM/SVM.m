%chemins liés à la toolbox pour les SVM
chemins

%regression SVM
load ../../analyse/hepatite;
hepatite;
%survie = hepatite(:,1);

hepatite_output=zeros(149,1);
hepatite_output(find(hepatite(:,1)==1),1)=1;
hepatite_output(find(hepatite(:,1)==0),1)=-1;

% Base d’apprentissage
XApp=hepatite(1:60,2:3); 
YApp=hepatite_output(1:60,1:1); 

% Base de test
XTest = hepatite(61:149,2:3); 
YTest = hepatite_output(61:149,1:1); 

%hepatite_in = hepatite(1:149,2:5); 

%apprentissage
kernel='gaussian';kerneloption=1; C=100;
lambda = 1e-7;
[xsup,w,w0,pos,tps,alpha] = svmclass(XApp, YApp, C, lambda, kernel, kerneloption);
ypredapp = svmval(XApp, xsup, w, w0, kernel, kerneloption);
figure
plot(hepatite_in(hepatite_output==1,1),hepatite_in(hepatite_output==1,2),'+r','MarkerSize',10,'LineWidth',2);
hold on
plot(hepatite_in(hepatite_output==-1,1),hepatite_in(hepatite_output==-1,2),'+b','MarkerSize',10,'LineWidth',2);
ax=axis;

plot(xsup(:,1),xsup(:,2),'om','MarkerSize',10,'LineWidth',1);
axis([-1 1 -1 1]);
%evaluation classification
%g1 = YApp;		%groupes connus 
%g2 = ypredapp;	%groupes predits 

%[C,order] = confusionmat(g1,g2)

[X,Y,T,AUC] = perfcurve(YApp,ypredapp,'1');

%la performance de notre modèle est équivalent à un modèle aléatoire :
%autrement dit il est sans interêt

plot(X,Y)
xlabel('Taux de Faux Positif')
ylabel('Taux de vrai positif')
title('ROC - SVM')



%test
kernel='gaussian';kerneloption=1; C=100;
lambda = 1e-7;
[xsup,w,w0,pos,tps,alpha] = svmclass(XTest, YTest, C, lambda, kernel, kerneloption);
ypredapp = svmval(XTest, xsup, w, w0, kernel, kerneloption);
figure
plot(hepatite_in(hepatite_output==1,1),hepatite_in(hepatite_output==1,2),'+r','MarkerSize',10,'LineWidth',2);
hold on
plot(hepatite_in(hepatite_output==-1,1),hepatite_in(hepatite_output==-1,2),'+b','MarkerSize',10,'LineWidth',2);
ax=axis;

plot(xsup(:,1),xsup(:,2),'om','MarkerSize',10,'LineWidth',1);
axis([-1 1 -1 1]);
%evaluation classification
%g1 = YApp;		%groupes connus 
%g2 = ypredapp;	%groupes predits 

%[C,order] = confusionmat(g1,g2)

[X,Y,T,AUC] = perfcurve(YTest,ypredapp,'1');

%la performance de notre modèle est équivalent à un modèle aléatoire :
%autrement dit il est sans interêt

plot(X,Y)
xlabel('Taux de Faux Positif')
ylabel('Taux de vrai positif')
title('ROC - SVM')





