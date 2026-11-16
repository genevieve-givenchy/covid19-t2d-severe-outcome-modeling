# Descriptive report (DDR) for the raw clinical features used in feature engineering.
# Input: the cleaned cohort after missing-value handling.
# Prints counts for categorical indicators and a summary table for numeric features,
# then returns the numeric summary so it can be saved as its own dataset.

DDR_feature_engineering <- function(feature_engineering_combined) {
  library(dplyr)
  library(tibble)

  # Define variable lists
  numeric_vars <- c(
    "BMI_max_observed_or_calculated_before_or_day_of_covid",
    "Diabetes_A1c_before_or_day_of_covid_indicator",
    "number_of_COVID_vaccine_doses_before_or_day_of_covid",
    "Oxygen_Saturation_before_or_day_of_covid_indicator"
  )

  categorical_vars <- c(
    "KIDNEYDISEASE_before_or_day_of_covid_indicator",
    "Diabetes_Nephropathy_before_or_day_of_covid_indicator",
    "Diabetes_Neuropathy_before_or_day_of_covid_indicator",
    "OBESITY_before_or_day_of_covid_indicator",
    "Drugs_not_insulin_before_or_day_of_covid_indicator"
  )

  cat("===== Categorical Variable Counts =====\n")
  for (var in categorical_vars) {
    cat("\n---", var, "---\n")
    print(table(feature_engineering_combined[[var]], useNA = "ifany"))
    cat("Total count (including NA):", length(feature_engineering_combined[[var]]), "\n")
  }

  cat("\n===== Numeric Variable Summary Table =====\n")
  numeric_summary <- feature_engineering_combined %>%
    select(all_of(numeric_vars)) %>%
    summarise(across(everything(), list(
      count_nonNA = ~sum(!is.na(.)),
      total_count = ~length(.),
      mean = ~mean(., na.rm = TRUE),
      sd = ~sd(., na.rm = TRUE),
      median = ~median(., na.rm = TRUE),
      min = ~min(., na.rm = TRUE),
      max = ~max(., na.rm = TRUE)
    ), .names = "{.col}__{.fn}"))

  # Reshape to one row per variable for readability
  stats <- c("count_nonNA", "total_count", "mean", "sd", "median", "min", "max")
  numeric_table <- do.call(rbind, lapply(numeric_vars, function(v) {
    row <- numeric_summary[paste0(v, "__", stats)]
    names(row) <- stats
    tibble(variable = v, row)
  }))

  print(numeric_table)

  return(numeric_table)
}
