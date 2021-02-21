# Analysis of COVID-19 impact, reproducing Cutler and Summers 2020
# @author: petez

library(ggplot2)

# 1. Load Datasets


setwd('C:\\Users\\thepe\\Documents\\GitHub\\acre-cutler')
# load GDP projections
GDP_projections <- read.csv("data/analysis/projections.csv")

# load COVID impairment data
crit_severe <- read.csv("data/analysis/impairments.csv")

# load COVID deaths data
covid_deaths <- read.csv("data/analysis/covid_deaths.csv")
covid_deaths$End.Date = as.Date(covid_deaths$End.Date, "%m/%d/%Y")

# load COVID deaths data
mental_health <- read.csv("data/analysis/mental_health.csv")

# 2. Set Paramters

# set VSL
VSL <- 7000000

# set value of lifeyear
VLY <- 100000

# 3. Reproduction

# 3.1. GDP Loss

# plot GDP forecasts
ggplot(data = GDP_projections, aes(x = Year)) + 
  geom_line(aes(y = Pre.Covid), color = "blue") + 
  geom_line(aes(y = Post.Covid), color="orangered") 

# calculate GDP losses, convert to billions
GDP_losses = sum(GDP_projections$Pre.Covid-GDP_projections$Post.Covid)*1000000000

# 3.2. Cost of premature mortality

# new current deaths
covid_deaths = subset(covid_deaths, End.Date <= as.Date("2020-09-25"))

# plot COVID death counts
ggplot(data = covid_deaths, aes(x = End.Date, y = COVID.19.Deaths)) + 
  geom_line(color='blue')

# 10-25-2020, 52 weeks at 5000 deaths
# obtained 201330 deaths, not 190000
current_deaths = 190076
# current_deaths = sum(covid_deaths$COVID.19.Deaths)
future_deaths =  52*5000
total_deaths = current_deaths+future_deaths

# add 40% excess deaths, 630000 not 625000
total_deaths_excess <- 1.38888*total_deaths

# convert to VTL with 7 million estimate
# obtained 4.521
value_deaths <- VSL*total_deaths_excess

# 3.3. Cost of Health Impairments

# 1.27M, not 1.2M
current_crit_severe = sum(crit_severe$Impairments)
# disagreement: using COVID current/forecast deaths, not excess
# also, strange choice - not relevant
total_crit_severe = current_crit_severe*(625000/250000)
impairments = 1/3*total_crit_severe
value_impairments = 0.35 * VSL * impairments

# 3.4. Mental Health Impairment

anx_dep_2019 = mental_health[which(mental_health$Indicator == 'Symptoms of anxiety disorder and/or depressive disorder' & mental_health$Time.Period == '2019'),]$Value
anx_dep_2020 = mental_health[which(mental_health$Indicator == 'Symptoms of Anxiety Disorder or Depressive Disorder' & mental_health$Time.Period == 'July 16 - July 21'),]$Value
anx_dep_increase = anx_dep_2020 - anx_dep_2019

# disagreement: adult population is 251M, not 266M, https://www.kff.org/other/state-indicator/distribution-by-age/

adult_pop = 263000000
new_anx_dep = anx_dep_increase/100 * adult_pop
value_mentalhealth = new_anx_dep * 0.2 * VYL

GDP_losses
value_deaths
value_impairments
value_mentalhealth

# summation
total_value = GDP_losses + value_deaths + value_impairments + value_mentalhealth
total_value

total_value/GDP_projections$Post.Covid[2]

# 4. Robustness Checks

# 4.1 Update Impairment Ratio

current_crit_severe = sum(crit_severe$Impairments)
total_crit_severe = current_crit_severe*(total_deaths/current_deaths)
impairments = 1/3*total_crit_severe
value_impairments = 0.35 * VSL * impairments

value_impairments

# 4.2 Update Current Deaths

current_deaths = 190000
future_deaths =  52*5000
total_deaths = current_deaths+future_deaths

# add 40% excess deaths, 630000 not 625000
total_deaths_excess <- 1.4*total_deaths

# convert to VTL with 7 million estimate
value_deaths <- VSL*total_deaths_excess

value_deaths

current_crit_severe = sum(crit_severe$Impairments)
total_crit_severe = current_crit_severe*(total_deaths_excess/current_deaths)
impairments = 1/3*total_crit_severe
value_impairments = 0.35 * VSL * impairments

value_impairments

# 4.3 Update Population

adult_pop = 250563000
new_anx_dep = anx_dep_increase/100 * adult_pop
value_mentalhealth = new_anx_dep * 0.2 * VYL

value_mentalhealth
