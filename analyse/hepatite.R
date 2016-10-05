###############################################################
"Khaled Ben Abdallah - Data analysis of the Hepatitis dataset"
###############################################################

votre_dossier = "YOUR_FOLDER"
setwd(votre_dossier)
hepatite = read.csv("hepatite.csv", header = TRUE, stringsAsFactors=FALSE)

#Les points interro correspondent aux valeurs manquantes
#On remplace les ? par des valeurs manquantes sous format R
hepatite[hepatite=='?'] <- NA

#recoder le fichier 
hepatite$SURVIE[hepatite$SURVIE==1] <- "D"
hepatite$SURVIE[hepatite$SURVIE==2] <- "V"

hepatite$SEXE[hepatite$SEXE==1] <- "M"
hepatite$SEXE[hepatite$SEXE==2] <- "F"

hepatite[4:14][hepatite[4:14]==1] <- "N"
hepatite[4:14][hepatite[4:14]==2] <- "O"

hepatite[20][hepatite[20]==1] <- "N"
hepatite[20][hepatite[20]==2] <- "O"

#le sauvegarder
write.csv(hepatite, file = "hepatite_recode.csv")

hepatite = read.csv("hepatite_recode.csv", header = TRUE, stringsAsFactors=FALSE)
#utilise pour affichage sous excel uniquement
hepatite[, 1] <- NULL
#hepatite$id_patient<- NULL

hepatite[, 15]  <- as.numeric(hepatite[, 15]) 
hepatite[, 16]  <- as.numeric(hepatite[, 16]) 
hepatite[, 17]  <- as.numeric(hepatite[, 17]) 
hepatite[, 18]  <- as.numeric(hepatite[, 18]) 
hepatite[, 19]  <- as.numeric(hepatite[, 19]) 

##############################
"FIN TRAITEMENT VALEURS NA"
##############################

#% valeur manquantes
val_manquantes <- colMeans(is.na(hepatite))
val_manquantes 
#grid.table(colMeans(is.na(hepatite)))

#si NA > 15/20% : on choisit de ne pas retenir la variable 
#on supprime les variables PHOSPHATASE.ALCALINE et TAUX.DE.PROTHROMBIE du dataset
hepatite$PHOSPHATASE.ALCALINE<- NULL
hepatite$TAUX.DE.PROTHROMBIE<- NULL

#idem en ligne sur patients
ligne_val_NA = apply(hepatite, 1, function(x) sum(is.na(x))) / ncol(hepatite) * 100

id <- rownames(hepatite)
hepatite <- cbind(id=id,  hepatite)

for(i in 1:nrow(hepatite)){
  
  if(ligne_val_NA[i] > 16.7){
    cat("Suppression de \n",i,"\n")
    hepatite<-hepatite[!hepatite$id==i,]
  }
  
} 

hepatite$id<- NULL

#les noms de colonnes
col_names <- names(hepatite)

#variable SURVIE
hepatite$SURVIE <- as.factor(hepatite$SURVIE)
#variables de 3 à 14 en factor
hepatite[,col_names[3:14]] <- lapply(hepatite[col_names[3:14]] , factor)
#AGE n'était pas en numérique
hepatite$AGE <- as.numeric(hepatite$AGE)
#variable 20
hepatite$HISTOLOGIE <- as.factor(hepatite$HISTOLOGIE)

#verifier type : factor ou numérique ?
sapply(hepatite, class)

##############################
"DISCRETISATION"
##############################

#vue d'ensemble
summary(hepatite)

#decoupage age
q<-quantile(hepatite$AGE,probs=seq(0,1,by=.3))
AGE<-cut(hepatite$AGE,q)
tab<-table(AGE,hepatite$SURVIE)
tab
prop.table(tab,1)
#graphique
barplot(t(prop.table(tab,1) [,1]), las=3, ylim=c(0,1),  main="AGE", ylab="DECES", density=0 )
abline(h=.2, lty=2)
hepatite$AGE_discret[hepatite$AGE <= 41] <- "AG <= 41"
hepatite$AGE_discret[hepatite$AGE > 41] <- "AG > 41"

#code pour envoyer ctrl + L : nettoyer la console
cat("\014") 

#croisement entre deciles BILIRUBIN et variable DIE/LIVE
q<-quantile(hepatite$BILIRUBINE,na.rm = TRUE)
BILIRUBINE<-cut(hepatite$BILIRUBINE,q)
tab<-table(BILIRUBINE,hepatite$SURVIE)
tab
prop.table(tab,1)
#graphique
barplot(t(prop.table(tab,1) [,1]), ylim=c(0,1), las=3, main="BILIRUBINE", ylab="DECES", density=0 )
abline(h=.2, lty=2)
hepatite$BILIRUBINE_discret[hepatite$BILIRUBINE <= 1] <- "BI <= 1"
hepatite$BILIRUBINE_discret[hepatite$BILIRUBINE > 1] <- "BI > 1"


#decoupage SGOT
q<-quantile(hepatite$SGOT,probs=seq(0,1,by=.1),na.rm = TRUE)
SGOT<-cut(hepatite$SGOT,q)
tab<-table(SGOT,hepatite$SURVIE)
tab
prop.table(tab,1)
#graphique
barplot(t(prop.table(tab,1) [,1]), ylim=c(0,1), las=3, main="SGOT", ylab="DECES", density=0 )
abline(h=.2, lty=2)
hepatite$SGOT_discret[hepatite$SGOT <= 30] <- "SG <= 30"
hepatite$SGOT_discret[hepatite$SGOT > 30 & hepatite$SGOT <= 48] <- "SG >30 <=48"
hepatite$SGOT_discret[hepatite$SGOT > 48] <- "SG > 48"

#decoupage  ALBUMIN
q<-quantile(hepatite$ALBUMINE,na.rm = TRUE)
ALBUMINE<-cut(hepatite$ALBUMINE,q)
tab<-table(ALBUMINE,hepatite$SURVIE )
prop.table(tab,1)
#graphique
barplot(t(prop.table(tab,1) [,1]), ylim=c(0,1), las=3, main="ALBUMINE", ylab="DECES", density=0 )
abline(h=.2, lty=2)
hepatite$ALBUMINE_discret[hepatite$ALBUMINE <= 3.45] <- "AL <= 3.45"
hepatite$ALBUMINE_discret[hepatite$ALBUMINE > 3.45] <- "AL > 3.45"

#on supprime de l'analyse les variable non discretisées
hepatite$AGE<- NULL
hepatite$BILIRUBINE<- NULL
hepatite$SGOT<- NULL
hepatite$ALBUMINE<- NULL

#bien remettre en factor
col_names <- names(hepatite)
hepatite[,col_names] <- lapply(hepatite[,col_names] , factor)

#sauvegarder le dataset 
save(hepatite,file="hepatite.Rda")

##############################
"VCramer"
##############################

cols <- -grep(('SURVIE'),names(hepatite))
hepatite_tmp <- hepatite[,cols]
#on construit une matric vide ou on mettra les resultats
cramer <- matrix(NA,ncol(hepatite_tmp), 2)
for(i in (1 : ncol(hepatite_tmp)))
#le nom des variables
{cramer[i, 1] <- names(hepatite_tmp[i])
#le calcul
cramer[i, 2] <- sqrt(chisq.test(table(hepatite_tmp[,i],
hepatite$SURVIE))$statistic / length(hepatite_tmp[,i]))

}
#nommer les variables
colnames(cramer) <- c("variable", "V Cramer")
vcramer <- cramer [order (cramer[, 2], decreasing='T'),]

install.packages("questionr")
library("questionr")
cramer <- matrix(NA,ncol(hepatite_tmp), ncol(hepatite_tmp) )
#chaque colonne boucle sur chacune des colonnes
for(i in (1 : ncol(hepatite_tmp))){
  for(j in (1 : ncol(hepatite_tmp))){
    
    cramer[i,j] <-cramer.v(table(hepatite_tmp[,i], hepatite_tmp[,j]))
  }
}

colnames(cramer) <- colnames(hepatite_tmp)
rownames(cramer) <- colnames(hepatite_tmp)

install.packages("corrplot")
library(corrplot)
corrplot(cramer, type="upper", tl.srt = 90, tl.col = "black", diag=F, addCoef.col = "black", 
         addCoefasPercent = T)

##############################
"ACM : PREMIERE ITERATION"
##############################

#la var illustrative : la variable a expliquer
#le tableau disjonctif est cree automatiquement par la fonction MCA, voir code ici 
#https://github.com/cran/FactoMineR/blob/master/R/MCA.R

install.packages("FactoMineR")
library(FactoMineR)
install.packages("missMDA")
library(missMDA)
nb <- estim_ncpMCA(hepatite)

#on renomme les champs en prenant les trois premieres lettres 
names(hepatite) <- sapply(names(hepatite),function(z) {
  sub("",substring(z,0,3),"")
})
names(hepatite)[8] <- "FOIG"
names(hepatite)[9] <- "FOIF"

#fonction pour remplacer les valeurs manquantes par le mode
Mode <- function (x, na.rm) {
  xtab <- table(x)
  xmode <- names(which(xtab == max(xtab)))
  if (length(xmode) > 1) xmode <- ">1 mode"
  return(xmode)
}
#imputation par la valeur modale
for (var in 1:ncol(hepatite)) {
    hepatite[is.na(hepatite[,var]),var] <- Mode(hepatite[,var], na.rm = TRUE)
}

complete <- hepatite
names(complete)

##############################
"CAH" 
##############################
res.mca <- MCA (complete, quali.sup = 1, graph = TRUE)
res.hcpc <- HCPC(res.mca)
##############################
"PATIENTS ATYPIQUES" 
##############################

##############################
"DEUXIEME ITERATION" 
##############################

#obtenir la liste des indications disponibles
res.mca

#val propres et cos2
res.mca$eig
res.mca$var$cos2
res.mca$var$v.test
res.mca$var$contrib
res.mca$quali.sup

#graph des valeurs propres
plot(res.mca$eig[,1],type="b",main="Valeurs propres",xlab="Composante", ylab="Valeurs propres")
#patients
plot(res.mca,invisible=c("var","quali.sup"), title="Hepatite - patients",habillage=1)
#modalites
plot(res.mca,invisible="ind", title="Hepatite - modalités",autoLab="yes", cex=0.6)
#aide a l'interpretation
abline(v=.48, lty=1, col = "blue")
abline(v=-.48, lty=1, col = "blue")
abline(h=.32, lty=1, col = "green")
abline(h=-.32, lty=1, col = "green")
#variables
plot(res.mca,choix="var", title="Hepatite - variables",  cex=0.7)

summary(hepatite)

#classification
res.mca <- MCA(complete,ncp=4, quali.sup = 1, graph = FALSE)
res.hcpc <- HCPC(res.mca)

load("hepatite.Rda")
#recoder la variable SURVIE 
hepatite$SURVIE <- ifelse(hepatite$SURVIE == "D", 0, ifelse(hepatite$SURVIE == "V", 1, 99))

#ajouter la variable à expliquer 
MCA_individus_SURVIE = res.mca$ind$coord;
MCA_individus_SURVIE = cbind(MCA_individus_SURVIE, SURVIE = hepatite$SURVIE);
#mettre variable à epliquer en premier
MCA_individus_SURVIE = MCA_individus_SURVIE[,c(5,1,2,3,4)];

install.packages("R.matlab")
library(R.matlab)
#exporter le dataset res.mca et poursuivre sous MATLAB 
#un csv aurait été suffisant mais il était facile de générer un fichier
#sous format MATLAB avec R
writeMat("hepatite.mat", hepatite = MCA_individus_SURVIE)
#fin analyse des données "classique"


