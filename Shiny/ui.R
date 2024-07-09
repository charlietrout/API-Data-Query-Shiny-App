library(shiny)

fluidPage(
  
  navbarPage(
    "NBA Player Data App",
    
    tabPanel("About",
             fluidPage(
               titlePanel("About This App"),
               tags$img(src = "your_logo_image_url", height = 150, width = 150), # Example image
               h3("Purpose of the App"),
               p("This app allows users to query NBA player data using an API and explore it through various visualizations and data summaries."),
               h3("Data Source"),
               p("The data is sourced from the NBA API. For more information, visit the NBA official website."),
               h3("Tabs"),
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
                   numericInput("season", "Season", value = 2023, min = 2000, max = 2025),
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
                   selectInput("xVar", "X-axis Variable", choices = colnames(player_data_by_team)),
                   selectInput("yVar", "Y-axis Variable", choices = colnames(player_data_by_team), selected = NULL, multiple = TRUE),
                   selectInput("plotType", "Plot Type", choices = c("bar", "scatter")),
                   selectInput("facetVar", "Facet By", choices = colnames(player_data_by_team), selected = NULL)
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

