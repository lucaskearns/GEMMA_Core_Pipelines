# Command Line Program Usage

## Introduction

Generally, scripts for each enclosure type are divided by directory. e.g. [rotarod](https://github.com/lucaskearns/GEMMA_Core_Pipelines/tree/main/rota_rod) has its own directory.

Usually, each enclosure has a primary python wrapper that connects to the set of scripts contained within the subdirectories' libs folder. The python wrapper is mainly just to facilitate convenient command line argumentation. However, all of the statistics and data visualization is performed by the scripts in the libs folder.

An additional note is that the internally calculate dataframes which are used in plotting and statistics will be output alongside the data visualizations by substituting the .pdf suffix with .csv.

## rotarod

### boxplot

This functionality generates paired boxplots and performs some simple t-tests across each pairing. Additionally, FDR is performed to account for multiple hypothesis testing.

<p align="center">
<img src=https://github.com/lucaskearns/GEMMA_Core_Pipelines/blob/main/images/boxplot.png width="60%">
<p>
  
**Usage**

`python GEMMA_Core_Pipelines/rota_rod/rota_rod.py boxplot -h`

Can be used to print argument descriptions for boxplot functionality.

A typical boxplot command would look like:
```
python GEMMA_Core_Pipelines/rota_rod/rota_rod.py --filename "/path/to/data.xlsx" --sheetname "sheetname" --num_col "Latency to fall (seconds)" --sep_col "Date Run" --output "/path/to/output.pdf" boxplot --comp_col "Genotype"
```
In this case *--num_col* encode the numerical data being compared within the paired boxplots (i.e. the y-axis). *--sep_col* refers to the column containing data about how the pairs of boxplots should be split. Finally, *--comp_col* is the column dictating which values below to which member of the boxplot pair.

### survival graph

The "survival" graph is typically used for examining the number of mice remaining on the rotarod across a continuous variable compared between some kind of differentiator (eg Drop speed). Notably, this is a plot of the mean with an indication of the spread (+- 1 stnd dev) across the continuous variable.

<p align="center">
<img src=https://github.com/lucaskearns/GEMMA_Core_Pipelines/blob/main/images/line_plot.png width="60%">
<p>

`python GEMMA_Core_Pipelines/rota_rod/rota_rod.py lineplot -h`

Can be used to print argument descriptions for survival graph functionality.

A typical survival graph command would look like:
```
python GEMMA_Core_Pipelines/rota_rod/rota_rod.py --filename "/path/to/input.xlsx" --sheetname "sheetname" --num_col "Drop Speed" --sep_col "Genotype" --output "/Users/lucaskearns/weissman_hood/working_dir/GEMMA/data/rotarod/test_output/test_lineplot.pdf" lineplot --trial_col "Trial Number"
```

Here *--num_col* indicates which column houses the numerical data to calculate number remaining across (the x-axis). *--sep_col* refers to the column encoding how to split the data between different lines. *--trial_col* is the column 
