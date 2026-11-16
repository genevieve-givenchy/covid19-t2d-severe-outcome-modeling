xgboost <- function(Summary_visualizations_combined) {
  library(dplyr); library(caret); library(pROC); library(xgboost)
  library(ROSE); library(tibble); library(ggplot2); library(precrec)

  model_label <- "XGBoost + ROSE"

  predictors <- c("sex", "age_at_covid",
                  "Antibody_Neg_before_or_day_of_covid_indicator",
                  "COVID_Vaccination_before_or_day_of_covid_indicator",
                  "Diabetes_medications_before_or_day_of_covid_indicator",
                  "Antibody_Pos_before_or_day_of_covid_indicator",
                  "Glucose_before_or_day_of_covid_indicator",
                  "BMI_category", "Poor_A1C_Control", "Vaccine_Status",
                  "Has_Kidney_Complication", "Total_Diabetes_Complications",
                  "Is_Obese", "Received_NonInsulin_Drugs",
                  "Poor_Oxygen_Saturation", "Multi_Organ_Impact_Risk")

  df <- Summary_visualizations_combined %>%
    select(all_of(predictors), severe_outcome_combined) %>%
    na.omit()
  df$severe_outcome_combined <- as.factor(df$severe_outcome_combined)

  set.seed(42)
  split_idx <- createDataPartition(df$severe_outcome_combined, p = 0.8, list = FALSE)
  train <- df[split_idx, ]; test <- df[-split_idx, ]

  convert_factors <- function(data) {
    data %>% mutate(across(where(~ is.character(.) | is.logical(.)), as.factor))
  }
  train <- convert_factors(train)

  # Balance the training set with ROSE (random over-sampling examples); the test set is left untouched
  resampled_data <- ROSE(severe_outcome_combined ~ ., data = train, seed = 123)$data
  resampled_data <- convert_factors(resampled_data)

  x_train <- model.matrix(severe_outcome_combined ~ . -1, data = resampled_data)
  y_train <- as.numeric(as.factor(resampled_data$severe_outcome_combined)) - 1

  x_test <- model.matrix(severe_outcome_combined ~ . -1, data = test)
  y_test <- as.numeric(as.factor(test$severe_outcome_combined)) - 1

  dtrain <- xgb.DMatrix(data = x_train, label = y_train)
  dtest <- xgb.DMatrix(data = x_test, label = y_test)

  base_params <- list(
    objective = "binary:logistic",
    eval_metric = "auc"
  )
  set.seed(123)
  model <- xgb.train(params = base_params, data = dtrain, nrounds = 100)

  prob <- predict(model, dtest)
  pred <- factor(ifelse(prob > 0.5, 1, 0), levels = c(0, 1))
  actual <- factor(y_test, levels = c(0, 1))

  roc_obj <- tryCatch({
    roc(response = y_test, predictor = prob)
  }, error = function(e) {
    message("ROC Error: ", e$message)
    NULL
  })

  auc_val <- if (!is.null(roc_obj) && inherits(roc_obj, "roc")) {
    tryCatch({ pROC::auc(roc_obj) }, error = function(e) NA)
  } else {
    NA
  }

  pr_obj <- evalmod(scores = prob, labels = actual)
  pr_auc <- tryCatch({
    subset(auc(pr_obj), curvetypes == "PRC")$aucs
  }, error = function(e) NA)

  conf <- confusionMatrix(pred, actual, positive = "1")
  accuracy <- conf$overall["Accuracy"]
  recall <- conf$byClass["Recall"]
  precision <- conf$byClass["Precision"]
  f1 <- conf$byClass["F1"]

  xgb_grid <- expand.grid(
    nrounds = c(50, 100),
    max_depth = c(3, 5),
    eta = c(0.05, 0.1),
    gamma = c(0, 1),
    colsample_bytree = c(0.6, 0.8),
    min_child_weight = c(1, 5),
    subsample = c(0.7, 0.9)
  )

  y_train_factor <- factor(y_train, levels = c(0, 1), labels = c("No", "Yes"))

  cv_model <- suppressWarnings(suppressMessages(tryCatch({
    train(x = x_train, y = y_train_factor,
          method = "xgbTree",
          tuneGrid = xgb_grid,
          trControl = trainControl(
            method = "cv",
            number = 3,
            classProbs = TRUE,
            summaryFunction = twoClassSummary
          ),
          metric = "ROC",
          na.action = na.omit)
  }, error = function(e) {
    message("CV Error: ", e$message)
    NULL
  })))

  cv_scores <- if (!is.null(cv_model)) cv_model$resample$ROC else NA

  importance_matrix <- xgb.importance(model = model)
  top_features <- importance_matrix[1:min(10, nrow(importance_matrix)), ]

  cat("\n📊 Original Class Distribution:", paste(capture.output(print(table(df$severe_outcome_combined))), collapse = " "))
  cat("\n📊 Resampled Class Distribution:", paste(capture.output(print(table(resampled_data$severe_outcome_combined))), collapse = " "))
  cat("\n✅ Accuracy:", round(accuracy, 2))
  cat("\n🔍 ROC AUC Score:", round(auc_val, 2))
  cat("\n🔍 PR AUC:", round(pr_auc, 2))
  cat("\n🔍 F1 Score:", round(f1, 2))
  cat("\n📉 Confusion Matrix:\n"); print(as.matrix(conf$table))
  if (!is.null(cv_model) && !is.na(cv_scores[1])) {
    cat("\n📊 Cross-Validation ROC AUC:", round(mean(cv_scores), 2), "±", round(sd(cv_scores), 2))
  } else {
    cat("\n⚠️ Cross-validation failed or returned no scores.")
  }
  cat("\n🏆 Top 10 Feature Importances (Gain):\n")
  print(top_features[, c("Feature", "Gain")])

  result <- data.frame(
    Model = model_label,
    Accuracy = round(as.numeric(accuracy), 3),
    Recall = round(as.numeric(recall), 3),
    Precision = round(as.numeric(precision), 3),
    F1 = round(as.numeric(f1), 3),
    AUC = round(as.numeric(auc_val), 3),
    PR_AUC = round(as.numeric(pr_auc), 3),
    CV_ROC_AUC = ifelse(is.null(cv_model), NA, round(mean(cv_scores), 3)),
    CV_SD = ifelse(is.null(cv_model), NA, round(sd(cv_scores), 3))
  )

  return(result)
}
