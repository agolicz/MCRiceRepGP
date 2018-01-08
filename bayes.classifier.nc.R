suppressMessages(library(e1071))
suppressMessages(library(caret))
suppressMessages(library(ROCR))
suppressMessages(library(DescTools))
suppressMessages(library(mltools))

set.seed(2)

args <- commandArgs(trailingOnly = TRUE)
outd <- args[1]
trsize <- args[2]
tesize <- args[3]
outputFile <-file(paste(outd,"error.txt",sep="/"))

tryCatch({
t<-read.csv(paste(outd,"PI.scores.nc.both.bayes.na.yn",sep="/"),sep="\t", header=F, row.names=1)
names(t)<-c("ET","EV","P","H","CP","CF","D","CLASS")
id<-sample(2,nrow(t),prob=c(trsize,tesize),replace=T)
emptrain<-t[id==1,]
emptest<-t[id==2,]
emp_nb<-naiveBayes(CLASS ~ ET + EV + P + CF + CF + D, data=emptrain)

t2<-read.csv(paste(outd,"PI.scores.forBayes.na.yn.nc",sep="/"),sep="\t",header=F, row.names=1)
names(t2)<-c("ET","EV","P","H","CP","CF","D")
res<-predict(emp_nb,t2)
t2$RES<-res
write.table(t2,file=paste(outd,"bayes.nc.tsv",sep="/"),sep="\t",row.names=T,quote=F)

save(emp_nb,file=paste(outd,"bayes.nc.classifier.model",sep="/"))
predictions = predict(emp_nb, emptest)
predictions2 = predict(emp_nb, emptest,type='raw')
cm<-confusionMatrix(table(predictions,emptest$CLASS), positive="pos")
nb.sen = cm$byClass['Sensitivity']
nb.spe = cm$byClass['Specificity']
nb.acc = cm$overall['Accuracy']
pa<-predictions
pa<-gsub("pos","TRUE", pa)
pa<-gsub("non","FALSE", pa)
ta<-emptest$CLASS
ta<-gsub("pos","TRUE", ta)
ta<-gsub("non","FALSE", ta)
nb.mcc<-mcc(as.logical(pa),as.logical(ta))
score <- predictions2[, c("pos")]
actual_class <- emptest$CLASS
pred <- prediction(score, actual_class)
perf <- performance(pred, "tpr", "fpr")
roc <- data.frame(fpr=unlist(perf@x.values), tpr=unlist(perf@y.values))
nb.auc = AUC(roc$fpr, roc$tpr)
roc$method <- "Naive Bayes"
save(cm, file=paste(outd,"confusion.nc.matrix",sep="/"))

outputFile2 <-file(paste(outd,"auc.txt",sep="/"))
writeLines(as.character(nb.auc), outputFile2)
outputFile3 <-file(paste(outd,"mcc.txt",sep="/"))
writeLines(as.character(nb.mcc), outputFile3)
close(outputFile2)
close(outputFile3)

print(cm)
cat(paste("AUC: ", nb.auc, "\n",sep=""))
cat(paste("MCC: ", nb.mcc, "\n",sep=""))
writeLines(as.character("SUCCESS"), outputFile)
}, error = function(e) {
writeLines(as.character(e), outputFile)
})
close(outputFile)
