# enso-forecast

**trying out a planetary ring system to predict enso**

This repository presents the R routines used for the preparation of a poster presentation for the annual meeting of the American Meteorologial Society in Austin, Texas, 2018. https://ams.confex.com/ams/98Annual/webprogram/Paper321391.html

This repository provides the data and R routines used to prepare figures on the poster https://ams.confex.com/ams/98Annual/webprogram/Handout/Paper321391/PlanetaryRingSystemForENSOPredictionJan2018.pdf

**the data**

The poster hypothesis was that ENSO could be predicted from astronomical ephemeris, namely the configuration of sun, moon, and Earth, plus sunspots.  This repository stores those datthe asets as they were when I used them:  

- a time series of ENSO, for which I used the multivariate ENSO index prepared and updated by NOAA, called X
- ephemeris of the Moon from JPL, called X
- ephemeris of the Earth from JPL, called X
- time series of sunspots from SIDC, called X

The datasets were read into data blocks for analysis.  The key issue here is that the model is developed from data in the time period covered by the MEI, 1875 to present.  It is a naive Bayes model.  I wish to extend that model forward in time.  Thus I compute the statistical breaks over the time period where the model is computed, and must use the same breaks going forward in time, else the model is inapplicable.
A second issue is that I wish to be able to change the number of bands into which the data is sorted for the Bayes analysis.  Smaller bands show the existence of relationships very clearly but the corresponding forecasts are not high resolution.

**the R routines**

*datablocks.R*

Taking these two issues into consideration, it is necessary to break out the original data into bands and store the corresponding break points each time new bands are tried - and then to use those breaks for the future datasets (ephemeris, assumed sunspot time series).  The R routine datablocks.R does all that

*Panels*

Panel 3 of the poster shows the relationship between the multivariate ENSO index and each of the six variables used as predictors.  These figures are produced in the routine XX.  This particular appearance requires having previously run datablocks.R with assignments YYYYY.

Panel 4 of the poster at the top shows (left) the truth table for the 6-variable model predictions of the multivariate ENSO index.  It shows it graphically - bluer squares are less occupied, white squares are more occupied.  To the right is the truth table for a predictive model using the same variables except for one:  the prior value of MEI is not used as a predictor.  The point is that the relationship still exists - a white spine runs along the diagonal, although contrast is lower  These figures are produced in teh routine Xx.  This particular appearance requires having previously run datablocks.R with assignments YYYYY.

Panel 4 then presents a time series in which a time series of the predictive model is presented as a red line and a blue line, while the multivariate ENSO index 1875 to 2016 is presented as black dots. The red line presents a model run where prior MEI was taken as a constant value at the uppermost band.  The blue line presents a model run where prior MEI is taken as a constant value at the lowest band.  MEI should therefore fall in between the two.  Despite the ambiguities as some points have no prediction at all due to data insufficiency, the prediction is clearly made overall and a comparison is possible in my opinion.  This time series 1875 to 2016 is produced in the routine XXX.  This particular appearance requires having previously run datablocks. R with assignments YYY.

Panel 5 presents an MEI forecast.  Two panels present a forecast for the assumption that SIDC monthly sunspot count will be a constant value 6 going forward; the two panel below that, that SIDC monthly sunspot count will be 25 going forward.  In this case, the forecast is made ten times (each time based on a random draw of 80 percent of available data).  Each includes a few years of MEI data used to build the model (up to 2016), plus the year 2017 which was not used to build the model but is provided for comparison.  Each predicton is presented at high time resolution and low.  These figures are using the routine XXX.  This particular appearance requires having previously run datablocks.R with assignments YYY.  The file WWW.txt provides some additional details on the setup of the multiple instances.
