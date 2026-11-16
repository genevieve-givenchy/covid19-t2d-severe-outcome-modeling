# Prints summary tables and plots the distribution of every model feature.
# Returns the dataset unchanged so it can feed the correlation and modeling steps.

summary_visualizations_combined <- function(final_predictor_cleanup_combined) {
  library(dplyr)
  library(ggplot2)

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
  for (var in c(categorical_vars, numeric_vars)) {
    cat("\n---", var, "---\n")
    if (var %in% categorical_vars) {
      print(table(final_predictor_cleanup_combined[[var]], useNA = "ifany"))
    } else {
      print(summary(final_predictor_cleanup_combined[[var]]))
    }
  }

  # Step 2: Visualizations
  cat("\n===== Visualizations =====\n")
  plot_categorical <- function(var) {
    df <- final_predictor_cleanup_combined %>%
      filter(!is.na(.data[[var]])) %>%
      count(.data[[var]]) %>%
      rename(Category = 1, Count = 2)

    print(
      ggplot(df, aes(x = reorder(as.character(Category), -Count), y = Count)) +
        geom_bar(stat = "identity", fill = "steelblue") +
        labs(
          title = paste("Distribution of", var),
          x = var,
          y = "Count"
        ) +
        theme_minimal(base_size = 12) +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))
    )
  }

  plot_numeric <- function(var) {
    df <- final_predictor_cleanup_combined %>%
      filter(!is.na(.data[[var]]))

    print(
      ggplot(df, aes(x = .data[[var]])) +
        geom_histogram(bins = 30, fill = "steelblue", color = "white") +
        labs(
          title = paste("Distribution of", var),
          x = var,
          y = "Count"
        ) +
        theme_minimal(base_size = 12)
    )
  }

  for (var in categorical_vars) plot_categorical(var)
  for (var in numeric_vars) plot_numeric(var)

  return(final_predictor_cleanup_combined)
}
