# 05/30/2020
# Script to process IO table w/ NAICS format; hard-tailored for Calif-IO table 2016
# Output: IO table 2020 (linear growth baseline)
library(ioanalysis)
library(tidyverse)

# INPUT====
mainIO.file <- "IO_processing/data/California_I-O Table_3-digit NAICS_2016.csv"
year.main <- 2016
sectoral.gdp19 <- "IO_processing/data/actualGDP_CA2019.csv" #secondary data from 2019 actual GDP; bill chained 2012 USD
gdp1619.file <- "IO_processing/data/GDP16-19download.csv"
# input\ends----

# Identify the structure and component of the IO table
mainIO <- mainIO.file %>% read.csv(stringsAsFactors = FALSE) %>% mutate(CAT_ID = gsub(" .*", "", Sectors)) %>% mutate(CAT_ID = CAT_ID %>% substr(1, 1) %>% as.numeric()) # generating CAT_ID for joining purposes; Non-sectors will contain NA

n_primIn <- mainIO %>% dplyr::select(CAT_ID) %>% pull() %>% is.na() %>% sum()
n_sectors <- mainIO %>% nrow(.) -n_primIn
# sectors
# Primary inputs

# Basic IO analytics: tech coeff, Leontieff, etc using  ioanalysis
out_total <- mainIO %>% slice(1:n_sectors) %>% dplyr::select(4:ncol(.)) %>% dplyr::select(-CAT_ID) %>% rowSums() # total output
sectors_chr <- mainIO %>% dplyr::select(2) %>% slice(1:n_sectors) %>% mutate(Region = "CA") %>% dplyr::select(Region, Sectors) %>% as.matrix() #RS_label
interMatrix <- mainIO %>% slice(1:n_sectors) %>% dplyr::select(4:(n_sectors+3)) %>% mutate_all(as.numeric) %>% replace(is.na(.), 0) %>% as.matrix()
io_CA16 <- interMatrix %>% as.inputoutput(sectors_chr, X = out_total)


# Final demand
# NOTE


# ## Projecting 2020 linear
# ## Based on the real GDP 2016-2019
# library(tidyverse)

# Read input
gdp1619 <- gdp1619.file %>% read.csv(stringsAsFactors = FALSE)
# Linear projection of 2020 per sector to obtain GDP sector

# Calculate the total output
# a. Calculate the rowSums of sectoral columns, denominator of GDP coeff.
gdp_coef <- data.frame(d = 1)
for(s in 1:n_sectors){
  # division
  demon <- mainIO %>% dplyr::select(3+s) %>% slice((n_sectors+1):(n_sectors+n_primIn)) %>% mutate_all(as.numeric) %>% replace(is.na(.), 0) %>% colSums()
  denom <- mainIO %>% dplyr::select(3+s) %>% mutate_all(as.numeric) %>% replace(is.na(.), 0) %>% colSums()
  
  gdp_coef <- eval(parse(text=paste0("gdp_coef %>% mutate(c", s, " = (demon/denom))")))
  # integration to blanko
}
gdp_coef <- gdp_coef %>% dplyr::select(2:ncol(.)) %>% as.matrix()

# test multiplication
gdp_perSec <- as.numeric(gdp_coef) * as.numeric(io_CA16$X)
