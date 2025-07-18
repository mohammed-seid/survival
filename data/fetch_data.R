# Data Fetching Script
# This script fetches data from CommCare API and saves it locally
# Run this script to update the data before analysis

# Load required libraries
library(httr)
library(jsonlite)
library(dplyr)
library(readr)

# Source common configuration
source("_common.R")

# Create data directory if it doesn't exist
if (!dir.exists("data")) {
  dir.create("data", recursive = TRUE)
}

# Function to fetch data from CommCare API
fetch_commcare_data <- function() {
  cat("🔄 Fetching data from CommCare API...\n")
  
  tryCatch({
    # API Endpoint
    url <- paste0("https://www.commcarehq.org/a/", PROJECT_SPACE, "/api/v0.5/odata/forms/", FORM_ID, "/feed")
    
    # Enhanced data fetching with progress tracking
    limit <- 2000
    all_records <- list()
    offset <- 0
    
    repeat {
      cat(sprintf("📥 Fetching records %d-%d...\n", offset + 1, offset + limit))
      
      # Make API request
      response <- GET(
        url,
        authenticate(USERNAME, PASSWORD),
        query = list(
          `$skip` = offset,
          `$top` = limit,
          `$format` = "json"
        ),
        timeout(30)
      )
      
      if (status_code(response) != 200) {
        stop(sprintf("API request failed with status %d", status_code(response)))
      }
      
      # Parse response
      data <- fromJSON(content(response, "text"))
      records <- data$value
      
      if (length(records) == 0) break
      
      all_records <- append(all_records, list(records))
      offset <- offset + limit
      
      if (length(records) < limit) break
    }
    
    # Convert to data frame
    df_raw <- bind_rows(all_records)
    
    # Save raw data
    saveRDS(df_raw, "data/raw_data.rds")
    write_csv(df_raw, "data/raw_data.csv")
    
    cat(sprintf("✅ Successfully fetched %d records from CommCare API\n", nrow(df_raw)))
    cat("💾 Data saved to data/raw_data.rds and data/raw_data.csv\n")
    
    return(df_raw)
    
  }, error = function(e) {
    cat("❌ Failed to fetch from CommCare API\n")
    cat("Error:", e$message, "\n")
    return(NULL)
  })
}

# Function to load data (API first, then local fallback)
load_survey_data <- function() {
  # Try to fetch from API first
  df_raw <- fetch_commcare_data()
  
  # If API fails, try to load from local file
  if (is.null(df_raw)) {
    cat("🔄 Attempting to load from local data file...\n")
    
    if (file.exists("data/raw_data.rds")) {
      df_raw <- readRDS("data/raw_data.rds")
      cat("✅ Loaded data from data/raw_data.rds\n")
    } else if (file.exists("df.rds")) {
      df_raw <- readRDS("df.rds")
      cat("✅ Loaded data from df.rds (legacy location)\n")
      # Save to new location
      saveRDS(df_raw, "data/raw_data.rds")
      write_csv(df_raw, "data/raw_data.csv")
      cat("💾 Data copied to data/ folder\n")
    } else {
      stop("❌ No data source available. Please ensure either CommCare API is accessible or data files exist.")
    }
  }
  
  return(df_raw)
}

# Function to process and save cleaned data
process_and_save_data <- function(df_raw) {
  cat("🔄 Processing data...\n")
  
  # Process the data (same logic as in individual files)
  df_processed <- df_raw %>%
    mutate(
      date = as.Date(substr(timeend, 1, 10)),
      week = format(date, "%Y-W%U"),
      day_of_week = weekdays(date),
      hour_started = as.numeric(substr(timestart, 12, 13)),
      duration_min = as.numeric(difftime(
        as.POSIXct(timeend, format = "%Y-%m-%dT%H:%M:%S"),
        as.POSIXct(timestart, format = "%Y-%m-%dT%H:%M:%S"),
        units = "mins"
      )),
      is_complete = !is.na(timeend) & !is.na(timestart),
      is_quality = duration_min >= 5 & duration_min <= 120,
      is_night_survey = hour_started < 6 | hour_started > 22
    ) %>%
    filter(is_complete)
  
  # Save processed data
  saveRDS(df_processed, "data/processed_data.rds")
  write_csv(df_processed, "data/processed_data.csv")
  
  cat(sprintf("✅ Processed %d complete surveys\n", nrow(df_processed)))
  cat("💾 Processed data saved to data/processed_data.rds and data/processed_data.csv\n")
  
  # Generate data summary
  summary_stats <- list(
    total_surveys = nrow(df_processed),
    date_range = list(
      start = min(df_processed$date, na.rm = TRUE),
      end = max(df_processed$date, na.rm = TRUE)
    ),
    unique_sites = n_distinct(df_processed$site, na.rm = TRUE),
    unique_enumerators = n_distinct(df_processed$username, na.rm = TRUE),
    avg_duration = round(mean(df_processed$duration_min, na.rm = TRUE), 2),
    quality_rate = round(mean(df_processed$is_quality, na.rm = TRUE) * 100, 2),
    last_updated = Sys.time()
  )
  
  # Save summary
  write_json(summary_stats, "data/data_summary.json", pretty = TRUE)
  
  cat("📊 Data summary saved to data/data_summary.json\n")
  
  return(df_processed)
}

# Main execution
if (!interactive()) {
  cat("🚀 Starting data fetch and processing...\n")
  df_raw <- load_survey_data()
  df_processed <- process_and_save_data(df_raw)
  cat("🎉 Data fetch and processing completed successfully!\n")
}