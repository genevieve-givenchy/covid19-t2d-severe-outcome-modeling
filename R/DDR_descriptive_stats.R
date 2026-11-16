# Descriptive statistics for the final modeling dataset, stratified by outcome.
# Prints counts and summaries, draws a few comparison plots, and returns the
# numeric summary table (one row per variable).

DDR_descriptive_stats <- function(summary_visualizations_combined) {
  library(dplyr)
  library(ggplot2)
  library(tibble)

  # Define variable types
  categorical_vars <- c(
    "sex",
    "race_ethnicity",
    "Antibody_Neg_before_or_day_of_covid_indicator",
    "COVID_Vaccination_before_or_day_of_covid_indicator",
    "Diabetes_medications_before_or_day_of_covid_indicator",
    "Antibody_Pos_before_or_day_of_covid_indicator",
    "severe_outcome_combined",
    "BMI_category",
    "Poor_A1C_Control",
    "Vaccine_Status",
    "Has_Kidney_Complication",
    "Is_Obese",
    "Received_NonInsulin_Drugs",
    "Poor_Oxygen_Saturation",
    "Multi_Organ_Impact_Risk"
  )

  numeric_vars <- c(
    "age_at_covid",
    "Glucose_before_or_day_of_covid_indicator",
    "Total_Diabetes_Complications"
  )

  # Step 1: Summary tables
  cat("\n===== Summary Tables =====\n")

  for (var in categorical_vars) {
    cat("\n---", var, "---\n")
    counts <- table(summary_visualizations_combined[[var]], useNA = "ifany")
    print(counts)
    cat("Total count (including NA):", length(summary_visualizations_combined[[var]]), "\n")
  }

  cat("\n--- Numeric Summary Table ---\n")
  numeric_summary <- do.call(rbind, lapply(numeric_vars, function(v) {
    x <- summary_visualizations_combined[[v]]
    tibble(
      variable = v,
      count_nonNA = sum(!is.na(x)),
      total_count = length(x),
      mean = mean(x, na.rm = TRUE),
      sd = sd(x, na.rm = TRUE),
      median = median(x, na.rm = TRUE),
      min = min(x, na.rm = TRUE),
      max = max(x, na.rm = TRUE)
    )
  }))
  print(numeric_summary)

  # Step 2: Numeric features by outcome
  cat("\n--- Numeric Features by Severe Outcome ---\n")
  by_outcome <- summary_visualizations_combined %>%
    filter(!is.na(severe_outcome_combined)) %>%
    group_by(severe_outcome_combined) %>%
    summarise(across(all_of(numeric_vars),
                     list(mean = ~mean(., na.rm = TRUE), median = ~median(., na.rm = TRUE))),
              n = n(), .groups = "drop")
  print(by_outcome)

  # Step 3: Plots comparing outcome groups
  for (v in numeric_vars) {
    print(
      ggplot(summary_visualizations_combined %>% filter(!is.na(.data[[v]]), !is.na(severe_outcome_combined)),
             aes(x = factor(severe_outcome_combined), y = .data[[v]])) +
        geom_boxplot(fill = "steelblue", alpha = 0.6) +
        labs(title = paste(v, "by severe outcome"),
             x = "Severe outcome (0 = no, 1 = yes)", y = v) +
        theme_minimal(base_size = 12)
    )
  }

  return(numeric_summary)
}
