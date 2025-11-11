# Multi-Horizon Tactical Asset Allocation Backtest

## 📋 Overview

Created a comprehensive R Markdown file that implements **tactical asset allocation strategies** across three rebalancing horizons using your ML forecasts.

## 📁 File Created

`src/strategy_backtest_multihorizon.Rmd`

---

## 🎯 Strategy Logic

### Decision Rule (Simple and Clear):

At each rebalancing date:
- **IF** ML Forecast ≥ T-Bill Rate → **Invest 100% in S&P 500**
- **IF** ML Forecast < T-Bill Rate → **Invest 100% in T-Bills**

### Three Rebalancing Horizons:

1. **Quarterly (3-Month)**: Rebalance every quarter using 3M forecasts
2. **Semi-Annual (6-Month)**: Rebalance every 6 months using 6M forecasts  
3. **Annual (12-Month)**: Rebalance every 12 months using 12M forecasts

---

## 🔬 Models Tested

For each horizon, tests **5 ML models**:
- Random Forest (RF)
- Lasso Regression
- Ridge Regression
- Principal Component Regression (PCR)
- Elastic Net

**Total Strategies: 15** (5 models × 3 horizons)

---

## 📊 Benchmarks

For each horizon, compares against:

1. **Buy-and-Hold S&P 500**: Passive equity exposure (our target to beat)
2. **Buy-and-Hold T-Bills**: Risk-free baseline (minimum acceptable performance)
3. **Perfect Foresight (Oracle)**: Uses actual returns as "forecasts" - theoretical maximum performance

**Expected Ranking:** T-Bill < [ML Models] ≤ Buy-Hold S&P500 < Perfect Foresight

---

## 📈 Performance Metrics

### Returns:
- Total Return
- Annualized Return
- Final Portfolio Value

### Risk Metrics:
- Annualized Volatility
- Maximum Drawdown
- Sharpe Ratio (risk-adjusted return)

### Trading Metrics:
- Win Rate (% of periods with positive excess returns)
- Turnover (% of periods with position switches)
- Number of Switches
- % Time in S&P 500

---

## 📑 Report Structure

The RMD file generates a comprehensive HTML report with:

### 1. Data Loading & Preparation
- Loads consolidated forecasts
- Loads T-Bill returns
- Merges datasets

### 2. Backtesting Functions
- `tactical_backtest()`: Main strategy function
- `buy_hold_benchmark()`: Passive benchmarks
- `perfect_foresight_benchmark()`: Oracle benchmark

### 3. Strategy Execution
- Section 3: Quarterly (3M) strategies
- Section 4: Semi-Annual (6M) strategies
- Section 5: Annual (12M) strategies

### 4. Performance Analysis
- Performance tables for each horizon
- Side-by-side comparisons

### 5. Visualizations
- Portfolio value evolution (log scale)
- Asset allocation over time
- Risk-return scatter plots
- Comparative charts across horizons

### 6. Key Findings
- Summary statistics by horizon
- Best performers by metric
- Insights and conclusions

### 7. Export Results
- CSV files for further analysis
- Performance tables
- Portfolio trajectories

---

## 🚀 How to Run

### Option 1: Knit the RMD (Recommended)
```r
# In RStudio
# Open: src/strategy_backtest_multihorizon.Rmd
# Click "Knit" button
```

### Option 2: Run Chunks Interactively
```r
# In RStudio
# Open the RMD file
# Run chunks one by one with Ctrl+Shift+Enter (Cmd+Shift+Enter on Mac)
```

### Option 3: Command Line
```bash
cd "/Users/fytian/Desktop/nus school years/year4/ec4308/EC4308_SP500/src"
Rscript -e "rmarkdown::render('strategy_backtest_multihorizon.Rmd')"
```

---

## 📤 Output Files

After running, creates in `output/` directory:

1. **Performance Tables:**
   - `performance_3m_quarterly.csv`
   - `performance_6m_semiannual.csv`
   - `performance_12m_annual.csv`

2. **Combined Metrics:**
   - `all_metrics_combined.csv` (all strategies, all horizons)

3. **Portfolio Values:**
   - `portfolio_values_3m.csv`
   - `portfolio_values_6m.csv`
   - `portfolio_values_12m.csv`

4. **HTML Report:**
   - `strategy_backtest_multihorizon.html` (interactive report)

---

## 🎨 Key Features

### ✅ Comprehensive Coverage
- All 5 ML models
- All 3 horizons
- All benchmarks

### ✅ Professional Visualization
- Log-scale portfolio charts
- Asset allocation timelines
- Risk-return scatter plots
- Multi-horizon comparisons

### ✅ Detailed Metrics
- 10+ performance metrics per strategy
- Risk-adjusted measures (Sharpe)
- Trading behavior (turnover, switches)
- Downside protection (max drawdown)

### ✅ Export-Ready Results
- CSV files for Excel/Python analysis
- HTML report for presentations
- Publication-quality tables

---

## 📝 Key Assumptions

1. **Starting Capital:** $1.00
2. **Transaction Costs:** 0% (baseline scenario)
3. **Position Size:** 100% allocation (no partial positions)
4. **Test Period:** 2011-Q4 to 2024-Q3 (matching your data)
5. **Rebalancing:** Aligned with forecast horizon

---

## 🔍 What to Look For

### Good Strategy Performance:
✅ Sharpe Ratio > Buy-Hold S&P 500  
✅ Maximum Drawdown < Buy-Hold S&P 500  
✅ Win Rate > 50%  
✅ Reasonable turnover (not too high)

### Red Flags:
❌ Total Return < T-Bills (failed to add value)  
❌ Sharpe Ratio < 0 (negative risk-adjusted returns)  
❌ Very high turnover with low returns (churning)  
❌ Max Drawdown > -50% (excessive risk)

---

## 🎯 Expected Insights

### Horizon Effects:
- **Quarterly (3M)**: More responsive, higher turnover
- **Semi-Annual (6M)**: Balanced approach
- **Annual (12M)**: Smoother, lower turnover

### Model Comparison:
- Which models generate actionable forecasts?
- Do complex models (RF) beat simple ones (Lasso)?
- Is there a clear winner?

### Economic Value:
- Do forecasts translate to better risk-adjusted returns?
- How much value does tactical allocation add?
- Gap to perfect foresight = room for improvement

---

## 🚦 Next Steps

After reviewing results:

1. **Sensitivity Analysis**: Add transaction costs (0.1%, 0.5%, 1%)
2. **Enhanced Strategies**: Test 60/40 allocations, stop-losses
3. **Ensemble Methods**: Combine multiple model signals
4. **Regime Analysis**: Performance in bull vs bear markets
5. **Statistical Tests**: Bootstrap confidence intervals

---

**You're all set! Run the RMD file to generate your comprehensive backtest report! 🎉**
