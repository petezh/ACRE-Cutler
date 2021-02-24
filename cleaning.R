# Cleaning for "The COVID-19 Pandemic and the $16 Trillion Virus" by Cutler and Summers
# @author: petezh

#######
# SETUP
#######

# loading required libraries
list.of.packages <- c("tidyverse", "readxl", "here")

new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos= "https://cran.r-project.org/")

lapply(list.of.packages, library, character.only = TRUE)

setwd(here())

######
# GDP
######

Year = c(2019:2030)

# raw jan 2020 projection
jan_df <- read_excel("data/raw/cbo-2020-01-economicprojections.xlsx", sheet = "2. Calendar Year")

# clean data
Pre.Covid <- tail(as.numeric(jan_df[12,]), 12)

# raw jun 2020 projection
jul_df <- read_excel("data/raw/cbo-2020-07-economicprojections.xlsx", sheet = "2. Calendar Year")

# clean data
Post.Covid <- tail(as.numeric(jul_df[12,]), 12)

# write to csv
write.csv(data.frame(Year, Pre.Covid, Post.Covid), "data/analysis/projections.csv", row.names=FALSE)

#############
# COVID DEATHS
#############

# raw jan 2020 projection
covid_data <- read.csv('data/raw/covid19-death-counts.csv')

# subset
clean_data <- subset(covid_data, State == 'United States' & Group == 'By Week',
                  select=c(COVID.19.Deaths, End.Date))

# write to csv
write.csv(clean_data, 'data/analysis/covid_deaths.csv', row.names=FALSE)

######
# MENTAL HEALTH
######

# read 2019 data
mhdata_2019 <- read.csv('data/raw/2019nchsmentalhealth.csv')
mhdata_2019$Time.Period = rep('2019', times=3)
# rename column
mhdata_2019 <- mhdata_2019 %>% rename(Indicator = Selected.mental.health.indicator)

# read 2020 data
mhdata_2020 <- read.csv('data/raw/2020pulsementalhealth.csv')
# subset
mhdata_2020 <- subset(mhdata_2020, Time.Period == 12 & Subgroup == 'United States',
       select=c(Time.Period.Label, Value, Low.CI, High.CI, Indicator))
# rename column
mhdata_2020 <- mhdata_2020  %>% rename(Time.Period = Time.Period.Label)

# combine and write to csv
write.csv(rbind(mhdata_2019, mhdata_2020), 'data/analysis/mental_health.csv', row.names=FALSE)

############
# IMPAIRMENTS
############

# covid deaths by age
covid_age <- read.csv('data/raw/covid_by_age.csv')

# combine <1, 1-4, and 5-14
covid_age[3,2] <- sum(covid_age[1:3, 2])
covid_age <-tail(covid_age, -2)

# covid deaths by age, updated
covid_age_new <- read.csv('data/raw/Provisional_COVID-19_Death_Counts_by_Sex__Age__and_Week.csv')

# subset to december
covid_age_new <- subset(covid_age_new, Sex == 'All Sex' & MMWR.Week == 53,
                        select=c(Age.Group, COVID.19.Deaths))

# get new counts
covid_age_new[4,2] = sum(covid_age_new[2:4, 2])
covid_age_new <- tail(covid_age_new, -3)

# rename column
covid_age_new <- covid_age_new %>% rename(New.COVID.19.Deaths = COVID.19.Deaths)

# covasim model
covasim <- read.csv('data/raw/covasim.csv')

# calculate impairment:death ratio
covasim$Ratio = (covasim$Severse.Disease + covasim$Critical.Disease)/covasim$Death - 1

# combine
impairments <- cbind(covasim, covid_age, covid_age_new)
impairments$Impairments = impairments$COVID.Deaths * impairments$Ratio
impairments$Impairments.New = impairments$New.COVID.19.Deaths * impairments$Ratio

write.csv(impairments[c('Age', 'Impairments', 'Impairments.New')], 'data/analysis/impairments.csv', row.names=FALSE)

############
# POPULATION
############

# read ACS data
ACS <- read_excel('data/raw/2019gender_table1.xlsx', sheet='Age Sex')

# sum adult population
population <- sum(as.numeric(unlist(ACS[28:31,'...2'])))
population
