# enso-forecast
This repository is related to the presentation I am preparing for AMS January 2018 (Austin)

The abstract follows.  It explains the purpose of all this, then refers to Github for the code itself.  

If Earth has a ring system (as other planets do), it might drive ENSO since the changing configuration of the rings would drive global cycles of Earth shading. Infalling ring dust, cold and electrically charged, could also drive local cycles in wind speed and direction, precipitation intensity, frequency of lightning strokes, sea surface temperature, and nutrient availability.
The purpose of this effort is to set out a corresponding ENSO prediction for comparison with the climate of the next few years.

The idea that Earth has a ring-driven climate was first put forward by O’Keefe (1980). It has faced several challenges. First, only the Moon could replenish a persistent ring. That is, if the Moon is dead there cannot be a persistent ring. And the Moon has indeed been thought by many geologists to be dead. But that majority view was challenged by Verbiscer in 2009, as evidence of geological activity on the Moon as little as 50 million years ago was established. Activity may have occurred since then – the methodology did not have the resolution to establish that.

A second area of challenge is the question of why the ring has not been observed. Broadly the answer seems to be that while it must have been observed if it exists, it could have been misidentified. We will not address any of those issues here. Of note, we have reviewed CWOP solar radiation data, a half-billion observations of solar radiation made by thousands of volunteer weather stations from 2009 forward in a global distribution. Solar radiation data is not inconsistent with the ring hypothesis (Hancock and Chadwick 2016, https://ams.confex.com/ams/96Annual/webprogram/Session38896.html).

Our exploration of this question is driven by two considerations that we believe are of immediate and broad appeal: First: As noted above, if the Moon is not geologically active, there can be no persistent ring system. It follows from this that if there is a persistent ring system, then the Moon is geologically active. If so, we would wish to develop all available detail on that. Second: if there is a ring system, then the effects of this driver will not be rightly identified by normal existing analyses, because this driver’s effects would be almost but not quite seasonal, almost but not quite aligned with terrestrial coordinate systems. On the other hand, understanding this driver in its own coordinate framework and timeframes could support a jump in forecasting skill for some teleconnections. This driver is best sought directly.

As a test and exemplar of what might be done to seek this jump in skill, this presentation considers the ENSO cycle, hypothesizing that it is driven by a cycle in the configuration of a two-ring system. A two-ring system should be considered because it is the most general possibility: an equatorial ring and one in the plane of the Moon’s orbit are the two orientations observed at Saturn. No other planetary ring orientations are known at this time. The key cycle concerned would be the precession of lunar nodes, the cycle on which the two rings would cycle in and out of phase with each other. It is 18.3 years. The proposal is that the ENSO cycle concerns this cycle. For example, Earth would be more effectively shaded when the rings were out of phase, and less effectively shaded when they were in phase . A visualization of this geometry is presented at 1997 which may be compared to 2007.

A statistical model has been developed using naïve Bayes techniques to predict the multivariate ENSO index (MEI) (broken out as four categories) from (a) the phase of the lunar precession of nodes, (b) phase of the solar year, (c) phase of the eclipse year, (d) sunspot number as a proxy for solar activity that is expected to thin the entire structure when strong; and (e) MEI of two months prior, introduced as a proxy for climate persistence.

A typical train/test run of the model (80%/20%) over monthly values of the MEI from 1950 - 2016 results in a truth table (not provided in the Github readme but is an output of the attached code.

Adapting this model for forecasting rather than hindcasting, the issue is that we do not know future values of MEI. So we have undertaken a kind of “ensemble” forecast: the band value of the MEI is predicted four times at each time point. Results are presented in the Figure (not provided in the Github readme but is an output of the attached code) , where

a red circle presents the prediction obtained using for the prior MEI (two months prior) a band value between 1 and 5 (an El Nino signal);
a pink circle presents the prediction obtained using for the prior MEI a band value 1 and 0 (a warm-neutral signal),
a green circle presents the prediction based on prior MEI between 0 and -1 (cool-neutral),
a blue circle presents the prediction for prior MEI less than -1 (a La Nina signal).
Statistical predictions are provided as categorization of MEI values into those same four bands. The predicted bands are distinguished at the vertical axis, where predictions plotted in the uppermost band are for high values, essentially El Nino, and so on down over four bands.

A statistical analysis of the ensemble forecast would need to incorporate solution to some statistical issues that we are not going to take up. But what we can say is that If the calculated truth table is representative, then this “ensemble” forecast suggests that a strong persistent El Nino is unlikely until late 2019. This point will be further discussed in the presentation, in terms of where the typical errors lie.

The presentation will present the same calculation for recent centuries for comparison with known events, and will update the forecast through 2020.

The code that trains/tests the statistical model, calculates a truth table, and prepares a forecast figure, is the content of this repository.  The code is R code.
   startup.R
   some long name.R
   A directory for data
   the data files
