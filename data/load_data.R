# Data Loading Utility
# This script provides functions to load data for analysis
# All analysis scripts should use this instead of duplicating data loading logic

# Load required libraries
library(dplyr)
library(readr)
library(jsonlite)

# Function to load processed data
load_processed_data <- function() {
  if (file.exists("data/processed_data.rds")) {
    cat("📊 Loading processed data from data/processed_data.rds\n")
    return(readRDS("data/processed_data.rds"))
  } else if (file.exists("data/processed_data.csv")) {
    cat("📊 Loading processed data from data/processed_data.csv\n")
    return(read_csv("data/processed_data.csv", show_col_types = FALSE))
  } else {
    stop("❌ No processed data found. Please run data/fetch_data.R first.")
  }
}

# Function to load raw data
load_raw_data <- function() {
  if (file.exists("data/raw_data.rds")) {
    cat("📊 Loading raw data from data/raw_data.rds\n")
    return(readRDS("data/raw_data.rds"))
  } else if (file.exists("data/raw_data.csv")) {
    cat("📊 Loading raw data from data/raw_data.csv\n")
    return(read_csv("data/raw_data.csv", show_col_types = FALSE))
  } else {
    stop("❌ No raw data found. Please run data/fetch_data.R first.")
  }
}

# Function to get data summary
get_data_summary <- function() {
  if (file.exists("data/data_summary.json")) {
    return(fromJSON("data/data_summary.json"))
  } else {
    return(NULL)
  }
}

# Function to check if data needs updating (older than 24 hours)
data_needs_update <- function() {
  if (!file.exists("data/data_summary.json")) {
    return(TRUE)
  }
  
  summary <- get_data_summary()
  if (is.null(summary$last_updated)) {
    return(TRUE)
  }
  
  last_update <- as.POSIXct(summary$last_updated)
  hours_since_update <- as.numeric(difftime(Sys.time(), last_update, units = "hours"))
  
  return(hours_since_update > 24)
}

# Function to ensure data is available and up-to-date
ensure_data_available <- function(force_update = FALSE) {
  if (force_update || data_needs_update()) {
    cat("🔄 Data needs updating. Running fetch_data.R...\n")
    source("data/fetch_data.R")
  }
  
  return(load_processed_data())
}