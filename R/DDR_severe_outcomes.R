DDR_severe_outcomes <- function(define_severe_outcome_combined) {
  library(dplyr)
  outcome_components <- c(
    "COVID_patient_death_indicator",
    "COVID_patient_death_during_strong_covid_hospitalization_indicator",
    "COVID_patient_death_during_weak_covid_hospitalization_indicator",
    "death_within_specified_window_post_covid",
    "LL_IMV_during_strong_covid_hospitalization_indicator",
    "LL_ECMO_during_strong_covid_hospitalization_indicator",
    "LL_IMV_during_weak_covid_hospitalization_indicator",
    "LL_ECMO_during_weak_covid_hospitalization_indicator"
  )
  cat("===== Counts for Severe Outcome Component Variables =====\n")
  for (var in outcome_components) {
    cat("\n---", var, "---\n")
    print(table(define_severe_outcome_combined[[var]], useNA = "ifany"))
    cat("Total count (including NA):", length(define_severe_outcome_combined[[var]]), "\n")
  }
}
