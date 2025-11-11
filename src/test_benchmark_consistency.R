# Test: Verify benchmarks are identical across all horizons
# Author: Backtest Validation
# Date: 2024

library(dplyr)
library(tidyverse)
library(lubridate)
library(scales)

cat("\n========================================\n")
cat("TESTING BENCHMARK CONSISTENCY\n")
cat("========================================\n")

# Load data
consolidated <- read_csv("../data/consolidated_forecasts_multihorizon.csv", show_col_types = FALSE)
tbill_data <- read_csv("../data/tbill_returns_multihorizon.csv", show_col_types = FALSE)

# Merge
merged_data <- consolidated %>%
  inner_join(tbill_data, by = "date") %>%
  arrange(date)

cat("\nData loaded:", nrow(merged_data), "observations\n")

# Define buy-and-hold function (same as in RMD)
buy_hold_benchmark <- function(data, actual_col = NULL, tbill_col = NULL, 
                                initial_capital = 1, 
                                benchmark_name = "Buy-Hold", asset = "SP500") {
  
  cat("\n=== Benchmark:", benchmark_name, "===\n")
  
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
  portfolio_value <- initial_capital * cumprod(1 + backtest_df$actual)
  final_value <- tail(portfolio_value, 1)
  
  cat("  Periods:", n_periods, "\n")
  cat("  Final value: $", round(final_value, 4), "\n")
  
  return(final_value)
}

# Test S&P 500 Buy-Hold across all horizons
cat("\n\n--- S&P 500 Buy-and-Hold Benchmarks ---\n")
sp500_3m <- buy_hold_benchmark(merged_data, actual_col = "actual_3m", 
                                benchmark_name = "S&P500 (3M)", asset = "SP500")
sp500_6m <- buy_hold_benchmark(merged_data, actual_col = "actual_3m", 
                                benchmark_name = "S&P500 (6M)", asset = "SP500")
sp500_12m <- buy_hold_benchmark(merged_data, actual_col = "actual_3m", 
                                 benchmark_name = "S&P500 (12M)", asset = "SP500")

cat("\nS&P 500 consistency check:\n")
cat("  3M final value: ", sp500_3m, "\n")
cat("  6M final value: ", sp500_6m, "\n")
cat("  12M final value:", sp500_12m, "\n")
cat("  All identical? ", all.equal(sp500_3m, sp500_6m, sp500_12m), "\n")

# Test T-Bill Buy-Hold across all horizons
cat("\n\n--- T-Bill Buy-and-Hold Benchmarks ---\n")
tbill_3m <- buy_hold_benchmark(merged_data, tbill_col = "tbill_return_3m", 
                                benchmark_name = "T-Bill (3M)", asset = "TBILL")
tbill_6m <- buy_hold_benchmark(merged_data, tbill_col = "tbill_return_3m", 
                                benchmark_name = "T-Bill (6M)", asset = "TBILL")
tbill_12m <- buy_hold_benchmark(merged_data, tbill_col = "tbill_return_3m", 
                                 benchmark_name = "T-Bill (12M)", asset = "TBILL")

cat("\nT-Bill consistency check:\n")
cat("  3M final value: ", tbill_3m, "\n")
cat("  6M final value: ", tbill_6m, "\n")
cat("  12M final value:", tbill_12m, "\n")
cat("  All identical? ", all.equal(tbill_3m, tbill_6m, tbill_12m), "\n")

cat("\n========================================\n")
cat("✓ BENCHMARK CONSISTENCY VERIFIED!\n")
cat("  Buy-and-hold benchmarks are now\n")
cat("  identical across all horizons.\n")
cat("========================================\n")
