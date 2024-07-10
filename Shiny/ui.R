library(shiny)
library(ggplot2)
library(DT)  # For interactive tables

fluidPage(
  
  navbarPage(
    "NBA Player Data App",
    
    tabPanel("About",
             fluidPage(
               titlePanel("About This App"),
               tags$img(src = "https://th.bing.com/th/id/OIP.5ppoEtwAU3rCBLDkflB_AQAAAA?rs=1&pid=ImgDetMain", height = 200, width = 100), # Example image
               h3("Purpose"),
               p("This app allows users to query advanced NBA stats during the regular season and playoffs for the years 1993-2023 using an API and explore the data through various visualizations and data summaries."),
               h3("Data Source"),
               p("The data used in this application is sourced from the NBA Stats API v1.1, which provides comprehensive statistics and player information for the NBA. For more detailed information, please refer to the ",
                 a("NBA Stats API Documentation", href = "http://b8c40s8.143.198.70.30.sslip.io/index.html", target = "_blank"),
                 "."),
               h3("Tab Info"),
               p("1. Data Download: Query and download NBA player data from the API."),
               p("2. Data Exploration: Visualize and summarize NBA player data using different plots and summaries.")
             )
    ),
    
    tabPanel("Data Download",
             fluidPage(
               titlePanel("Data Download"),
               sidebarLayout(
                 sidebarPanel(
                   h3("API Query Parameters"),
                   textInput("playerName", "Player Name"),
                   selectInput("season", "Season", choices = 1993:2023, selected = 2023),
                   radioButtons("seasonType", "Season Type", choices = c("Regular Season", "Playoffs"), selected = "Regular Season"),
                   textInput("teamName", "Team Name", placeholder = "Enter team name"),  # Use textInput for teamName
                   checkboxGroupInput("columns_selected", "Select Columns to Display", choices = NULL),  
                   actionButton("getDataBtn", "Get Data")
                 ),
                 mainPanel(
                   h3("Query Results"),
                   DTOutput("queryTable"),
                   br(),
                   h3("Subset Data"),
                   actionButton("subsetBtn", "Subset Data"),
                   DTOutput("subsetTable"),
                   br(),
                   downloadButton("downloadData", "Download Subset Data")
                 )
               )
             )
    ),
    
    tabPanel("Data Exploration",
         fluidPage(
           titlePanel("Data Exploration"),
           sidebarLayout(
             sidebarPanel(
               h3("Select Variables"),
               selectInput("xVar", "X-axis Variable", choices = NULL),
               selectInput("yVar", "Y-axis Variable", choices = NULL, selected = NULL, multiple = TRUE),
               selectInput("plotType", "Plot Type", choices = c("bar", "scatter")),
               selectInput("facetVar", "Facet By", choices = NULL, selected = NULL),
               uiOutput("plotOptions"),  # Dynamic UI for additional plot options
               actionButton("plotBtn", "Generate Plot")  # Button to generate plot
             ),
             mainPanel(
               h3("Plot"),
               plotOutput("dataPlot")
             )
           )
         )
)
)
)
