library(httr)
library(jsonlite)

get_player_data_advanced_query <- function(query_params) {
  base_url <- "http://b8c40s8.143.198.70.30.sslip.io/api/PlayerDataAdvanced/query"
  
  response <- httr::GET(url = base_url, query = query_params)
  stop_for_status(response)
  
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
  pageSize = 10
)

# Get player data using query parameters
player_data_query <- get_player_data_advanced_query(query_params)
print(player_data_query)




get_player_data_advanced_by_name <- function(player_name) {
  base_url <- paste("http://b8c40s8.143.198.70.30.sslip.io/api/PlayerDataAdvanced/name", player_name, sep = "/")
  
  response <- httr::GET(url = base_url)
  stop_for_status(response)
  
  player_data <- content(response, as = "text")
  player_data <- fromJSON(player_data)
  
  return(player_data)
}

# Example usage:
player_data_by_name <- get_player_data_advanced_by_name("LeBron James")
print(player_data_by_name)

get_player_data_advanced_by_name <- function(player_name) {
  base_url <- paste("http://b8c40s8.143.198.70.30.sslip.io/api/PlayerDataAdvanced/name", player_name, sep = "/")
  
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
player_data_by_season <- get_player_data_advanced_by_season("2023")
print(player_data_by_season)



get_player_data_advanced_by_player_id <- function(player_id) {
  base_url <- paste("http://b8c40s8.143.198.70.30.sslip.io/api/PlayerDataAdvanced/playerid", player_id, sep = "/")
  
  response <- httr::GET(url = base_url)
  stop_for_status(response)
  
  player_data <- content(response, as = "text")
  player_data <- fromJSON(player_data)
  
  return(player_data)
}

# Example usage:
player_data_by_id <- get_player_data_advanced_by_player_id("12345")
print(player_data_by_id)



get_player_data_advanced_by_team <- function(team_name) {
  base_url <- paste("http://b8c40s8.143.198.70.30.sslip.io/api/PlayerDataAdvanced/team", team_name, sep = "/")
  
  response <- httr::GET(url = base_url)
  stop_for_status(response)
  
  player_data <- content(response, as = "text")
  player_data <- fromJSON(player_data)
  
  return(player_data)
}

# Example usage:
player_data_by_team <- get_player_data_advanced_by_team("Los Angeles Lakers")
print(player_data_by_team)



get_player_data_advanced_count <- function() {
  base_url <- "http://b8c40s8.143.198.70.30.sslip.io/api/PlayerDataAdvanced/count"
  
  response <- httr::GET(url = base_url)
  stop_for_status(response)
  
  player_count <- content(response, as = "text")
  player_count <- fromJSON(player_count)
  
  return(player_count)
}

# Example usage:
player_count <- get_player_data_advanced_count()
print(player_count)
