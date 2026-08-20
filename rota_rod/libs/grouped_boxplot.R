library(tidyverse)
library(readxl)
# Lucas Kearns
# 14 Aug 2026

# Script for performing a two way anova


###################
## Argument parsing
###################

# filename <- "/Users/lucaskearns/weissman_hood/working_dir/GEMMA/data/rotarod/ML-70 Cohort 3 Rotarod Data FAKE GENOTYPE.xlsx"
# sheetname <- "Sheet1"
# comp_col <- "Genotype"
# num_col <- "Latency to fall (seconds)"
# sep_col <- "Date Run"
# output <- "/Users/lucaskearns/weissman_hood/working_dir/GEMMA/data/rotarod/test_output/ML-70 Cohort 3 Rotarod Data FAKE GENOTYPE.pdf"
args <- commandArgs(trailingOnly = TRUE)
filename <- args[1]
sheetname <- args[2]
comp_col <- args[3]
num_col <- args[4]
sep_col <- args[5]
output <- args[6]

#################################
## Load in and clean up the files
#################################

# Load in the file
df <- read_xlsx(filename, sheet = sheetname)

# Drop un-labeled columns - these are typically columns containing note information
# added by the GEMMA core which doesn't really factor into analysis.
df <- df %>%
  select(!starts_with("...")) %>%
  mutate(!!sep_col := as.factor(.data[[sep_col]]),
         !!num_col:= as.numeric(.data[[num_col]])
  )



#######################
## Calculate statistics
#######################

# Calculate t test stats

print("===========================")
print("Running statistical testing")

stat_results <- c()
for (val in unique(df[[sep_col]])){
  print("--")
  print(val)
  
  # Subset down to column of interest
  sep_df <- df %>%
    filter(.data[[sep_col]] == val)
  
  # Perform statistical testing based upon
  # comparison column. Number of variables
  # is checked to ensure statistical test
  # possible.
  # ------------------------------------------
  
  # 2 values enables t test
  if (length(unique(sep_df[[comp_col]])) == 2){
    print("Performing t - test")
    
    # Produce formula
    sep_formula <- as.formula(paste0("`", num_col, "`", " ~ ", "`", comp_col, "`"))
    
    # Input t test into results
    stat_res <- t.test(sep_formula, sep_df)
    stat_results[val] <- stat_res$p.value
    
  # Otherwise do no statistical testing
  }
  else{
    print("Length of comparison groups != 2. Skipping t-test.")
    stat_results[val] = NA
  }
}

# Perform multiple testing correction
q_vals <- p.adjust(unname(stat_results))

# Round p and q values
stat_results <- round(stat_results, 4)
q_vals <- round(q_vals, 4)

# Produce statistics DF and add in a column for easy testing
stat_df = data.frame(sep = names(stat_results), 
                     p_val = unname(stat_results),
                     q_val = q_vals)
stat_df <- stat_df %>%
  mutate(combined_vals = paste0("P Value: ", unname(stat_results),
                                "\n",
                                "Q Value: ", q_vals))


#############################
## Perform data visualization
#############################

# Produce boxplot data visualization
ggplot(df, aes(x = .data[[sep_col]], y = .data[[num_col]], fill = .data[[comp_col]])) +
  geom_boxplot(position = position_dodge(width = .8)) +
  coord_cartesian(clip="off") +
  labs(title = "Boxplot With T-tests") +
  geom_label(data = stat_df, aes(x=`sep`, y=Inf, label = combined_vals, vjust = 1.5), 
            inherit.aes = FALSE,
            size = 3) +
  scale_y_continuous(
    expand = expansion(mult = c(0.05, 0.15)) 
  ) +
  theme_classic() +
  theme(plot.title = element_text(hjust = .5))


# Save visualization to output file
ggsave(output)



