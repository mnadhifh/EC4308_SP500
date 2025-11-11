# ============================================================================
# Extract T-Bill Rates for Backtesting (Multi-Horizon)
# ============================================================================
# This script extracts T-Bill rates for 3-month, 6-month, and 12-month horizons
# aligned with the test period and converts them to holding period returns
# ============================================================================

library(dplyr)
library(tidyverse)
library(readxl)
library(lubridate)
library(readr)

cat("\n=== EXTRACTING T-BILL RATES (MULTI-HORIZON) ===\n\n")

# Set test period start date (matching consolidated forecasts)
TEST_START_DATE <- as.Date("2011-10-01")

# ============================================================================
# 1. Load 3-Month T-Bill (TB3MS) - Quarterly Data
# ============================================================================
cat("1. Loading 3-Month T-Bill (TB3MS) - Quarterly...\n")
tbill_3m_raw <- read_xlsx("../data/TB3MS.xlsx", sheet = 2) %>%
  rename(date = observation_date) %>%
  mutate(date = as.Date(date)) %>%
  filter(date >= TEST_START_DATE) %>%
  arrange(date)

# TB3MS is annualized bank-discount yield (%)
# Convert to 3-month holding period return
tbill_3m <- tbill_3m_raw %>%
  mutate(
    discount_rate = TB3MS / 100,
    # Bank discount formula: Price = 1 - (discount_rate * days/360)
    # For 3-month T-bill: days = 90
    price = 1 - discount_rate * (90/360),
    # Holding period return = (Face Value - Price) / Price
    tbill_return_3m = (1 / price) - 1
  ) %>%
  select(date, TB3MS, tbill_return_3m)

cat("   ✓ 3M T-Bill loaded:", nrow(tbill_3m), "quarterly observations\n")
cat("   Date range:", min(tbill_3m$date), "to", max(tbill_3m$date), "\n")
cat("   Average quarterly return:", round(mean(tbill_3m$tbill_return_3m) * 100, 4), "%\n\n")

# ============================================================================
# 2. Load 6-Month T-Bill (DGS6MO) - Daily → Convert to Quarterly
# ============================================================================
cat("2. Loading 6-Month T-Bill (DGS6MO) - Daily data...\n")
tbill_6m_daily <- read_csv("../data/DGS6MO.csv") %>%
  rename(date = observation_date, rate = DGS6MO) %>%
  mutate(date = as.Date(date)) %>%
  filter(!is.na(rate), date >= TEST_START_DATE) %>%
  arrange(date)

# Convert daily 6M T-Bill yields to quarterly observations
# Take the last observation of each quarter
tbill_6m <- tbill_6m_daily %>%
  mutate(
    year = year(date),
    quarter = quarter(date)
  ) %>%
  group_by(year, quarter) %>%
  slice_max(date, n = 1) %>%
  ungroup() %>%
  mutate(
    # DGS6MO is annualized yield (%)
    # For 6-month holding period: divide by 2 as instructed
    tbill_return_6m = (rate / 100) / 2,
    # Standardize to quarterly dates (first day of quarter)
    date = floor_date(date, "quarter")
  ) %>%
  select(date, DGS6MO = rate, tbill_return_6m)

cat("   ✓ 6M T-Bill loaded:", nrow(tbill_6m), "quarterly observations\n")
cat("   Date range:", min(tbill_6m$date), "to", max(tbill_6m$date), "\n")
cat("   Average 6-month return:", round(mean(tbill_6m$tbill_return_6m) * 100, 4), "%\n\n")

# ============================================================================
# 3. Load 1-Year T-Bill (DGS1) - Daily → Convert to Quarterly
# ============================================================================
cat("3. Loading 1-Year T-Bill (DGS1) - Daily data...\n")
tbill_1y_daily <- read_csv("../data/DGS1.csv") %>%
  rename(date = observation_date, rate = DGS1) %>%
  mutate(date = as.Date(date)) %>%
  filter(!is.na(rate), date >= TEST_START_DATE) %>%
  arrange(date)

# Convert daily 1Y T-Bill yields to quarterly observations
tbill_1y <- tbill_1y_daily %>%
  mutate(
    year = year(date),
    quarter = quarter(date)
  ) %>%
  group_by(year, quarter) %>%
  slice_max(date, n = 1) %>%
  ungroup() %>%
  mutate(
    # DGS1 is annualized yield (%)
    # Use as-is for 1-year holding period return
    tbill_return_12m = rate / 100,
    # Standardize to quarterly dates
    date = floor_date(date, "quarter")
  ) %>%
  select(date, DGS1 = rate, tbill_return_12m)

cat("   ✓ 1Y T-Bill loaded:", nrow(tbill_1y), "quarterly observations\n")
cat("   Date range:", min(tbill_1y$date), "to", max(tbill_1y$date), "\n")
cat("   Average 12-month return:", round(mean(tbill_1y$tbill_return_12m) * 100, 4), "%\n\n")

# ============================================================================
# 4. Combine All T-Bill Data
# ============================================================================
cat("=== COMBINING T-BILL DATA ===\n")
tbill_combined <- tbill_3m %>%
  full_join(tbill_6m, by = "date") %>%
  full_join(tbill_1y, by = "date") %>%
  arrange(date) %>%
  # Keep only rows where ALL three horizons have data
  filter(!is.na(tbill_return_3m) & !is.na(tbill_return_6m) & !is.na(tbill_return_12m))

cat("✓ T-Bill data combined successfully!\n")
cat("  Observations:", nrow(tbill_combined), "quarters\n")
cat("  Date range:", min(tbill_combined$date), "to", max(tbill_combined$date), "\n\n")

# ============================================================================
# 5. Summary Statistics
# ============================================================================
cat("=== SUMMARY STATISTICS ===\n\n")

cat("3-Month T-Bill Returns:\n")
cat("  Mean:", round(mean(tbill_combined$tbill_return_3m) * 100, 4), "%\n")
cat("  Median:", round(median(tbill_combined$tbill_return_3m) * 100, 4), "%\n")
cat("  Min:", round(min(tbill_combined$tbill_return_3m) * 100, 4), "%\n")
cat("  Max:", round(max(tbill_combined$tbill_return_3m) * 100, 4), "%\n\n")

cat("6-Month T-Bill Returns:\n")
cat("  Mean:", round(mean(tbill_combined$tbill_return_6m) * 100, 4), "%\n")
cat("  Median:", round(median(tbill_combined$tbill_return_6m) * 100, 4), "%\n")
cat("  Min:", round(min(tbill_combined$tbill_return_6m) * 100, 4), "%\n")
cat("  Max:", round(max(tbill_combined$tbill_return_6m) * 100, 4), "%\n\n")

cat("12-Month T-Bill Returns:\n")
cat("  Mean:", round(mean(tbill_combined$tbill_return_12m) * 100, 4), "%\n")
cat("  Median:", round(median(tbill_combined$tbill_return_12m) * 100, 4), "%\n")
cat("  Min:", round(min(tbill_combined$tbill_return_12m) * 100, 4), "%\n")
cat("  Max:", round(max(tbill_combined$tbill_return_12m) * 100, 4), "%\n\n")

# Show first few rows
cat("First 10 rows:\n")
print(head(tbill_combined, 10))

# Show last few rows
cat("\n\nLast 10 rows:\n")
print(tail(tbill_combined, 10))

# Full summary
cat("\n\nDetailed summary:\n")
print(summary(tbill_combined))

# ============================================================================
# 6. Export to CSV
# ============================================================================
output_file <- "../data/tbill_returns_multihorizon.csv"

# Create clean output with just the returns
tbill_output <- tbill_combined %>%
  select(date, tbill_return_3m, tbill_return_6m, tbill_return_12m)

write_csv(tbill_output, output_file)

cat("\n\n=== SUCCESS! ===\n")
cat("T-Bill returns saved to:", output_file, "\n")
cat("Total observations:", nrow(tbill_output), "\n")
cat("Columns: date, tbill_return_3m, tbill_return_6m, tbill_return_12m\n\n")

cat("Ready to merge with consolidated forecasts for backtesting!\n")
