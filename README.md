# Survival Survey Dashboard - Quarto Website

This interactive Quarto website replaces the original Shiny application with enhanced functionality and better performance. The website provides comprehensive analysis of survey data with interactive filtering and visualization capabilities.

## Features

### 📊 Executive Summary
- Key performance indicators (KPIs)
- Interactive filters for date range, site, woreda, and enumerator
- Daily survey progress tracking
- Target achievement monitoring
- Geographic distribution analysis

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
- Advanced interactive filtering
- Comprehensive data table with export capabilities
- Dynamic visualizations
- Cross-tabulation analysis
- Real-time summary statistics

### 📈 Advanced Analytics
- Survey completion funnel analysis
- Duration distribution with statistical markers
- Weekly trends with forecasting
- Correlation analysis
- Time series decomposition
- Performance clustering
- Predictive analytics

## Interactive Features

### Global Filters
- **Date Range**: Filter data by specific date ranges
- **Site Selection**: Multi-select site filtering
- **Woreda Selection**: Geographic filtering
- **Enumerator Selection**: Individual performance tracking

### Data Export
- CSV, Excel, and PDF export capabilities
- Filtered data export
- Copy to clipboard functionality

### Real-time Updates
- Filters update all visualizations simultaneously
- Cross-linked interactive elements
- Responsive design for all screen sizes

## Technical Requirements

### R Packages Required
```r
install.packages(c(
  "quarto",
  "dplyr", 
  "tidyr",
  "lubridate",
  "stringr", 
  "plotly",
  "reactable",
  "DT",
  "htmlwidgets",
  "crosstalk"
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

## Data Requirements

The website expects a file named `df.rds` in the `myapp/` directory containing the survey data with the following key columns:

- `consent`: Survey consent status
- `completed_time`, `started_time`: Timestamp data
- `site`, `woreda`, `username`: Geographic and enumerator information
- `duration_minutes`: Survey duration
- `hh_size`, `education_level`, `age`, `sex`: Demographic data
- `ps_num_planted_*`, `num_surv_*`: Tree planting and survival data

## Advantages over Shiny App

1. **Better Performance**: Static generation with interactive JavaScript
2. **No Server Required**: Can be hosted on any static hosting service
3. **Better SEO**: Search engine friendly
4. **Offline Capability**: Works without internet connection once loaded
5. **Version Control Friendly**: All code is in text files
6. **Easy Deployment**: Simple file upload to hosting service
7. **Better Caching**: Faster load times for repeat visitors

## Customization

### Colors and Themes
Edit `custom.scss` and `styles.css` to modify the visual appearance.

### Adding New Pages
Create new `.qmd` files and add them to the `_quarto.yml` navigation.

### Modifying Visualizations
Each page contains R code chunks that can be modified to change visualizations.

## Support

For questions or issues, please refer to the [Quarto documentation](https://quarto.org/) or create an issue in the project repository.