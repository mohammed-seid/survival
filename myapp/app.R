# ETH 2025 Survival Survey Dashboard
# Revision Date: 2025-01-16
# Description: A Shinylive-optimized dashboard for analyzing survey data.
# This version minimizes dependencies and uses only packages that are
# fully compatible with WebAssembly R (webR) for seamless deployment.

# --- Core Libraries (Shinylive Compatible) ---
library(shiny)
library(bslib)
library(reactable)
library(plotly)
library(dplyr)
library(tidyr)
library(lubridate)
library(stringr)

# --- Custom Color Palette for Enhanced Visuals ---
custom_colors <- list(
  primary = "#2E8B57",      # Sea Green
  secondary = "#20B2AA",    # Light Sea Green
  success = "#28a745",      # Bootstrap Success
  warning = "#ffc107",      # Bootstrap Warning
  danger = "#dc3545",       # Bootstrap Danger
  info = "#17a2b8",         # Bootstrap Info
  light = "#f8f9fa",        # Light Gray
  dark = "#343a40",         # Dark Gray
  gradient = c("#2E8B57", "#20B2AA", "#66CDAA", "#98FB98", "#90EE90")
)

# --- Helper Functions ---
# Custom formatting functions to replace scales dependency
format_percent <- function(x, digits = 1) {
  paste0(round(x * 100, digits), "%")
}

format_number <- function(x, digits = 0) {
  format(round(x, digits), big.mark = ",", scientific = FALSE)
}

# --- Data Loading and Preprocessing ---
# Load the raw dataset from the RDS file
df_raw <- readRDS("df.rds")

# Clean and preprocess the data
df_processed <- df_raw %>%
  mutate(across(everything(), ~ na_if(., "---"))) %>%
  mutate(across(where(is.list), ~ sapply(., function(x) if(length(x) > 0) x[1] else NA))) %>%
  mutate(
    # Ensure time columns are in POSIXct format for calculations
    completed_time = ymd_hms(completed_time),
    started_time = ymd_hms(started_time)
  ) %>%
  mutate(
    date = as.Date(completed_time),
    week = floor_date(date, "week"),
    month = floor_date(date, "month"),
    hour_started = hour(started_time),
    day_of_week = wday(date, label = TRUE, week_start = 1),
    is_weekend = day_of_week %in% c("Sat", "Sun"),
    duration_minutes = as.numeric(difftime(completed_time, started_time, units = "mins")),
    is_night_survey = hour_started >= 19 | hour_started < 6,
    is_short_survey = duration_minutes <= 5,
    is_long_survey = duration_minutes >= 60
  ) %>%
  # Ensure numeric columns are correctly typed for calculations
  mutate(across(c(starts_with("ps_num_planted_"), starts_with("num_surv_")), as.numeric))

# --- UI Definition ---
ui <- page_navbar(
  title = div(
    icon("seedling", style = "color: #2E8B57; margin-right: 10px;"),
    "Survival Survey Dashboard",
    style = "font-weight: bold; font-size: 1.2em;"
  ),
  theme = bs_theme(
    version = 5, 
    bootswatch = "flatly",
    primary = "#2E8B57", 
    secondary = "#20B2AA",
    success = "#28a745",
    warning = "#ffc107",
    danger = "#dc3545",
    info = "#17a2b8"
  ),
  
  # Global Filters Sidebar
  sidebar = sidebar(
    title = div(icon("filter"), "Global Filters"),
    width = 280,
    
    # Date Range Filter
    dateRangeInput(
      "global_date_range", 
      "📅 Date Range:",
      start = Sys.Date() - 30, 
      end = Sys.Date(),
      format = "yyyy-mm-dd",
      separator = " to "
    ),
    
    # Site Filter
    selectInput(
      "global_site_filter", 
      "🏢 Site:",
      choices = NULL, 
      multiple = TRUE,
      selectize = TRUE
    ),
    
    # Woreda Filter
    selectInput(
      "global_woreda_filter", 
      "🗺️ Woreda:",
      choices = NULL, 
      multiple = TRUE,
      selectize = TRUE
    ),
    
    # Enumerator Filter
    selectInput(
      "global_enum_filter", 
      "👤 Enumerator:",
      choices = NULL, 
      multiple = TRUE,
      selectize = TRUE
    ),
    
    hr(),
    
    # Quick Stats
    div(
      style = "background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%); padding: 15px; border-radius: 8px; margin-top: 10px;",
      h6("📊 Quick Stats", style = "margin-bottom: 10px; color: #2E8B57; font-weight: bold;"),
      div(
        style = "display: flex; justify-content: space-between; margin-bottom: 5px;",
        span("Filtered Records:", style = "font-size: 0.9em;"),
        textOutput("filtered_count", inline = TRUE)
      ),
      div(
        style = "display: flex; justify-content: space-between;",
        span("Completion Rate:", style = "font-size: 0.9em;"),
        textOutput("filtered_completion_rate", inline = TRUE)
      )
    ),
    
    # Reset Filters Button
    div(
      style = "margin-top: 15px;",
      actionButton(
        "reset_filters", 
        "🔄 Reset Filters",
        class = "btn-outline-secondary btn-sm",
        style = "width: 100%;"
      )
    )
  ),
  
  # -- Main Content Panels --
  nav_panel(
    title = "Executive Summary",
    layout_column_wrap(
      width = 1/5,
      value_box("Total Surveys", value = textOutput("total_surveys"), showcase = icon("clipboard-list"), theme = "primary"),
      value_box("Completed", value = textOutput("completed_surveys"), showcase = icon("check-circle"), theme = "bg-success"),
      value_box("Refusal Rate", value = textOutput("refusal_rate"), showcase = icon("times-circle"), theme = "bg-danger"),
      value_box("Avg. Duration", value = textOutput("avg_duration"), showcase = icon("clock"), theme = "bg-warning"),
      value_box("Enumerators", value = textOutput("unique_enumerators"), showcase = icon("users"), theme = "secondary")
    ),
    layout_columns(
      col_widths = c(8, 4),
      card(
        full_screen = TRUE,
        card_header("📈 Daily Survey Progress"),
        plotlyOutput("daily_progress_plot", height = "400px")
      ),
      card(
        full_screen = TRUE,
        card_header("🎯 Target Achievement"),
        plotlyOutput("gauge_plot", height = "400px")
      )
    )
  ),
  
  nav_panel(
    title = "Enumerator Performance",
    layout_columns(
      col_widths = c(7, 5),
      card(
        full_screen = TRUE,
        card_header("📊 Individual Performance"),
        reactable::reactableOutput("enumerator_table")
      ),
      card(
        full_screen = TRUE,
        card_header("🎯 Target vs Actual Performance"),
        plotlyOutput("target_comparison_plot")
      )
    ),
    layout_columns(
      col_widths = c(8, 4),
      card(
        full_screen = TRUE,
        card_header("📅 Daily Productivity Heatmap"),
        plotlyOutput("productivity_heatmap")
      ),
      card(
        full_screen = TRUE,
        card_header("⚠️ Quality Alerts"),
        reactable::reactableOutput("quality_alerts_table")
      )
    )
  ),
  
  nav_panel(
    title = "Agricultural Analysis",
    layout_columns(
      col_widths = c(7, 5),
      card(
        full_screen = TRUE,
        card_header("🌱 Tree Survival Rates by Species"),
        plotlyOutput("survival_rates_plot")
      ),
      card(
        full_screen = TRUE,
        card_header("🌱 Detailed Species Performance"),
        reactable::reactableOutput("species_table")
      )
    ),
    card(
      full_screen = TRUE,
      card_header("🗺️ Geographic Performance (Surveys per Woreda)"),
      plotlyOutput("geographic_plot")
    )
  ),
  
  nav_panel(
    title = "Site Analysis",
    layout_columns(
      col_widths = c(6, 6),
      card(
        full_screen = TRUE,
        card_header("🏢 Site Performance Overview"),
        plotlyOutput("site_performance_plot", height = "400px")
      ),
      card(
        full_screen = TRUE,
        card_header("📊 Site Comparison Table"),
        reactable::reactableOutput("site_comparison_table")
      )
    ),
    layout_columns(
      col_widths = c(8, 4),
      card(
        full_screen = TRUE,
        card_header("🌱 Survival Rates by Site"),
        plotlyOutput("site_survival_plot", height = "400px")
      ),
      card(
        full_screen = TRUE,
        card_header("⏱️ Average Duration by Site"),
        plotlyOutput("site_duration_plot", height = "400px")
      )
    )
  ),
  
  nav_panel(
    title = "Data Explorer",
    card(
      card_header("🔍 Interactive Data Explorer"),
      layout_columns(
        col_widths = c(4, 4, 4),
        dateRangeInput("date_range", "Date Range:", start = Sys.Date() - 30, end = Sys.Date()),
        selectInput("site_filter", "Site:", choices = NULL, multiple = TRUE),
        selectInput("enum_filter", "Enumerator:", choices = NULL, multiple = TRUE)
      ),
      reactable::reactableOutput("explorer_table")
    )
  ),
  
  nav_panel(
    title = "Advanced Analytics",
    layout_columns(
      col_widths = c(6, 6),
      card(
        full_screen = TRUE,
        card_header("🔄 Survey Completion Funnel"),
        plotlyOutput("funnel_plot")
      ),
      card(
        full_screen = TRUE,
        card_header("📊 Survey Duration Distribution"),
        plotlyOutput("duration_plot")
      )
    ),
    card(
      full_screen = TRUE,
      card_header("📅 Weekly Performance Trends"),
      plotlyOutput("weekly_trends_plot")
    )
  )
)

# --- Server Logic ---
server <- function(input, output, session) {
  
  # --- Reactive Data ---
  raw_data <- reactiveVal(df_processed)
  
  # Base completed data (before global filters)
  df_completed_base <- reactive({
    raw_data() %>% filter(consent == 1)
  })
  
  # Global filtered data
  df_filtered <- reactive({
    data <- df_completed_base()
    
    # Apply global date filter
    if (!is.null(input$global_date_range)) {
      data <- data %>% 
        filter(date >= input$global_date_range[1] & date <= input$global_date_range[2])
    }
    
    # Apply global site filter
    if (length(input$global_site_filter) > 0) {
      data <- data %>% filter(site %in% input$global_site_filter)
    }
    
    # Apply global woreda filter
    if (length(input$global_woreda_filter) > 0) {
      data <- data %>% filter(woreda %in% input$global_woreda_filter)
    }
    
    # Apply global enumerator filter
    if (length(input$global_enum_filter) > 0) {
      data <- data %>% filter(username %in% input$global_enum_filter)
    }
    
    data
  })
  
  # For backward compatibility, use filtered data as default
  df_completed <- reactive({
    df_filtered()
  })
  
  # --- Initialize and Update Global Filters ---
  observe({
    data <- df_completed_base()
    req(nrow(data) > 0)

    min_date <- min(data$date, na.rm = TRUE)
    max_date <- max(data$date, na.rm = TRUE)

    # Update global filter choices
    if (is.finite(min_date) && is.finite(max_date)) {
      updateSelectInput(session, "global_site_filter", 
                       choices = sort(unique(data$site)), selected = NULL)
      updateSelectInput(session, "global_woreda_filter", 
                       choices = sort(unique(data$woreda)), selected = NULL)
      updateSelectInput(session, "global_enum_filter", 
                       choices = sort(unique(data$username)), selected = NULL)
      updateDateRangeInput(session, "global_date_range", 
                          start = min_date, end = max_date)
    }
    
    # Also update local filters for Data Explorer
    updateSelectInput(session, "site_filter", 
                     choices = sort(unique(data$site)), selected = NULL)
    updateSelectInput(session, "enum_filter", 
                     choices = sort(unique(data$username)), selected = NULL)
    updateDateRangeInput(session, "date_range", 
                        start = min_date, end = max_date)
  })
  
  # --- Reset Filters ---
  observeEvent(input$reset_filters, {
    data <- df_completed_base()
    min_date <- min(data$date, na.rm = TRUE)
    max_date <- max(data$date, na.rm = TRUE)
    
    updateSelectInput(session, "global_site_filter", selected = character(0))
    updateSelectInput(session, "global_woreda_filter", selected = character(0))
    updateSelectInput(session, "global_enum_filter", selected = character(0))
    updateDateRangeInput(session, "global_date_range", start = min_date, end = max_date)
  })
  
  # --- Quick Stats in Sidebar ---
  output$filtered_count <- renderText({
    format_number(nrow(df_filtered()))
  })
  
  output$filtered_completion_rate <- renderText({
    total_filtered <- nrow(raw_data())
    if (total_filtered > 0) {
      # Apply same filters to raw data for completion rate calculation
      raw_filtered <- raw_data()
      
      if (!is.null(input$global_date_range)) {
        raw_filtered <- raw_filtered %>% 
          filter(date >= input$global_date_range[1] & date <= input$global_date_range[2])
      }
      
      if (length(input$global_site_filter) > 0) {
        raw_filtered <- raw_filtered %>% filter(site %in% input$global_site_filter)
      }
      
      if (length(input$global_woreda_filter) > 0) {
        raw_filtered <- raw_filtered %>% filter(woreda %in% input$global_woreda_filter)
      }
      
      if (length(input$global_enum_filter) > 0) {
        raw_filtered <- raw_filtered %>% filter(username %in% input$global_enum_filter)
      }
      
      completed_count <- sum(raw_filtered$consent == 1, na.rm = TRUE)
      total_count <- nrow(raw_filtered)
      
      if (total_count > 0) {
        rate <- (completed_count / total_count)
        format_percent(rate)
      } else {
        "0%"
      }
    } else {
      "0%"
    }
  })
  
  # --- Executive Summary ---
  output$total_surveys <- renderText({ format_number(nrow(raw_data())) })
  output$completed_surveys <- renderText({ format_number(nrow(df_completed())) })
  output$refusal_rate <- renderText({
    rate <- sum(raw_data()$consent == 0, na.rm = TRUE) / nrow(raw_data())
    format_percent(rate)
  })
  output$avg_duration <- renderText({
    paste(round(mean(df_completed()$duration_minutes, na.rm = TRUE), 1), "min")
  })
  output$unique_enumerators <- renderText({ format_number(n_distinct(df_completed()$username)) })
  
  output$daily_progress_plot <- renderPlotly({
    daily_data <- df_completed() %>%
      group_by(date) %>%
      summarise(surveys = n(), .groups = "drop")
    
    plot_ly(daily_data, x = ~date, y = ~surveys, type = 'bar',
            marker = list(color = custom_colors$primary),
            hovertemplate = "Date: %{x}<br>Surveys: %{y}<extra></extra>") %>%
      layout(
        title = FALSE,
        xaxis = list(title = "Date"),
        yaxis = list(title = "Number of Surveys"),
        paper_bgcolor = "transparent", 
        plot_bgcolor = "transparent",
        showlegend = FALSE
      )
  })
  
  output$gauge_plot <- renderPlotly({
    target <- 3600
    current <- nrow(df_completed())
    percentage <- min(current / target, 1) * 100
    
    plot_ly(
      type = "indicator",
      mode = "gauge+number+delta",
      value = current,
      delta = list(reference = target),
      gauge = list(
        axis = list(range = list(NULL, target)),
        bar = list(color = custom_colors$primary),
        steps = list(
          list(range = c(0, target*0.5), color = "lightgray"),
          list(range = c(target*0.5, target*0.8), color = "gray")
        ),
        threshold = list(
          line = list(color = "red", width = 4),
          thickness = 0.75,
          value = target
        )
      )
    ) %>% 
    layout(
      title = FALSE, 
      paper_bgcolor = "transparent",
      font = list(color = custom_colors$dark)
    )
  })
  
  # --- Enumerator Performance ---
  enumerator_stats <- reactive({
    df_completed() %>%
      group_by(username) %>%
      summarise(
        total_surveys = n(),
        avg_duration = round(mean(duration_minutes, na.rm = TRUE), 1),
        short_surveys = sum(is_short_survey, na.rm = TRUE),
        night_surveys = sum(is_night_survey, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      arrange(desc(total_surveys))
  })
  
  output$enumerator_table <- reactable::renderReactable({
    reactable(
      enumerator_stats(),
      columns = list(
        username = colDef(name = "Enumerator", minWidth = 120),
        total_surveys = colDef(name = "Total Surveys", align = "center"),
        avg_duration = colDef(name = "Avg Duration (min)", align = "center"),
        short_surveys = colDef(name = "Short Surveys (<5min)", align = "center"),
        night_surveys = colDef(name = "Night Surveys", align = "center")
      ),
      defaultPageSize = 8, 
      searchable = TRUE, 
      highlight = TRUE, 
      bordered = TRUE, 
      striped = TRUE,
      theme = reactableTheme(
        headerStyle = list(backgroundColor = "#f8f9fa", fontWeight = "bold"),
        cellStyle = list(fontSize = "0.9em")
      )
    )
  })
  
  output$target_comparison_plot <- renderPlotly({
    target_per_enum <- 50
    p_data <- enumerator_stats()
    
    plot_ly(p_data, x = ~reorder(username, -total_surveys), y = ~total_surveys, 
            type = 'bar', name = "Actual",
            marker = list(color = custom_colors$primary),
            hovertemplate = "Enumerator: %{x}<br>Surveys: %{y}<extra></extra>") %>%
      add_trace(x = ~reorder(username, -total_surveys), y = target_per_enum, 
                type = 'scatter', mode = 'lines', name = "Target",
                line = list(color = custom_colors$danger, dash = 'dash', width = 3),
                hovertemplate = "Target: %{y}<extra></extra>") %>%
      layout(
        title = FALSE,
        xaxis = list(title = "Enumerator", tickangle = -45),
        yaxis = list(title = "Total Surveys"),
        paper_bgcolor = "transparent", 
        plot_bgcolor = "transparent",
        legend = list(orientation = 'h', y = 1.1, x = 0.5, xanchor = 'center'),
        margin = list(b = 100)
      )
  })
  
  output$productivity_heatmap <- renderPlotly({
    heatmap_data <- df_completed() %>%
      group_by(day_of_week, hour_started) %>%
      summarise(count = n(), .groups = "drop")
      
    plot_ly(
      data = heatmap_data,
      x = ~hour_started, y = ~day_of_week, z = ~count,
      type = "heatmap", 
      colorscale = list(c(0, "#f8f9fa"), c(1, custom_colors$primary)),
      hovertemplate = "Day: %{y}<br>Hour: %{x}<br>Surveys: %{z}<extra></extra>"
    ) %>% 
    layout(
      title = FALSE,
      xaxis = list(title = "Hour of Day"),
      yaxis = list(title = "Day of Week", categoryorder = "array", 
                   categoryarray = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")),
      paper_bgcolor = "transparent"
    )
  })
  
  output$quality_alerts_table <- reactable::renderReactable({
    quality_data <- enumerator_stats() %>%
      filter(short_surveys > 0 | night_surveys > 0) %>%
      select(Enumerator = username, `Short Surveys` = short_surveys, `Night Surveys` = night_surveys)
      
    reactable(
      quality_data,
      columns = list(
        `Short Surveys` = colDef(style = function(value) {
          if (value > 0) list(color = custom_colors$danger, fontWeight = "bold") else NULL
        }),
        `Night Surveys` = colDef(style = function(value) {
          if (value > 0) list(color = custom_colors$danger, fontWeight = "bold") else NULL
        })
      ),
      defaultPageSize = 5, 
      highlight = TRUE, 
      bordered = TRUE, 
      striped = TRUE,
      theme = reactableTheme(
        headerStyle = list(backgroundColor = "#f8f9fa", fontWeight = "bold")
      )
    )
  })
  
  # --- Agricultural Analysis ---
  species_data <- reactive({
    df_completed() %>%
      select(starts_with("ps_num_planted_"), starts_with("num_surv_")) %>%
      pivot_longer(everything(), names_to = "key", values_to = "value") %>%
      mutate(
        type = ifelse(str_detect(key, "ps_num_planted"), "planted", "survived"),
        species = str_remove_all(key, "ps_num_planted_|num_surv_")
      ) %>%
      group_by(species, type) %>%
      summarise(total = sum(value, na.rm = TRUE), .groups = "drop") %>%
      pivot_wider(names_from = type, values_from = total) %>%
      mutate(
        survival_rate = ifelse(planted > 0, (survived / planted) * 100, 0)
      )
  })
  
  output$survival_rates_plot <- renderPlotly({
    p_data <- species_data() %>% arrange(desc(survival_rate))
    
    plot_ly(p_data, x = ~reorder(species, survival_rate), y = ~survival_rate, 
            type = 'bar', marker = list(color = ~survival_rate, 
            colorscale = list(c(0, "#ffcdd2"), c(1, custom_colors$success))),
            hovertemplate = "Species: %{x}<br>Survival Rate: %{y:.1f}%<extra></extra>") %>%
      layout(
        title = FALSE,
        xaxis = list(title = "Species", tickangle = -45),
        yaxis = list(title = "Survival Rate (%)", range = c(0, 100)),
        paper_bgcolor = "transparent", 
        plot_bgcolor = "transparent",
        showlegend = FALSE,
        margin = list(b = 100)
      )
  })
  
  output$species_table <- reactable::renderReactable({
    display_data <- species_data() %>%
      select(Species = species, Planted = planted, Survived = survived, `Survival Rate (%)` = survival_rate) %>%
      arrange(desc(`Survival Rate (%)`))
      
    reactable(
      display_data,
      columns = list(
        `Survival Rate (%)` = colDef(
          name = "Survival Rate (%)",
          style = function(value) {
            if (is.na(value)) return(NULL)
            color <- if (value >= 80) {
              "#A5D6A7"
            } else if (value >= 60) {
              "#FFF9C4"
            } else {
              "#FFCDD2"
            }
            list(background = color)
          },
          format = list(digits = 1)
        )
      ),
      defaultPageSize = 7, 
      highlight = TRUE, 
      bordered = TRUE, 
      striped = TRUE,
      theme = reactableTheme(
        headerStyle = list(backgroundColor = "#f8f9fa", fontWeight = "bold")
      )
    )
  })
  
  output$geographic_plot <- renderPlotly({
    geo_data <- df_completed() %>%
      group_by(woreda) %>%
      summarise(count = n(), .groups = "drop")
      
    plot_ly(geo_data, x = ~reorder(woreda, -count), y = ~count, 
            type = 'bar', marker = list(color = custom_colors$secondary),
            hovertemplate = "Woreda: %{x}<br>Surveys: %{y}<extra></extra>") %>%
      layout(
        title = FALSE,
        xaxis = list(title = "Woreda", tickangle = -45),
        yaxis = list(title = "Number of Surveys"),
        paper_bgcolor = "transparent", 
        plot_bgcolor = "transparent",
        showlegend = FALSE,
        margin = list(b = 100)
      )
  })
  
  # --- Site Analysis ---
  site_stats <- reactive({
    df_completed() %>%
      group_by(site) %>%
      summarise(
        total_surveys = n(),
        avg_duration = round(mean(duration_minutes, na.rm = TRUE), 1),
        completion_rate = round((n() / nrow(df_completed())) * 100, 1),
        unique_enumerators = n_distinct(username),
        avg_hh_size = round(mean(hh_size, na.rm = TRUE), 1),
        .groups = "drop"
      ) %>%
      arrange(desc(total_surveys))
  })
  
  output$site_performance_plot <- renderPlotly({
    p_data <- site_stats()
    
    plot_ly(p_data, x = ~reorder(site, -total_surveys), y = ~total_surveys, 
            type = 'bar', marker = list(color = custom_colors$gradient[1]),
            hovertemplate = "Site: %{x}<br>Surveys: %{y}<br>Avg Duration: %{customdata} min<extra></extra>",
            customdata = ~avg_duration) %>%
      layout(
        title = FALSE,
        xaxis = list(title = "Site", tickangle = -45),
        yaxis = list(title = "Number of Surveys"),
        paper_bgcolor = "transparent", 
        plot_bgcolor = "transparent",
        showlegend = FALSE,
        margin = list(b = 100)
      )
  })
  
  output$site_comparison_table <- reactable::renderReactable({
    reactable(
      site_stats(),
      columns = list(
        site = colDef(name = "Site", minWidth = 120),
        total_surveys = colDef(name = "Total Surveys", align = "center", minWidth = 100),
        avg_duration = colDef(name = "Avg Duration (min)", align = "center"),
        completion_rate = colDef(name = "Completion Rate (%)", align = "center"),
        unique_enumerators = colDef(name = "Enumerators", align = "center"),
        avg_hh_size = colDef(name = "Avg HH Size", align = "center")
      ),
      defaultPageSize = 8, 
      searchable = TRUE, 
      highlight = TRUE, 
      bordered = TRUE, 
      striped = TRUE,
      theme = reactableTheme(
        headerStyle = list(backgroundColor = "#f8f9fa", fontWeight = "bold"),
        cellStyle = list(fontSize = "0.9em")
      )
    )
  })
  
  output$site_survival_plot <- renderPlotly({
    # Calculate survival rates by site
    site_survival <- df_completed() %>%
      select(site, starts_with("ps_num_planted_"), starts_with("num_surv_")) %>%
      group_by(site) %>%
      summarise(
        total_planted = sum(across(starts_with("ps_num_planted_")), na.rm = TRUE),
        total_survived = sum(across(starts_with("num_surv_")), na.rm = TRUE),
        .groups = "drop"
      ) %>%
      mutate(
        survival_rate = ifelse(total_planted > 0, (total_survived / total_planted) * 100, 0)
      ) %>%
      arrange(desc(survival_rate))
    
    plot_ly(site_survival, x = ~reorder(site, survival_rate), y = ~survival_rate, 
            type = 'bar', marker = list(color = ~survival_rate, 
            colorscale = list(c(0, "#ffcdd2"), c(1, custom_colors$success))),
            hovertemplate = "Site: %{x}<br>Planted: %{customdata[0]}<br>Survived: %{customdata[1]}<br>Rate: %{y:.1f}%<extra></extra>",
            customdata = ~cbind(total_planted, total_survived)) %>%
      layout(
        title = FALSE,
        xaxis = list(title = "Site", tickangle = -45),
        yaxis = list(title = "Survival Rate (%)", range = c(0, 100)),
        paper_bgcolor = "transparent", 
        plot_bgcolor = "transparent",
        showlegend = FALSE,
        margin = list(b = 100)
      )
  })
  
  output$site_duration_plot <- renderPlotly({
    duration_data <- site_stats() %>%
      arrange(desc(avg_duration))
    
    plot_ly(duration_data, x = ~reorder(site, avg_duration), y = ~avg_duration, 
            type = 'bar', marker = list(color = custom_colors$warning),
            hovertemplate = "Site: %{x}<br>Avg Duration: %{y} min<extra></extra>") %>%
      layout(
        title = FALSE,
        xaxis = list(title = "Site", tickangle = -45),
        yaxis = list(title = "Average Duration (minutes)"),
        paper_bgcolor = "transparent", 
        plot_bgcolor = "transparent",
        showlegend = FALSE,
        margin = list(b = 100)
      )
  })
  
  # --- Data Explorer ---
  filtered_data <- reactive({
    # Add guards to ensure inputs are ready before filtering
    req(input$date_range, cancelOutput = TRUE)
    req(is.Date(input$date_range[1]), is.Date(input$date_range[2]), cancelOutput = TRUE)

    df <- df_completed() %>%
      select(
        Date = date, Enumerator = username, 
        Site = site, Woreda = woreda, `Duration (min)` = duration_minutes,
        `HH Size` = hh_size, `Education` = education_level, Age = age, Sex = sex
      )
      
    # Apply filters
    df <- df %>% 
      filter(Date >= input$date_range[1] & Date <= input$date_range[2])
    
    if (length(input$site_filter) > 0) {
      df <- df %>% filter(Site %in% input$site_filter)
    }
    
    if (length(input$enum_filter) > 0) {
      df <- df %>% filter(Enumerator %in% input$enum_filter)
    }
    
    df
  })
  
  output$explorer_table <- reactable::renderReactable({
    reactable(
      filtered_data(),
      searchable = TRUE,
      striped = TRUE,
      highlight = TRUE,
      bordered = TRUE,
      defaultPageSize = 10,
      showPageSizeOptions = TRUE,
      pageSizeOptions = c(10, 25, 50),
      theme = reactableTheme(
        headerStyle = list(backgroundColor = "#f8f9fa", fontWeight = "bold"),
        cellStyle = list(fontSize = "0.9em")
      )
    )
  })
  
  # --- Advanced Analytics ---
  output$funnel_plot <- renderPlotly({
    funnel_data <- data.frame(
      stage = c("Total Attempts", "Completed", "Refused"),
      value = c(nrow(raw_data()), sum(raw_data()$consent == 1, na.rm = TRUE), sum(raw_data()$consent == 0, na.rm = TRUE))
    )
    
    plot_ly(funnel_data, type = 'funnel',
            y = ~stage, x = ~value,
            textposition = "inside", textinfo = "value+percent initial",
            marker = list(color = c(custom_colors$primary, custom_colors$success, custom_colors$danger))) %>%
      layout(
        title = FALSE, 
        paper_bgcolor = "transparent",
        font = list(color = custom_colors$dark)
      )
  })
  
  output$duration_plot <- renderPlotly({
    plot_ly(df_completed(), x = ~duration_minutes, type = 'histogram',
            marker = list(color = custom_colors$secondary),
            hovertemplate = "Duration: %{x} min<br>Count: %{y}<extra></extra>") %>%
      layout(
        title = FALSE,
        xaxis = list(title = "Duration (minutes)"),
        yaxis = list(title = "Frequency"),
        paper_bgcolor = "transparent", 
        plot_bgcolor = "transparent",
        showlegend = FALSE
      )
  })
  
  output$weekly_trends_plot <- renderPlotly({
    weekly_data <- df_completed() %>%
      group_by(week) %>%
      summarise(surveys = n(), .groups = "drop")
      
    plot_ly(weekly_data, x = ~week, y = ~surveys, type = 'scatter', mode = 'lines+markers',
            line = list(color = custom_colors$primary, width = 3), 
            marker = list(color = custom_colors$primary, size = 8),
            hovertemplate = "Week: %{x}<br>Surveys: %{y}<extra></extra>") %>%
      layout(
        title = FALSE,
        xaxis = list(title = "Week"),
        yaxis = list(title = "Number of Surveys"),
        paper_bgcolor = "transparent", 
        plot_bgcolor = "transparent",
        showlegend = FALSE
      )
  })
}

# --- Run Application ---
shinyApp(ui, server)