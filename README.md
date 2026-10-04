# student-performance-dashboard
https://01a10631-cd47-fc35-cd98-816ea471c4e3.share.connect.posit.cloud/
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
1. Students who completed the test preparation course scored higher in all
   three subjects (math, reading and writing) than students who did not.
2. Students with a standard lunch scored higher on average than students
   with a free/reduced lunch.
3. Students whose parents have a higher education level (bachelor's or
   master's degree) tend to score higher than students whose parents
   finished only high school.
4. Female students scored higher in reading and writing, while male
   students scored slightly higher in math.
5. Reading and writing scores are very strongly related (correlation above
   0.9), and math is also strongly related to both (above 0.8).

These are patterns in this dataset and do not prove cause and effect. For
example, lunch type may reflect family income, not lunch itself.

Project done by Kayalvizhi Thiyagarajan
BCA (Artificial Intelligence and Data Science)
Dr. M.G.R. Educational and Research Institute
