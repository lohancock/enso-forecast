# enso-forecast

#
**trying out a planetary ring system to predict enso**
# 
This repository presents data and R code used to prepare the poster presentation, **Trying out a planetary ring system to predict ENSO** which was presented at the annual meeting of the American Meteorologial Society in Austin, Texas, 2018.  The poster is linked herein:   https://ams.confex.com/ams/98Annual/webprogram/Paper321391.html

The flow is as follows:

- Put all data and code into a single directory.  Suppose it is called 'enso'.  Then set the working directory, **setwd('~/enso')**
- Source **datablocks.R** to assemble the data blocks. To change the way the output files look later on, edit the parameters at the top of datablocks.R.
- Source **TimeSeriesComparison.R** to prepare time series comparing the model to observed MEI from 1875 to 2016, such as the three time series figures from the middle panel, lower half of the poster.

#
**data**

- Two files:  MEI_ext_1871_2005.txt and MEI_1950_Dec2016.txt comprise time series of the multivariate ENSO index (from NOAA).
- Two files:  ephemeris_moon_1600_2030.txt and horizons_orbitalelementsofmoon4.txt.  These are ephemerides of the Moon from JPL Horizons system.  Parameters of the download  preserved as top lines of the file.  
- ephemeris of the Earth from JPL,  Parameters of the download are preserved as top lines of the file.
- time series of sunspots from SIDC.  From http://www.sidc.be/silso/datafiles
- time series of Schatten sunspot group number, where the annual series is interpolated with constant values.  This time series is not actually used for the presentation so the defects in approach do not matter.  It is supplied here because the code expects it.

#     
**code**

*datablocks.R*

- Code begins with a reminder to **setwd** to the directory which contains the data files because the read commands expect to find data in the working directory.
- Code then lists **require** calls for needed packages outside base R.  
- Code then assigns values that determine the number of bands into which each variable will be cut for the Bayes analysis.  These assignments are often changed.  (This script should better have been turned into a function and these parameters its arguments.)
- Datasets are then read into data blocks for analysis.  

  The need to prepare a sequence of different data blocks arises because the availability of the predictors varies over time:  MEI, extended MEI, sunspots,  Schatten sunspot group count, and astronomical ephemerides.  (remark:  the Schatten group number was not used in the poster, but a block was dedicated to assemblng data that match its time frame.)  Furthermore, the future is a time block of its own where assumptions are made about sunspots and MEI.

  The data block most often used is the first one.  The block 1875 to 2016 has data available in all categories, so it is used (in other routines listed below) to develop a predictive model that is applied to other time blocks.   To make the model applicable, the breaks used for block 1 are preserved so that other blocks can be broken out into the same bands.  Else the model is not applicable. 
  
  An aspect of using Bayes as a predictive model where the future predictors are constant values is that the approach fails if bands are completely empty.  For this reason, a future block is prepared with data going back in time so that the bands will not be empty.  However that future block is not used as a source of past data.
  
  Note that the breaks are calculated before the 80/20 breakout is made; for this reason, the bands used to calculate the model, which draw on the 80% selection, are not exactly equally occupied.  This is a consideration that weights the bands not quite equally.  One solution is not to do the 80/20 breakout - another is to run the process many times.  


*Austin_Poster_3Part_TS_Middle Panel.R*

This code produces the time series on the middle panel, panel 3, of the Austin poster.  To make those figures, begin with datablocks.R, using the following parameters to achieve the same look as the Austin poster:
- mein <- 75 
- lout2 <- 49 
- lout3 <- 13 
- lout4 <- 13 
- lout5 <- 13 
- loutApsides <- 49 

Then run this routine.  It saves on disk three PNG files, each 8 inches wide and 3 high.  You can change that of course.



*Panels*

Panel 3 of the poster shows the relationship between the multivariate ENSO index and each of the six variables used as predictors.  These figures are produced in the routine XX.  This particular appearance requires having previously run datablocks.R with assignments YYYYY.

Panel 4 of the poster at the top shows (left) the truth table for the 6-variable model predictions of the multivariate ENSO index.  It shows it graphically - bluer squares are less occupied, white squares are more occupied.  To the right is the truth table for a predictive model using the same variables except for one:  the prior value of MEI is not used as a predictor.  The point is that the relationship still exists - a white spine runs along the diagonal, although contrast is lower  These figures are produced in teh routine Xx.  This particular appearance requires having previously run datablocks.R with assignments YYYYY.

Panel 4 then presents a time series in which a time series of the predictive model is presented as a red line and a blue line, while the multivariate ENSO index 1875 to 2016 is presented as black dots. The red line presents a model run where prior MEI was taken as a constant value at the uppermost band.  The blue line presents a model run where prior MEI is taken as a constant value at the lowest band.  MEI should therefore fall in between the two.  Despite the ambiguities as some points have no prediction at all due to data insufficiency, the prediction is clearly made overall and a comparison is possible in my opinion.  This time series 1875 to 2016 is produced in the routine XXX.  This particular appearance requires having previously run datablocks. R with assignments YYY.

Panel 5 presents an MEI forecast.  Two panels present a forecast for the assumption that SIDC monthly sunspot count will be a constant value 6 going forward; the two panel below that, that SIDC monthly sunspot count will be 25 going forward.  In this case, the forecast is made ten times (each time based on a random draw of 80 percent of available data).  Each includes a few years of MEI data used to build the model (up to 2016), plus the year 2017 which was not used to build the model but is provided for comparison.  Each predicton is presented at high time resolution and low.  These figures are using the routine XXX.  This particular appearance requires having previously run datablocks.R with assignments YYY.  The file WWW.txt provides some additional details on the setup of the multiple instances.
