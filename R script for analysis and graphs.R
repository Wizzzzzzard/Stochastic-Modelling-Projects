library(tidyverse)
library(scales)
library(gridExtra)

setwd("E:/elija/OneDrive/OneDrive - University of Strathclyde/Semester 2/Stochastic Modelling/Agent Based Modelling/Assignment/CSVs" );

x <- read_csv(file = "Wealth Model Comparison of Economy Growth Rate on Population and Class Wealth-table.csv",
              skip = 6)
y <- read_csv(file = "Wealth Model Comparison of Society with and without UBI (Effect on Population and Class Wealth)-table.csv",
              skip = 6)
z <- read_csv(file = "Wealth Model Comparison of Tax Rates on Upper Class (With and Without UBI) (Effect on Population and Class Wealth)-table.csv",
              skip = 6)

names(x)
names(y)
names(z)

x <- x %>%
  rename(run='[run number]', day='[step]', economy_growth_rate='growth-of-economy',
         max_life_expectancy='life-expectancy-max', universal_basic_income='universal-basic-income',
         percentage_LC='lower-class-population', total_population='num-of-people',
         percentage_UC='upper-class-population', UC_tax_rate='upper-class-tax-rate',
         LC_tax_rate='lower-class-tax-rate', percent_best_jobs='percent-best-jobs', 
         percentage_MC='middle-class-population', MC_tax_rate='middle-class-tax-rate',          
         rate_of_return='rate-of-return', min_life_expectancy='life-expectancy-min', 
         LC_population='count lowerclasses', MC_population='count middleclasses', 
         UC_population='count upperclasses', total_LC_wealth='sum [ wealth ] of lowerclasses', 
         total_MC_wealth='sum [ wealth ] of middleclasses', total_UC_wealth='sum [ wealth ] of upperclasses')

y <- y %>%
  rename(run='[run number]', day='[step]', economy_growth_rate='growth-of-economy',
         max_life_expectancy='life-expectancy-max', universal_basic_income='universal-basic-income',
         percentage_LC='lower-class-population', total_population='num-of-people',
         percentage_UC='upper-class-population', UC_tax_rate='upper-class-tax-rate',
         LC_tax_rate='lower-class-tax-rate', percent_best_jobs='percent-best-jobs', 
         percentage_MC='middle-class-population', MC_tax_rate='middle-class-tax-rate',          
         rate_of_return='rate-of-return', min_life_expectancy='life-expectancy-min', 
         LC_population='count lowerclasses', MC_population='count middleclasses', 
         UC_population='count upperclasses', total_LC_wealth='sum [ wealth ] of lowerclasses', 
         total_MC_wealth='sum [ wealth ] of middleclasses', total_UC_wealth='sum [ wealth ] of upperclasses')

z <- z %>%
  rename(run='[run number]', day='[step]', economy_growth_rate='growth-of-economy',
         max_life_expectancy='life-expectancy-max', universal_basic_income='universal-basic-income',
         percentage_LC='lower-class-population', total_population='num-of-people',
         percentage_UC='upper-class-population', UC_tax_rate='upper-class-tax-rate',
         LC_tax_rate='lower-class-tax-rate', percent_best_jobs='percent-best-jobs', 
         percentage_MC='middle-class-population', MC_tax_rate='middle-class-tax-rate',          
         rate_of_return='rate-of-return', min_life_expectancy='life-expectancy-min', 
         LC_population='count lowerclasses', MC_population='count middleclasses', 
         UC_population='count upperclasses', total_LC_wealth='sum [ wealth ] of lowerclasses', 
         total_MC_wealth='sum [ wealth ] of middleclasses', total_UC_wealth='sum [ wealth ] of upperclasses')

#Recall, our data is for 10 simulation replicates. Let’s create a new tibbles taking averages.

# Take average of tibble x (profit adjustment)
x_avg <- x %>% group_by(economy_growth_rate, day) %>%
  summarise(mean_LC_population = mean(LC_population),
            mean_MC_population = mean(MC_population),
            mean_UC_population = mean(UC_population),
            mean_LC_wealth = mean(total_LC_wealth),
            mean_MC_wealth = mean(total_MC_wealth),
            mean_UC_wealth = mean(total_UC_wealth))

# Take average of tibble x (profit adjustment)
y_avg <- y %>% group_by(universal_basic_income, day) %>%
  summarise(mean_LC_population = mean(LC_population),
            mean_MC_population = mean(MC_population),
            mean_UC_population = mean(UC_population),
            mean_LC_wealth = mean(total_LC_wealth),
            mean_MC_wealth = mean(total_MC_wealth),
            mean_UC_wealth = mean(total_UC_wealth))

# Take average of tibble x (profit adjustment)
z_avg <- z %>% group_by(UC_tax_rate, day) %>%
  summarise(mean_LC_population = mean(LC_population),
            mean_MC_population = mean(MC_population),
            mean_UC_population = mean(UC_population),
            mean_LC_wealth = mean(total_LC_wealth),
            mean_MC_wealth = mean(total_MC_wealth),
            mean_UC_wealth = mean(total_UC_wealth))

figx1 <- x_avg %>%
  gather(key,value, mean_LC_population, mean_MC_population, mean_UC_population) %>%
  ggplot(aes(x=day, y=value, colour=key)) +
  geom_line()   +
  scale_y_continuous(name = "Population") +
  scale_x_continuous(name = "Day") +
  facet_wrap("economy_growth_rate",scale='free') +
  theme_light() +
  theme(legend.position = "bottom", legend.title = element_blank())

figx2 <- x_avg %>%
  gather(key,value, mean_LC_wealth, mean_MC_wealth, mean_UC_wealth) %>%
  ggplot(aes(x=day, y=value, colour=key)) +
  geom_line()   +
  scale_y_continuous(name = "Wealth (£)") +
  scale_x_continuous(name = "Day") +
  facet_wrap("economy_growth_rate",scale='free') +
  theme_light() +
  theme(legend.position = "bottom", legend.title = element_blank())

figx1
figx2


figy1 <- y_avg %>%
  gather(key,value, mean_LC_population, mean_MC_population, mean_UC_population) %>%
  ggplot(aes(x=day, y=value, colour=key)) +
  geom_line()   +
  scale_y_continuous(name = "Population") +
  scale_x_continuous(name = "Day") +
  facet_wrap("universal_basic_income",scale='free') +
  theme_light() +
  theme(legend.position = "bottom", legend.title = element_blank())

figy2 <- y_avg %>%
  gather(key,value, mean_LC_wealth, mean_MC_wealth, mean_UC_wealth) %>%
  ggplot(aes(x=day, y=value, colour=key)) +
  geom_line()   +
  scale_y_continuous(name = "Wealth (£)") +
  scale_x_continuous(name = "Day") +
  facet_wrap("universal_basic_income",scale='free') +
  theme_light() +
  theme(legend.position = "top", legend.title = element_blank())

figy <- grid.arrange(figy1, figy2, nrow=2)

figz1 <- z_avg %>%
  gather(key,value, mean_LC_population, mean_MC_population, mean_UC_population) %>%
  ggplot(aes(x=day, y=value, colour=key)) +
  geom_line()   +
  scale_y_continuous(name = "Population") +
  scale_x_continuous(name = "Day") +
  facet_wrap("UC_tax_rate",scale='free') +
  theme_light() +
  theme(legend.position = "bottom", legend.title = element_blank())

figz2 <- z_avg %>%
  gather(key,value, mean_LC_wealth, mean_MC_wealth, mean_UC_wealth) %>%
  ggplot(aes(x=day, y=value, colour=key)) +
  geom_line()   +
  scale_y_continuous(name = "Wealth (£)") +
  scale_x_continuous(name = "Day") +
  facet_wrap("UC_tax_rate",scale='free') +
  theme_light() +
  theme(legend.position = "botom", legend.title = element_blank())

figz1
figz2

