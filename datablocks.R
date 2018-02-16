# setwd("Wherever you have put all this.  The code expects to find the data in the working directory.")
library(e1071)
library(stats)
library(dplyr)
library(reshape2)
library(lubridate)
rm(list=ls())

# to add a new variable, pick a lout, add it in the three time blocks,
# fix the column naming, then fix column five assembly

mein <- 75 # use 5 for astro-only raster, use 13 for prediction.  number of bins for MEI plus 1.  Use 3 bins or more. Same num bins for meilag.
lout2 <- 49 # number of bins for omega plus 1
lout3 <- 13 # number of bins for for solarmo plus 1
lout4 <- 13 # number of bins for sunspots/GN plus 1
lout5 <- 13 # number of bins for moonmonths plus 1
loutApsides <- 49 # one plus the number of bins for periapsis of lunar orbit which has 8.8 yr cycle thus about 100 will cover it.
# set.seed (20180108)
# m <- 5 # number of loops of 80/20 model/predict to accumulate, moved this to it.R

# BLOCKS - 
#       Block 1:  The block 1950 to 2016.  The MEI time series is available for all of this.
#       Block 2:  decjan 1871 to novdec 2005, 1620 data points.  The MEI-extended series is available for this.
#       joined in data_block_df, DecJan1871 to NovDec 2016 w pref to block1 where overlapping
#       Block 3:  jan1750 to dec1870.  The period for which a consistent sunspot time series exists.  No MEI.
#       Block 4:  1616 to 2030.  The framework of the Schatten sunspot (group number GN) reconstruction.  No MEI.
#       Block 5:  Jan 1750 to Jan 2030
#       Block 6:  Jan 2017 to Jan 2030.  Going to treat it all as future, and take sunspots as low.  No MEI.  Sunspots from projection.

##################################################################
#
#  Block 1:  1950 to 2016.  There is more but here not used.  
#  Block 2:  1875 through 2005 - ("MEI extended.")
#  These are the time frames where the statistical model can be built
#  In this section I string them together into one datablock, preferring MEI.
#
###################################################################

#        Initiate data block with the MEI time series.  Read it in, name it, clip the dates so it is 804 points DECJAN 1950 to NOVDEC 2016.
#        mei_df runs from DECJAN 1950 that I am everywhere linking to Jan 1, 1950 to NOVDEC 2016, that I am everywhere linking to Dec 1, 2016.
#        As imported it is a square not a sequence so it is melted and re-formed. Thanks, Hadley Wickham!!!

mei_wide_df <- read.csv('MEI_1950_Dec2016.txt',sep="",skip=8,header=TRUE,nrows=67)
mei_df <- melt(mei_wide_df, id=c("YEAR"))
names(mei_df) <- c("year","bimo","MEI") 
mei_df <- arrange(mei_df,year,bimo)

#         Read in MEI extended.  Include only 1875 to end 1949 in data block.

mei_ext_df <- read.csv('MEI_ext_1871_2005.txt',sep="",skip=7,header=TRUE,nrows=135)
mei_ext_df <- melt(mei_ext_df, id=c("YEAR"))
names(mei_ext_df) <- c("year","bimo","MEI")
mei_ext_df <- arrange(mei_ext_df,year,bimo)
mei_ext_df<-mei_ext_df[1:1620,]

#        Join Block 1 and Block 2

mei_df_join<- rbind(mei_ext_df[1:948,],mei_df)
mei_df <- mei_df_join

#          Obtain data quantiles to use as breaks.  This calls on the setting mein up at top of routinee

nbreaks<-seq(from=0,to=1,length.out=mein)
meibreaks<-quantile(mei_df$MEI,probs=nbreaks)

#           Obtain top and bottom of each bin, to help in plotting later on.
#           note that if I pull out the assembly of the data block as a separate routine,
#           then this segment needs focused attention so they can be computed and passed to plotting below.

meibinslo<-meibreaks[1:mein-1]
meibinshi<-meibreaks[2:mein]
meicenters<-(meibinslo+meibinshi)/2
meibinsheight<-meibinshi-meibinslo

#           Obtain midpoints of the bins.  Note that midpoints are not the same thing as the centers:  difference between half-height versus quantile space.

noffset<-(nbreaks[1]+nbreaks[2])/2
nmids<-nbreaks+noffset
nmids<-nmids[1:(mein-1)]
meimids<-quantile(mei_df$MEI,probs=nmids)
nmids
meimids

#           Use the quantiles to cut the MEI data.

meilvl<-cut(mei_df$MEI,breaks=meibreaks,include.lowest=TRUE)
mei_df<-cbind(mei_df,meilvl)

#   B.  The lagged MEI: construct it and name the column. Note it is lagged by two months not one bc the MEI is bimonthly (e.g DecJan, then JanFeb).  Block 1 then 2.  #           Note that the column name is the same for the two blocks. 

meilag_df<-data.frame(lag(mei_df$MEI,2))
names(meilag_df)<-"meilag"
#           because it is a lag by two slots, there will be two blanks in the beginning so I fill those in.
meilag_df$meilag[1:2]<-mei_df$MEI[1]

#        Break meilag using same breaks as for MEI.  I made it a separate step so i could use different lags though here I do not.

meilaglvl<-cut(meilag_df$meilag,breaks=meibreaks,include.lowest=TRUE)
mei_df<-cbind(mei_df,meilaglvl) 
data_block_df<-mei_df

#   C.  Phase of the precession of lunar nodes.  Import it, clip it, name the columns.  #           note that lunarorbit begins 1750 April 1 and ends Jan 1 2030  Block 1 then 2.

lunarorbit_df<-read.csv ('horizons_orbitalelementsofmoon4.txt',skip=52,nrows=3361,header=FALSE)
precess_df<-lunarorbit_df[1453:3204,c(2,6,7)]  #  while precess_df runs from Jan 1950 to Dec 2016, of note it formally has 3361 levels, all the time labels that lunarorbit had.  (which does not matter)
names(precess_df)<-c("month","precession","argperiapsis")

#           Obtain data quantiles to use as breaks.  Use lout2 set at top of routine, n+1 where n is number of bins.

n2breaks<-seq(from=0,to=1,length.out=lout2)
omegabreaks<-quantile(precess_df$precession,probs=n2breaks)

n2abreaks<-seq(from=0,to=1,length.out=loutApsides)
apsidesbreaks<-quantile(precess_df$argperiapsis,probs=n2abreaks)

#           Use the quantiles to cut the data.  The segments may be of uneven angular length because orbits are not circles.

phaselvl<-cut(precess_df$precession,breaks=omegabreaks,include.lowest=TRUE)
apsideslvl<-cut(precess_df$argperiapsis,breaks=apsidesbreaks,include.lowest=TRUE)


#           Bind the level to precess_df.  Bind that to the block.

precess_df<-cbind(precess_df,phaselvl,apsideslvl) 
data_block_df<-cbind(data_block_df,precess_df)

#   D.  solar month.  Import it, name it, clip it to the time frame of the block.  Is phase of the solar year, which is a few months shorter than the solar year.

eclipticlonearth<-read.table('horizons_eartheclipticlatlong.txt',skip=56,nrows=3373,header=FALSE)
names(eclipticlonearth)<-c("date","v1","eclipticlon","v2")
solarmo<-eclipticlonearth[1465:3216,c(1,3)]

#           Obtain data quantiles to use as breaks.

n3breaks<-seq(from=0,to=1,length.out=lout3)
solarmobreaks<-quantile(solarmo$eclipticlon,probs=n3breaks)

#           Use the quantiles to cut the data.  The segments are of uneven length. I assume this is because neither orbit is a circle. I Will be able to see when I plot the model.

solarmolvl<-cut(solarmo$eclipticlon,breaks=solarmobreaks,include.lowest=TRUE)

#           Bind the result to solarmo.  And bind that to the block.

solarmo<-cbind(solarmo,solarmolvl) 
data_block_df<-cbind(data_block_df,solarmo)

#   E.  Import sunspot data, name the columns, clip it to the time frame of the block.
#       Same for Schatten and Svalgard reconstruction Group Number data

sunspotalltime_df<-read.table('monthly_sunspots.csv',sep=";")
names(sunspotalltime_df)<-c("yr","mo","year_frac","ss","sd","nobs","final_prov")
sunspot_df<-sunspotalltime_df[1465:3216,c(-3,-5,-6,-7)]

#          Obtain data quantiles to use as breaks.  5 quantiles yield four bins

n4breaks<-seq(from=0,to=1,length.out=lout4)
ssbreaks<-quantile(sunspot_df$ss,probs=n4breaks)
ssbreaks

#           Use the quantiles to cut the data, bind to sunspot_df, bind that to the block.

sslvl<-cut(sunspot_df$ss,breaks=ssbreaks,include.lowest=TRUE)
sunspot_df<-cbind(sunspot_df,sslvl) 
data_block_df<-cbind(data_block_df,sunspot_df)

#          Schatten group number, alternative to Wolf sunspot number
#          Import Schatten sunspot data, name the columns, 

schattenx_df<-data.frame(read.csv('schatten_extrapolated.txt',sep="\t"))
names(schattenx_df)<-c("Year","LowGN","MeanGN","HighGN","Error")
nxyears <- dim(schattenx_df)[1]
schattenx_df<-schattenx_df[,c(1,3)]
schattenxyr<-floor(schattenx_df[,1])
schattenxyr_ext <- rep(schattenxyr, each=12)
schattenxmo <- rep(1:12, times=nxyears)
schattenxGN <- schattenx_df[,2]
schattenxGN_ext <- rep(schattenxGN, each=12)
schattenx_ext <- data.frame(cbind(schattenxyr_ext,schattenxmo,schattenxGN_ext))
names(schattenx_ext) <- c("yr","mo","GN")

#    Trim it to the time frame of the block.

schatten1_ext <- schattenx_ext[3061:4812,]
gnbreaks<-quantile(schatten1_ext$GN,probs=n4breaks) # Note the quantiles are all on datablock12
gnlvl<-cut(schatten1_ext$GN,breaks=gnbreaks,include.lowest=TRUE)

#   Bind the result to schatten1_ext and bind that to the block.

schatten1_ext<-cbind(schatten1_ext,gnlvl) 
data_block_df<-cbind(data_block_df,schatten1_ext)

#          Month of the eclipse year cut it and bind to the block.
#          Note:  I do understand that the way I am doing this leads to 
#          values of this angle running from -360 to 360.  I know that but I am unsure
#          that the phase information is meaningless, so I left it in.  Unsure about
#          this, as it tangles interpretation of the angle, which thus runs between zero to 360 
#          in a different way every year.  ... To fix it I think I would take all the
#          negative values and add 360 to each, then subtract 180 from everything.
#          For now I can just use a large lot of buckets and see if the pattern repeats.

# It was:
#monthlvl<-cut(data_block_df$mo,lout5)
#monthlvl <- cut(moonmo,lout5)

moonmo <- solarmo$eclipticlon - precess_df$precession
n5breaks<-seq(from=0,to=1,length.out=lout5)
moonmobreaks<-quantile(moonmo,probs=n5breaks)

# Note I am using old name, monthlvl, so as to minimize changes
monthlvl<-cut(moonmo,breaks=moonmobreaks,include.lowest=TRUE)
data_block_df<-cbind(data_block_df,monthlvl)

#  F.  Add date - that finishes datablock which comprises 1 and 2.

idate <- as.POSIXlt("2009-02-10")
edate<-update(idate,year=data_block_df$yr,month=data_block_df$mo)
data_block_df<-cbind(data_block_df,edate)


#################################################################
##################################################################
##################################################################
#
#  Block 3:  1750 to 1875. The sunspot dataset prior to MEI
#  No MEI, no MEI lag.  So begin with C.
#  It does not have yet the apsides
#
###################################################################

#   C.  Phase of the precession of lunar nodes.  Trim it, name the columns.  

precess3_df<-lunarorbit_df[1:1452,c(2,6,7)]  #  while precess_df runs from Jan 1950 to Dec 2016, of note it formally has 3361 levels, all the time labels that lunarorbit had.  (which does not matter)
names(precess3_df)<-c("month","precession","argperiapsis")


#           Use the exact same breaks as datablock1, so its model is applicable.

phaselvl3<-cut(precess3_df$precession,breaks=omegabreaks,include.lowest=TRUE)
apsideslvl3<-cut(precess3_df$argperiapsis,breaks=apsidesbreaks,include.lowest=TRUE)

#           Bind the cuts to precess3_df.  Use that to initiate the block.

precess3_df<-cbind(precess3_df,phaselvl3,apsideslvl3) 
data_block3_df<-precess3_df

#   D.  solar month.  Trim it to the time frame of the block.  

solarmo3<-eclipticlonearth[13:1464,c(1,3)]

#           Use same breaks as for datablock1 so I can later apply its model.

solarmolvl3<-cut(solarmo3$eclipticlon,breaks=solarmobreaks,include.lowest=TRUE)

#           Bind the result to solarmo3.  And bind that to the block.

solarmo3<-cbind(solarmo3,solarmolvl3) 
data_block3_df<-cbind(data_block3_df,solarmo3)

#   E.  Import sunspot data, name the columns, trim it to the time frame of the block.

sunspot3_df<-sunspotalltime_df[13:1464,c(-3,-5,-6,-7)]

#           Use the same breaks as datablock1, so to apply its model.

sslvl3<-cut(sunspot3_df$ss,breaks=ssbreaks,include.lowest=TRUE)

#           Bind the result to sunspot3_df.  And bind that to the block.

sunspot3_df<-cbind(sunspot3_df,sslvl3) 
data_block3_df<-cbind(data_block3_df,sunspot3_df)

schatten3_ext <- schattenx_ext[1609:3060,]  ### Trim Group Number
gnlvl3<-cut(schatten3_ext$GN,breaks=gnbreaks,include.lowest=TRUE) #   Cut the data (use same quantiles as those computed in block 1)
schatten3_ext<-cbind(schatten3_ext,gnlvl3) #   Bind the result to schatten1_ext and bind that to the block.
data_block3_df<-cbind(data_block3_df,schatten3_ext)

#          Month of the eclipse year cut it and bind to the block.  Note, the angle itself is not saved.
#          It is anyway the difference of two others that are saved.

moonmo3 <- solarmo3$eclipticlon - precess3_df$precession
monthlvl3<-cut(moonmo3,breaks=moonmobreaks,include.lowest=TRUE)
data_block3_df<-cbind(data_block3_df,monthlvl3)

#  F.  Add date. And that finishes block 3.

idate <- as.POSIXlt("2009-02-10")
edate3<-update(idate,year=data_block3_df$yr,month=data_block3_df$mo)
data_block3_df<-cbind(data_block3_df,edate3)
names(data_block3_df)<-names(data_block_df)[6:23]


##################################################################
#
#  Block 4:  1616-2030 - timeframe of Schatter sunspot time series
#  and projection to 2030.  There is no MEI for this time frame
#  So begin with item C.
#  It does not have apsides yet.
#
###################################################################

#   C.  Phase of the precession of lunar nodes.  Trim it, name the columns.  

lunarorbit4_df<-read.csv ('ephemeris_moon_1600_2030.txt',skip=192,nrows=5017,header=FALSE)
precess4_df<-lunarorbit4_df[,c(2,6,7)]  #  out of date but analytically helpful remark:  while precess_df runs from Jan 1950 to Dec 2016, of note it formally has 3361 levels, all the time labels that lunarorbit had.  (which does not matter)
names(precess4_df)<-c("month","precession","argperiapsis")

#           Use the exact same breaks as datablock1, so its model is applicable.

phaselvl4<-cut(precess4_df$precession,breaks=omegabreaks,include.lowest=TRUE)
apsideslvl4<-cut(precess4_df$argperiapsis,breaks=omegabreaks,include.lowest=TRUE)

#           Bind the cuts to precess4_df.  Use that to initiate the block.

precess4_df<-cbind(precess4_df,phaselvl4,apsideslvl4) 
data_block4_df<-precess4_df

#   D.  solar month.  Trim it to the time frame of the block.  

eclipticlonearth4<-read.table('horizons_eartheclipticlatlong_LONG.txt',skip=201,nrows=5017,header=FALSE)
names(eclipticlonearth4)<-c("date","v2","eclipticlon","v4")
solarmo4<-eclipticlonearth4[,c(1,3)]

#           Use same breaks as for datablock1 so I can apply its model.

solarmolvl4<-cut(solarmo4$eclipticlon,breaks=solarmobreaks,include.lowest=TRUE)

#           Bind the result to solarmo4 and bind that to the block.

solarmo4<-cbind(solarmo4,solarmolvl4) 
data_block4_df<-cbind(data_block4_df,solarmo4)

#           Schatten & Svalgard group number
# NOTE NOTE NOTE that because SS values begin in 1616, I throw away data from 1612-1615.
# Therefore datablock 4 is shortened within the following.

schatten4_ext <- schattenx_ext[1:4969,]  ### Trim to data frame 4
gnlvl4<-cut(schatten4_ext$GN,breaks=gnbreaks,include.lowest=TRUE) #   Cut the data (use same quantiles as those computed in block 1)
schatten4_ext<-cbind(schatten4_ext,gnlvl4) #   Bind the result to schatten1_ext and bind that to the block.
data_block4_df<-cbind(data_block4_df[49:5017,],schatten4_ext)

#          Month of the eclipse year cut it and bind to the block.  Note, the angle itself is not saved.
#          It is anyway the difference of two others that are saved.
#          Note an inconsistency (which does not matter) between how this block
#          is computed versus the analogues in data_block_df and data_block3_df.
#          Namely, because this has just been shortened in the Schatten block,
#          I will compute the phase of eclipse month from the data block as it is thus far
#          instead of reverting to solarmo4 and precess4_df

moonmo4 <- data_block4_df$eclipticlon - data_block4_df$precession
monthlvl4<-cut(moonmo4,breaks=moonmobreaks,include.lowest=TRUE)
data_block4_df<-cbind(data_block4_df,monthlvl4)

#  F.  Add date, and that finishes the data block.

idate <- as.POSIXlt("2009-02-10")
edate4<-update(idate,year=data_block4_df$yr,month=data_block4_df$mo)
data_block4_df<-cbind(data_block4_df,edate4)

names(data_block4_df)[1:8]<-names(data_block_df)[6:13]
names(data_block4_df)[9:14]<-names(data_block_df)[18:23]

##################################################################
#
#  Block 5: 1750 to 2030  
#  Use block3 for 1750 to 1870, block for 1871 to 2016
#  Use 2017 to 2030 (future) from block4 
#  to which final sunspot data from 2016 is added for 2017 to end
#
#  MEI is omitted bc it is not always available for this time frame.
#
###################################################################

# Here I am assembling the future out of the extrapolation I already
# undertook for datablock4. But that did not include sunspots.
# So I am inserting columns for sunspots ss and sslvl by taking the
# final value observed in Dec 2016.
# To match up the column dimensions of block and block3,
# I also add a repetition of the dates prepared for GN.


data_block5a_df<-data_block3_df  # 1750 to 1870.  Already has the columns I want
data_block5b_df <- data_block_df[,6:23]   # 1871 to 2016.  Omit first columns, mei and meilaglvl
data_block5c_df<-data_block3_df[1:157,] # Is to be future, but block4 does not have the right columns.  So i initize something correctly dimensioned and prepare to overwrite.

data_block5c_df[,1:10]<-data_block4_df[4813:4969,1:10] # future gets phaselvl, apsideslvl, and eclipsmolvl from datablock5x, i.e., future

#################################
# The below requires fixing as columns shifted with addition of new variable.
# In the below 1752 would be Dec 2016 and best but it is the low extremum so I used next-up
data_block5c_df[,11]<-data_block_df[1625,16] # future gets ss from Dec2016 value in data_block_df
data_block5c_df[,12]<-data_block_df[1625,17]  # future gets sslvl from Dec2016 value in data_block_df
data_block5c_df[,13:14]<-data_block4_df[4813:4969,9:10]  # future gets sslvl yr and mo by repeating values it has already
data_block5c_df[,15:18]<-data_block4_df[4813:4969,11:14]
#
#
############################################3


# Reconcile the names and bind a,b,c

names(data_block5c_df) <- names(data_block5b_df)
names(data_block5a_df) <- names(data_block5b_df)
data_block5_df<-rbind(data_block5a_df,data_block5b_df,data_block5c_df)

# Here I am re-cutting sslvl.  There is some issue about factors
# in the new section of data block 5, and this guess is that it is because
# I added one single constant value for ss.

data_block5_df$sslvl <- NULL
sslvl<-cut(data_block5_df$ss,breaks=ssbreaks,include.lowest=TRUE)
data_block5_df<-cbind(data_block5_df,sslvl)

##################################################################
#
#  Block 6: 2017 to 2030
#  Use block4 and then add sunspot projection.
# For the sunspot projection I am using dec 2016 which is very low
# and just supposing it repeats. How absurd this is depends on
# how many bands I cut sunspots into.
#
###################################################################

# Here I am assembling the future out of the extrapolation I already
# undertook for datablock4. But that did not include sunspots.
# So I am inserting column for sslvl.

data_block6_df <-data_block4_df[4813:4969,] #
projectssvalue <- data_block_df[1752,17]
ss5  <- data.frame(rep(projectssvalue, each=157)) 
# names(ss5)<-c("sslvl") 
data_block6_df<-cbind(data_block6_df,ss5)
namesdf4<- names(data_block4_df)
names(data_block6_df)<-c(namesdf4,"sslvl")


##################################################################
#
#  Block 7: Jan 1750 to Jan 2030
#  Build it the same way as block3 but go further and then add sunspot projection.
#
###################################################################

#   C.  Phase of the precession of lunar nodes.  Trim it, name the columns.  

precess7_df<-lunarorbit_df[1:3361,c(2,6,7)]  #  while precess_df runs from Jan 1950 to Dec 2016, of note it formally has 3361 levels, all the time labels that lunarorbit had.  (which does not matter)
names(precess7_df)<-c("month","precession","argperiapsis")


#           Use the exact same breaks as datablock1, so its model is applicable.

phaselvl7<-cut(precess7_df$precession,breaks=omegabreaks,include.lowest=TRUE)
apsideslvl7<-cut(precess7_df$argperiapsis,breaks=apsidesbreaks,include.lowest=TRUE)

#           Bind the cuts to precess7_df.  Use that to initiate the block.

precess7_df<-cbind(precess7_df,phaselvl7,apsideslvl7) 
data_block7_df<-precess7_df

#   D.  solar month.  Trim it to the time frame of the block.  

solarmo7<-eclipticlonearth[13:3373,c(1,3)]

#           Use same breaks as for datablock1 so I can later apply its model.

solarmolvl7<-cut(solarmo7$eclipticlon,breaks=solarmobreaks,include.lowest=TRUE)

#           Bind the result to solarmo7.  And bind that to the block.

solarmo7<-cbind(solarmo7,solarmolvl7) 
data_block7_df<-cbind(data_block7_df,solarmo7)

#   E.  Import sunspot data, name the columns, trim it to the time frame of the block.

sunspot7_df<-sunspotalltime_df[13:3216,c(-3,-5,-6,-7)]
sunspot_addendum <- data_block4_df[4813:4969,c("yr","mo","GN")]
ss7<-sunspot_addendum$GN *10 # project low values
ss7[1:11]<-c(26, 24, 17, 32, 19, 19, 18, 13, 44, 13, 6) # replace 2017 to November with data from SIDC
ss7 [12:36] <- c(26.4, 25.1,  23.8,  22.5,  21.3, 20.2,  19.1, 18.0,  17.0, 16.0,  15.1, 14.2, 13.3,  12.5,  11.8,  11.0, 10.3,   9.7,   9.0, 8.4, 7.9,  7.3, 6.8,  6.4, 5.9)             
# use NASA projection from https://solarscience.msfc.nasa.gov/images/ssn_predict.txt
ss7[12:36] <- c(25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25) # Here suppose the last value of Nov 2017 persists to mid 2018.
sunspot_addendum <- cbind(sunspot_addendum,ss7)
sunspot_addendum$GN <- NULL
colnames(sunspot_addendum) <- c("yr","mo","ss") 
sunspot7_df <- rbind(sunspot7_df,sunspot_addendum)


#           Use the same breaks as datablock1, so to apply its model.

sslvl7<-cut(sunspot7_df$ss,breaks=ssbreaks,include.lowest=TRUE)

#           Bind the result to sunspot7_df.  And bind that to the block.

sunspot7_df<-cbind(sunspot7_df,sslvl7) 
data_block7_df<-cbind(data_block7_df,sunspot7_df)

#schatten7_ext <- schattenx_ext[1609:3060,]  ### Trim Group Number
#gnlvl7<-cut(schatten7_ext$GN,breaks=gnbreaks,include.lowest=TRUE) #   Cut the data (use same quantiles as those computed in block 1)
#schatten7_ext<-cbind(schatten7_ext,gnlvl7) #   Bind the result to schatten1_ext and bind that to the block.
#data_block7_df<-cbind(data_block7_df,schatten7_ext)

#          Month of the eclipse year cut it and bind to the block.  Note, the angle itself is not saved.
#          It is anyway the difference of two others that are saved.

moonmo7 <- solarmo7$eclipticlon - precess7_df$precession
monthlvl7<-cut(moonmo7,breaks=moonmobreaks,include.lowest=TRUE)
data_block7_df<-cbind(data_block7_df,monthlvl7)

#  F.  Add date. And that finishes block 7.

#idate <- as.POSIXlt("2009-02-10")
#edate7<-update(idate,year=data_block7_df$yr,month=data_block7_df$mo)
edate7 <- edate4[1609:4969]
data_block7_df<-cbind(data_block7_df,edate7)

colnames7 <- colnames(data_block_df[,6:17])
colnames7 <- c(colnames7,"monthlvl","edate")
names(data_block7_df)<-colnames7

newmeidates <- data_block7_df$edate[3205:3215]
newmeinums <- data.frame(c(-.055, -.056, -.08, .77, 1.455, 1.049, .461, .027, -.449, -.551, -.277))
newmei<-(cbind(newmeinums,newmeidates))
colnames(newmei)<-c("MEI","edate")

