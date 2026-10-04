# student-performance-dashboard
Interactive student performance dashboard built in R (Shiny, shinydashboard, plotly). Filter by gender, parental education, lunch and test preparation to explore math, reading and writing scores, pass rate and group comparisons.
# Student Performance Dashboard (R Shiny)

Interactive dashboard to explore student exam performance.

## Problem
How do factors like gender, parental education, lunch type and test
preparation relate to math, reading and writing scores?

## Data
Students Performance in Exams (Kaggle), 1,000 records. This is a practice
dataset and not real university records.

## What I built
- 4 tabs: Overview, Group Comparison, Score Explorer, Student Data
- Filters in the sidebar that update every chart, box and table
- Value boxes: students, average scores, pass rate, highest average
- Interactive plotly charts, a correlation matrix and a searchable table
- Download button for the filtered data as CSV
- Pass mark can be changed (my assumption: average of 40 or more)

## Tools
R, Shiny, shinydashboard, plotly, DT, dplyr, tidyr

## How to run
1. Install packages:
   install.packages(c("shiny", "shinydashboard", "dplyr", "tidyr", "plotly", "DT"))
2. Keep app.R and StudentsPerformance.csv in the same folder
3. Run shiny::runApp()

## What I found
1. ___
2. ___
3. ___

Project done by Kayalvizhi Thiyagarajan
BCA (Artificial Intelligence and Data Science)
Dr. M.G.R. Educational and Research Institute
