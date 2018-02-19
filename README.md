# enso-forecast

#
**trying out a planetary ring system to predict enso**
# 
This repository presents data and R code used to prepare the poster presentation, **Trying out a planetary ring system to predict ENSO** which was presented at the annual meeting of the American Meteorologial Society in Austin, Texas, 2018.  The poster is linked herein:   https://ams.confex.com/ams/98Annual/webprogram/Paper321391.html
# 
Download all data and code from here into a single directory and remember to set the working directory as a preliminary; for example, **setwd('~/enso')**  This preliminary is needed because this code expects to find the data in the working directory.
         
  For each graphic prepared, as a preliminary step run **datablocks.R** to clear the workspace and to set the number of bands parameters should be sliced into for the Bayes analysis.
        
Note that the code for most of the graphics is two core routines, each with small changes made for the respective graphics.  
     
- Panel 2 lower graphics:  Visual representations of the model relationships between MEI and each predictor:  phase of the precession of lunar nodes, number of sunspots, phase of solar year, phase of eclipse year, phase of rotation of apsides, magnitude of the two-months-prior value of the MEI.  For the first five model relationships, use **austin_panel_ephemeris_rasters_pub.R**.  For the model relationship between MEI and two-months-prior MEI, use **austin_panel_truthtable_pub.R**.
- Panel 3 upper - Graphical truth tables to find out whether the model has any skill.  For this, run **datablocks.R** using a low number for mein, such as 12 or 13.  Then run **austin_panel_truthable1.R** and **austin_panel_truthtable2_R.**  Note that these routines do a lot of things, which I have not removed from the code.  But each saves just one file on disk, respectively the two truth tables.  The reason it works this way is that the same code makes all the different graphics, but the final poster versions required different tuning of graphics, so I saved the same underlying code under many names.
- Panel 3 lower - Comparison between model and data over the period 1875 to 2016, similar to the time series found in the lower half of the middle panel of the Austin poster.  For this, first run **datablocks.R** using a high number for mein (25 to 70) and then source **TimeSeriesComparison.R** which will save three PNG files.  Note they are each 8 inches wide.  Note also that if you copy and paste the file in, rather than sourcing it, then it will print the files to your output screen so you can look at them (and it will save these).
- Panel 4 - An ensemble forecast of MEI, like the one found on panel 4 of the Austin poster.


#
**data**

- Two files:  **MEI_ext_1871_2005.txt** and **MEI_1950_Dec2016.txt** comprise time series of the multivariate ENSO index (from NOAA).
- Two files:  **ephemeris_moon_1600_2030.txt** and **horizons_orbitalelementsofmoon4.txt** provide ephemerides of the Moon from JPL Horizons system.  Parameters of the download are preserved as top lines of the files.   They have different time frames and might have different orbital elements.  There are two because in preparing the first datablocks I did not realize I would later make data blocks with wider time frames.  I did not want to go back and rewrite working code so I left the earlier code linked to a shorter data file.
- Two files:  **horizons_eartheclipticlatlong.txt** and **horizons_eartheclipticlatlong_LONG.txt** provide ephemerides of the Earth from JPL.
- The file **monthly_sunspots.csv** provides time series of sunspots from SIDC.  From http://www.sidc.be/silso/datafiles
- The file **schatten_extrapolated.txt** provides time series of Schatten sunspot group number, where the annual series is interpolated with constant values.  This time series is not actually used for the presentation so the defects in approach do not matter.  It is supplied here because the code expects it.

#     
**code**

**datablocks.R**

- Code begins with a reminder to **setwd** to the directory which contains the data files because the read commands expect to find data in the working directory.
- Code then lists **require** calls for needed packages outside base R.  
- Code then assigns values that determine the number of bands into which each variable will be cut for the Bayes analysis.  These assignments are often changed.  (This script should better have been turned into a function and these parameters its arguments.)
- Datasets are then read into data blocks for analysis.  

  The need to prepare a sequence of different data blocks arises because the availability of the predictors varies over time:  MEI, extended MEI, sunspots,  Schatten sunspot group count, and astronomical ephemerides.  (remark:  the Schatten group number was not used in the poster, but a block was dedicated to assemblng data that match its time frame.)  Furthermore, the future is a time block of its own where assumptions are made about sunspots and MEI.

  The data block most often used is the first one.  The block 1875 to 2016 has data available in all categories, so it is used (in other routines listed below) to develop a predictive model that is applied to other time blocks.   To make the model applicable, the breaks used for block 1 are preserved so that other blocks can be broken out into the same bands.  Else the model is not applicable. 
  
  An aspect of using Bayes as a predictive model where the future predictors are constant values is that the approach fails if bands are completely empty.  For this reason, a future block is prepared with data going back in time so that the bands will not be empty.  However that future block is not used as a source of past data.
  
  Note that the breaks are calculated before the 80/20 breakout is made; for this reason, the bands used to calculate the model, which draw on the 80% selection, are not exactly equally occupied.  This is a consideration that weights the bands not quite equally.  One solution is not to do the 80/20 breakout - another is to run the process many times.  
#  
**austin_panel_ephemeris_rasters_pub.R** and **austin_panel_truthtable_pub.R.**
  
TBD xxxxxxxxxxxxxxxxxxxxxx

#   
**austin_panel_truthable1.R** and **austin_panel_truthtable2_R.**

  These generate the truth tables presented as graphics at the top of the middle panel of the Austin poster.  One is the truth table for the 6-variable model predictions of the multivariate ENSO index; it shows it graphically - bluer squares are the less-occupied squares on a table, while white squares are more occupied. The white spine running along the diagonal shows that the model has skill.  To the right on the poster is the truth table for a predictive model using the same variables except for one:  the prior value of MEI is not used as a predictor.  **The point is that the relationship still exists - a white spine runs along the diagonal,** although contrast is lower  The appearance of the figures as on the poster depends on having previously run datablocks.R using mein set to 12 or 13.  Else the figured is a bit cluttered although it shows the same thing.

# 
**TimeSeriesComparison.R**

  This code produces the time series on the middle panel, panel 3, of the Austin poster.  To make those figures, begin with datablocks.R, using the following parameters to achieve the same look as the Austin poster:
  
- mein <- 75 
- lout2 <- 49 
- lout3 <- 13 
- lout4 <- 13 
- lout5 <- 13 
- loutApsides <- 49 

  Then run this routine.  It saves on disk three PNG files, each 8 inches wide and 3 high.  You can change that of course.
  
  When complete this presents a time series in which a time series of the predictive model is presented as a red line and a blue line, while the multivariate ENSO index 1875 to 2016 is presented as black dots. The red line presents a model run where prior MEI was taken as a constant value at the uppermost band.  The blue line presents a model run where prior MEI is taken as a constant value at the lowest band.  MEI should therefore fall in between the two.  Despite the ambiguities as some points have no prediction at all due to data insufficiency, the prediction is clearly made overall and a comparison is possible in my opinion. 


# 
**make_ensemble.txt**
  
  This is a set of notes describing how to make an ensemble forecast of future MEI.  The procedure describes 
  
- setting an assumption about future sunspots, running datablocks to assemble that into quantiles ready for Bayes, 
- running the routine austin_panel5_nearfin.R in order to output a single pair of red and blue forecasts, and saving that
- doing all of that ten times
- plotting the resulting ensemble at high and low time resolution
- then doing all of that again with a different assumption about sunspots.
  
  In the end, two panels present a forecast for the assumption that SIDC monthly sunspot count will be a constant value 6 going forward; the two panel below that, that SIDC monthly sunspot count will be 25 going forward.  Each presents a ten-member ensemble.  That is, the forecast is made ten times, each time based on a random draw of 80 percent of available data 1875 to 2016.  The forecasts are presented at high time resolution and low.  Each presentation includes a few years of actual MEI data (which was used to build the model), simply to train the eye. Each also includes the year 2017 which was not used to build the model but is "forecast" since it is the future from the point of view of the model.  Observations are also provided for 2017 but using different symbols.  Each predicton is presented at high time resolution and low.  

# 
**austin_panel5_nearfin.R**

  This routine is used to output a forecast.  It is used as indicated in the notes, **make_ensemble.txt**
  
  


