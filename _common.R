# Common data loading script for all pages
# This script fetches data from CommCare and processes it

library(httr)
library(jsonlite)
library(dplyr)
library(tidyr)
library(lubridate)
library(stringr)

# Helper functions
format_percent <- function(x, digits = 1) {
  paste0(round(x * 100, digits), "%")
}

format_number <- function(x, digits = 0) {
  format(round(x, digits), big.mark = ",", scientific = FALSE)
}

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

cat("Fetching data from CommCare...\n")

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
df_raw <- bind_rows(all_records)

# Drop farmer name and phone number 
df_raw <- df_raw %>% 
  select(-any_of(c("farmer_name", "name", "phone_no", "tno")))

cat(paste0("Successfully fetched ", nrow(df_raw), " records from CommCare\n"))

# Process the data
df_processed <- df_raw %>%
  mutate(across(everything(), ~ na_if(., "---"))) %>%
  mutate(across(where(is.list), ~ sapply(., function(x) if(length(x) > 0) x[1] else NA))) %>%
  mutate(
    completed_time = ymd_hms(completed_time),
    started_time = ymd_hms(started_time)
  ) %>%
  mutate(
    date = as.Date(completed_time),
    week = floor_date(date, "week"),
    month = floor_date(date, "month"),
    hour_started = hour(started_time),
    day_of_week = wday(date, label = TRUE, week_start = 1),
    is_weekend = day_of_week %in% c("Sat", "Sun"),
    duration_minutes = as.numeric(difftime(completed_time, started_time, units = "mins")),
    is_night_survey = hour_started >= 19 | hour_started < 6,
    is_short_survey = duration_minutes <= 5,
    is_long_survey = duration_minutes >= 60
  ) %>%
  mutate(across(c(starts_with("ps_num_planted_"), starts_with("num_surv_")), as.numeric))

df_completed <- df_processed %>% filter(consent == 1)