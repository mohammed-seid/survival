# Common configuration and utilities for Survival Survey Dashboard
# This file contains shared functions, styling, and configuration

# Load required libraries
library(dplyr)
library(tidyr)
library(lubridate)
library(stringr)
library(plotly)
library(reactable)
library(DT)

# Helper functions
format_percent <- function(x, digits = 1) {
  paste0(round(x * 100, digits), "%")
}

format_number <- function(x, digits = 0) {
  format(round(x, digits), big.mark = ",", scientific = FALSE)
}

# Configuration (use environment variables for security in production)
USERNAME <- Sys.getenv("COMMCARE_USERNAME", "your_username_here")
PASSWORD <- Sys.getenv("COMMCARE_PASSWORD", "your_password_here")
PROJECT_SPACE <- Sys.getenv("COMMCARE_PROJECT", "oaf-ethiopia")
FORM_ID <- Sys.getenv("COMMCARE_FORM_ID", "e24ab639e5b7d1b609cf2894f7057b75")

# Custom color palette
custom_colors <- list(
  primary = "#2E8B57",      # Sea Green
  secondary = "#4682B4",    # Steel Blue
  success = "#28a745",      # Green
  warning = "#ffc107",      # Yellow
  danger = "#dc3545",       # Red
  info = "#17a2b8",         # Cyan
  light = "#f8f9fa",        # Light Gray
  dark = "#343a40",         # Dark Gray
  gradient = c("#2E8B57", "#4682B4", "#17a2b8", "#28a745", "#ffc107", "#dc3545")
)

# Load data using centralized data loading system
source("data/load_data.R")

# Load processed data
tryCatch({
  df_completed <- ensure_data_available()
  cat("✅ Data loaded successfully\n")
}, error = function(e) {
  cat("❌ Error loading data:", e$message, "\n")
  cat("ℹ️  Please run data/fetch_data.R to fetch and process data\n")
  
  # Create empty dataframe as fallback
  df_completed <- data.frame()
})

# Common plot styling function
style_plot <- function(p, title = "", subtitle = "") {
  p %>%
    layout(
      title = list(
        text = paste0("<b>", title, "</b><br><sub>", subtitle, "</sub>"),
        font = list(size = 16, color = custom_colors$dark)
      ),
      font = list(family = "Arial, sans-serif", size = 12),
      plot_bgcolor = "rgba(0,0,0,0)",
      paper_bgcolor = "rgba(0,0,0,0)",
      margin = list(t = 80, b = 60, l = 60, r = 60)
    )
}

# Common reactable styling
style_reactable <- function(data, ...) {
  reactable(
    data,
    theme = reactableTheme(
      headerStyle = list(
        backgroundColor = custom_colors$primary,
        color = "white",
        fontWeight = "bold"
      ),
      stripedColor = custom_colors$light,
      borderColor = "#ddd"
    ),
    defaultPageSize = 10,
    showPageSizeOptions = TRUE,
    pageSizeOptions = c(10, 25, 50, 100),
    searchable = TRUE,
    ...
  )
}