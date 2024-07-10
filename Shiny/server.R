library(shiny)
library(httr)
library(jsonlite)
library(ggplot2)
library(DT)  # For interactive tables

# Function to fetch player data for regular season
get_player_data_advanced_by_season <- function(season) {
  base_url <- paste("http://b8c40s8.143.198.70.30.sslip.io/api/PlayerDataAdvanced/season", season, sep = "/")
  
  response <- httr::GET(url = base_url)
  stop_for_status(response)
  
  player_data <- content(response, as = "text")
  player_data <- fromJSON(player_data)
  
  return(player_data)
}

# Function to fetch player data for playoffs
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
    season <- input$season
    season_type <- ifelse(input$seasonType == "Regular Season", "regular", "playoffs")
    team <- input$teamName
    player <- input$playerName
    
    # Call appropriate API function based on user selection
    if (season_type == "regular") {
      player_data_raw <- get_player_data_advanced_by_season(season)
    } else {
      player_data_raw <- get_player_data_advancedplayoff_by_season(season)
    }
    
    # Filter data based on selected team name and player name
    if (!is.null(team) && team != "") {
      player_data_filtered <- player_data_raw[player_data_raw$team == team, ]
    } else {
      player_data_filtered <- player_data_raw
    }
    
    if (!is.null(player) && player != "") {
      player_data_filtered <- player_data_filtered[grep(player, player_data_filtered$playerName, ignore.case = TRUE), ]
    }
    
    player_data(player_data_filtered)
    
    # Update choices for columns_selected based on the structure of player_data_filtered
    updateCheckboxGroupInput(session, "columns_selected", choices = colnames(player_data_filtered))
    
    # Update choices for selectInput elements in Data Exploration tab
    updateSelectInput(session, "xVar", choices = colnames(player_data_filtered))
    updateSelectInput(session, "yVar", choices = colnames(player_data_filtered))
    updateSelectInput(session, "facetVar", choices = c("Position", "Season", "Team", "Player Name"), selected = "Position")
  })
  
  # Render query results table
  output$queryTable <- renderDT({
    req(player_data())  # Require player_data to be available
    
    datatable(player_data(), options = list(
      lengthMenu = c(10, 20, 30, 50, 100, 250, 500, 1000), 
      pageLength = 10,
      dom = 'Blfrtip',  # Adding buttons for subset and download
      buttons = list(
        list(
          extend = 'collection',
          text = 'Subset',
          action = DT::JS("function ( e, dt, node, config ) {
                           var rows = dt.rows('.selected').indexes();
                           Shiny.setInputValue('subset_rows', rows.toArray());
                         }")
        ),
        'csv'
      )
    ))
  })
  
  # Subset data based on user input
  observeEvent(input$subsetBtn, {
    req(player_data())  # Require player_data to be available
    
    subset_data <- player_data()
    
    # Filter data based on input variables
    if (!is.null(input$teamName) && input$teamName != "") {
      subset_data <- subset_data[subset_data$team == input$teamName, ]
    }
    
    if (!is.null(input$playerName) && input$playerName != "") {
      subset_data <- subset_data[grep(input$playerName, subset_data$playerName, ignore.case = TRUE), ]
    }
    
    # Subset columns based on user selection
    if (!is.null(input$columns_selected) && length(input$columns_selected) > 0) {
      subset_data <- subset_data[, input$columns_selected, drop = FALSE]
    }
    
    output$subsetTable <- renderDT({
      datatable(subset_data, options = list(
        lengthMenu = c(10, 20, 30, 50, 100, 250, 500, 1000),
        pageLength = 10
      ))
    })
  })
  
  # Download subsetted data as CSV
  output$downloadData <- downloadHandler(
    filename = function() { paste("subset_data", ".csv", sep = "") },
    content = function(file) {
      subset_data <- isolate({
        req(player_data())  # Ensure player_data() is available
        player_data_sub <- player_data()
        
        # Filter data based on input variables
        if (!is.null(input$teamName) && input$teamName != "") {
          player_data_sub <- player_data_sub[player_data_sub$team == input$teamName, ]
        }
        
        if (!is.null(input$playerName) && input$playerName != "") {
          player_data_sub <- player_data_sub[grep(input$playerName, player_data_sub$playerName, ignore.case = TRUE), ]
        }
        
        # Subset columns based on user selection
        if (!is.null(input$columns_selected) && length(input$columns_selected) > 0) {
          player_data_sub <- player_data_sub[, input$columns_selected, drop = FALSE]
        }
        
        # Subset rows based on selected rows (from table selection)
        if (!is.null(input$subset_rows) && length(input$subset_rows) > 0) {
          player_data_sub <- player_data_sub[input$subset_rows, , drop = FALSE]
        }
        
        player_data_sub
      })
      
      write.csv(subset_data, file, row.names = FALSE)
    }
  )
  
  # Dynamic UI for additional plot options based on plot type
  output$plotOptions <- renderUI({
    if (input$plotType == "Bar Plot") {
      selectInput("barFill", "Bar Fill Color", choices = c("Automatic" = "auto", "Manual" = "manual"))
    } else if (input$plotType == "Scatter Plot") {
      selectInput("pointShape", "Point Shape", choices = c("Circle" = 1, "Square" = 2, "Triangle" = 3))
    } else {
      NULL  # For other plot types, no additional options are needed
    }
  })
  
  # Plotting based on user input
  observeEvent(input$plotBtn, {
    req(input$xVar, input$yVar, input$plotType)
    
    if (input$plotType == "Bar Plot") {
      output$dataPlot <- renderPlot({
        ggplot(player_data(), aes(x = input$xVar, fill = input$barFill)) +
          geom_bar() +
          facet_wrap(~input$facetVar) +
          labs(x = input$xVar, y = "Count", title = "Bar Plot") +
          theme_minimal()
      })
    } else if (input$plotType == "Scatter Plot") {
      output$dataPlot <- renderPlot({
        ggplot(player_data(), aes(x = input$xVar, y = input$yVar)) +
          geom_point(shape = input$pointShape) +
          facet_wrap(~input$facetVar) +
          labs(x = input$xVar, y = input$yVar, title = "Scatter Plot") +
          theme_minimal()
      })
    } else if (input$plotType == "Contingency Table") {
      output$dataPlot <- renderPlot({
        table_data <- table(player_data()[, c(input$xVar, input$yVar)])
        heatmap(table_data, Rowv = NA, Colv = NA, scale = "column", margins = c(5, 10))
      })
    } else if (input$plotType == "Heatmap") {
      output$dataPlot <- renderPlot({
        ggplot(player_data(), aes(x = input$xVar, y = input$yVar)) +
          geom_tile(aes(fill = ..count..), colour = "white") +
          labs(x = input$xVar, y = input$yVar, fill = "Frequency", title = "Heatmap") +
          theme_minimal()
      })
    } else if (input$plotType == "Summary (Mean & SD)") {
      output$dataPlot <- renderPlot({
        summary_data <- player_data() %>%
          summarise_if(is.numeric, list(mean = mean, sd = sd))
        ggplot(summary_data, aes(x = variable, y = value, fill = stat)) +
          geom_bar(stat = "identity", position = "dodge") +
          labs(x = "Variable", y = "Value", fill = "Statistic", title = "Summary: Mean & SD") +
          theme_minimal()
      })
    }
  })
  
})
