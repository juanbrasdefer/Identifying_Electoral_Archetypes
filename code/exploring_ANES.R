# so it begins

# libraries, directory ------------------------------------------------------------
library(tidyverse)
library(here)

here::i_am("code/exploring_ANES.R")


# load data -----------------------------------------------------------------------

df <- read.delim(here("data/ANES/2016/anes_timeseries_2016/anes_timeseries_2016_rawdata.txt")
                 , sep = "|", 
                 header = TRUE)  # For tab-separated


#length(unique(df$V160001)) 
# gives 4270
# which means this is definitely our unique identifier column