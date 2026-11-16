define_severe_outcome_combined <- function(df) {
  df$severe_outcome_combined <- ifelse(
    df$COVID_patient_death_indicator == 1 |
      df$COVID_patient_death_during_strong_covid_hospitalization_indicator == 1 |
      df$COVID_patient_death_during_weak_covid_hospitalization_indicator == 1 |
      df$death_within_specified_window_post_covid == 1 |
      df$LL_IMV_during_strong_covid_hospitalization_indicator == 1 |
      df$LL_ECMO_during_strong_covid_hospitalization_indicator == 1 |
      df$LL_IMV_during_weak_covid_hospitalization_indicator == 1 |
      df$LL_ECMO_during_weak_covid_hospitalization_indicator == 1,
    1, 0
  )
  return(df)
}
