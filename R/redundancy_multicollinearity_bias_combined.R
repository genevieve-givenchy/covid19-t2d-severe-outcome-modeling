# Removes three groups of variables before modeling:
#   1. Raw inputs replaced by engineered features (redundancy / multicollinearity)
#   2. Outcome components and post-COVID measurements (outcome leakage, look-ahead bias)
#   3. Identifiers and date-shift fields that carry no predictive meaning

redundancy_multicollinearity_bias_combined <- function(feature_engineering_combined) {
  library(dplyr)

  # Step 1: Define variables to remove
  vars_to_remove <- c(
    # Raw variables superseded by engineered features
    "race",
    "OBESITY_before_or_day_of_covid_indicator",
    "Drugs_not_insulin_before_or_day_of_covid_indicator",
    "Diabetes_A1c_before_or_day_of_covid_indicator",
    "number_of_COVID_vaccine_doses_before_or_day_of_covid",
    "KIDNEYDISEASE_before_or_day_of_covid_indicator",
    "Diabetes_Nephropathy_before_or_day_of_covid_indicator",
    "Diabetes_Neuropathy_before_or_day_of_covid_indicator",
    "BMI_max_observed_or_calculated_before_or_day_of_covid",
    "Oxygen_Saturation_before_or_day_of_covid_indicator",

    # Components of the outcome itself (would leak the label)
    "COVID_patient_death_indicator",
    "COVID_patient_death_during_weak_covid_hospitalization_indicator",
    "COVID_patient_death_during_strong_covid_hospitalization_indicator",
    "death_within_specified_window_post_covid",
    "LL_IMV_during_weak_covid_hospitalization_indicator",
    "LL_IMV_during_strong_covid_hospitalization_indicator",
    "LL_ECMO_during_weak_covid_hospitalization_indicator",
    "LL_ECMO_during_strong_covid_hospitalization_indicator",

    # Measured after COVID diagnosis (look-ahead bias)
    "BMI_max_observed_or_calculated_post_covid",
    "Diabetes_A1c_post_covid_indicator",
    "Glucose_post_covid_indicator",
    "Oxygen_Saturation_post_covid_indicator",
    "WBC_post_covid_indicator",
    "Diabetes_medications_post_covid_indicator",
    "Drugs_not_insulin_post_covid_indicator",
    "PCR_AG_Pos_post_covid_indicator",
    "PCR_AG_Neg_post_covid_indicator",
    "Antibody_Neg_post_covid_indicator",
    "Antibody_Pos_post_covid_indicator",
    "KIDNEYDISEASE_post_covid_indicator",
    "Long_COVID_diagnosis_post_covid_indicator",
    "Long_COVID_clinic_visit_post_covid_indicator",
    "number_of_COVID_vaccine_doses_post_covid",
    "had_at_least_one_reinfection_post_covid_indicator",

    # Identifiers and date-shift fields
    "person_id",
    "max_num_shift_days"
  )

  # Step 2: Remove selected variables
  cleaned_dataset <- feature_engineering_combined %>%
    select(-any_of(vars_to_remove))

  cat("Columns removed:", sum(vars_to_remove %in% names(feature_engineering_combined)), "\n")
  cat("Columns remaining:", ncol(cleaned_dataset), "\n")

  return(cleaned_dataset)
}
