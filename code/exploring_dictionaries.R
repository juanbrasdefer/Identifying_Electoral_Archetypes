
# libraries, directory --------------------------------------------------------

library(tidyverse)
library(here)

here::i_am("code/exploring_dictionaries.R")


# load data --------------------------------------------------------------------

change_dict <- read_csv(here("data/dictionaries/change_dictionary.csv"))






















# SAMPLE CODE FOR CHECKING DEMOCRATIC FREQUENCIES ------------------------------


# Text cleaning packages
library(textdata)
library(textclean)
library(dplyr)

# Plotting 
library(scales)
library(forcats)
library(ggplot2)
library(repr)
options(repr.plot.width = 10, repr.plot.height = 10)

# load data ---------------------------------------------------------------------
debates_jm_raw <- read.csv(here("data/APP_UCSB/josiah_mcmillan/pres_debates.csv"))


# filter-out non-candidates (like moderators) 
# filter-out debates preceding 21st century 
debates_contemporary = debates_jm_raw %>% 
  filter(year > 1999)  %>% 
  filter(candidate == 1) %>% 
  mutate(year = as.factor(year)) %>%
  mutate(speaker_year_id = paste0(speaker, "_", year)) 



debates_contemporary_bydebate <- debates_contemporary %>%
  group_by(date, speaker, year, type, speaker_year_id) %>%
  summarise(text = paste(text, collapse = " "), .groups = "drop") %>%
  mutate(text_length = nchar(text))

debates_contemporary_concat <- debates_contemporary_bydebate %>%
  group_by(speaker, year, speaker_year_id) %>%
  summarise(text = paste(text, collapse = " "), .groups = "drop") %>%
  mutate(text_length = nchar(text))

# need to check out: 
# there is a 11/28/2007 entry for Clinton
# that says she appeared at the republican debate
# this means that a lot in the dataset could be wrong

# similarly there's a 
# 10/4/2016 entry for trump 
# that is clearly for the vice presidential debate and anti-trump


ggplot(debates_contemporary_concat, aes(x = text_length)) +
  geom_histogram(binwidth = 200, fill = "#be67e6", color = "#be67e6", alpha = 0.7) +
  labs(title = "Distribution of Text Lengths",
       x = "Number of Characters",
       y = "Frequency") +
  theme_minimal()




# COUNTS ----------------------------------------------------------------


# Create a new dataframe with speaker names
crosstab_debates <- debates_contemporary_concat %>%
  group_by(speaker_year_id) %>%
  summarise(across(everything(), ~ first(.), .names = "meta_{.col}")) %>% # Preserve metadata
  select(speaker_year_id)  # Keep only speaker_year_id column for now



unigrams_as_list <- as.list(change_dict$stem)

# Count occurrences of each word
for (word in unigrams_as_list) {
  crosstab_debates[[word]] <- debates_contemporary_concat %>%
    group_by(speaker_year_id) %>%
    summarise(count = sum(str_count(tolower(text), 
                                    tolower(word))), .groups = "drop") %>%
    pull(count)
}


crosstab_debates <- crosstab_debates %>%
  mutate(total_changegrams = rowSums(across(where(is.numeric)), 
                                     na.rm = TRUE)) %>%
  left_join(debates_contemporary_concat%>%select(speaker_year_id,text_length),    
            by = "speaker_year_id") 

crosstab_debates <- crosstab_debates %>%
  mutate(percent_changegrams = (total_changegrams/text_length)*10) %>%
  arrange(desc(percent_changegrams)) 

crosstab_debates %>%
  write_csv(here("data/results/crosstab_debates.csv"))







# generating plot
single_words = c("corporations","businesses","slavery","police","woman",
                 "women","tax", "latino", "immigration", "racism", 
                 "gay", "carbon", "white", "Asian", "wages")

climate_test = dem_debate_words %>% filter(word %in% single_words) 
climate_test$freq = climate_test$n/climate_test$total



ggplot(climate_test, aes(x=freq, y=word), fig(10,10)) + 
  geom_point(size=4, aes(colour=year), alpha = 0.7) +
  theme_bw() +  
  ggtitle("Frequency of selected terms in Democratic Primary Debates") +
  xlab("Frequency") + 
  # ylab("Word") + 
  # scale_fill_discrete(name ="Election Year") +  
  labs(color ='Election Year')  +
  theme(axis.title.y=element_blank())