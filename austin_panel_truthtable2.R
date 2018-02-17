#  Fin:  Use These:
# mein <-30  # use 5 for astro-only raster, use 13 for prediction.  number of bins for MEI plus 1.  Use 3 bins or more. Same num bins for meilag.
#lout2 <- 49 # number of bins for omega plus 1
#lout3 <- 13 # number of bins for for solarmo plus 1
#lout4 <- 13 # number of bins for sunspots/GN plus 1
#lout5 <- 13 # number of bins for moonmonths plus 1
#loutApsides <- 49 # one plus the number of bins for periapsis of lunar orbit which has 8.8 yr cycle thus about 100 will cover it.
#  The larger detail is useful for apsides and phaselvl, where detail is that fine.
# For the other input variables the bigger level of detail just dilutes a weak signal.
# Likewise the large number of mein enables fine variations to show up.
#

m <- 100 # number of loops of 80/20 model/predict to accumulate

# First calculate the model for MEI based on five astronomical variables

b<-data_block_df[,c("meilvl","phaselvl","apsideslvl","sslvl","solarmolvl","monthlvl","meilaglvl","edate")] # copy the data block and call it b, for manipulation in the train/test, adding columns and trimming them.
train<-ifelse(runif(nrow(b))<0.80,1,0)
b<-data.frame(cbind(b,train))
trainColNum<-grep("train",names(b)) 
dateColNum<-grep("edate",names(b)) 
trainb <-b[b$train==1,]
testb <-b[b$train==0,]
mei_model<-naiveBayes(meilvl~.,data=trainb[-c(trainColNum,dateColNum)])
mei_test_predict_df <- data.frame(predict(mei_model,testb[,-1]))
colnames(mei_test_predict_df)<-c("mei_pr_level") 
table(pred=mei_test_predict_df$mei_pr_level,true=testb$meilvl)
compare_df<-data.frame(table(pred=mei_test_predict_df$mei_pr_level,true=testb$meilvl)) # an accumulator

finding <- mean(mei_test_predict_df$mei_pr_level==testb$meilvl)
finding
finding_acc<-finding # an accumulator

# Change the forecast in levels to a forecast in values, in several ways.

test_centers <- transform(mei_test_predict_df, mei_pr_ctr=meicenters[as.integer(mei_pr_level)])
test_heights<-transform(mei_test_predict_df, mei_pr_height=meibinsheight[as.integer(mei_pr_level)])
test_forecast<-cbind(test_centers,test_heights)
test_forecast2<-test_forecast # Initialize an accumulator for the forecast in values, and keep a list of dates to go with it
testb2<-testb # dates to go with that

# Truth table for this model which does not use persistence

pmodel<- ggplot(compare_df,aes(true,pred))
pmodel+geom_raster(aes(fill=Freq),interpolate=TRUE) +scale_fill_gradientn(colours=c("#0000FFFF","#FFFFFFFF","#FF0000FF")) # what the figure shows is that the El Nina usually occurs at set phases while El Nino is complementary but still less particular

# Plot models based on single run, just to see difference the hundred runs will make.
# And at the same time initialize all the accumulators.
#
# As for interpretation of phaselvl, note that time advances BACKWARD; this angle goes DOWN year to year.
# Mention that Nov 2015 had phaselvl around 180. Dec 2016 was in the range 153 to 163. only 108 to 120 has more than even likelihood of El Nino and I wonder whether it is contaminated by an event.
#
mei_phaselvl_df<-data.frame(mei_model$tables$phaselvl)
p51<- ggplot(mei_phaselvl_df,aes(phaselvl,Y))
p51+geom_raster(aes(fill=Freq),interpolate=TRUE) +scale_fill_gradientn(colours=c("#0000FFFF","#FFFFFFFF","#FF0000FF"))  +theme(axis.text.x = element_text(angle = 90, hjust = 1))
mei_phaselvl_df_acc<-mei_phaselvl_df

# Plot model of suspots.  what this shows is again that it is the Nina that is particular - only occur in low sunspot eras
#
mei_sslvl_df<-data.frame(mei_model$tables$sslvl)
p52<- ggplot(mei_sslvl_df,aes(sslvl,Y))
p52+geom_raster(aes(fill=Freq),interpolate=TRUE) +scale_fill_gradientn(colours=c("#0000FFFF","#FFFFFFFF","#FF0000FF"))
mei_sslvl_df_acc<-mei_sslvl_df

# Plot model of solarmolvl  - again, the La Nina is very definite on which months are La Nina months
#
mei_solarmolvl_df<-data.frame(mei_model$tables$solarmolvl)
p53<- ggplot(mei_solarmolvl_df,aes(solarmolvl,Y))
p53+geom_raster(aes(fill=Freq),interpolate=TRUE) +scale_fill_gradientn(colours=c("#0000FFFF","#FFFFFFFF","#FF0000FF"))
mei_solarmolvl_df_acc<-mei_solarmolvl_df

# Plot model of monthlvl-it is vague but it seems the Nina is less likel to occur from May to August; La Nina is less likely Jan to April.
#
mei_monthlvl_df<-data.frame(mei_model$tables$monthlvl)
p54<- ggplot(mei_monthlvl_df,aes(monthlvl,Y))
p54+geom_raster(aes(fill=Freq),interpolate=TRUE) +scale_fill_gradientn(colours=c("#0000FFFF","#FFFFFFFF","#FF0000FF"))
mei_monthlvl_df_acc<-mei_monthlvl_df

# Plot model of apsideslvl

mei_apsideslvl_df<-data.frame(mei_model$tables$apsideslvl)
p65<- ggplot(mei_apsideslvl_df,aes(apsideslvl,Y))
p65+geom_raster(aes(fill=Freq),interpolate=TRUE) +scale_fill_gradientn(colours=c("#0000FFFF","#FFFFFFFF","#FF0000FF"))
mei_apsideslvl_df_acc<-mei_apsideslvl_df

# accumulate for a raster figure of MEI prior

mei_meilaglvl_df<-data.frame(mei_model$tables$meilaglvl)
mei_meilaglvl_df_acc <- mei_meilaglvl_df

#  A loop to run the train/test m times and average out the model.

for (k in 1:m) {
  
  b<-data_block_df[,c("meilvl","phaselvl","apsideslvl","sslvl","solarmolvl","monthlvl","meilaglvl","edate")] 
  
  train<-ifelse(runif(nrow(b))<0.80,1,0)
  b<-data.frame(cbind(b,train))
  trainb <-b[b$train==1,]
  testb <-b[b$train==0,]
  mei_model<-naiveBayes(meilvl~.,data=trainb[-c(trainColNum,dateColNum)])
  mei_test_predict_df <- data.frame(predict(mei_model,testb[,-1]))
  colnames(mei_test_predict_df)<-c("mei_pr_level") 
  table(pred=mei_test_predict_df$mei_pr_level,true=testb$meilvl)
  finding <- mean(mei_test_predict_df$mei_pr_level==testb$meilvl)
  
  # Transform the forecast in levels to a forecast in values
  
  test_centers <- transform(mei_test_predict_df, mei_pr_ctr=meicenters[as.integer(mei_pr_level)])
  test_heights<-transform(mei_test_predict_df, mei_pr_height=meibinsheight[as.integer(mei_pr_level)])
  test_forecast<-cbind(test_centers,test_heights)
  
  # Increment all the accumulators
  
  finding_acc <- finding_acc + finding
  compare_df_temp<-data.frame(table(pred=mei_test_predict_df$mei_pr_level,true=testb$meilvl))
  compare_df$Freq<-compare_df$Freq + compare_df_temp$Freq 

  mei_phaselvl_df_acc<-mei_phaselvl_df_acc+data.frame(mei_model$tables$phaselvl)
  mei_sslvl_df_acc<-mei_sslvl_df_acc+data.frame(mei_model$tables$sslvl)
  mei_solarmolvl_df_acc<-mei_solarmolvl_df_acc+data.frame(mei_model$tables$solarmolvl)
  mei_monthlvl_df_acc<-mei_monthlvl_df_acc+data.frame(mei_model$tables$monthlvl)
  mei_apsideslvl_df_acc<-mei_apsideslvl_df_acc+data.frame(mei_model$tables$apsideslvl)
  mei_meilaglvl_df_acc <- mei_meilaglvl_df_acc + data.frame(mei_model$tables$meilaglvl)
  
  # Note re the above - it will object to adding factors but I do not use those columns.  
  # This may be why the model is not smoothed in the end - it is still just using the first value.
  # That's OK - just say so.
  
  testb2<-rbind(testb2,testb)  # save the dates that go with this random 80/20 split
  test_forecast2<-rbind(test_forecast2,test_forecast)
}

v1 <- finding_acc/(m+1)  # average skill index, namely percent that are on the diagonal
v2 <- 1/(mein-1) # scale factor for size of matrix
v3<-v1/v2 # normalized skill
v3

# Plot and save the relationships between ENSO and astro variables

plothite <- 3.25
widewidth <- 7.5
smallwidth <- widewidth

p<- ggplot(mei_phaselvl_df,aes(phaselvl,Y))
Percent_in_phase_band<-100*mei_phaselvl_df_acc$Freq/m
p+geom_raster(aes(fill=Percent_in_phase_band),interpolate=TRUE) +scale_fill_gradientn(colours=c("#0000FFFF","#FFFFFFFF","#FF0000FF"))  +theme(axis.text.x = element_text(angle = 90, hjust = 1))
# ggsave("precessionlvl.png",width=widewidth,height=plothite,units=c("in"))

p<- ggplot(mei_sslvl_df,aes(sslvl,Y))
Percent_in_ss_band<-100*mei_sslvl_df_acc$Freq/m
p+geom_raster(aes(fill=Percent_in_ss_band),interpolate=TRUE) +scale_fill_gradientn(colours=c("#0000FFFF","#FFFFFFFF","#FF0000FF"))  +theme(axis.text.x = element_text(angle = 90, hjust = 1))
# ggsave("sslvl.png",width=smallwidth,height=plothite,units=c("in"))

p<- ggplot(mei_solarmolvl_df,aes(solarmolvl,Y))
Percent_in_eclipse_month_band<-100*mei_solarmolvl_df_acc$Freq/m
p+geom_raster(aes(fill=Percent_in_eclipse_month_band),interpolate=TRUE) +scale_fill_gradientn(colours=c("#0000FFFF","#FFFFFFFF","#FF0000FF"))  +theme(axis.text.x = element_text(angle = 90, hjust = 1))
# ggsave("solarmolvl.png",width=smallwidth,height=plothite,units=c("in"))

p<- ggplot(mei_monthlvl_df,aes(monthlvl,Y))
Percent_in_month_band<-100*mei_monthlvl_df_acc$Freq/m
p+geom_raster(aes(fill=Percent_in_month_band),interpolate=TRUE) +scale_fill_gradientn(colours=c("#0000FFFF","#FFFFFFFF","#FF0000FF"))  +theme(axis.text.x = element_text(angle = 90, hjust = 1))
# ggsave("monthlvl.png",width=smallwidth,height=plothite,units=c("in"))

p<- ggplot(mei_apsideslvl_df,aes(apsideslvl,Y))
Percent_in_ap_band<-100*mei_apsideslvl_df_acc$Freq/m
p+geom_raster(aes(fill=Percent_in_ap_band),interpolate=TRUE) +scale_fill_gradientn(colours=c("#0000FFFF","#FFFFFFFF","#FF0000FF"))  +theme(axis.text.x = element_text(angle = 90, hjust = 1))
# ggsave("apsides.png",width=widewidth,height=plothite,units=c("in"))

p<- ggplot(mei_meilaglvl_df,aes(meilaglvl,Y))
Percent_in_prior_band<-100*mei_meilaglvl_df_acc$Freq/m
p+geom_raster(aes(fill=Percent_in_prior_band),interpolate=TRUE) +
  scale_fill_gradientn(colours=c("#0000FFFF","#FFFFFFFF","#FF0000FF"))  +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  ggtitle("Statistical breakout: ENSO band against prior ENSO band") +
  labs(y= "ENSO band", x = "Prior ENSO band") +
guides(fill=guide_legend(title="Percent"))
ggsave("meilag.png",width=widewidth,height=plothite,units=c("in"))


pmodel<- ggplot(compare_df,aes(true,pred))
pmodel+geom_raster(aes(fill=Freq),interpolate=TRUE) +
  scale_fill_gradientn(colours=c("#0000FFFF","#FFFFFFFF","#FF0000FF"))  +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  ggtitle("ENSO forecast from prior MEI and ephemeris") +
  labs(y= "Predicted ENSO band", x = "True ENSO band") 
# what the figure shows is that the El Nina usually occurs at set phases while El Nino is complementary but still less particular
ggsave("truthtable2.png",width=smallwidth,height=plothite,units=c("in"))

