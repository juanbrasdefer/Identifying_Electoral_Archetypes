
# scraping the American Presidential Project
# for campaign documents 

# libraries -----------------------------------------------------------------------

library(tidyverse) # data manipulation
library(here) # working paths
library(httr) # access sites 
library(rvest) # harvest (scrape) data 
library(xml2) # xml data manipulation



# working directory
here::i_am("code/scraping_APP.R")










# attempt 3, automated link collection ------------------------------------------------------


# URL of the speeches index page (Modify this to match the right page!)
base_url <- "https://www.presidency.ucsb.edu/documents/app-categories/elections-and-transitions/campaign-documents?items_per_page=60" 

page_num <- 1  # Start at page 1

# Maximum number of pages to scrape
max_pages <- 10  # Set the limit here (adjust this number as needed)
# need to go to page 361 at least
# page 361 is the first one with 2000
# but there's only a total of like 30 documents for the 2000 election... interesting

# Initialize an empty vector to store all the URLs you scrape
all_links <- c()

# Loop to scrape each page until max_pages
while(page_num <= max_pages) {
  # Construct the URL for the current page
  url <- paste0(base_url, "&page=",page_num)
  
  # Fetch the webpage
  page <- GET(url)
  
  # Parse the HTML
  html_content <- read_html(content(page, "text"))
  

  # Extract all speech URLs
  speech_links <- html_content %>%
    html_elements(xpath = "//div[contains(@class, 'view-content')]//div[contains(@class, 'field-title')]//a") %>%
    html_attr("href")
  
  # Store the links (if there are any)
  all_links <- c(all_links, speech_links)
  
  # Print status
  cat("Scraped page ", page_num, "\n")
  
  # Increment the page number
  page_num <- page_num + 1
  
  # Optional: Sleep to avoid being blocked by the website
  Sys.sleep(1)  # Sleep for 1 seconds between requests
}





# attempt 4, batch scrape from automated links -------------------------------------------------

urls <- all_links[1:10]

# Function to extract text using XPath
extract_text <- function(html_content, xpath) {
  elements <- html_content %>%
    html_elements(xpath = xpath) %>%
    html_text(trim = TRUE)
  
  if (length(elements) > 0) {
    return(elements[1])  # Extract first valid result
  } else {
    return(NA)  # Handle missing data
  }
}


# Initialize an empty data frame
speech_data <- data.frame(
  url = character(),
  speaker = character(),
  date = character(),
  title = character(),
  citation = character(),
  body = character(),
  stringsAsFactors = FALSE
)


for (url in urls){
  # Define the URL
  website_stub <- "https://www.presidency.ucsb.edu"
  url <- paste0(website_stub, url)
  
  cat("fetching page: ", url, "\n")
  
  # Fetch the webpage
  page <- GET(url)
  
  # Parse the HTML content
  html_content <- read_html(content(page, "text"))
  
  # Define XPaths
  xpaths <- list(
    speaker = "//div[contains(@class, 'field-title')]",
    date = "//div[contains(@class, 'field-docs-start-date-time')]",
    title = "//div[contains(@class, 'field-ds-doc-title')]",
    citation = "//div[contains(@class, 'field-prez-document-citation')]",
    body = "//div[contains(@class, 'field-docs-content')]"
  )
  
  # create data row from xpath results
  data_row <- data.frame(
    url = url,
    speaker = extract_text(html_content, xpaths$speaker),
    date = extract_text(html_content, xpaths$date),
    title = extract_text(html_content, xpaths$title),
    citation = extract_text(html_content, xpaths$citation),
    body = extract_text(html_content, xpaths$body),
    stringsAsFactors = FALSE
  )
  
  # append row to running df
  speech_data <- rbind(speech_data, data_row)
  
  # system messages and sleep
  cat("row appended, sleeping...","\n")
  Sys.sleep(1)
  
}





# attempt 1, just one page -----------------------------------------------------------


xpath_speaker <- "//div[contains(@class, 'field-title')]" # name of speaker (returns two items, one of which is meta; kill it in future scrape)
xpath_date <- "//div[contains(@class, 'field-docs-start-date-time')]" # date (is a string, maybe u will want to extract the formatted version instead)
xpath_title <- "//div[contains(@class, 'field-ds-doc-title')]" # title of speech (like type of speech and city and state)
xpath_citation <- "//div[contains(@class, 'field-prez-document-citation')]" # academic citation
xpath_body <- "//div[contains(@class, 'field-docs-content')]" # full text of speech (including audience interactions etc.)




# Define the URL
url <- "https://www.presidency.ucsb.edu/documents/remarks-the-vice-president-political-event-west-allis-wisconsin"

# Fetch the webpage
page <- GET(url)

# Parse the HTML content
html_content <- read_html(content(page, "text"))

# Define XPaths
xpaths <- list(
  speaker = "//div[contains(@class, 'field-title')]",
  date = "//div[contains(@class, 'field-docs-start-date-time')]",
  title = "//div[contains(@class, 'field-ds-doc-title')]",
  citation = "//div[contains(@class, 'field-prez-document-citation')]",
  body = "//div[contains(@class, 'field-docs-content')]"
)

# Function to extract text using XPath
extract_text <- function(xpath) {
  elements <- html_content %>%
    html_elements(xpath = xpath) %>%
    html_text(trim = TRUE)
  
  if (length(elements) > 0) {
    return(elements[1])  # Extract first valid result
  } else {
    return(NA)  # Handle missing data gracefully
  }
}

# Extract data and store in a data frame
speech_data <- data.frame(
  speaker = extract_text(xpaths$speaker),  # Removing unwanted metadata
  date = extract_text(xpaths$date),  
  title = extract_text(xpaths$title),
  citation = extract_text(xpaths$citation),
  body = extract_text(xpaths$body),
  stringsAsFactors = FALSE  # Prevents automatic factor conversion
)

# Print the structured data
print(speech_data)



# attempt 2, non-elegant batch scrape -------------------------------------------------


# Function to extract text using XPath
extract_text <- function(html_content, xpath) {
  elements <- html_content %>%
    html_elements(xpath = xpath) %>%
    html_text(trim = TRUE)
  
  if (length(elements) > 0) {
    return(elements[1])  # Extract first valid result
  } else {
    return(NA)  # Handle missing data
  }
}


# Initialize an empty data frame
speech_data <- data.frame(
  url = character(),
  speaker = character(),
  date = character(),
  title = character(),
  citation = character(),
  body = character(),
  stringsAsFactors = FALSE
)

urls <- c(
  "https://www.presidency.ucsb.edu/documents/remarks-the-vice-president-political-event-west-allis-wisconsin",
  "https://www.presidency.ucsb.edu/documents/remarks-the-vice-president-campaign-event-atlanta-georgia"
)

for (url in urls){
  # Define the URL
  url <- url
  
  cat("fetching page: ", url, "\n")
  
  # Fetch the webpage
  page <- GET(url)
  
  # Parse the HTML content
  html_content <- read_html(content(page, "text"))
  
  # Define XPaths
  xpaths <- list(
    speaker = "//div[contains(@class, 'field-title')]",
    date = "//div[contains(@class, 'field-docs-start-date-time')]",
    title = "//div[contains(@class, 'field-ds-doc-title')]",
    citation = "//div[contains(@class, 'field-prez-document-citation')]",
    body = "//div[contains(@class, 'field-docs-content')]"
  )
  
  # create data row from xpath results
  data_row <- data.frame(
    url = url,
    speaker = extract_text(html_content, xpaths$speaker),
    date = extract_text(html_content, xpaths$date),
    title = extract_text(html_content, xpaths$title),
    citation = extract_text(html_content, xpaths$citation),
    body = extract_text(html_content, xpaths$body),
    stringsAsFactors = FALSE
  )
  
  # append row to running df
  speech_data <- rbind(speech_data, data_row)
  
  # system messages and sleep
  cat("row appended, sleeping...","\n")
  Sys.sleep(2)
  
}








