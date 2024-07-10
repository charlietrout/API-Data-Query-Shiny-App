library(shiny)

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
                   selectInput("facetVar", "Facet By", choices = NULL, selected = NULL)
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

library(shiny)
library(httr)
library(jsonlite)
library(ggplot2)
library(DT) # For interactive tables

get_player_data_advanced_by_season <- function(season) {
  base_url <- paste("http://b8c40s8.143.198.70.30.sslip.io/api/PlayerDataAdvanced/season", season, sep = "/")
  
  response <- httr::GET(url = base_url)
  stop_for_status(response)
  
  player_data <- content(response, as = "text")
  player_data <- fromJSON(player_data)
  
  return(player_data)
}

get_player_data_advancedplayoff_by_season <- function(season) {
  base_url <- paste("http://b8c40s8.143.198.70.30.sslip.io/api/PlayerDataAdvancedPlayoffs/season", season, sep = "/")
  
  response <- httr::GET(url = base_url)
  stop_for_status(response)
  
  player_data <- content(response, as = "text")
  player_data <- fromJSON(player_data)
  
  return(player_data)
}

# Define server function
shinyServer(function(input, output, session) {
  
  # Reactive value to store queried data
  player_data <- reactiveVal(NULL)  # Initialize as NULL
  
  observeEvent(input$getDataBtn, {
    season_type <- ifelse(input$seasonType == "Regular Season", "regular", "playoffs")
    
    # Call your appropriate API function based on user selection
    if (season_type == "regular") {
      player_data(get_player_data_advanced_by_season(season))
    }  else {
      player_data(get_player_data_advancedplayoff_by_season(season))
    }
  }
  )
  
  
  
  # Render query results table
  output$queryTable <- renderDT({
    req(player_data())  # Require player_data to be available
    
    datatable(player_data(), options = list(lengthMenu = c(10, 20, 30, 50, 100, 250, 500, 1000), pageLength = 10))
  })
  
  # Subset data based on user input
  observeEvent(input$subsetBtn, {
    subset_data <- player_data()  # Example: You can subset based on input variables
    output$subsetTable <- renderDT({
      datatable(subset_data, options = list(lengthMenu = c(10, 20, 30, 50, 100, 250, 500, 1000), pageLength = 10))
    })
  })
  
  # Download subsetted data as CSV
  output$downloadData <- downloadHandler(
    filename = function() { paste("subset_data", ".csv", sep = "") },
    content = function(file) {
      write.csv(player_data(), file, row.names = FALSE)
    }
  )
  
  # Plotting based on user input
  output$dataPlot <- renderPlot({
    req(input$xVar, input$plotType)
    
    ggplot(player_data_all_seasons, aes_string(x = input$xVar, y = input$yVar)) +
      geom_bar(stat = input$plotType) +
      facet_wrap(~input$facetVar) +
      labs(x = input$xVar, y = "Count", title = "Player Data Visualization") +
      theme_minimal()
  })
  
  
})
