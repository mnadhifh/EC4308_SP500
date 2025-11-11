# Test Strategy Backtest - Validate T-Bill Logic
# This script specifically tests the corrected buy-and-hold T-bill logic

library(dplyr)
library(tidyverse)
library(lubridate)
library(scales)

cat("\n========================================\n")
cat("TESTING CORRECTED T-BILL LOGIC\n")
cat("========================================\n\n")

# Load data
forecast_data <- read_csv("../data/consolidated_forecasts_multihorizon.csv", show_col_types = FALSE)
tbill_data <- read_csv("../data/tbill_returns_multihorizon.csv", show_col_types = FALSE)

backtest_data <- forecast_data %>%
  inner_join(tbill_data, by = "date") %>%
  arrange(date) %>%
  drop_na()

cat("Data loaded:", nrow(backtest_data), "observations\n")
cat("Date range:", min(backtest_data$date), "to", max(backtest_data$date), "\n\n")

# Define corrected buy-hold function
buy_hold_benchmark <- function(data, actual_col = NULL, tbill_col = NULL, 
                                initial_capital = 1, 
                                benchmark_name = "Buy-Hold", asset = "SP500") {
  
  # For T-bills, use tbill_col; for S&P500, use actual_col
  if (asset == "TBILL") {
    if (is.null(tbill_col)) stop("tbill_col must be provided for T-bill benchmark")
    backtest_df <- data %>%
      select(date, actual = all_of(tbill_col)) %>%
      arrange(date) %>%
      drop_na()
  } else {
    if (is.null(actual_col)) stop("actual_col must be provided for S&P500 benchmark")
    backtest_df <- data %>%
      select(date, actual = all_of(actual_col)) %>%
      arrange(date) %>%
      drop_na()
  }
  
  n_periods <- nrow(backtest_df)
  
  # Compound returns over time (CORRECTED)
  portfolio_value <- c(initial_capital, initial_capital * cumprod(1 + backtest_df$actual))
  
  results_df <- data.frame(
    date = c(backtest_df$date[1], backtest_df$date),
    portfolio_value = portfolio_value,
    position = asset
  )
  
  total_return <- (portfolio_value[n_periods + 1] / portfolio_value[1]) - 1
  
  metrics <- list(
    strategy_name = benchmark_name,
    total_return = total_return,
    final_value = portfolio_value[n_periods + 1],
    n_periods = n_periods
  )
  
  return(list(results = results_df, metrics = metrics))
}

# Test S&P 500
cat("Testing Buy-Hold S&P500 (3M):\n")
bh_sp500 <- buy_hold_benchmark(
  data = backtest_data,
  actual_col = "actual_3m",
  benchmark_name = "Buy-Hold S&P500 (3M)",
  asset = "SP500"
)
cat("  Periods:", bh_sp500$metrics$n_periods, "\n")
cat("  Final value: $", round(bh_sp500$metrics$final_value, 4), "\n")
cat("  Total return:", percent(bh_sp500$metrics$total_return, accuracy = 0.01), "\n\n")

# Test T-Bill (CORRECTED)
cat("Testing Buy-Hold T-Bill (3M) - CORRECTED:\n")
bh_tbill <- buy_hold_benchmark(
  data = backtest_data,
  tbill_col = "tbill_return_3m",
  benchmark_name = "Buy-Hold T-Bill (3M)",
  asset = "TBILL"
)
cat("  Periods:", bh_tbill$metrics$n_periods, "\n")
cat("  Final value: $", round(bh_tbill$metrics$final_value, 4), "\n")
cat("  Total return:", percent(bh_tbill$metrics$total_return, accuracy = 0.01), "\n\n")

# Manual verification
cat("Manual verification of T-Bill compounding:\n")
tbill_returns <- backtest_data %>% 
  select(date, tbill_return_3m) %>% 
  arrange(date)

cat("  First 5 T-bill returns:\n")
print(head(tbill_returns, 5))

manual_final <- 1
for (i in 1:nrow(tbill_returns)) {
  manual_final <- manual_final * (1 + tbill_returns$tbill_return_3m[i])
}
cat("\n  Manual calculation final value: $", round(manual_final, 4), "\n")
cat("  Function result final value:    $", round(bh_tbill$metrics$final_value, 4), "\n")
cat("  Match:", abs(manual_final - bh_tbill$metrics$final_value) < 0.0001, "\n\n")

# Show trajectory
cat("T-Bill portfolio growth (first 10 periods):\n")
print(head(bh_tbill$results, 10))

cat("\n========================================\n")
cat("✓ T-BILL LOGIC CORRECTED!\n")
cat("  T-bills now correctly compound returns\n")
cat("  over the entire test period.\n")
cat("========================================\n")
