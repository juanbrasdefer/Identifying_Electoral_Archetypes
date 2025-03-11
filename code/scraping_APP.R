
# scraping the American Presidential Project
# for campaign documents 

# libraries -----------------------------------------------------------------------

library(tidyverse) # data manipulation
library(here) # working paths
library(tictoc) # stopwatch functionality
library(httr) # access sites 
library(rvest) # harvest (scrape) data 
library(xml2) # xml data manipulation


# working directory
here::i_am("code/scraping_APP.R")






# 1.1 PREP automated link collection ------------------------------------------------------


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


# 1.1 LOOP automated link collection ------------------------------------------------------

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
  cat("Scraped index page", page_num, "for links", "\n")
  
  # Increment the page number
  page_num <- page_num + 1
  
  # Optional: Sleep to avoid being blocked by the website
  Sys.sleep(1)  # Sleep for 1 seconds between requests
}

all_links <- unique(all_links)
all_links_df <- as.data.frame(all_links)

all_links_df %>%
  write_csv(here("data/APP_UCSB/scraped_links_campaigndocs.csv"))






# 2.1 PREP scrape webpages using links -------------------------------------------------


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



speech_data <- speech_data %>%
  mutate(body = str_replace_all(body, "[\r\n]", " ")) %>%
  mutate(nchars = nchar(body))


speech_data %>%
  saveRDS(file = "data/APP_UCSB/scraped_campaigndocs.rds")
  

# for excel
speech_data_truncated <- speech_data %>%
  #mutate(body = str_replace_all(body, "[:punct:]", " ")) %>%
  mutate(body_1 = str_sub(body, 1, 30000),  # First 30,000 characters
         body_2 = str_sub(body, 30001, 60000),
         body_3 = str_sub(body, 60001, 90000),
         body_4 = str_sub(body, 90001, nchar(body))) %>%
  select(-body) %>%
  write_csv(here("data/APP_UCSB/scraped_campaigndocs_truncated.csv"), quote = "all")













# 3 perhaps pipeline ---------------------------------------------------------

# Set batch size for saving
save_interval <- 500  
today_date <- date()

# Initialize an empty data frame or load existing progress
output_file <- here("data/APP_UCSB/scraped_campaigndocs.rds")

if (file.exists(output_file)) {
  speech_data <- readRDS(output_file)  # Load existing progress
  scraped_urls <- speech_data$url      # Track scraped URLs
} else {
  speech_data <- data.frame(
    url = character(),
    date_scraped = character(),
    speaker = character(),
    date = character(),
    title = character(),
    citation = character(),
    body = character(),
    stringsAsFactors = FALSE
  )
  scraped_urls <- c()  # Start with empty list
}


# URLs to scrape (excluding already scraped ones)
urls_to_scrape <- setdiff(all_links, scraped_urls)  

x <- nrow(speech_data) + 1  # Resume from last scraped entry
tictoc::tic()

for (url in urls_to_scrape){
  # Define the full URL
  website_stub <- "https://www.presidency.ucsb.edu"
  url <- paste0(website_stub, url)
  
  cat("Fetching page:", x, "\n")
  cat(url, "\n\n")
  
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
  
  # Create data row from xpath results
  data_row <- data.frame(
    url = url,
    date_scraped = today_date,
    speaker = extract_text(html_content, xpaths$speaker),
    date = extract_text(html_content, xpaths$date),
    title = extract_text(html_content, xpaths$title),
    citation = extract_text(html_content, xpaths$citation),
    body = extract_text(html_content, xpaths$body),
    stringsAsFactors = FALSE
  )
  
  # Append row to dataframe
  speech_data <- rbind(speech_data, data_row)
  
  # Save every `save_interval` pages
  if (x %% save_interval == 0) {
    saveRDS(speech_data, file = output_file)
    cat("---Progress saved at", x, "pages\n")
  }
  
  # Increment counter
  x <- x + 1  
  Sys.sleep(1)  # Prevent rate limiting
}


tictoc::toc()

# saving data -----------------------------------------------------------------
speech_data <- speech_data %>%
  mutate(body = str_replace_all(body, "[\r\n]", " ")) %>%
  mutate(nchars = nchar(body))

speech_data %>%
  saveRDS(file = here("data/APP_UCSB/scraped_campaigndocs.rds"))

# for excel
speech_data_truncated <- speech_data %>%
  #mutate(body = str_replace_all(body, "[:punct:]", " ")) %>%
  mutate(body_1 = str_sub(body, 1, 30000),  # First 30,000 characters
         body_2 = str_sub(body, 30001, 60000),
         body_3 = str_sub(body, 60001, 90000),
         body_4 = str_sub(body, 90001, nchar(body))) %>%
  select(-body) %>%
  write_csv(here("data/APP_UCSB/scraped_campaigndocs_truncated.csv"), quote = "all")


cat("Final dataset saved \n")




























































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








