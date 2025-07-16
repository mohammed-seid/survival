# export the Shiny app to a static site

# Install specific versions (replace with the versions shown in your warnings)
# Load necessary libraries
library(httr)
library(jsonlite)
library(tidyverse)
library(lubridate)
# Set the working directory to the location of your Shiny app

getwd()

#| include: false
# Configuration
USERNAME <- "mohammed.seidhussen@oneacrefund.org"
API_KEY <- "a749d18804539c5a2210817cda29630391a088bd"
PROJECT_SPACE <- "oaf-ethiopia"
FORM_ID <- "e24ab639e5b7d1b609cf2894f7057b75"

# API Endpoint
url <- paste0("https://www.commcarehq.org/a/", PROJECT_SPACE, "/api/v0.5/odata/forms/", FORM_ID, "/feed")

# Enhanced data fetching with progress tracking
limit <- 2000
offset <- 0
all_records <- list()


while (TRUE) {
  # Set query parameters
  query <- list(
    limit = limit,
    offset = offset
  )
  
  # Make API request
  response <- GET(
    url,
    query = query,
    authenticate(USERNAME, API_KEY, type = "basic")
  )
  
  # Check response
  if (status_code(response) != 200) {
    cat(paste0("Error: ", status_code(response), "\n"))
    cat(content(response, "text"), "\n")
    break
  }
  
  # Parse response
  data <- fromJSON(content(response, "text"))
  records <- data$value
  
  if (length(records) == 0) {
    break
  }
  
  # Add records to collection
  all_records <- c(all_records, records)
  
  # Check if we have all records
  if (length(records) < limit) {
    break
  }
  
  # Update offset for next page
  offset <- offset + limit
  cat(paste0("Fetched ", length(all_records), " records so far...\n"))
}

# Convert to data frame
# Note: This approach works best if all records have the same structure
df <- bind_rows(all_records)

# drop farmer name and phone number 
df<- df %>% select(-c(farmer_name, name, phone_no, tno))
  
  
# Save the cleaned data to a rds file inside myapp folder
saveRDS(df, "C:/Users/Lenovo/Documents/github/survival/myapp/df.rds")

# change the working directory to the location of your Shiny app shinylive


library(shinylive)

shinylive::assets_cleanup()

shinylive::assets_info()

unlink("docs", recursive = TRUE)

# Export the Shiny app to a static site
shinylive::export("myapp", "docs")

# Serve the static site using httpuv
library(httpuv)
# Set the working directory to the docs folder
httpuv::runStaticServer("docs")


