# ============================================================
# Student Performance Dashboard
# Dr. M.G.R. Educational and Research Institute
# Project by: Kayalvizhi Thiyagarajan | BCA (AI & Data Science)
#
# Folder:
#   student_dashboard/
#     app.R                    <- this file
#     StudentsPerformance.csv  <- Kaggle: "Students Performance in Exams"
#     www/logo.png             <- optional university logo
#
# Install packages ONCE in the Console (not in this file):
#   install.packages(c("shiny", "shinydashboard", "dplyr", "tidyr", "plotly", "DT"))
#
# Run: click "Run App" at the top of this file
# ============================================================

library(shiny)
library(shinydashboard)
library(dplyr)
library(tidyr)
library(plotly)
library(DT)

# ---------- Colours (change here to re-theme everything) ----------
mgr_red  <- "#D71920"
mgr_navy <- "#1F2A80"
mgr_gold <- "#F0B323"
mgr_bg   <- "#F6F4EE"
subject_cols <- c(Math = mgr_red, Reading = mgr_navy, Writing = mgr_gold)
group_cols   <- rep(c(mgr_red, mgr_navy, mgr_gold, "#6B7280", "#0F766E", "#9D174D"),
                    length.out = 12)

# ---------- Load and clean data ----------
cols <- c("gender", "race", "parent_edu", "lunch", "test_prep",
          "math", "reading", "writing")

real <- NULL
if (file.exists("StudentsPerformance.csv")) {
  real <- tryCatch(
    read.csv("StudentsPerformance.csv", check.names = FALSE, stringsAsFactors = FALSE),
    error = function(e) NULL
  )
}

if (!is.null(real) && nrow(real) > 0 && ncol(real) == 8) {
  df <- real
  names(df) <- cols
  using_demo <- FALSE
} else {
  # Demo data (same columns as the Kaggle file) so the app still opens
  using_demo <- TRUE
  set.seed(42)
  n <- 1000
  df <- data.frame(
    gender     = sample(c("female", "male"), n, TRUE),
    race       = sample(paste("group", LETTERS[1:5]), n, TRUE),
    parent_edu = sample(c("some high school", "high school", "some college",
                          "associate's degree", "bachelor's degree",
                          "master's degree"), n, TRUE),
    lunch      = sample(c("standard", "free/reduced"), n, TRUE, prob = c(.65, .35)),
    test_prep  = sample(c("none", "completed"), n, TRUE, prob = c(.64, .36)),
    stringsAsFactors = FALSE
  )
  base <- 62 + ifelse(df$lunch == "standard", 8, 0) +
    ifelse(df$test_prep == "completed", 6, 0) + rnorm(n, 0, 11)
  clip <- function(x) pmin(100, pmax(0, round(x)))
  df$math    <- clip(base + ifelse(df$gender == "male", 3, -3) + rnorm(n, 0, 6))
  df$reading <- clip(base + ifelse(df$gender == "female", 4, -4) + rnorm(n, 0, 6))
  df$writing <- clip(base + ifelse(df$gender == "female", 5, -5) + rnorm(n, 0, 6))
}

edu_levels <- c("some high school", "high school", "some college",
                "associate's degree", "bachelor's degree", "master's degree")

df <- df %>%
  mutate(
    race       = tools::toTitleCase(race),
    gender     = tools::toTitleCase(gender),
    lunch      = tools::toTitleCase(lunch),
    test_prep  = tools::toTitleCase(test_prep),
    parent_edu = factor(parent_edu, levels = edu_levels),
    average    = round((math + reading + writing) / 3, 1)
  )

group_choices <- c("Gender" = "gender",
                   "Race / Ethnicity" = "race",
                   "Parental Education" = "parent_edu",
                   "Lunch Type" = "lunch",
                   "Test Preparation" = "test_prep")
score_choices <- c("Math" = "math", "Reading" = "reading",
                   "Writing" = "writing", "Average" = "average")

has_logo <- file.exists("www/logo.png")

# ---------- CSS ----------
css <- paste0("
.skin-blue .main-header .logo,
.skin-blue .main-header .logo:hover { background-color:", mgr_navy, "; color:#fff; font-weight:700; }
.skin-blue .main-header .navbar { background-color:", mgr_navy, "; border-bottom:4px solid ", mgr_gold, "; }
.skin-blue .main-sidebar { background-color:", mgr_navy, "; }
.skin-blue .sidebar a { color:#fff; }
.skin-blue .sidebar-menu > li.active > a,
.skin-blue .sidebar-menu > li:hover > a {
  background:", mgr_gold, "; color:", mgr_navy, "; border-left-color:", mgr_red, "; font-weight:700; }
.skin-blue .sidebar-menu > li > a { border-left:3px solid transparent; }
.sidebar .form-group label, .sidebar .control-label { color:#fff; font-weight:600; }
.sidebar .checkbox label { color:#fff; font-weight:400; }
.main-sidebar { overflow-y:auto; }
.content-wrapper, .right-side { background-color:", mgr_bg, "; }
.box { border-top:3px solid ", mgr_red, "; border-radius:6px; }
.box-header .box-title { font-weight:700; color:", mgr_navy, "; }
.bg-red    { background-color:", mgr_red, " !important; }
.bg-navy   { background-color:", mgr_navy, " !important; }
.bg-yellow { background-color:", mgr_gold, " !important; color:", mgr_navy, " !important; }
.bg-yellow .small-box-footer, .bg-yellow .icon { color:", mgr_navy, " !important; }
.banner { background:#fff; border-bottom:4px solid ", mgr_gold, "; padding:8px 20px;
          display:flex; align-items:center; justify-content:space-between; }
.banner img { height:70px; }
.banner h2 { margin:0; color:", mgr_navy, "; font-weight:800; }
.banner h2 span { color:", mgr_red, "; }
.credit { color:", mgr_navy, "; font-size:13px; margin-top:4px; line-height:1.4; }
.credit strong { color:", mgr_red, "; }
.btn-mgr { background:", mgr_red, "; color:#fff; border:none; }
.btn-mgr:hover { background:", mgr_navy, "; color:#fff; }
.app-footer { background:", mgr_navy, "; color:#fff; text-align:center; padding:10px;
              margin-top:20px; border-top:4px solid ", mgr_gold, "; font-size:13px; }
.app-footer strong { color:", mgr_gold, "; }
")

# ---------- UI ----------
ui <- dashboardPage(
  title = "Student Performance Dashboard",

  dashboardHeader(title = "Student Analytics", titleWidth = 260),

  dashboardSidebar(
    width = 260,
    if (has_logo)
      div(style = "background:#fff; padding:8px; margin:10px; border-radius:6px;",
          img(src = "logo.png", style = "width:100%;")),
    sidebarMenu(
      id = "tabs",
      menuItem("Overview",         tabName = "overview", icon = icon("gauge")),
      menuItem("Group Comparison", tabName = "compare",  icon = icon("chart-column")),
      menuItem("Score Explorer",   tabName = "explorer", icon = icon("chart-line")),
      menuItem("Student Data",     tabName = "data",     icon = icon("table"))
    ),
    hr(),
    h4("  Filters", style = paste0("color:", mgr_gold, "; font-weight:700;")),
    checkboxGroupInput("f_gender", "Gender",
                       choices = sort(unique(df$gender)),
                       selected = unique(df$gender)),
    checkboxGroupInput("f_race", "Race / Ethnicity",
                       choices = sort(unique(df$race)),
                       selected = unique(df$race)),
    checkboxGroupInput("f_edu", "Parental Education",
                       choices = edu_levels,
                       selected = edu_levels),
    checkboxGroupInput("f_lunch", "Lunch",
                       choices = sort(unique(df$lunch)),
                       selected = unique(df$lunch)),
    checkboxGroupInput("f_prep", "Test Preparation",
                       choices = sort(unique(df$test_prep)),
                       selected = unique(df$test_prep)),
    numericInput("pass_mark", "Pass mark (average)", value = 40, min = 0, max = 100)
  ),

  dashboardBody(
    tags$head(tags$style(HTML(css))),

    div(class = "banner",
        if (has_logo) img(src = "logo.png") else div(),
        div(style = "text-align:right;",
            h2("Student Performance ", span("Dashboard")),
            div(class = "credit",
                "Project by ", strong("Kayalvizhi Thiyagarajan"),
                " | BCA - Artificial Intelligence & Data Science",
                br(),
                "Dr. M.G.R. Educational and Research Institute"))),

    if (using_demo)
      div(style = paste0("background:", mgr_gold, "; color:", mgr_navy,
                         "; padding:8px 20px; font-weight:600;"),
          "Demo data in use: StudentsPerformance.csv was not found. ",
          "Put the real CSV next to app.R and run the app again."),
    br(),

    tabItems(
      # ---------------- Overview ----------------
      tabItem("overview",
        fluidRow(
          valueBoxOutput("vb_n", 3),
          valueBoxOutput("vb_math", 3),
          valueBoxOutput("vb_read", 3),
          valueBoxOutput("vb_write", 3)
        ),
        fluidRow(
          valueBoxOutput("vb_avg", 4),
          valueBoxOutput("vb_pass", 4),
          valueBoxOutput("vb_top", 4)
        ),
        fluidRow(
          box(title = "Score Distribution", width = 8,
              plotlyOutput("p_hist", height = 360)),
          box(title = "Top 10 Students (Average)", width = 4,
              tableOutput("t_top"))
        ),
        fluidRow(
          box(title = "Average Score by Subject", width = 6,
              plotlyOutput("p_subject", height = 300)),
          box(title = "Pass vs Fail", width = 6,
              plotlyOutput("p_pass", height = 300))
        )
      ),

      # ---------------- Group comparison ----------------
      tabItem("compare",
        fluidRow(
          box(width = 12,
            fluidRow(
              column(4, selectInput("cmp_group", "Compare by",
                                    group_choices, selected = "test_prep")),
              column(4, selectInput("cmp_score", "Score for boxplot",
                                    score_choices, selected = "average"))
            ))
        ),
        fluidRow(
          box(title = "Mean Scores by Group", width = 6,
              plotlyOutput("p_group_bar", height = 380)),
          box(title = "Score Spread by Group", width = 6,
              plotlyOutput("p_group_box", height = 380))
        ),
        fluidRow(
          box(title = "Group Summary Table", width = 12, DTOutput("t_group"))
        )
      ),

      # ---------------- Score explorer ----------------
      tabItem("explorer",
        fluidRow(
          box(width = 12,
            fluidRow(
              column(3, selectInput("sx", "X axis", score_choices, "math")),
              column(3, selectInput("sy", "Y axis", score_choices, "reading")),
              column(3, selectInput("scol", "Colour by", group_choices, "gender")),
              column(3, checkboxInput("strend", "Show trend line", TRUE))
            ))
        ),
        fluidRow(
          box(title = "Score Relationship", width = 8,
              plotlyOutput("p_scatter", height = 420)),
          box(title = "Correlation Matrix", width = 4,
              plotlyOutput("p_corr", height = 420))
        )
      ),

      # ---------------- Data ----------------
      tabItem("data",
        fluidRow(
          box(title = "Student Records (filtered)", width = 12,
              downloadButton("dl", "Download CSV", class = "btn-mgr"),
              br(), br(),
              DTOutput("t_data"))
        )
      )
    ),

    div(class = "app-footer",
        "Developed by ", strong("Kayalvizhi Thiyagarajan"),
        " | BCA (Artificial Intelligence & Data Science) | ",
        "Dr. M.G.R. Educational and Research Institute")
  )
)

# ---------- Server ----------
server <- function(input, output, session) {

  filtered <- reactive({
    df %>%
      filter(gender %in% input$f_gender,
             race %in% input$f_race,
             parent_edu %in% input$f_edu,
             lunch %in% input$f_lunch,
             test_prep %in% input$f_prep)
  })

  need_data <- function(d) {
    validate(need(nrow(d) > 0, "No students match the current filters."))
  }

  # ----- value boxes -----
  output$vb_n <- renderValueBox(
    valueBox(nrow(filtered()), "Students", icon = icon("users"), color = "navy"))

  output$vb_math <- renderValueBox({
    d <- filtered(); need_data(d)
    valueBox(round(mean(d$math), 1), "Avg Math", icon = icon("calculator"), color = "red")
  })

  output$vb_read <- renderValueBox({
    d <- filtered(); need_data(d)
    valueBox(round(mean(d$reading), 1), "Avg Reading", icon = icon("book-open"), color = "navy")
  })

  output$vb_write <- renderValueBox({
    d <- filtered(); need_data(d)
    valueBox(round(mean(d$writing), 1), "Avg Writing", icon = icon("pen"), color = "yellow")
  })

  output$vb_avg <- renderValueBox({
    d <- filtered(); need_data(d)
    valueBox(round(mean(d$average), 1), "Overall Average", icon = icon("chart-simple"), color = "red")
  })

  output$vb_pass <- renderValueBox({
    d <- filtered(); need_data(d)
    rate <- round(100 * mean(d$average >= input$pass_mark), 1)
    valueBox(paste0(rate, "%"), "Pass Rate", icon = icon("circle-check"), color = "navy")
  })

  output$vb_top <- renderValueBox({
    d <- filtered(); need_data(d)
    valueBox(max(d$average), "Highest Average", icon = icon("trophy"), color = "yellow")
  })

  # ----- Overview -----
  output$p_hist <- renderPlotly({
    d <- filtered(); need_data(d)
    plot_ly(alpha = 0.65) %>%
      add_histogram(x = d$math, name = "Math", marker = list(color = mgr_red)) %>%
      add_histogram(x = d$reading, name = "Reading", marker = list(color = mgr_navy)) %>%
      add_histogram(x = d$writing, name = "Writing", marker = list(color = mgr_gold)) %>%
      layout(barmode = "overlay",
             xaxis = list(title = "Score"),
             yaxis = list(title = "Students"))
  })

  output$t_top <- renderTable({
    d <- filtered(); need_data(d)
    d %>%
      arrange(desc(average)) %>%
      head(10) %>%
      transmute(Gender = gender, Group = race,
                Math = math, Read = reading, Write = writing, Avg = average)
  }, striped = TRUE, spacing = "xs")

  output$p_subject <- renderPlotly({
    d <- filtered(); need_data(d)
    plot_ly(x = c("Math", "Reading", "Writing"),
            y = round(c(mean(d$math), mean(d$reading), mean(d$writing)), 1),
            type = "bar",
            marker = list(color = c(mgr_red, mgr_navy, mgr_gold))) %>%
      layout(yaxis = list(title = "Mean score", range = c(0, 100)),
             xaxis = list(title = ""))
  })

  output$p_pass <- renderPlotly({
    d <- filtered(); need_data(d)
    r <- d %>%
      mutate(Result = ifelse(average >= input$pass_mark, "Pass", "Fail")) %>%
      count(Result)
    plot_ly(r, labels = ~Result, values = ~n, type = "pie", hole = 0.5,
            marker = list(colors = ifelse(r$Result == "Pass", mgr_navy, mgr_red)))
  })

  # ----- Group comparison -----
  output$p_group_bar <- renderPlotly({
    d <- filtered(); need_data(d)
    g <- input$cmp_group
    long <- d %>%
      group_by(Group = as.character(.data[[g]])) %>%
      summarise(Math = mean(math), Reading = mean(reading),
                Writing = mean(writing), .groups = "drop") %>%
      pivot_longer(-Group, names_to = "Subject", values_to = "Mean")
    plot_ly(long, x = ~Group, y = ~round(Mean, 1), color = ~Subject,
            colors = unname(subject_cols), type = "bar") %>%
      layout(barmode = "group",
             xaxis = list(title = names(group_choices)[group_choices == g]),
             yaxis = list(title = "Mean score"))
  })

  output$p_group_box <- renderPlotly({
    d <- filtered(); need_data(d)
    g <- input$cmp_group
    s <- input$cmp_score
    d$grp <- as.character(d[[g]])
    d$val <- d[[s]]
    plot_ly(d, x = ~grp, y = ~val, color = ~grp, colors = group_cols,
            type = "box") %>%
      layout(showlegend = FALSE,
             xaxis = list(title = names(group_choices)[group_choices == g]),
             yaxis = list(title = names(score_choices)[score_choices == s]))
  })

  output$t_group <- renderDT({
    d <- filtered(); need_data(d)
    g <- input$cmp_group
    d %>%
      group_by(Group = as.character(.data[[g]])) %>%
      summarise(Students = n(),
                Math = round(mean(math), 1),
                Reading = round(mean(reading), 1),
                Writing = round(mean(writing), 1),
                Average = round(mean(average), 1),
                `Pass %` = round(100 * mean(average >= input$pass_mark), 1),
                .groups = "drop") %>%
      datatable(rownames = FALSE, options = list(dom = "t", pageLength = 20))
  })

  # ----- Score explorer -----
  output$p_scatter <- renderPlotly({
    d <- filtered(); need_data(d)
    validate(need(nrow(d) > 2, "Not enough students match the filters."))
    xx <- d[[input$sx]]
    yy <- d[[input$sy]]
    d$grp <- as.character(d[[input$scol]])

    p <- plot_ly(d, x = xx, y = yy, color = ~grp, colors = group_cols,
                 type = "scatter", mode = "markers",
                 marker = list(size = 7, opacity = 0.7)) %>%
      layout(xaxis = list(title = names(score_choices)[score_choices == input$sx]),
             yaxis = list(title = names(score_choices)[score_choices == input$sy]))

    if (isTRUE(input$strend) && length(unique(xx)) > 1) {
      fit <- lm(yy ~ xx)
      ord <- order(xx)
      p <- p %>%
        add_lines(x = xx[ord], y = fitted(fit)[ord], name = "Trend",
                  inherit = FALSE, line = list(color = "black", width = 2))
    }
    p
  })

  output$p_corr <- renderPlotly({
    d <- filtered(); need_data(d)
    validate(need(nrow(d) > 2, "Not enough students match the filters."))
    m <- round(cor(d[, c("math", "reading", "writing")]), 2)
    plot_ly(x = colnames(m), y = rownames(m), z = m, type = "heatmap",
            colorscale = list(c(0, "#FFFFFF"), c(1, mgr_red)),
            zmin = 0, zmax = 1)
  })

  # ----- Data table -----
  output$t_data <- renderDT({
    datatable(filtered(), rownames = FALSE, filter = "top",
              options = list(pageLength = 10, scrollX = TRUE))
  })

  output$dl <- downloadHandler(
    filename = function() paste0("students_filtered_", Sys.Date(), ".csv"),
    content  = function(file) write.csv(filtered(), file, row.names = FALSE)
  )
}

shinyApp(ui, server)
