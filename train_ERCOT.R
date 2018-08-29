library(tidyverse)
library(lubridate)
library(knitr)
library(ggthemes)
library(caret)


source("functions.R")

urlBase = 'https://services.yesenergy.com/PS/rest/timeseries/multiple.csv?'
aggLevel = 'hour'
stat = 'avg'

# Date Ranges
startdate = '01/01/2014'
enddate = 'today'

# Data items
object_1 = "10000712973"
datatype_1 = "RTLOAD"
object_2 = "10000697078"
datatype_2 = "RTLMP"
object_3 = "10000697078"
datatype_3= "DALMP"
object_4 = "10000712973"
datatype_4 = "WINDDATA"
object_5 = "10000756298"
datatype_5 = "TOTAL_RESOURCE_CAP_OUT"

# Create the URL for the desired query
items = sprintf("%s:%s,%s:%s,%s:%s,%s:%s,%s:%s", 
                datatype_1, object_1, 
                datatype_2, object_2, 
                datatype_3, object_3,
                datatype_4, object_4,
                datatype_5, object_5)
itemCount = length(unlist(gregexpr(',',items))) + 1
metaCols = 6
cols = paste(c(1,seq(itemCount+2,itemCount+metaCols),seq(2,length.out = itemCount)),collapse=',')
url = sprintf('%sagglevel=%s&stat=%s&startdate=%s&enddate=%s&items=%s',
              urlBase,aggLevel,stat,startdate,enddate,items)

# Pull the data and store in DT
DT = callAPI(uid=uid,url=url,pwd=pwd)

names(DT)[str_detect(names(DT), "RTLOAD")] <- "LOAD"
names(DT)[str_detect(names(DT), "WINDDATA")] <- "WIND"
names(DT)[str_detect(names(DT), "TOTAL_RESOURCE_CAP_OUT")] <- "OUTAGES"
names(DT)[str_detect(names(DT), "RTLMP")] <- "RTLMP"
names(DT)[str_detect(names(DT), "DALMP")] <- "DALMP"

model_data <- DT %>% 
  mutate(date = as.POSIXct(DATETIME, "%m/%d/%Y %H", tz = "US/Central"),
         year = lubridate::year(date),
         month = lubridate::month(date),
         day = lubridate::day(date),
         hour = lubridate::hour(date),
         market_date = as.Date(MARKETDAY, format = "%m/%d/%Y")) %>% 
  select(year,
         month,
         day,
         hour,
         DALMP,
         LOAD,
         WIND,
         OUTAGES) %>%
  na.omit()

write.csv(model_data, "model_data.csv", row.names = FALSE)
