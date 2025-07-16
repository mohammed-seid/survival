# Shinylive Deployment Script for Survival Survey Dashboard
# This script exports the Shiny app to a static website compatible with GitHub Pages

# Load required libraries
library(shinylive)

# Clean up previous exports
if (dir.exists("docs")) {
  unlink("docs", recursive = TRUE)
}

# Export the Shiny app to static files
cat("🚀 Exporting Shiny app to Shinylive...\n")

shinylive::export(
  appdir = "myapp",
  destdir = "docs",
  verbose = TRUE
)

cat("✅ Export completed!\n")
cat("📁 Files exported to: docs/\n")
cat("🌐 To deploy to GitHub Pages:\n")
cat("   1. Commit and push the 'docs' folder to your GitHub repository\n")
cat("   2. Go to Settings > Pages in your GitHub repository\n")
cat("   3. Set source to 'Deploy from a branch'\n")
cat("   4. Select 'main' branch and '/docs' folder\n")
cat("   5. Save and wait for deployment\n\n")

cat("🔧 To test locally, run:\n")
cat("   httpuv::runStaticServer('docs')\n")
cat("   Then open: http://127.0.0.1:8080\n\n")

# Test if the export was successful
if (file.exists("docs/app.json")) {
  cat("✅ Export verification: app.json found\n")
  
  # Check file size
  app_size <- file.info("docs/app.json")$size
  cat(sprintf("📊 App size: %.2f KB\n", app_size / 1024))
  
  if (app_size > 0) {
    cat("🎉 Export appears successful!\n")
  } else {
    cat("⚠️  Warning: app.json is empty\n")
  }
} else {
  cat("❌ Error: app.json not found. Export may have failed.\n")
}

# Check for WebR packages directory
if (dir.exists("docs/shinylive/webr/packages")) {
  pkg_count <- length(list.files("docs/shinylive/webr/packages", pattern = "\\.data$"))
  cat(sprintf("📦 WebR packages: %d found\n", pkg_count))
} else {
  cat("⚠️  Warning: WebR packages directory not found\n")
}

cat("\n🌟 Your Shinylive app is ready for deployment!\n")