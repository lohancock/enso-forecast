# enso-forecast

#
**trying out a planetary ring system to predict enso**
# 
This repository presents the R routines used for the preparation of a poster presentation, **Trying out a planetary ring system to predict ENSO** for the annual meeting of the American Meteorologial Society in Austin, Texas, 2018. https://ams.confex.com/ams/98Annual/webprogram/Paper321391.html

#
**the data in the repository**

The hypothesis of the presentation was that ENSO could be predicted from astronomical ephemeris, namely the configuration of sun, moon, and Earth, plus sunspots.  This repository stores those datasets as they were when I used them:  

- a time series of ENSO, for which I used the multivariate ENSO index prepared and updated by NOAA.  The file is called MEI_1950_Dec2016.txt 
- ephemeris of the Moon from JPL, called X
- ephemeris of the Earth from JPL, called X
- time series of sunspots from SIDC, called X

#     
**the R routines in the repository**

*datablocks.R*

This file begins with a reminder to setwd to the directory which contains the data files:  The R routines are written expecting to find all data files in the working directory.

This file then includes library calls at the top which indicate what packages are needed outside base R.  
This file then sets the number of bands into which each variable will be cut for the Bayes analysis.  This affects the appearance of the graphics that will be prepared from these data blocks.
# 
The main work of this routine next follows:  The datasets ae read into data blocks for analysis.  The block 1875 to 2016 is used to develop a Bayes model.  The breaks chosen here are saved so that the future data block can be broken out the same way, and the model be applied.

*Panels*

Panel 3 of the poster shows the relationship between the multivariate ENSO index and each of the six variables used as predictors.  These figures are produced in the routine XX.  This particular appearance requires having previously run datablocks.R with assignments YYYYY.

Panel 4 of the poster at the top shows (left) the truth table for the 6-variable model predictions of the multivariate ENSO index.  It shows it graphically - bluer squares are less occupied, white squares are more occupied.  To the right is the truth table for a predictive model using the same variables except for one:  the prior value of MEI is not used as a predictor.  The point is that the relationship still exists - a white spine runs along the diagonal, although contrast is lower  These figures are produced in teh routine Xx.  This particular appearance requires having previously run datablocks.R with assignments YYYYY.

Panel 4 then presents a time series in which a time series of the predictive model is presented as a red line and a blue line, while the multivariate ENSO index 1875 to 2016 is presented as black dots. The red line presents a model run where prior MEI was taken as a constant value at the uppermost band.  The blue line presents a model run where prior MEI is taken as a constant value at the lowest band.  MEI should therefore fall in between the two.  Despite the ambiguities as some points have no prediction at all due to data insufficiency, the prediction is clearly made overall and a comparison is possible in my opinion.  This time series 1875 to 2016 is produced in the routine XXX.  This particular appearance requires having previously run datablocks. R with assignments YYY.

Panel 5 presents an MEI forecast.  Two panels present a forecast for the assumption that SIDC monthly sunspot count will be a constant value 6 going forward; the two panel below that, that SIDC monthly sunspot count will be 25 going forward.  In this case, the forecast is made ten times (each time based on a random draw of 80 percent of available data).  Each includes a few years of MEI data used to build the model (up to 2016), plus the year 2017 which was not used to build the model but is provided for comparison.  Each predicton is presented at high time resolution and low.  These figures are using the routine XXX.  This particular appearance requires having previously run datablocks.R with assignments YYY.  The file WWW.txt provides some additional details on the setup of the multiple instances.
