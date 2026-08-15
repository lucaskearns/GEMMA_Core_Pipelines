library(tidyverse)
library(readxl)
# Lucas Kearns
# 14 Aug 2026

# Script for generating a endurance line graph

###################
## Argument parsing
###################

filename <- "/Users/lucaskearns/weissman_hood/working_dir/GEMMA/data/rotarod/1536 Prelim Cohort Days 1-3 FAKE GENOTYPE.xlsx"
sheetname <- "Sheet1"
comp_col <- "Trial Number"
num_col = "Drop Speed"
sep_col <- "Genotype"
output <- "/Users/lucaskearns/weissman_hood/working_dir/GEMMA/data/rotarod/test_output/1536 Prelim Cohort Days 1-3 FAKE GENOTYPE.pdf"

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
         !!num_col := as.numeric(.data[[num_col]])
)

###########################################################################
## Calculate percent remaining across a dynamically generated range for the
## numeric column
###########################################################################

# Generate a data data frame of survival across separation variables and
# comp variables
# ----------------------------------------------------------------------
num_max <- round(max(df[[num_col]], na.rm = TRUE))
survival_pts <- seq(0, num_max, by = 1)

# Generate a dataframe recording survival results
survival_df <- data.frame()
for (sep_val in unique(df[[sep_col]])){
  print("++++")
  print(sep_val)
  
  for (comp_val in unique(df[[comp_col]])){
    print("-")
    print(comp_val)
    
    sep_comp_num_df <- df %>%
      filter( (.data[[sep_col]] == sep_val) & (.data[[comp_col]] == comp_val) )
    
    sep_comp_num_col <- sep_comp_num_df %>%
      pull(num_col)
    
    survival_count <- map(survival_pts, function(sur_val){
      sum(sep_comp_num_col > sur_val, na.rm = TRUE)
      } 
    ) %>%
    unlist()
    survival_df <- rbind(survival_df, data.frame(survival_num = survival_pts,
                                                 survival_count = survival_count, 
                                                 sep_val = sep_val, 
                                                 comp_val = comp_val))
  }
}

# Calculate spread and mean across comp variables within separation var
# categories
# ---------------------------------------------------------------------

mean_survival_df = data.frame()
for (sep_v in unique(survival_df[["sep_val"]])){
  print("++++")
  print(sep_v)
  
  summar_df <- survival_df %>%
    filter(survival_df[["sep_val"]] == sep_v) %>%
    group_by(survival_num) %>%
    summarise(mean_val = mean(survival_count, na.rm = TRUE),
              sd_val = sd(survival_count, na.rm = TRUE)) %>%
    ungroup() %>%
    mutate(sep = sep_v)

  mean_survival_df <- rbind(mean_survival_df, summar_df)
}

#########################################
## Generate line graph data visualization
#########################################

# Dynamically generate lines in by separation variables
p <- ggplot()
for (sep_v in unique(mean_survival_df[["sep"]])){
  print("+++++++++++++++++++++")
  print(sep_v)
  
  
  line_df <- mean_survival_df %>%
    filter(sep == sep_v) %>%
    as.data.frame()
  
  print(line_df)
    
  p <- p + geom_line(data = line_df, aes(x = survival_num, 
                                         y = mean_val,
                                         color = sep))
  p <- p + geom_point(data = line_df, aes(x = survival_num, 
                                         y = mean_val,
                                         color = sep))
  p <- p + geom_errorbar(data = line_df, aes(x = survival_num,
                                             y = mean_val,
                                             ymin = mean_val - sd_val,
                                             ymax = mean_val + sd_val,
                                             color = sep), width = 0, alpha = .7)
}

# Finalize data visualization formatting
p <- p + theme_classic() +
  labs(title = "Num Remaining Line Graph") +
  theme(plot.title = element_text(hjust = .5)) +
  ylab("Number Remaining") +
  xlab(num_col)
  
print(p)
ggsave(output)
