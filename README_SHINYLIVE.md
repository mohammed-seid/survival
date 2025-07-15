# 🌱 ETH 2025 Survival Survey Dashboard - Shinylive App

This repository contains a Shinylive web application for monitoring agricultural tree survival and survey quality across Ethiopia. The dashboard is adapted from the original Quarto dashboard and can be hosted on GitHub Pages.

## 📁 Files Structure

```
survival_2025/
├── app_survival.R          # Full Shiny application (for local development)
├── index.html             # Shinylive web app (for GitHub Pages)
├── README_SHINYLIVE.md    # This file
└── Survival_Enhanced.qmd  # Original Quarto dashboard
```

## 🚀 Hosting on GitHub Pages

### Step 1: Enable GitHub Pages

1. Go to your GitHub repository settings
2. Scroll down to "Pages" section
3. Under "Source", select "Deploy from a branch"
4. Choose "main" branch and "/ (root)" folder
5. Click "Save"

### Step 2: Access Your Dashboard

Once GitHub Pages is enabled, your dashboard will be available at:
```
https://[your-username].github.io/survival_2025/
```

Replace `[your-username]` with your actual GitHub username.

## 🎯 Dashboard Features

### 📊 Executive Summary
- **Real-time Metrics**: Total surveys, completion rates, refusal rates
- **Progress Tracking**: Daily survey progress with trend analysis
- **Target Achievement**: Visual gauge showing progress toward goals

### 👥 Enumerator Performance
- **Individual Analysis**: Performance metrics for each enumerator
- **Quality Scoring**: Automated quality assessment based on survey patterns
- **Productivity Tracking**: Daily averages and target comparisons

### 🌱 Agricultural Analysis
- **Survival Rates**: Tree survival rates by species
- **Species Performance**: Detailed breakdown of planted vs survived trees
- **Geographic Distribution**: Performance mapping by location

### 📋 Data Explorer
- **Interactive Filtering**: Filter by date, site, enumerator
- **Export Capabilities**: Download filtered data as CSV/Excel
- **Real-time Search**: Dynamic data exploration

## 🔧 Technical Details

### Data Source
The dashboard connects to CommCare HQ API to fetch real-time survey data:
- **API Endpoint**: CommCare HQ OData API
- **Authentication**: Basic authentication with username/API key
- **Data Processing**: Real-time cleaning and transformation

### Technology Stack
- **Frontend**: HTML5, CSS3, JavaScript
- **Backend**: R Shiny (via Shinylive)
- **Visualization**: Plotly.js for interactive charts
- **Tables**: DataTables for interactive data grids
- **Hosting**: GitHub Pages (static hosting)

### Browser Compatibility
- Chrome 80+
- Firefox 75+
- Safari 13+
- Edge 80+

## 🛠️ Local Development

### Running the Full Shiny App

1. Install required R packages:
```r
install.packages(c(
  "shiny", "shinydashboard", "DT", "plotly", 
  "dplyr", "tidyr", "lubridate", "httr", 
  "jsonlite", "stringr", "scales"
))
```

2. Run the application:
```r
shiny::runApp("app_survival.R")
```

### Modifying the Shinylive Version

The `index.html` file contains the embedded Shinylive app. To modify:

1. Edit the JavaScript code within the `appCode` variable
2. Test locally by opening `index.html` in a web browser
3. Commit and push changes to update the GitHub Pages version

## 📊 Data Structure

### Survey Data Fields
- **Basic Info**: Date, enumerator, farmer details
- **Location**: Site, woreda (district)
- **Quality Metrics**: Duration, timing, completion status
- **Agricultural Data**: Trees planted and survived by species

### Species Tracked
- **Gesho** (Rhamnus prinoides)
- **Dec** (Psydrax schimperiana)
- **Grev** (Grevillea robusta)
- **Moringa** (Moringa oleifera)
- **Coffee** (Coffea arabica)
- **Papaya** (Carica papaya)
- **Wanza** (Cordia africana)

## 🔒 Security & Privacy

- **API Keys**: Stored securely, not exposed in client-side code
- **Data Privacy**: No personal data stored in browser
- **HTTPS**: All connections encrypted
- **Access Control**: GitHub repository permissions control access

## 🐛 Troubleshooting

### Common Issues

1. **Dashboard not loading**
   - Check browser console for JavaScript errors
   - Ensure GitHub Pages is properly enabled
   - Verify internet connection

2. **Data not updating**
   - Check API connectivity
   - Verify authentication credentials
   - Review CommCare HQ permissions

3. **Charts not displaying**
   - Ensure browser supports modern JavaScript
   - Check for ad blockers interfering with content
   - Try refreshing the page

### Getting Help

1. Check browser developer console for errors
2. Review GitHub Pages deployment status
3. Verify all files are properly committed to repository

## 📈 Performance Optimization

### Loading Speed
- **CDN Resources**: Shinylive loaded from CDN
- **Lazy Loading**: Charts load on demand
- **Caching**: Browser caching enabled for static assets

### Data Efficiency
- **Pagination**: Large datasets split into pages
- **Filtering**: Client-side filtering for responsiveness
- **Compression**: Data compressed during transmission

## 🔄 Updates & Maintenance

### Regular Updates
- **Data Refresh**: Automatic data updates from API
- **Feature Enhancements**: Regular dashboard improvements
- **Bug Fixes**: Ongoing maintenance and fixes

### Version Control
- **Git Tracking**: All changes tracked in Git
- **Branching**: Feature development in separate branches
- **Releases**: Tagged releases for major updates

## 📞 Support

For technical support or feature requests:
1. Create an issue in the GitHub repository
2. Include detailed description of the problem
3. Provide browser and system information
4. Include screenshots if applicable

---

**Last Updated**: December 2024  
**Version**: 1.0.0  
**License**: MIT License