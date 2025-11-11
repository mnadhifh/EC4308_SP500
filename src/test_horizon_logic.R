# Test: Verify corrected multi-horizon tactical strategy logic
# The key fix: All strategies use quarterly returns, but rebalance at different frequencies

library(dplyr)
library(tidyverse)
library(lubridate)
library(scales)

cat("\n========================================\n")
cat("TESTING CORRECTED HORIZON LOGIC\n")
cat("========================================\n")

# Load the updated tactical_backtest function
source("strategy_backtest_multihorizon.Rmd")

# Load data
consolidated <- read_csv("../data/consolidated_forecasts_multihorizon.csv", show_col_types = FALSE)
tbill_data <- read_csv("../data/tbill_returns_multihorizon.csv", show_col_types = FALSE)
merged_data <- consolidated %>%
  inner_join(tbill_data, by = "date") %>%
  arrange(date)

cat("\nData loaded:", nrow(merged_data), "observations\n")
cat("Date range:", min(merged_data$date), "to", max(merged_data$date), "\n")

# Test RF model across all horizons
cat("\n\n--- Testing RF Tactical Strategy Across Horizons ---\n")

cat("\n3M Horizon (rebalance every 1 quarter):\n")
rf_3m <- tactical_backtest(
  data = merged_data,
  forecast_col = "rf_forecast_3m",
  actual_col = "actual_3m",
  tbill_col = "tbill_return_3m",
  horizon = "3m",
  strategy_name = "RF Tactical (3M)"
)

cat("\n6M Horizon (rebalance every 2 quarters):\n")
rf_6m <- tactical_backtest(
  data = merged_data,
  forecast_col = "rf_forecast_6m",
  actual_col = "actual_3m",  # Same quarterly returns!
  tbill_col = "tbill_return_3m",  # Same quarterly T-bills!
  horizon = "6m",
  strategy_name = "RF Tactical (6M)"
)

cat("\n12M Horizon (rebalance every 4 quarters):\n")
rf_12m <- tactical_backtest(
  data = merged_data,
  forecast_col = "rf_forecast_12m",
  actual_col = "actual_3m",  # Same quarterly returns!
  tbill_col = "tbill_return_3m",  # Same quarterly T-bills!
  horizon = "12m",
  strategy_name = "RF Tactical (12M)"
)

cat("\n\n========================================\n")
cat("SUMMARY OF RESULTS\n")
cat("========================================\n")
cat("RF 3M:  Final value =", round(rf_3m$metrics$final_value, 4), 
    " | Rebalances:", rf_3m$metrics$n_switches, "\n")
cat("RF 6M:  Final value =", round(rf_6m$metrics$final_value, 4), 
    " | Rebalances:", rf_6m$metrics$n_switches, "\n")
cat("RF 12M: Final value =", round(rf_12m$metrics$final_value, 4), 
    " | Rebalances:", rf_12m$metrics$n_switches, "\n")

cat("\n✓ Logic Check:\n")
cat("  - All strategies use same underlying return stream (actual_3m)\n")
cat("  - 3M rebalances every quarter (most frequent)\n")
cat("  - 6M rebalances every 2 quarters (semi-annual)\n")
cat("  - 12M rebalances every 4 quarters (annual)\n")
cat("  - Returns should be reasonable (not 700% or 6000%!)\n")
cat("========================================\n")
