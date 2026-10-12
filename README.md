# Survival Analysis

A course project in mathematical statistics examining survival times in treatment and placebo groups using a supplied simulated dataset. The analysis combines Kaplan-Meier estimation, a log-rank test, power calculations based on an estimated hazard ratio, and a Wilcoxon rank-sum test to examine age differences between the groups.

## Report

[Project report (PDF, German)](report.pdf)

The report explains the methods and their assumptions, provides intuitive derivations, and discusses the results of the analysis in R.

## Files

- `stat_prakt_ag_r_skript.R`: the R analysis script.
- `simulierte_daten_a20.xlsx`: the supplied dataset, containing 30 observations and the variables `Zeit`, `status`, `Gruppe` and `Alter`.
- `SurvivalAnalysis.Rproj`: the RStudio project file.

The dataset contains right-censored observations: `status` distinguishes deaths from observations censored while alive. The time unit is not documented in the supplied data.

## Running the analysis

Run the script from the repository root. It reads the included workbook and saves four plots and a descriptive CSV table in `Abbildungen und Tabellen/`. Those generated files are not committed.

Install R, then restore the package versions and run the analysis from the repository root:

```sh
Rscript -e 'renv::restore()'
Rscript stat_prakt_ag_r_skript.R
```

Alternatively, open `SurvivalAnalysis.Rproj` in RStudio, run `renv::restore()` in the console and execute the script.

The script has been checked with **R 4.6.1**. The package versions are recorded in `renv.lock`; installed packages are not committed. The console displays the Kaplan-Meier estimates, log-rank test, power calculations and Wilcoxon test. Plotting may print informational messages about the default dotplot bin width.

## Maintenance note

This repository was prepared in 2026 with assistance from generative AI for documentation and dependency setup. The report, dataset and analysis code are retained from the project materials.
