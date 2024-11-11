# This script reads in population data from a CSV file, processes it
# to generate summary statistics and density plots, and saves the
# results to specified output files.

#It performs data cleaning, joins the data with censustree crosswalk files,
# and categorizes the data based on the censustree linkage status for the
# years 1920 and 1940. Summary statistics and density plots are generated
# for different groups based on the GQTYPE variable.

#Last updated: June 20, 2024
#Author: Krista Cherry

library("dplyr")
library("tidyverse")
library("data.table")
library("R.utils")
library("xtable")
library("scales")
library("ggplot2")

data_file_path <<- "/homes/nber/kcherr/bulk/"
data_name <<- "fullpop.csv"
output_file_path <<- "/homes/nber/kcherr/de-inst/de-inst_9_censustreelinkstats/output/"

setwd(data_file_path)
df <- fread(data_name)
head(df)

df <- df %>%
  rename(histid1930 = HISTID) %>%
  mutate(histid1930 = tolower(histid1930)) %>%
  filter(YEAR == 1930 & AGE <= 90)
head(df)

crosswalk_1930_1940 <- fread("/homes/nber/kcherr/bulk/de-inst_data/censustree_crosswalks/1930_1940.csv")
head(crosswalk_1930_1940)
crosswalk_1930_1940 <- crosswalk_1930_1940 %>%
  mutate(histid1930 = tolower(histid1930))
crosswalk_1920_1930 <- fread("/homes/nber/kcherr/bulk/de-inst_data/censustree_crosswalks/1920_1930.csv")
crosswalk_1920_1930 <- crosswalk_1920_1930 %>%
  mutate(histid1930 = tolower(histid1930))

data_1930_1940 <- left_join(df, crosswalk_1930_1940, by = "histid1930")
str(data_1930_1940)
data_1930_1940 <- data_1930_1940 %>%
  mutate(linked1940 = ifelse(is.na(histid1940), 0, 1))
data_1920_1940 <- left_join(data_1930_1940,
                            crosswalk_1920_1930, by = "histid1930")
str(data_1920_1940)
data_1920_1940 <- data_1920_1940 %>%
  mutate(linked1920 = ifelse(is.na(histid1920), 0, 1))

# This function generates a summary statistics data frame for a
# given data frame and assigns the result to the global environment.
# The function assumes the dataframe has variables written inside it,
# and will throw an error if "df" doesn't have those variables.
generate_summarise <- function(df, df_name) {
  df_name <- deparse(substitute(df))
  summary_stats_name <- paste(df_name, "summary_stats", sep = "_")
  summary_stats <- df %>%
    summarise(
      Link_type = df_name,
      Count = n(),
      `Mean Age` = mean(AGE),
      `% Not Metro` = sum(METRO == 1) / n() * 100,
      `% Urban` = sum(URBAN == 2) / n() * 100,
      `% Male` = sum(SEX == 1) / n() * 100,
      `% Married` = sum(MARST == 1 | MARST == 2) / n() * 100,
      `% Never Married` = sum(MARST == 6) / n() * 100,
      `% Divorced` = sum(MARST == 4) / n() * 100,
      `% Widowed` = sum(MARST == 5) / n() * 100,
      `% White` = sum(RACE == 1) / n() * 100,
      `% Black` = sum(RACE == 2) / n() * 100,
      `% Foreign Born` = sum(NATIVITY == 5) / n() * 100,
      `% Not Veterans` = sum(VET1930 == 0) / n() * 100,
      `% In Labor Force` = sum(EMPSTAT != 3) / n() * 100,
      `% Employed` = sum(EMPSTAT == 1) / sum(EMPSTAT == 1 | EMPSTAT == 2) * 100,
      `% Literate` = sum(LIT != 1) / n() * 100
    )
  assign(summary_stats_name, summary_stats, envir = .GlobalEnv)
}

# This function generates summary statistics and density plots
# for a given data frame, categorized by the censustree linkage status
# for individuals in the years 1920 and 1940.
# It creates a LaTeX table of the summary statistics and saves a density plot as a JPEG file.
# It saves these files to the output_file_path directory.
# The dataframe must have all the variables "linkeded1920" and "linked1940"
# as well as all variables in generate_summarise().
generate_gq_summary <- function(df, gq_type) {
  df_linked1920 <- df %>% filter(linked1920 == 1)
  df_linked1940 <- df %>% filter(linked1940 == 1)
  df_unlinked <- df %>% filter(linked1920 == 0 & linked1940 == 0)
  df_linkedboth <- df %>% filter(linked1920 == 1 & linked1940 == 1)
  generate_summarise(df_unlinked, "unlinked")
  generate_summarise(df_linked1920, "linked1920")
  generate_summarise(df_linked1940, "linked1940")
  generate_summarise(df_linkedboth, "both")
  generate_summarise(df, "total")
  combined_summary_stats <- rbind(df_unlinked_summary_stats,
                                  df_linked1920_summary_stats,
                                  df_linked1940_summary_stats,
                                  df_linkedboth_summary_stats,
                                  df_summary_stats)
  combined_summary_stats <- combined_summary_stats[-1] #deletes the first column
  df_combined_summary_stats <- t(combined_summary_stats) #transpose
  colnames(df_combined_summary_stats) <- c("Unlinked", "Linked 1920", "Linked 1940", "Linked Both", "Total")
  df_combined_summary_stats <- round(df_combined_summary_stats, 1)
  df_combined_summary_stats[1, ] <- sapply(df_combined_summary_stats[1, ], function(x) formatC(x, format = "f", digits = 0, big.mark = ","))
  latex_table <- xtable(df_combined_summary_stats)
  # Print the latex table without the first column (index)
  print(latex_table, type = "latex", file = paste0(output_file_path, gq_type, "_censustree_linked", ".tex"),
        table.placement = NULL, include.rownames = TRUE, include.colnames = TRUE)
  # Combine all dataframes into one
  # Plot with legend
  base_plot <- ggplot() +
    labs(color = "Dataframe", x = "Age", y = "Density")

  # Add density plots for each dataframe
  combined_plot <- base_plot +
    geom_density(data = df, aes(x = AGE, color = "Total"), fill = "transparent") +
    geom_density(data = df_unlinked, aes(x = AGE, color = "Unlinked"), fill = "transparent") +
    geom_density(data = df_linkedboth, aes(x = AGE, color = "Linked, both"), fill = "transparent") +
    geom_density(data = df_linked1940, aes(x = AGE, color = "Linked, 1940"), fill = "transparent") +
    geom_density(data = df_linked1920, aes(x = AGE, color = "Linked, 1920"), fill = "transparent") +
    scale_color_discrete(name = "Legend") +
    theme_minimal()

  ggsave(paste0(output_file_path, gq_type, "_censustree_age.jpg"), plot = combined_plot, width = 6, height = 4, dpi = 300)
}

df_gq0 <- data_1920_1940 %>% filter(GQTYPE == 0)
df_gq1 <- data_1920_1940 %>% filter(GQTYPE == 6 |
                                      GQTYPE == 7 |
                                      GQTYPE == 8 |
                                      GQTYPE == 9)
df_gq2 <- data_1920_1940 %>% filter(GQTYPE == 2)
df_gq3 <- data_1920_1940 %>% filter(GQTYPE == 3) #mental institutions
df_gq4 <- data_1920_1940 %>% filter(GQTYPE == 4)

generate_gq_summary(df_gq0, "gq_0")
generate_gq_summary(df_gq1, "gq_1")
generate_gq_summary(df_gq2, "gq_2")
generate_gq_summary(df_gq3, "gq_3")
generate_gq_summary(df_gq4, "gq_4")
