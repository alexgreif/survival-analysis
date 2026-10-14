# Survival Analysis

A course project in mathematical statistics covering the theory and practice of survival analysis. I estimated survival curves for treatment and placebo groups using the Kaplan-Meier method, compared the groups with a log-rank test, and examined age distributions using a Wilcoxon rank-sum test to investigate potential confounding. I also calculated statistical power and required event counts based on an estimated hazard ratio. The accompanying report explains the methods’ assumptions and provides intuitive derivations of the Kaplan-Meier estimator and the test statistics, including their distributions under the null hypothesis.

## Files

- [Project report (PDF, German)](report.pdf).
- `stat_prakt_ag_r_skript.R`: the R analysis script.
- `simulierte_daten_a20.xlsx`: supplied simulated dataset with 30 observations, containing survival times, event/censoring status, group membership and age.
- `SurvivalAnalysis.Rproj`: the RStudio project file.

## Running the analysis

In RStudio, open `SurvivalAnalysis.Rproj`, run `renv::restore()` in the console to install the required package versions, then execute `stat_prakt_ag_r_skript.R`.

Alternatively, run these commands from the repository root in a terminal:

```sh
Rscript -e 'renv::restore()'
Rscript stat_prakt_ag_r_skript.R
```

The script saves four plots and a CSV summary in `Abbildungen und Tabellen/`. Tested with R 4.6.1.

## Maintenance note

This repository was prepared in 2026 with assistance from generative AI for documentation and dependency setup. The report, dataset and analysis code are retained from the project materials.
