# Setup Script for Survival Survey Dashboard
# Run this script to set up the project for the first time

cat("🚀 Setting up Survival Survey Dashboard...\n\n")

# Check if required packages are installed
required_packages <- c(
  "httr", "jsonlite", "dplyr", "tidyr", 
  "lubridate", "stringr", "plotly", 
  "reactable", "DT", "readr"
)

missing_packages <- required_packages[!required_packages %in% installed.packages()[,"Package"]]

if (length(missing_packages) > 0) {
  cat("📦 Installing missing R packages...\n")
  cat("Missing packages:", paste(missing_packages, collapse = ", "), "\n")
  
  install.packages(missing_packages, dependencies = TRUE)
  cat("✅ Packages installed successfully!\n\n")
} else {
  cat("✅ All required R packages are already installed!\n\n")
}

# Create data directory if it doesn't exist
if (!dir.exists("data")) {
  dir.create("data", recursive = TRUE)
  cat("📁 Created data directory\n")
} else {
  cat("📁 Data directory already exists\n")
}

# Check for environment file
if (!file.exists(".env")) {
  if (file.exists(".env.example")) {
    cat("⚙️  Please copy .env.example to .env and fill in your CommCare credentials\n")
    cat("   cp .env.example .env\n")
  } else {
    cat("⚙️  Please create a .env file with your CommCare credentials\n")
  }
} else {
  cat("✅ Environment file (.env) found\n")
}

# Check if Quarto is installed
quarto_installed <- system("quarto --version", intern = TRUE, ignore.stderr = TRUE)
if (length(quarto_installed) > 0) {
  cat("✅ Quarto is installed:", quarto_installed[1], "\n")
} else {
  cat("❌ Quarto is not installed. Please install from https://quarto.org/\n")
}

cat("\n🎉 Setup complete!\n\n")

cat("Next steps:\n")
cat("1. Configure your CommCare credentials in .env file\n")
cat("2. Run: source('data/fetch_data.R') to fetch data\n")
cat("3. Run: quarto render to build the website\n")
cat("4. Run: quarto preview to preview locally\n\n")

cat("For deployment:\n")
cat("- GitHub Pages: Push to main branch with secrets configured\n")
cat("- Netlify: Connect repository with environment variables set\n")
cat("- Manual: Upload docs/ folder to any web hosting service\n\n")

cat("📚 See README.md for detailed instructions\n")