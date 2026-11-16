handle_missing_values_combined <- function(define_severe_outcome_combined) {
  library(dplyr)

  # Remove columns with >70% missing values
  define_severe_outcome_combined <- define_severe_outcome_combined %>% select(where(~ mean(is.na(.)) <= 0.7))

  # Convert logical TRUE/FALSE to 1/0
  define_severe_outcome_combined <- define_severe_outcome_combined %>% mutate(across(where(is.logical), ~ as.integer(.)))

  # Convert "null" strings to NA
  define_severe_outcome_combined <- define_severe_outcome_combined %>% mutate(across(where(is.character), ~ na_if(., "null")))

  # Remove any rows missing the severe outcome label
  define_severe_outcome_combined <- define_severe_outcome_combined %>% filter(!is.na(severe_outcome_combined))

  return(define_severe_outcome_combined)
}
