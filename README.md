# 🌱 Survival Survey Dashboard

An interactive web dashboard for analyzing agricultural survey data, built with Quarto and R. This dashboard provides comprehensive insights into survey performance, agricultural outcomes, and data quality metrics.

## 🚀 Live Demo

- **GitHub Pages**: [Your GitHub Pages URL]
- **Netlify**: [Your Netlify URL]

## 📊 Features

- **Executive Summary**: Overview of key metrics and trends
- **Enumerator Performance**: Analysis of survey team productivity and quality
- **Agricultural Analysis**: Tree planting and survival rate insights
- **Site Analysis**: Geographic and location-based performance
- **Data Explorer**: Interactive data table with filtering and export
- **Advanced Analytics**: Funnel analysis and trend forecasting

## 🏗️ Project Structure

```
survival/
├── 📁 data/                    # Data management
│   ├── fetch_data.R           # Data fetching from CommCare API
│   ├���─ load_data.R            # Data loading utilities
│   ├── README.md              # Data documentation
│   ├── raw_data.rds           # Raw survey data
│   ├── processed_data.rds     # Cleaned data for analysis
│   └── data_summary.json      # Dataset metadata
├── 📁 .github/workflows/      # GitHub Actions for deployment
│   └── deploy.yml             # Automated deployment workflow
├── 📁 docs/                   # Generated website (output)
├── 📄 _common.R               # Shared configuration and utilities
├── 📄 _quarto.yml             # Quarto website configuration
├── 📄 index.qmd               # Executive Summary page
├── 📄 enumerator-performance.qmd
├── 📄 agricultural-analysis.qmd
├── 📄 site-analysis.qmd
├── 📄 data-explorer.qmd
├── 📄 advanced-analytics.qmd
├── 📄 styles.css              # Custom CSS styling
├── 📄 custom.scss             # SCSS theme customization
├── 📄 netlify.toml            # Netlify deployment configuration
└── 📄 README.md               # This file
```

## 🛠️ Setup and Installation

### Prerequisites

- R (version 4.0 or higher)
- Quarto CLI
- Git

### Required R Packages

```r
install.packages(c(
  "httr", "jsonlite", "dplyr", "tidyr", 
  "lubridate", "stringr", "plotly", 
  "reactable", "DT", "readr"
))
```

### Local Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/survival.git
   cd survival
   ```

2. **Set up data**
   ```r
   # Option 1: Fetch fresh data (requires CommCare credentials)
   source("data/fetch_data.R")
   
   # Option 2: Use existing data files (if available)
   # Data files should be in the data/ directory
   ```

3. **Render the website**
   ```bash
   quarto render
   ```

4. **Preview locally**
   ```bash
   quarto preview
   ```

## 🚀 Deployment

### GitHub Pages

1. **Enable GitHub Pages** in repository settings
2. **Set up secrets** in repository settings:
   - `COMMCARE_USERNAME`
   - `COMMCARE_PASSWORD`
   - `COMMCARE_PROJECT`
   - `COMMCARE_FORM_ID`

3. **Push to main branch** - GitHub Actions will automatically build and deploy

### Netlify

1. **Connect repository** to Netlify
2. **Set environment variables** in Netlify dashboard:
   - `COMMCARE_USERNAME`
   - `COMMCARE_PASSWORD`
   - `COMMCARE_PROJECT`
   - `COMMCARE_FORM_ID`

3. **Deploy** - Netlify will automatically build using `netlify.toml` configuration

### Manual Deployment

```bash
# Fetch latest data
Rscript data/fetch_data.R

# Render website
quarto render

# Deploy the docs/ folder to your hosting service
```

## 📊 Data Management

### Data Sources

- **Primary**: CommCare API (real-time data)
- **Fallback**: Local data files (for offline development)

### Data Workflow

1. **Fetch**: `data/fetch_data.R` retrieves data from CommCare API
2. **Process**: Clean and standardize data format
3. **Save**: Store both raw and processed versions
4. **Load**: Analysis scripts use `data/load_data.R` utilities

### Data Updates

- **Automatic**: GitHub Actions runs daily at 6 AM UTC
- **Manual**: Run `source("data/fetch_data.R")` locally
- **On-demand**: Use GitHub Actions workflow dispatch

## 🔧 Configuration

### Environment Variables

For production deployment, set these environment variables:

```bash
COMMCARE_USERNAME=your_username
COMMCARE_PASSWORD=your_password
COMMCARE_PROJECT=your_project_space
COMMCARE_FORM_ID=your_form_id
```

### Customization

- **Colors**: Edit `custom_colors` in `_common.R`
- **Styling**: Modify `styles.css` and `custom.scss`
- **Layout**: Update `_quarto.yml` configuration
- **Content**: Edit individual `.qmd` files

## 📈 Analytics Features

### Key Metrics
- Total surveys completed
- Survey completion rates
- Data quality indicators
- Geographic distribution
- Temporal trends

### Visualizations
- Interactive charts with Plotly
- Responsive data tables with Reactable
- Geographic mapping
- Time series analysis
- Performance heatmaps

### Export Options
- CSV data export
- PDF report generation
- Excel file downloads
- Chart image exports

## 🔒 Security

- Credentials stored as environment variables
- No sensitive data in repository
- HTTPS enforcement
- Security headers configured

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally with `quarto preview`
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For questions or issues:
- Create an issue in this repository
- Contact the development team
- Check the documentation in the `data/` folder

## 🔄 Version History

- **v1.0**: Initial dashboard with basic analytics
- **v1.1**: Added data management system
- **v1.2**: Improved deployment configuration
- **Current**: Enhanced structure for easy deployment

---

Built with ❤️ using [Quarto](https://quarto.org/) and [R](https://www.r-project.org/)