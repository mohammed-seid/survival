# 🚀 Deployment Guide

This guide will help you deploy your Survival Survey Dashboard to GitHub Pages or Netlify.

## 📋 Pre-Deployment Checklist

### ✅ Local Setup
- [ ] R and required packages installed
- [ ] Quarto CLI installed
- [ ] Data fetching works locally (`source("data/fetch_data.R")`)
- [ ] Website renders successfully (`quarto render`)
- [ ] Website previews correctly (`quarto preview`)

### ✅ Repository Setup
- [ ] Code committed to GitHub repository
- [ ] `.env` file is NOT committed (check `.gitignore`)
- [ ] Data files are present in `data/` folder
- [ ] `docs/` folder is generated and committed

## 🐙 GitHub Pages Deployment

### Step 1: Repository Settings
1. Go to your repository on GitHub
2. Click **Settings** tab
3. Scroll to **Pages** section
4. Set source to **Deploy from a branch**
5. Select **main** branch and **docs** folder
6. Click **Save**

### Step 2: Set Up Secrets
1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Add the following secrets:
   - `COMMCARE_USERNAME`: Your CommCare username
   - `COMMCARE_PASSWORD`: Your CommCare password
   - `COMMCARE_PROJECT`: Your project space (e.g., "oaf-ethiopia")
   - `COMMCARE_FORM_ID`: Your form ID

### Step 3: Enable GitHub Actions
1. Go to **Actions** tab
2. Enable workflows if prompted
3. The deployment workflow will run automatically on push to main

### Step 4: Access Your Site
- Your site will be available at: `https://yourusername.github.io/survival`
- Check the **Actions** tab for deployment status

## 🌐 Netlify Deployment

### Step 1: Connect Repository
1. Go to [Netlify](https://netlify.com)
2. Click **New site from Git**
3. Choose **GitHub** and select your repository
4. Set build settings:
   - **Build command**: `quarto render`
   - **Publish directory**: `docs`

### Step 2: Set Environment Variables
1. Go to **Site settings** → **Environment variables**
2. Add the following variables:
   - `COMMCARE_USERNAME`: Your CommCare username
   - `COMMCARE_PASSWORD`: Your CommCare password
   - `COMMCARE_PROJECT`: Your project space
   - `COMMCARE_FORM_ID`: Your form ID

### Step 3: Deploy
1. Click **Deploy site**
2. Netlify will automatically build and deploy
3. Your site will be available at a generated URL (e.g., `https://amazing-site-123.netlify.app`)

### Step 4: Custom Domain (Optional)
1. Go to **Site settings** → **Domain management**
2. Add your custom domain
3. Configure DNS settings as instructed

## 🔧 Manual Deployment

For other hosting services:

1. **Build locally**:
   ```bash
   source("data/fetch_data.R")  # Fetch latest data
   quarto render                # Build website
   ```

2. **Upload files**:
   - Upload the entire `docs/` folder to your web server
   - Ensure the web server serves `index.html` as the default page

## 🔄 Updating Your Site

### Automatic Updates
- **GitHub Pages**: Pushes to main branch trigger automatic rebuilds
- **Netlify**: Pushes to main branch trigger automatic rebuilds
- **Scheduled**: GitHub Actions runs daily at 6 AM UTC to fetch fresh data

### Manual Updates
1. **Update data locally**:
   ```r
   source("data/fetch_data.R")
   ```

2. **Rebuild and commit**:
   ```bash
   quarto render
   git add .
   git commit -m "Update data and rebuild site"
   git push
   ```

## 🐛 Troubleshooting

### Common Issues

#### Build Fails
- Check that all R packages are installed
- Verify Quarto is properly installed
- Check for syntax errors in `.qmd` files

#### Data Not Loading
- Verify CommCare credentials are correct
- Check that data files exist in `data/` folder
- Review error messages in build logs

#### Site Not Updating
- Check that changes are committed and pushed
- Verify GitHub Actions/Netlify build completed successfully
- Clear browser cache

### Debug Commands

```bash
# Check Quarto installation
quarto --version

# Render with verbose output
quarto render --verbose

# Check R package installation
Rscript -e "installed.packages()[c('httr', 'jsonlite', 'dplyr'), 'Version']"
```

## 📊 Monitoring

### GitHub Pages
- Check **Actions** tab for build status
- Monitor **Insights** → **Traffic** for usage statistics

### Netlify
- Check **Deploys** tab for build status
- Monitor **Analytics** for usage statistics

## 🔒 Security Best Practices

1. **Never commit credentials** to the repository
2. **Use environment variables** for all sensitive data
3. **Regularly rotate** CommCare passwords
4. **Monitor access logs** for unusual activity
5. **Keep dependencies updated** for security patches

## 📞 Support

If you encounter issues:

1. Check the build logs for error messages
2. Review this deployment guide
3. Consult the [Quarto documentation](https://quarto.org/)
4. Create an issue in the repository

---

��� **Congratulations!** Your dashboard should now be live and automatically updating with fresh data!