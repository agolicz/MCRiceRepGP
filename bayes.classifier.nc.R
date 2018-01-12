suppressMessages(library(e1071))
suppressMessages(library(caret))
suppressMessages(library(ROCR))
suppressMessages(library(DescTools))
suppressMessages(library(mltools))

set.seed(2)

args <- commandArgs(trailingOnly = TRUE)
outd <- args[1]
feats <- args[2]
outputFile <-file(paste(outd,"error.txt",sep="/"))

tryCatch({
  d2<-read.csv(paste(outd,"PI.scores.nc.both.bayes.na.yn",sep="/"),sep="\t", header=F, row.names=1)
  names(d2)<-c("ET","EV","P","H","CP","CF","D","CLASS")
  pv<-unlist(strsplit(feats,","))
  fv<-c("CLASS",pv)
  d2<-subset(d2, select=fv)
  f<-sample(5,nrow(d2),prob=c(0.2,0.2,0.2,0.2,0.2),replace=T)
  d2$fold <-f
  nb.sen <- c()
  nb.spe <- c()
  nb.acc <- c()
  nb.auc <- c()
  nb.mcc <- c()
  pdfc<-data.frame()
    for (i in 1:5) {
      d2.1=d2[d2$fold != i,]
      d2.1$fold<-NULL
      d2.2=d2[d2$fold == i,]
      d2.2$fold<-NULL
      m.nbi <- naiveBayes(CLASS ~ ., data=d2.1)
      predictions <- predict(m.nbi, d2.2)
      predictions2 <- predict(m.nbi, d2.2,type='raw')
      cm<-confusionMatrix(table(predictions,d2.2$CLASS))
      nb.sen <- append(cm$byClass['Sensitivity'], nb.sen)
      nb.spe <- append(cm$byClass['Specificity'], nb.spe)
      nb.acc <- append(cm$overall['Accuracy'], nb.acc)
      pa<-predictions
      pa<-gsub("pos","TRUE", pa)
      pa<-gsub("non","FALSE", pa)
      ta<-d2.2$CLASS
      ta<-gsub("pos","TRUE", ta)
      ta<-gsub("non","FALSE", ta)
      mccv<-mcc(as.logical(pa),as.logical(ta))
      nb.mcc <- append(mccv, nb.mcc)
      score <- predictions2[, c("pos")]
      actual_class <- d2.2$CLASS
      pred <- prediction(score, actual_class)
      perf <- performance(pred, "tpr", "fpr")
      roc <- data.frame(fpr=unlist(perf@x.values), tpr=unlist(perf@y.values))
      nb.auc <- append(AUC(roc$fpr, roc$tpr),nb.auc)
      roc$fold <- paste("Fold",as.character(i),sep=" ")
      roc$method <- "Non-Coding"
      pdfc <- rbind(pdfc,roc)
    }
  sim.res <- data.frame()
  tdf<-data.frame(value=nb.sen,measure=rep("Sensitivity", length(nb.sen)), method="Naive Bayes")
  sim.res<-rbind(tdf,sim.res)
  tdf<-data.frame(value=nb.spe,measure=rep("Specificity", length(nb.spe)), method="Naive Bayes")
  sim.res<-rbind(tdf,sim.res)
  tdf<-data.frame(value=nb.acc,measure=rep("Accuracy", length(nb.acc)), method="Naive Bayes")
  sim.res<-rbind(tdf,sim.res)
  tdf<-data.frame(value=nb.auc,measure=rep("AUC", length(nb.auc)), method="Naive Bayes")
  sim.res<-rbind(tdf,sim.res)
  tdf<-data.frame(value=nb.mcc,measure=rep("MCC", length(nb.mcc)), method="Naive Bayes")
  sim.res<-rbind(tdf,sim.res)

  save(sim.res, file=paste(outd,"classifer.stats",sep="/"))
  save(pdfc, file=paste(outd,"classifer.roc",sep="/")) 
  
  tdf.sn <- subset(sim.res, measure == "Sensitivity")
  tdf.sp <- subset(sim.res, measure == "Specificity")
  tdf.acc <- subset(sim.res, measure == "Accuracy")
  tdf.auc <- subset(sim.res, measure == "AUC")
  tdf.mcc <- subset(sim.res, measure == "MCC")
  cat("Sensitivity: ", mean(tdf.sn$value),"(",sd(tdf.sn$value),")","\n",sep="")
  cat("Specificity: ", mean(tdf.sp$value),"(",sd(tdf.sp$value),")","\n",sep="")
  cat("Accuracy: ", mean(tdf.acc$value),"(",sd(tdf.acc$value),")","\n",sep="")
  cat("AUC: ", mean(tdf.auc$value),"(",sd(tdf.auc$value),")","\n",sep="")
  cat("MCC: ", mean(tdf.mcc$value),"(",sd(tdf.mcc$value),")","\n",sep="")

  d2$fold <- NULL
  m.nbif = naiveBayes(CLASS ~ ., data=d2)
  save(m.nbif,file=paste(outd,"bayes.nc.classifier.model",sep="/"))
  t2<-read.csv(paste(outd,"PI.scores.forBayes.na.yn.nc",sep="/"),sep="\t",header=F, row.names=1)
  names(t2)<-c("ET","EV","P","H","CP","CF","D")
  fv2<-setdiff(fv, "CLASS")
  t3<-subset(t2, select=fv2)
  res<-predict(m.nbif,t3)
  t2$RES<-res
  write.table(t2,file=paste(outd,"bayes.nc.tsv",sep="/"),sep="\t",row.names=T,quote=F)

writeLines(as.character("SUCCESS"), outputFile)

}, error = function(e) {
writeLines(as.character(e), outputFile)
})
close(outputFile)
