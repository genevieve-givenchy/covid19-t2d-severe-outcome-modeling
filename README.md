# Predicting ICU-level outcomes or in-hospital death in people with type 2 diabetes and COVID-19

An R pipeline that builds an interpretable machine learning model (XGBoost) to predict severe outcomes (in-hospital death, invasive mechanical ventilation or ECMO) among patients with type 2 diabetes who were infected with SARS-CoV-2.

This work comes from a team project in the **AIM-AHEAD Health Data Science Training Program** (2025), using electronic health record data in the **NIH N3C (National Clinical Cohort Collaborative) Data Enclave**. It was presented as a poster at the AIM-AHEAD Annual Meeting 2025:

> *AI Models Predict Risk of ICU Admission or In-Hospital Death Among Type 2 Diabetes Patients With SARS-CoV-2 Infection.* Michael Sam, MPH; Sadaf Ghaderzadeh, PhD (now Genevieve Givenchy); Donna Kuehu, PhD; Molla Fentie Mengist, PhD; Kumaraswamy Naidu Chitrala, PhD; Nettie Brown, PhD; Babajide Sadiq, DrPH.

The team compared logistic regression, random forest and XGBoost. This repository contains the R pipeline for data preparation, leakage removal and the XGBoost model.

## Data availability

This repository contains **code only**. The patient-level data live in the N3C Data Enclave and, under the N3C Data Use Agreement, cannot be downloaded or shared. No data, outputs or results tables are included here.

Each script is written as a function that takes the previous step's dataset as its input. That is how transforms are chained in an N3C (Palantir Foundry) Code Workbook, so the pipeline is meant to run inside the Enclave rather than on a local machine.

## Pipeline

| Step | Script | What it does |
| --- | --- | --- |
| 1 | `define_severe_outcome_combined.R` | Creates the binary outcome: death, IMV or ECMO during or after the COVID-19 hospitalization |
| 2 | `DDR_severe_outcomes.R` | Reports counts for each outcome component |
| 3 | `handle_missing_values_combined.R` | Drops columns with more than 70% missing values, converts logical and "null" values, removes rows without an outcome |
| 4 | `DDR_feature_engineering.R` | Summarizes the raw clinical features used to build engineered variables |
| 5 | `redundancy_multicollinearity_bias_combined.R` | Removes outcome components, post-COVID measurements (look-ahead bias), raw variables replaced by engineered ones, and identifiers |
| 6 | `final_predictor_cleanup_combined.R` | Removes remaining leakage: in-hospital indicators, length of stay and other outcome-derived variables |
| 7 | `summary_visualizations_combined.R` | Summary tables and distribution plots for every model feature |
| 8 | `DDR_descriptive_stats.R` | Descriptive statistics, with numeric features compared by outcome |
| 9 | `feature_correlation.R` | Correlation heatmap; drops features correlated above 0.90 |
| 10 | `xgboost.R` | Trains XGBoost on a ROSE-balanced training set, evaluates on a held-out 20% test set (ROC AUC, PR AUC, F1, confusion matrix), runs 3-fold cross-validated tuning and reports feature importance |

The engineered features used in the model (for example `Poor_A1C_Control`, `Vaccine_Status`, `Has_Kidney_Complication` and `Multi_Organ_Impact_Risk`) were created in an upstream Enclave transform that is not part of this repository.

## Design choices

- **Preventing outcome leakage.** Any variable measured during the hospitalization or after the COVID-19 diagnosis is removed before modeling, so the model only uses information available at or before diagnosis.
- **Handling class imbalance.** Severe outcomes are much rarer than non-severe ones, so the training set is balanced with ROSE (random over-sampling examples). The test set is left untouched to give an honest estimate of performance.
- **Interpretability.** XGBoost feature importance (gain) shows which clinical factors drive predictions.

## Requirements

R 4.2 or later with:

```r
install.packages(c("dplyr", "ggplot2", "tibble", "reshape2", "viridis",
                   "xgboost", "caret", "pROC", "ROSE", "precrec"))
```

## Results

The figures below are the ones reported on the AIM-AHEAD 2025 poster. No other results have been exported from the Enclave.

- **Cohort:** 9,012 adults with type 2 diabetes and confirmed SARS-CoV-2 infection; 820 (about 9%) had a severe outcome
- **XGBoost:** accuracy 0.70, ROC AUC about 0.73, PR AUC 0.20
- **Across models**, logistic regression gave the best balance of sensitivity and specificity (recall 0.70, AUC 0.70), making it the most suitable for triage
- **Most important XGBoost features:** kidney complications, glucose before or on the day of COVID-19 diagnosis, multi-organ impact, non-insulin diabetes drugs and total diabetes complications

The low PR AUC reflects how rare severe outcomes are in this cohort: the model ranks patients reasonably well, but many patients it flags as high-risk do not go on to have a severe outcome.

## Acknowledgments

The analyses described here were conducted with data or tools accessed through the NCATS N3C Data Enclave and supported by the AIM-AHEAD program. N3C data are provided under the N3C Data Use Agreement; see the [N3C attribution and publication policy](https://covid.cd2h.org/acknowledgements) for the full acknowledgment of contributing data partners.

## License

MIT. See [LICENSE](LICENSE).
