
# scraping the American Presidential Project
# for campaign documents 

# libraries -----------------------------------------------------------------------

library(tidyverse) # data manipulation
library(here) # working paths
library(httr) # web scraping
library(rvest)
library(xml2)

# path
here::i_am("code/scraping_APP.R")


# attempt 1, just one page -----------------------------------------------------------

# URL for one page
url <- "https://www.presidency.ucsb.edu/documents/remarks-the-vice-president-political-event-west-allis-wisconsin"

# Fetch the webpage
page <- GET(url) # seems to be meta info, such as date accessed, url

# Parse the HTML content
html_content <- read_html(content(page, "text")) # contains the entire page


xpath_speaker <- "//div[contains(@class, 'field-title')]" # name of speaker (returns two items, one of which is meta; kill it in future scrape)
xpath_date <- "//div[contains(@class, 'field-docs-start-date-time')]" # date (is a string, maybe u will want to extract the formatted version instead)
xpath_title <- "//div[contains(@class, 'field-ds-doc-title')]" # title of speech (like type of speech and city and state)
xpath_citation <- "//div[contains(@class, 'field-prez-document-citation')]" # academic citation
xpath_body <- "//div[contains(@class, 'field-docs-content')]" # full text of speech (including audience interactions etc.)


extracted_element <- html_content %>%
  html_elements(xpath = xpath_citation) %>%
  html_text(trim = TRUE)
print(extracted_date)
