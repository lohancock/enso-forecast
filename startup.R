substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}
 

#f <- function(x) {
#  r <- quantile(x, probs = c(0.05, 0.25, 0.5, 0.75, 0.95))
#  names(r) <- c("ymin", "lower", "middle", "upper", "ymax")
#  r
#}
#ggplot(d, aes(x, y)) + stat_summary(fun.data = f, geom="boxplot")

# substrRight source is Andrie on stack overflow,
# here:  http://stackoverflow.com/questions/7963898/extracting-the-last-n-characters-from-a-string-in-r

# install.packages("rmarkdown")
library(rmarkdown)
# install.packages("stringr")
library (stringr)
# install.packages("insol")
library(insol)
#install.packages("plyr")
library(plyr)
# install.packages("marelac")
library(marelac)
# install.packages("sqldf")
library(sqldf)
# install.packages("RODBC")
 library(RODBC)
# install.packages("dplyr")
library(dplyr)
# install.packages("lubridate")
library(lubridate)
# install.packages("tidyr")
library(tidyr)
# install.packages("ggplot2")
library(ggplot2)
# install.packages("RPostgreSQL")
library(RPostgreSQL)
# install.packages ("reshape")
library(reshape)

# install.packages("rworldmap")
library(rworldmap)
# install.packages("gdata")
library(gdata)
# install.packages("ggmap")
library(ggmap)
# install.packages("broom")
library(broom)
library(grid)
#install.packages("swirl")
#library(swirl)
library(png)
#install.packages("forcats")
library(forcats)
library(e1071)
library(xml2)
library(XML)
library(RCurl)
library(xts)
