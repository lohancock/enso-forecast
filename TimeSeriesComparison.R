# Time series of MEI measured and predicted.

require(ggplot2)
inputblock<-data_block5_df[1:3204,]

# Always initialize the model with data_block_df.  Inputblock varies, but model always comes from data_block_df.

b<-data_block_df[,c("meilvl","phaselvl","sslvl","solarmolvl","apsideslvl","monthlvl","meilaglvl","edate")]
train<-ifelse(runif(nrow(b))<0.80,1,0)
b<-data.frame(cbind(b,train))
trainColNum<-grep("train",names(b))
dateColNum<-grep("edate",names(b))
trainb <-b[b$train==1,]
testb <-b[b$train==0,]
mei_model<-naiveBayes(meilvl~.,data=trainb[-c(trainColNum,dateColNum)])

Amei_test_predict_df <- data.frame(predict(mei_model,testb[,-1]))
colnames(Amei_test_predict_df)<-c("mei_pr_level") 

finding <- mean(Amei_test_predict_df$mei_pr_level==testb$meilvl)
finding # this is WITH persistence so it is NOT astro only

# The model is to be applied to data in future, so it is necessary to assemble a block of MEI assumptions dimensioned for block5.
# It is called mei_assume, a block of meilaglvl assumptions/dummy columns.  

mei_possible <- sort(unique(mei_df$meilaglvl)) # Labels of the bins found in blocks 1 and 2.
ndata <-dim(inputblock)[1] # Find the number of rows needed for block 5.  output here is length 1.  for datablock5 is about 3361 points, will change if extended...

mei_assume <- as.data.frame(data_block_df$meilvl[1:ndata]) # Initiate mei_assume with a column of MEI values from block1, simply to set up a column of factors, with the needed levels, namely the levels from datablock1.
mei_assume<-cbind(mei_assume,inputblock$edate) # Next the dates from datablock5.  Label the columns and switch order.
colnames(mei_assume)<-c("mei_true","meidate") # Label the columns.
mei_assume <- mei_assume[,c(2,1)] # Switch their order

lmax<-mein-1 # lmax is the number of bins for mei, set in the datablock assembly. By choice, it is same for the forecast

for (l in 1:lmax) {  #   Assemble mei_assume column by column
  colsbegin<-colnames(mei_assume) # make a copy of the column names for this block as they are now  
  mei_assume_col <- data.frame(rep(mei_possible[l],ndata)) # Make a new column:  one of the MEI values, ndata times.
  mei_assume <- cbind(mei_assume,mei_assume_col) # Paste that onto mei_assume to be used as meilaglvl
  colnames(mei_assume)<- c(colsbegin,paste("meibin",l,sep="")) # Paste togther a full set of column names, tack it onto colnames: that is new colnames  
}

# Initialize the data set that will be input to the forecast
# It is called testb in memory of the test/train breakout.
# n is appended as a reminder it will be used n times, once per mei bin.
# In this initialization the first column of mei_assume is swapped in.
# Below in section called LOOP the other mei assumptions will be swapped in column by column.

testb_n<-inputblock # initialize testb_n with a copy of the input data
ntestb_n<-dim(inputblock)[1] # its length is noted
testb_n_firstcols<-colnames(testb_n) # initial set of column names
testb_n <-cbind(testb_n,mei_assume[1:ntestb_n,3]) # Attach one column of meilaglvl, one column of mei_assume are tacked onto the input data
testb_cols<-c(testb_n_firstcols,"meilaglvl") # Column name set is revised to include the name meilaglvl to correspond to model expectations
colnames(testb_n)<-testb_cols # the new column names are attached to testb_n

testb_n<-testb_n[c("phaselvl","sslvl","solarmolvl","apsideslvl","monthlvl","meilaglvl","edate")] # throw away the columns i do not want

mei_test_predict_df <- data.frame(predict(mei_model,testb_n[,-8])) # run it without edate, although do not dispose of the column, which will give dates to the forecasts
colnames(mei_test_predict_df)<-c("mei_pr_level") 

# Transform forecast which is factor output into numbers on MEI scale: ctrs, hi or lo

test_centers <- transform(mei_test_predict_df, mei_pr_ctr=meicenters[as.integer(mei_pr_level)])
test_heights<-transform(mei_test_predict_df, mei_pr_height=meibinsheight[as.integer(mei_pr_level)])
test_highs <- transform(mei_test_predict_df, mei_pr_high=meibinshi[as.integer(mei_pr_level)])
test_lows <- transform(mei_test_predict_df, mei_pr_low=meibinslo[as.integer(mei_pr_level)])

test_forecast<-cbind(test_centers,test_heights,test_highs,test_lows) # note that all columns of test_predict_df come along four times
test_forecast <- test_forecast[,c(1,2,4,6,8)] # drop the repetitions of the factor-forecast

# Accumulate the result to initialize an ensemble of results.

# To scale the final plot, I need a column of values like the values of MEI.
mei_Sample <- data.frame(rep(data_block_df$MEI,2)) # Make a new column:  the original MEI values twice in a row, just dummies.
mei_Sample <- data.frame(mei_Sample[1:ndata,]) # And now trim it to length ndata.
colnames(mei_Sample) <- c("MEI_Sample") # bestow a column name

#  Initiate an accumulator for the forecasts.
#  This is where the different lengths encounter each other - testb_n 3361, forecast 3204

test_forecast_ensemble<-cbind (testb_n$edate, mei_Sample$MEI_Sample,test_forecast) # forecast dates, Sample data to set the scale, and then the forecast.  This way no matter what extract I plot, the total scale is fixed.  Not elegant but it works.
colnames(test_forecast_ensemble) <-c("meidate","MEI_Scale","mei_pr_level1","mei_pr_ctr1","mei_pr_height1","mei_pr_high1","mei_pr_low1")

# LOOP

for (h in 2:lmax) {  # remember lmax is the number of bins, thus the no. of columns in mei_assume

  assumecol<-h+2  # h labels which mei bin we are processing now.  then h+2 finds it in mei_assume, considering that mei_assume begins with columns for date, Samplemeilvl, Samplemei
  testb_n<-inputblock # Just as above, a copy is made of the input data
  testb_n_firstcols<-colnames(testb_n) # we record currnet column names
  testb_n <-cbind(testb_n,mei_assume[1:ntestb_n,assumecol]) # we tag on an meilaglvl assumption
  testb_cols<-c(testb_n_firstcols,"meilaglvl") # we add a column name for that
  colnames(testb_n)<-testb_cols
  testb_n<-testb_n[c("phaselvl","sslvl","solarmolvl","apsideslvl","monthlvl","meilaglvl","edate")]
  
  # Here I run the model over that new data block, convert output to MEI scale, and bind to ensemble.
  
  mei_test_predict_df <- data.frame(predict(mei_model,testb_n[,-7]))
  colnames(mei_test_predict_df)<-("mei_pr_level") 
  test_centers <- transform(mei_test_predict_df, mei_pr_ctr=meicenters[as.integer(mei_pr_level)])    # The model outputs levels so I turn those into centers and heights on the MEI scale.
  test_heights<-transform(mei_test_predict_df, mei_pr_height=meibinsheight[as.integer(mei_pr_level)])
  test_highs <- transform(mei_test_predict_df, mei_pr_high=meibinshi[as.integer(mei_pr_level)])
  test_lows <- transform(mei_test_predict_df, mei_pr_low=meibinslo[as.integer(mei_pr_level)])
  colnames(test_centers)<-paste(colnames(test_centers),h,sep="")    # Then I assign an indexed column name and bind it to a block of forecasts
  colnames(test_heights)<-paste(colnames(test_heights),h,sep="")
  colnames(test_highs)<-paste(colnames(test_highs),h,sep="")
  colnames(test_lows)<-paste(colnames(test_lows),h,sep="")
  test_forecast_ensemble <-cbind (test_forecast_ensemble, test_centers,test_heights,test_highs,test_lows)
  
}

p1<-ggplot(test_forecast_ensemble,aes(meidate,MEI_Sample))  # this provides scales
p2<-p1+geom_line(data=test_forecast_ensemble,aes(meidate,mei_pr_low1),color="dark blue") # the low end limit
hilimit<-colnames(test_forecast_ensemble)[dim(test_forecast_ensemble)[2]-2]
p3<-p2+geom_line(data=test_forecast_ensemble,aes_string(x="meidate",y=hilimit,   alpha=1/20) , color="red") #
p15<-p3  +geom_point(data=data_block_df,aes(edate,MEI))


p15+xlim(test_forecast_ensemble$meidate[1500],test_forecast_ensemble$meidate[2068]) + 
  labs(y= "MEI", x = "Time") + theme(legend.position = "none")
ggsave("forecast1wide.png",width=8,height=3,units=c("in"))

p15+xlim(test_forecast_ensemble$meidate[2068],test_forecast_ensemble$meidate[2636]) + 
  labs(y= "MEI", x = "Time") + theme(legend.position = "none")
ggsave("forecast2wide.png",width=8,height=3,units=c("in"))

p15+xlim(test_forecast_ensemble$meidate[2636],test_forecast_ensemble$meidate[3204]) + 
  labs(y= "MEI", x = "Time") + theme(legend.position = "none")
ggsave("forecast3wide.png",width=8,height=3,units=c("in"))
