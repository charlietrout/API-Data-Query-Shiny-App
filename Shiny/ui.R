library(shiny)

get_player_data_advanced_by_season <- function(season) {
  base_url <- paste("http://b8c40s8.143.198.70.30.sslip.io/api/PlayerDataAdvanced/season", season, sep = "/")
  
  response <- httr::GET(url = base_url)
  stop_for_status(response)
  
  player_data <- content(response, as = "text")
  player_data <- fromJSON(player_data)
  
  return(player_data)
}

# Function to fetch player data from 1993 to 2023 to make selectInput possible for teamName
get_player_data_for_all_seasons <- function() {
  all_seasons_data <- list()
  
  # Loop through each season from 1993 to 2023
  for (season in 1993:2023) {
    season_data <- get_player_data_advanced_by_season(season)
    all_seasons_data[[as.character(season)]] <- season_data
  }
  
  # Combine all data into a single data frame or list
  combined_data <- do.call(rbind, all_seasons_data)
  
  return(combined_data)
}

# Example usage
player_data_all_seasons <- get_player_data_for_all_seasons()







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
                   selectInput("teamName", "Team Name", choices = sort(unique(player_data_all_seasons$team))),  # Replace with actual teams data
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
