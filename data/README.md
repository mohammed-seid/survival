# Data Directory

This directory contains all data files and data management scripts for the Survival Survey Dashboard.

## 📁 Directory Structure

```
data/
├── README.md              # This file
├── fetch_data.R           # Script to fetch and process data from CommCare API
├── load_data.R            # Utility functions for loading data in analysis scripts
├── raw_data.rds           # Raw data from CommCare API (binary format)
├── raw_data.csv           # Raw data from CommCare API (CSV format)
├── processed_data.rds     # Cleaned and processed data (binary format)
├── processed_data.csv     # Cleaned and processed data (CSV format)
└── data_summary.json      # Summary statistics and metadata
```

## 🔄 Data Workflow

### 1. Data Fetching
Run `fetch_data.R` to:
- Fetch latest data from CommCare API
- Save raw data to `raw_data.rds` and `raw_data.csv`
- Process and clean the data
- Save processed data to `processed_data.rds` and `processed_data.csv`
- Generate summary statistics in `data_summary.json`

```r
# Run from project root
source("data/fetch_data.R")
```

### 2. Data Loading in Analysis Scripts
All analysis scripts should use `load_data.R` functions:

```r
# Load the data loading utilities
source("data/load_data.R")

# Load processed data for analysis
df <- load_processed_data()

# Or ensure data is up-to-date before loading
df <- ensure_data_available()
```

## 📊 Data Files

### Raw Data (`raw_data.rds`, `raw_data.csv`)
- Direct export from CommCare API
- Contains all original fields and values
- Used as backup and for data lineage

### Processed Data (`processed_data.rds`, `processed_data.csv`)
- Cleaned and standardized data
- Additional calculated fields (duration, date parsing, quality flags)
- Ready for analysis and visualization
- **This is what analysis scripts should use**

### Data Summary (`data_summary.json`)
- Key statistics about the dataset
- Date ranges, counts, quality metrics
- Last update timestamp
- Used for dashboard metrics and data freshness checks

## 🔧 Data Processing

The data processing pipeline includes:

1. **Date/Time Processing**: Parse and standardize date/time fields
2. **Duration Calculation**: Calculate survey duration in minutes
3. **Quality Flags**: Identify quality surveys based on duration and timing
4. **Derived Fields**: Add day of week, hour started, week numbers
5. **Filtering**: Remove incomplete surveys

## 🚀 Deployment Notes

### For GitHub Pages / Netlify:
- Data files are included in the repository
- The website will use the most recent data files
- To update data, run `fetch_data.R` locally and commit the updated files

### For Automated Updates:
- Set up GitHub Actions to run `fetch_data.R` on a schedule
- Use environment variables for CommCare credentials
- Commit updated data files automatically

## 🔒 Security

- Never commit CommCare credentials to the repository
- Use environment variables or secure credential storage
- The `_common.R` file should contain placeholder values for public repositories

## 📝 Usage Examples

```r
# Basic data loading
source("data/load_data.R")
df <- load_processed_data()

# Check if data needs updating
if (data_needs_update()) {
  cat("Data is older than 24 hours")
}

# Force data update
df <- ensure_data_available(force_update = TRUE)

# Get summary statistics
summary <- get_data_summary()
print(paste("Total surveys:", summary$total_surveys))
```