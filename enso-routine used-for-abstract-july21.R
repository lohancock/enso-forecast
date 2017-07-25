# MEI data from NOAA/ESRL:
#   http://www.esrl.noaa.gov/psd/enso/mei/table.html
# Sunspot data:
#   http://www.sidc.be/silso/datafiles
# Precession of nodes was obtained from JPL ephemeris
# Ecliptic month:
# http://ssd.jpl.nasa.gov/horizons.cgi
# details required by Horizons:  choose Target body:  Sun; Ephemeris type:  Observer; Observer location:  Geocentric
# Start time 1749-01-01; Increment in calendar months; Stop time 2030-01-01;
# table settings:  observer ecliptic lat and lon; angle format:  decimal degrees; download/save
# find it in downloads and upload to R server where I called it
# horizons_eartheclipticlatlong.txt


library(e1071)
library(stats)
rm(list=ls())

ssbreaks<-c(0,25, 50,100,250,1200)
meibreaks<-c(-5,-1,0,1,5) 
meilagbreaks<-meibreaks

# mei_df runs from DECJAN 1950 to NOVDEC 2016, with year, month, mei, and meilvl

mei_wide_df <- read.csv('~/enso/data/MEI_1950_Dec2016.txt',sep="",skip=8,header=TRUE,nrows=67)
mei_df <- melt(mei_wide_df, id=c("YEAR"))
names(mei_df) <- c("year","bimo","MEI") 
mei_df <- arrange(mei_df,year,bimo)

# Add columns for fake MEI values to accompany real data up to Deec 2016:  hi pos neg a lo values of MEI for real dates

mei_df$meihi <- rep(3,nrow(mei_df)) # make new column
mei_df$meilo <- rep(-3,nrow(mei_df)) # make new column
mei_df$meipos <- rep(0.25,nrow(mei_df)) # make new column
mei_df$meineg <- rep(-0.25,nrow(mei_df)) # make new column

# Add rows for future values of MEI

meiline<-mei_df[804,]
meiline[,1]<-2030
meiline[,2]<-'ANYMONTH'
meiline[,3]<-0
n<-40
meisynthetic<-do.call("rbind",replicate(n,meiline,simplify=FALSE)) # that synthesizes meihi
mei_df<-rbind(mei_df,meisynthetic)  

# Cut all the values:  real data, synthetic data

meilvl<-cut(mei_df$MEI,meibreaks)
mei_df<-cbind(mei_df,meilvl)

# as to the below I am not sure these are ever used.  
# If they were it would matter that they are being cut with meibreaks, not
# the same way as the meilaglvl, which is just positive and negative. 
# But I think these are not used at all.

meihilvl<-cut(mei_df$meihi,meibreaks)
mei_df<-cbind(mei_df,meihilvl)
meilolvl<-cut(mei_df$meilo,meibreaks)
mei_df<-cbind(mei_df,meilolvl)
meiposlvl<-cut(mei_df$meipos,meibreaks)
mei_df<-cbind(mei_df,meiposlvl)
meineglvl<-cut(mei_df$meineg,meibreaks)
mei_df<-cbind(mei_df,meineglvl)

# And now obtain the lagged values and bind those columns on and cut them into levels.
# Real and fake data done the same way.

# out of date note I think:
# Note:  I am not using meibreaks, just -5, 0, 5.  Same for real and fake data. (out of date I think see below)  Wonder whether forecasts would be better with meibreaks instead?
# Followup remark in July 2017: the cut is named meilagbreaks but in this edition meilagbreaks is set equal to meibreaks so they ARE equal....

meilag_df<-data.frame(lag(mei_df$MEI,2))
names(meilag_df)<-"meilag"
# because it is a lag by two slots, there will be two blanks in the beginning so I fill those in.
meilag_df$meilag[1:2]<-mei_df$MEI[1]
meilaglvl<-cut(meilag_df$meilag,meilagbreaks)
mei_df<-cbind(mei_df,meilaglvl) 

meihilag_df<-data.frame(lag(mei_df$meihi,2))
names(meihilag_df)<-"meihilag"
# because it is a lag by two slots, there will be two blanks in the beginning so I fill those in.
meihilag_df$meihilag[1:2]<-mei_df$meihi[1]
meihilaglvl<-cut(meihilag_df$meihilag,meilagbreaks)
mei_df<-cbind(mei_df,meihilaglvl) 


meilolag_df<-data.frame(lag(mei_df$meilo,2))
names(meilolag_df)<-"meilolag"
# because it is a lag by two slots, there will be two blanks in the beginning so I fill those in.
meilolag_df$meilolag[1:2]<-mei_df$meilo[1]
meilolaglvl<-cut(meilolag_df$meilolag,meilagbreaks)
mei_df<-cbind(mei_df,meilolaglvl) 

meiposlag_df<-data.frame(lag(mei_df$meipos,2)) 
names(meiposlag_df)<-"meiposlag" 
# because it is a lag by two slots, there will be two blanks in the beginning so I fill those in.
meiposlag_df$meiposlag[1:2]<-mei_df$meipos[1] 
meiposlaglvl<-cut(meiposlag_df$meiposlag,meilagbreaks)
mei_df<-cbind(mei_df,meiposlaglvl)  

meineglag_df<-data.frame(lag(mei_df$meineg,2))
names(meineglag_df)<-"meineglag"
# because it is a lag by two slots, there will be two blanks in the beginning so I fill those in.
meineglag_df$meineglag[1:2]<-mei_df$meineg[1]
meineglaglvl<-cut(meineglag_df$meineglag,meilagbreaks)
mei_df<-cbind(mei_df,meineglaglvl)  

# precess_df runs from Jan 1950 to Jan 2030 with month precession and phaselvl.  Line 802 is Oct 2016.

lunarorbit_df<-read.csv ('~/enso/data/horizons_orbitalelementsofmoon4.txt',skip=52,nrows=3361,header=FALSE)
precess_df<-lunarorbit_df[2401:3361,c(2,6)]
names(precess_df)<-c("month","precession")
precess3<-data.frame(stats::filter(precess_df$precession, rep(1, 1)))
names(precess3)<-c("precess3")
precess3[is.na(precess3$precess3),] <- 0 
# phaselvl<-cut(precess3$precess3,24)
phaselvl<-cut(precess3$precess3,48)
precess_df<-cbind(precess_df,phaselvl) 

# eclipse month is to keep track of where we are in the eclipse year: 
# Jan 1950 to Oct 2016, date eclipticlon

eclipticlonearth<-read.table('~/enso/data/horizons_eartheclipticlatlong.txt',skip=56,nrows=3373,header=FALSE)
names(eclipticlonearth)<-c("date","v1","eclipticlon","v2")
moeclipse<-eclipticlonearth[2413:3373,c(1,3)]
eclipsemolvl<-cut(moeclipse$eclipticlon,4)
moeclipse<-cbind(moeclipse,eclipsemolvl)

# sunspot_df runs from Jan 1749 to Nov 2016, with yr, mo, yr_frac, ss, sd, nobs, final_prov

sunspot_df<-read.table('~/enso/data/monthly_sunspots.csv',sep=";")
names(sunspot_df)<-c("yr","mo","year_frac","ss","sd","nobs","final_prov")

## ss_future runs from June 2016 to Dec 2019 with yr mo ss ss_hi ss_lo rad_pred rad_hi rad_lo

ss_future<-read.table('~/enso/data/sunspots_future.txt')
names(ss_future)<-c("yr","mo","ss","ss_hi","ss_lo","rad_pred","rad_hi","rad_lo")

# sunspots past:  take Jan 1950 to Dec 2016
# sunspots future:  start with Jan 2017 projection and go to dec 2019
# take running 3 month averages 
# bind these, cut sunspot levels, bind that onto the dataframe:  Dec 1949 to Dec 2019, yr mo ss
sunspots<-sunspot_df[2413:3216,c(-3,-5,-6,-7)]
sunspots<-rbind(sunspots,ss_future[8:43,c("yr","mo","ss")])
sslvl<-cut(sunspots$ss,ssbreaks)
sunspots<-cbind(sunspots,sslvl)

# Assemble the test/train subset:  MEI begins DECJAN 1950; sunspots begin DEC 1949; precession JAN 1950

enso_df<-mei_df[1:840,]
enso_df<-cbind(enso_df,precess_df[1:840,])
enso_df<-cbind(enso_df,sunspots[1:840,])
enso_df<-cbind(enso_df,moeclipse[1:840,])

# Add months to the data frame - note, mo comes from sunspots -
# though I am not using month at the moment.  
monthlvl<-cut(enso_df$mo,4)
enso_df<-cbind(enso_df,monthlvl)

# Add date

idate <- as.POSIXlt("2009-02-10")
edate<-update(idate,year=enso_df$yr,month=enso_df$mo)
enso_df<-cbind(enso_df,edate)

# Remove all lines with an NA (there is one) and extract the MEI/predictor factors

enso_df<-enso_df[complete.cases(enso_df),]

# Now train/test the model on real data, namely up to 803rd value since one of the 804 is dropped.
b<-enso_df
# The lines that follow show how to change the variables used in the model
# b<-b[,c("meilvl","sslvl","phaselvl","meilaglvl","monthlvl","eclipsemolvl")]
# b<-b[,c("meilvl","sslvl","phaselvl","meilaglvl","monthlvl","wplaglvl")]
# b<-b[,c("meilvl","phaselvl","sslvl","eclipsemolvl","monthlvl","meilaglvl")]
# b<- b[1:804,c("meilvl","sslvl","phaselvl")] 
b<-b[1:804,c("meilvl","phaselvl","sslvl","eclipsemolvl","monthlvl","meilaglvl")]


train<-ifelse(runif(nrow(b))<0.80,1,0)
b<-data.frame(cbind(b,train))
trainColNum<-grep("train",names(b))
#trainb <-b[b$train==1,-trainColNum]
trainb<-b[,-trainColNum]
testb <-b[b$train==0,-trainColNum]



mei_model<-naiveBayes(meilvl~.,data=trainb)
mei_test_predict <- predict(mei_model,testb[,-1])
table(pred=mei_test_predict,true=testb$meilvl)
finding <- mean(mei_test_predict==testb$meilvl)
finding

bpos<-enso_df[,c("phaselvl","sslvl","meiposlaglvl")]
names(bpos)<-c("phaselvl","sslvl","meilaglvl")
bpos_pred<-predict(mei_model,bpos)

bhi<-enso_df[,c("phaselvl","sslvl","meihilaglvl")]
names(bhi)<-c("phaselvl","sslvl","meilaglvl")
bhi_pred<-predict(mei_model,bhi)

bneg<-enso_df[,c("phaselvl","sslvl","meineglaglvl")]
names(bneg)<-c("phaselvl","sslvl","meilaglvl")
bneg_pred<-predict(mei_model,bneg)

blo<-enso_df[,c("phaselvl","sslvl","meilolaglvl")]
names(blo)<-c("phaselvl","sslvl","meilaglvl")
blo_pred<-predict(mei_model,blo)


plot(enso_df$edate[800:804],enso_df$meilvl[800:804],pch=1,cex=1,col="black",ylim=range(0,5),
     xlim=c(as.POSIXct('2016-07-01 12:00:00', format="%Y-%m-%d %H:%M:%S"),as.POSIXct('2020-07-01 12:00:00', format="%Y-%m-%d %H:%M:%S")),
     main="MEI Forecast",xlab="Date",ylab="Category",yaxt='n')
points(enso_df$edate[800:839],bhi_pred[800:839],pch=1,cex=4,col="red")
points(enso_df$edate[800:839],bpos_pred[800:839],pch=1,cex=3,col="magenta")
points(enso_df$edate[800:839],bneg_pred[800:839],pch=1,cex=2,col="green") 
points(enso_df$edate[800:839],blo_pred[800:839],pch=1,cex=1,col="blue") 


