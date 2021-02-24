# Analysis for "The COVID-19 Pandemic and the $16 Trillion Virus" by Cutler and Summers
# @author: petezh

#######
# SETUP
#######

# loading required libraries
list.of.packages <- c("ggplot2", "tidyverse", "kableExtra", "here")

new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos= "https://cran.r-project.org/")

lapply(list.of.packages, library, character.only = TRUE)

setwd(here())

#########
# SOURCES
#########

# load GDP projections
GDP_so <- read.csv("data/analysis/projections.csv")

# load COVID deaths data
deaths_so <- read.csv("data/analysis/covid_deaths.csv")
deaths_so$End.Date <- as.Date(deaths_so$End.Date, "%m/%d/%Y")
deaths_so <- subset(deaths_so, End.Date <= as.Date("2020-09-25"))

# load COVID impairment data
impairments_so <- read.csv("data/analysis/impairments.csv")

# load COVID deaths data
mentalhealth_so <- read.csv("data/analysis/mental_health.csv")

# based on estimates
VSL_so <- 7000000
VLY_so <- 100000

# based on research/estimates
currentdeaths_so <- 190076
weeklydeaths_so <- 5000
excessdeaths_so <- 1.38888

# based on estimate
futureratio_so <- 625000/250000

# based on research/estimates
complications_so <- 1/3
impQOLloss_so <- 0.35
mhQOLloss_so <- 0.2

# based on data
totalpop_so = 328200000
adultpop_so = 263000000

#########
# FIGURES
#########

# open GPD fig output
png("results/gdp_fig.png")

# create graph
GDP_fig <- ggplot(data = GDP_so, aes(x = Year)) + 
  geom_line(aes(y = Pre.Covid), color = "blue") + 
  geom_line(aes(y = Post.Covid), color="orangered") +
  labs(y = "Real GDP in $ Billions",
       x = "Year" ,
       title = "Change in GDP",
       subtitle = "January 2020 and July 2020 GBO Projections"
  ) 
GDP_fig
dev.off()

# open deaths fig output
png("results/deaths_fig.png")

# create graph
deaths_fig <- ggplot(data = deaths_so, aes(x = End.Date, y = COVID.19.Deaths)) + 
  geom_line(color='blue') +
  labs(y = "Weekly COVID-19 Deaths",
       x = "Month" ,
       title = "Number of COVID-19 Deaths",
       subtitle = "Based on estimates from the CDC"
  ) 
deaths_fig
dev.off()

##################
# POLICY ESTIMATES
##################

# GDP estimate
GDP_main_pe <- sum(GDP_so$Pre.Covid-GDP_so$Post.Covid)*1000000000

# mortality estimate
deaths_main_pe <- (currentdeaths_so + 52*weeklydeaths_so) * excessdeaths_so * VSL_so

# impairments estimate
impairments_main_pe <- sum(impairments_so$Impairments) * futureratio_so * complications_so * impQOLloss_so * VSL_so 

# mental health estimate
anx_dep_2019 <- mentalhealth_so[which(mentalhealth_so$Indicator == 'Symptoms of anxiety disorder and/or depressive disorder' & mentalhealth_so$Time.Period == '2019'),]$Value
anx_dep_2020 <- mentalhealth_so[which(mentalhealth_so$Indicator == 'Symptoms of Anxiety Disorder or Depressive Disorder' & mentalhealth_so$Time.Period == 'July 16 - July 21'),]$Value
mentalhealth_main_pe <- (anx_dep_2020 - anx_dep_2019) / 100 * adultpop_so * mhQOLloss_so * VLY_so

# sum
total_main_pe <- GDP_main_pe + deaths_main_pe + impairments_main_pe + mentalhealth_main_pe

###########
# ALT SPECS
###########

# 1. Change Impairment Ratio

# use death data to calculate ratio
futureratio_alt1 = (52*weeklydeaths_so+currentdeaths_so)/currentdeaths_so
# recalculate impairments estimate
impairments_alt1_pe <- sum(impairments_so$Impairments) * futureratio_alt1 * complications_so * impQOLloss_so * VSL_so 
# recalculate total
total_alt1_pe = GDP_main_pe + deaths_main_pe + impairments_alt1_pe + mentalhealth_main_pe

# 2. Update Deaths Data

# calculate current deaths from new data
currentdeaths_alt2 = sum(deaths_so$COVID.19.Deaths)
# update impairments future ratio
futureratio_alt2 = (52*weeklydeaths_so+currentdeaths_alt2)/currentdeaths_alt2
# recalculate death and impairment estimates
deaths_alt2_pe <- (currentdeaths_alt_so + 52*weeklydeaths_so) * excessdeaths_so * VSL_so
impairments_alt2_pe <- sum(impairments_so$Impairments) * futureratio_alt2 * complications_so * impQOLloss_so * VSL_so 
# recalculate total
total_alt2_pe = GDP_main_pe + deaths_alt2_pe + impairments_alt2_pe + mentalhealth_main_pe

# 3. Change Adult Pop

# use new adult pop estimate
adultpop_alt3 = 250563000
# recalculate mental health estimate
mentalhealth_alt3_pe <- (anx_dep_2020 - anx_dep_2019) / 100 * adultpop_alt3 * mhQOLloss_so * VLY_so
total_alt3_pe = GDP_main_pe + deaths_main_pe + impairments_main_pe + mentalhealth_alt3_pe

########
# TABLE
########

# calculate "family of four" ratios
householdfactor = 4/totalpop_so
household_main_pe = total_main_pe * householdfactor
household_alt1_pe = total_alt1_pe * householdfactor
household_alt2_pe = total_alt2_pe * householdfactor
household_alt3_pe = total_alt3_pe * householdfactor

# calculate "percent of GDP" ratios
annualGDP = GDP_so$Post.Covid[2]*1000000000
GDPprop_main_pe = total_main_pe / annualGDP
GDPprop_alt1_pe = total_alt1_pe / annualGDP
GDPprop_alt2_pe = total_alt2_pe / annualGDP
GDPprop_alt3_pe = total_alt3_pe / annualGDP

# construct results table
results_table <- data.frame("GDP" =   c(GDP_main_pe, GDP_main_pe, GDP_main_pe, GDP_main_pe),
                            "deaths" =  c(deaths_main_pe, deaths_main_pe, deaths_alt2_pe, deaths_main_pe),
                            "impairments" = c(impairments_main_pe, impairments_alt1_pe, impairments_alt2_pe, impairments_main_pe),
                            "mentalhealth" = c(mentalhealth_main_pe, mentalhealth_main_pe, mentalhealth_main_pe, mentalhealth_alt3_pe),
                            "total" = c(total_main_pe, total_alt1_pe, total_alt2_pe, total_alt3_pe),
                            "household" = c(household_main_pe, household_alt1_pe, household_alt2_pe, household_alt3_pe),
                            "propGDP" = c(GDPprop_main_pe, GDPprop_alt1_pe, GDPprop_alt2_pe, GDPprop_alt3_pe),
                            row.names = c("Main","Alternative 1","Alternative 2","Alternative 3"))

# scale down for readability
results_table$GDP = results_table$GDP/1000000000
results_table$deaths = results_table$deaths/1000000000
results_table$impairments = results_table$impairments/1000000000
results_table$mentalhealth = results_table$mentalhealth/1000000000
results_table$total = results_table$total/1000000000


# build table
results_kable <- kable(results_table,
      caption = "Estimated Economic Cost of the COVID-19 Crisis",
      digits=2,
      col.names = c("Lost GDP",
                    "Premature death",
                    "Long term health impairment",
                    "Mental health impairment",
                    "Total",
                    "Total for a family of 4",
                    "Percent of annual GDP")) %>%
  kable_styling("striped", full_width = F)
# save table
save_kable(results_kable,
           "results/results_fig.png")

