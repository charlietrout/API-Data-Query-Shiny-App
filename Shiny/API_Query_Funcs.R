library(httr)
library(jsonlite)

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

adv_reg_season_stats <- get_player_data_advanced_by_season("2023")

contingency_table <- table(adv_reg_season_stats$position, adv_reg_season_stats$team)
print(contingency_table)

# Example numerical summary by position
library(dplyr)

numerical_summary <- adv_reg_season_stats |>
  group_by(position) |>
  summarize(
    avg_offensiveWS = mean(offensiveWS),
    avg_defensiveWS = mean(defensiveWS),
    avg_winShares = mean(winShares)
  )
numerical_summary

plot1 <- ggplot(adv_reg_season_stats, aes(x = team, y = minutesPlayed, fill = team)) +
  geom_bar(stat = "summary", fun = "mean") +
  labs(title = "Average Minutes Played by Team", x = "Team", y = "Average Minutes Played") +
  theme_minimal()
plot1
plot2 <- ggplot(adv_reg_season_stats, aes(x = usagePercent, y = winShares, color = position)) +
  geom_point() +
  labs(title = "Usage Percent vs Win Shares", x = "Usage Percent", y = "Win Shares") +
  theme_minimal()
plot2
plot3 <- ggplot(adv_reg_season_stats, aes(x = position, y = offensiveWS, fill = position)) +
  geom_boxplot() +
  labs(title = "Offensive Win Shares by Position", x = "Position", y = "Offensive Win Shares") +
  theme_minimal()
plot3
plot4 <- ggplot(adv_reg_season_stats, aes(x = team, y = position, fill = totalRBPercent)) +
  geom_tile() +
  labs(title = "Total Rebound Percent by Position and Team", x = "Team", y = "Position", fill = "Total Rebound Percent") +
  theme_minimal()
plot4