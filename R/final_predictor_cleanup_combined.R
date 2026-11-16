final_predictor_cleanup_combined <- function(redundancy_multicollinearity_bias_combined) {
  library(dplyr)

  # Step 1: Define variables to remove with rationale
  vars_to_remove <- c(
    # Redundant cohort-defining variable
    "Type_2_Diabetes_Mellitus_before_or_day_of_covid_indicator",

    # Outcome leakage variables
    "COVID_diagnosis_during_strong_covid_hospitalization_indicator",
    "COVID_Vaccination_during_strong_covid_hospitalization_indicator",
    "Diabetes_medications_during_strong_covid_hospitalization_indicator",
    "Drugs_not_insulin_during_strong_covid_hospitalization_indicator",
    "COVID_diagnosis_during_weak_covid_hospitalization_indicator",
    "COVID_Vaccination_during_weak_covid_hospitalization_indicator",
    "Diabetes_medications_during_weak_covid_hospitalization_indicator",
    "Drugs_not_insulin_during_weak_covid_hospitalization_indicator",

    # Post-COVID indicators (look-ahead bias)
    "Type_2_Diabetes_Mellitus_post_covid_indicator",
    "OBESITY_post_covid_indicator",
    "Diabetes_CRP_post_covid_indicator",

    # Outcome-derived or reverse causal variables
    "strong_COVID_hospitalization_length_of_stay",
    "Severity_Type"
  )

  # Step 2: Remove these variables
  cleaned_dataset <- redundancy_multicollinearity_bias_combined %>%
    select(-any_of(vars_to_remove))

  return(cleaned_dataset)
}
