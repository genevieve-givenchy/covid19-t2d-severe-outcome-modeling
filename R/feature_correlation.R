feature_correlation <- function(Summary_visualizations_combined) {
  library(dplyr)
  library(ggplot2)
  library(reshape2)
  library(viridis)

  df <- Summary_visualizations_combined

  # Step 1: Compute absolute correlation matrix (numeric columns only)
  numeric_df <- df %>% select(where(is.numeric))
  corr_matrix <- abs(cor(numeric_df, use = "pairwise.complete.obs"))

  # Step 2: Identify upper triangle
  corr_upper <- corr_matrix
  corr_upper[lower.tri(corr_upper, diag = TRUE)] <- NA

  # Step 3: Identify columns to drop based on correlation threshold > 0.90
  to_drop <- colnames(corr_upper)[apply(corr_upper, 2, function(x) any(x > 0.90, na.rm = TRUE))]
  cleaned_df <- df %>% select(-any_of(to_drop))

  cat("Dropped columns due to high correlation (> 0.90):\n")
  print(to_drop)

  # Step 4: Plot heatmap of correlations
  melted_corr <- melt(round(corr_matrix, 2), na.rm = TRUE)
  ggplot(data = melted_corr, aes(x = Var1, y = Var2, fill = value)) +
    geom_tile(color = "white") +
    scale_fill_viridis(name = "Correlation", limits = c(0, 1)) +
    geom_text(aes(label = value), color = "white", size = 4) +
    theme_minimal(base_size = 14) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(title = "Correlation Heatmap")

  return(cleaned_df)
}
