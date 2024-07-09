library(httr)
library(jsonlite)

get_player_data_advanced_query <- function(playerName, season, team) {
  base_url <- "http://b8c40s8.143.198.70.30.sslip.io/api/PlayerDataAdvanced/query"
  
  query_params <- list(
    playerName = playerName,
    season = season,
    team = team
  )
  
  # Construct the query URL with parameters
  query_url <- modify_url(base_url, query = query_params)
  
  # Make the GET request
  response <- httr::GET(url = query_url)
  stop_for_status(response)
  
  # Parse the JSON content
  player_data <- content(response, as = "text")
  player_data <- fromJSON(player_data)
  
  return(player_data)
}



# Get player data using the defined function
player_data_query <- get_player_data_advanced_query("Lebron James", "2022", "LAL")
print(player_data_query)




get_player_data_advanced_by_name <- function(player_name) {
  base_url <- paste0("http://b8c40s8.143.198.70.30.sslip.io/api/PlayerDataAdvanced/name/", URLencode(player_name))
  
  response <- httr::GET(url = base_url)
  stop_for_status(response)
  
  player_data <- content(response, as = "text")
  player_data <- fromJSON(player_data)
  
  return(player_data)
}

# Example usage:
player_data_by_name <- get_player_data_advanced_by_name("LeBron James")
print(player_data_by_name)



get_player_data_advanced_by_season <- function(season) {
  base_url <- paste("http://b8c40s8.143.198.70.30.sslip.io/api/PlayerDataAdvanced/season", season, sep = "/")
  
  response <- httr::GET(url = base_url)
  stop_for_status(response)
  
  player_data <- content(response, as = "text")
  player_data <- fromJSON(player_data)
  
  return(player_data)
}

# Example usage:
player_data_by_season <- get_player_data_advanced_by_season()
print(player_data_by_season)



get_player_data_advanced_by_team <- function(team_name) {
  base_url <- paste0("http://b8c40s8.143.198.70.30.sslip.io/api/PlayerDataAdvanced/team/", URLencode(team_name))
  
  response <- httr::GET(url = base_url)
  stop_for_status(response)
  
  player_data <- content(response, as = "text")
  player_data <- fromJSON(player_data)
  
  return(player_data)
}

# Example usage:
player_data_by_team <- get_player_data_advanced_by_team("LAL")
print(player_data_by_team)







#Advanced Stats During Playoff Functions
get_player_data_advancedplayoff_query <- function(query_params) {
  base_url <- "http://b8c40s8.143.198.70.30.sslip.io/api/PlayerDataAdvancedPlayoffs/query"
  
  # Construct the query URL with parameters
  query_url <- modify_url(base_url, query = query_params)
  
  # Make the GET request
  response <- httr::GET(url = query_url)
  stop_for_status(response)
  
  # Parse the JSON content
  player_data <- content(response, as = "text")
  player_data <- fromJSON(player_data)
  
  return(player_data)
}

# Example usage:
# Define query parameters
query_params <- list(
  playerName = "LeBron James",
  sortBy = "PlayerName",
  ascending = TRUE,
  pageNumber = 1,
  pageSize = 30
)

# Get player data using query parameters
playoff_player_data_query <- get_player_data_advancedplayoff_query(query_params)
print(playoff_player_data_query)




get_player_data_advancedplayoff_by_name <- function(player_name) {
  base_url <- paste0("http://b8c40s8.143.198.70.30.sslip.io/api/PlayerDataAdvancedPlayoffs/name/", URLencode(player_name))
  
  response <- httr::GET(url = base_url)
  stop_for_status(response)
  
  player_data <- content(response, as = "text")
  player_data <- fromJSON(player_data)
  
  return(player_data)
}

# Example usage:
playoff_player_data_by_name <- get_player_data_advancedplayoff_by_name("LeBron James")
print(playoff_player_data_by_name)



get_player_data_advancedplayoff_by_season <- function(season) {
  base_url <- paste("http://b8c40s8.143.198.70.30.sslip.io/api/PlayerDataAdvancedPlayoffs/season", season, sep = "/")
  
  response <- httr::GET(url = base_url)
  stop_for_status(response)
  
  player_data <- content(response, as = "text")
  player_data <- fromJSON(player_data)
  
  return(player_data)
}

# Example usage:
playoff_player_data_by_season <- get_player_data_advancedplayoff_by_season("2023")
print(playoff_player_data_by_season)



get_player_data_advancedplayoff_by_team <- function(team_name) {
  base_url <- paste0("http://b8c40s8.143.198.70.30.sslip.io/api/PlayerDataAdvancedPlayoffs/team/", URLencode(team_name))
  
  response <- httr::GET(url = base_url)
  stop_for_status(response)
  
  player_data <- content(response, as = "text")
  player_data <- fromJSON(player_data)
  
  return(player_data)
}


# Function to fetch player data from 1993 to 2023
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




# Example usage:
playoff_player_data_by_team <- get_player_data_advancedplayoff_by_team("LAL")
print(playoff_player_data_by_team)

contingency_table <- table(player_data_by_team$position, player_data_by_team$team)
print(contingency_table)



