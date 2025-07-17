# Survival Survey Dashboard - Quarto Website

This interactive Quarto website replaces the original Shiny application with enhanced functionality and better performance. The website provides comprehensive analysis of survey data fetched directly from CommCare with real-time data updates.

## Features

### 📊 Executive Summary
- Key performance indicators (KPIs)
- Daily survey progress tracking
- Target achievement monitoring
- Geographic distribution analysis
- Weekly trends analysis

### 👥 Enumerator Performance
- Individual performance metrics
- Target vs actual comparison
- Productivity heatmaps
- Quality alerts for short and night surveys
- Performance distribution analysis

### 🌱 Agricultural Analysis
- Tree survival rates by species
- Detailed species performance tables
- Planted vs survived comparisons
- Species distribution analysis
- Performance categorization

### 🏢 Site Analysis
- Site performance overview
- Comprehensive comparison tables
- Survival rates by site
- Duration analysis
- Efficiency scoring

### 🔍 Data Explorer
- Interactive data table with export capabilities
- Dynamic visualizations
- Cross-tabulation analysis
- Real-time summary statistics

### 📈 Advanced Analytics
- Survey completion funnel analysis
- Duration distribution with statistical markers
- Weekly trends with moving averages
- Correlation analysis
- Time series analysis
- Performance clustering
- Statistical summaries

## Data Source

### CommCare Integration
The website fetches data directly from CommCare using the API with the following configuration:

- **Username**: mohammed.seidhussen@oneacrefund.org
- **Project Space**: oaf-ethiopia  
- **Form ID**: e24ab639e5b7d1b609cf2894f7057b75

### Data Processing
- Automatic data fetching with progress tracking
- Real-time data processing and cleaning
- Privacy protection (sensitive fields automatically excluded)
- Data validation and type conversion

### Expected Data Structure
The data should contain the following key columns:
- `consent`: Survey consent status
- `completed_time`, `started_time`: Timestamp data
- `site`, `woreda`, `username`: Geographic and enumerator information
- `duration_minutes`: Survey duration
- `hh_size`, `education_level`, `age`, `sex`: Demographic data
- `ps_num_planted_*`, `num_surv_*`: Tree planting and survival data

**Note**: Sensitive fields (`farmer_name`, `name`, `phone_no`, `tno`) are automatically excluded for privacy.

## Technical Requirements

### R Packages Required
```r
install.packages(c(
  "quarto",
  "httr",
  "jsonlite", 
  "dplyr", 
  "tidyr",
  "lubridate",
  "stringr", 
  "plotly",
  "reactable",
  "DT",
  "htmlwidgets",
  "htmltools",
  "zoo",
  "tibble"
))
```

## How to Use

### 1. Render the Website
```bash
quarto render
```

### 2. Preview the Website
```bash
quarto preview
```

### 3. Publish the Website
The website will be generated in the `docs/` folder and can be:
- Hosted on GitHub Pages
- Deployed to Netlify, Vercel, or similar platforms
- Served from any web server

## Key Improvements

### Real-time Data
- Direct CommCare API integration
- Automatic data fetching and processing
- No manual data export/import required
- Always up-to-date information

### Enhanced Performance
- Static generation with interactive JavaScript
- No server required for hosting
- Better caching and load times
- Responsive design for all devices

### Privacy & Security
- Automatic exclusion of sensitive personal data
- Secure API authentication
- No local data storage required

### Interactive Features
- Advanced data tables with filtering and export
- Interactive visualizations with hover details
- Cross-tabulation analysis
- Statistical summaries and trends

## Advantages over Shiny App

1. **Real-time Data**: Direct API integration eliminates manual data updates
2. **Better Performance**: Static generation with interactive JavaScript
3. **No Server Required**: Can be hosted on any static hosting service
4. **Privacy Protection**: Automatic exclusion of sensitive data
5. **Easy Deployment**: Simple file upload to hosting service
6. **Better Caching**: Faster load times for repeat visitors
7. **Mobile Friendly**: Responsive design works on all devices

## Customization

### API Configuration
Update the CommCare credentials in each page's setup section:
```r
USERNAME <- "your-username@domain.com"
API_KEY <- "your-api-key"
PROJECT_SPACE <- "your-project-space"
FORM_ID <- "your-form-id"
```

### Colors and Themes
Edit `custom.scss` and `styles.css` to modify the visual appearance.

### Adding New Pages
Create new `.qmd` files and add them to the `_quarto.yml` navigation.

### Modifying Visualizations
Each page contains R code chunks that can be modified to change visualizations.

## Support

For questions or issues, please refer to the [Quarto documentation](https://quarto.org/) or create an issue in the project repository.