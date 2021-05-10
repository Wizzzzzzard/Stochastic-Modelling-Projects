library(bnlearn)
library(tidyverse)
library(scales)
library(patchwork)
library(leaps)
library(gridExtra)

setwd("C:/Users/elija/OneDrive - University of Strathclyde/Semester 2/Stochastic Modelling/Bayesian Belief Network Modelling/Assignment" );

df <- read_csv(file = "MS986 Assignment 2 BBN Modelling Data Set v2.csv")

# print first rows of the data
head(df)

# print column names
colnames(df)

# create table for Water Treatment Works and Service Reservoir
wtw = subset(df, select = c(wtw_coliform, wtw_colony22, wtw_colony37, wtw_ecoli, wtw_free.chlorine, wtw_total.chlorine, wtw_sourcetype,
                            wtw_chloramination, wtw_floc, wtw_floctype, wtw_sw, wtw_hypo, wtw_mains.power, wtw_raw.water.storage,
                            wtw_raw.water.pre.treatment, wtw_membrane, wtw_clarification, wtw_flotation, wtw_rgf, 
                            wtw_pressure.filters, wtw_slow.sand.filters, wtw_gac.filters, wtw_filters, wtw_ph.adjustment, wtw_phosphate.dosing, 
                            wtw_ozonation, wtw_manganese.removal))

srs = subset(df, select = -c(wtw_coliform, wtw_colony22, wtw_colony37, wtw_ecoli, wtw_free.chlorine, wtw_total.chlorine, wtw_sourcetype,
                             wtw_chloramination, wtw_floc, wtw_floctype, wtw_sw, wtw_hypo, wtw_mains.power, wtw_raw.water.storage,
                             wtw_raw.water.pre.treatment, wtw_membrane, wtw_clarification, wtw_flotation, wtw_rgf, 
                             wtw_pressure.filters, wtw_slow.sand.filters, wtw_gac.filters, wtw_filters, wtw_ph.adjustment, wtw_phosphate.dosing, 
                             wtw_ozonation, wtw_manganese.removal))

# drop wtw_mains.power as all values are 1, hence no impact on other variables
# drop srs_fails_in_previous_years
# drop srs_sample.month

df <- subset(df, select = -c(wtw_mains.power, srs_fails_in_previous_year, srs_sample.month))

# set categorical variables as factors


discrete_df <- read_csv(file = "MS986 Assignment 2 BBN Modelling Data Set v2 (Discretised).csv")
discrete_df = lapply(discrete_df, as.factor)

continuous_df = subset(df, select = -c(srs_region, srs_tank.construction, srs_secondary.disinfection.delivery, wtw_sourcetype))

# check for N/A or Inf values
apply(df, 2, function(x) any(is.na(x)))
apply(discrete_df, 2, function(x) any(is.na(x)))
apply(continuous_df, 2, function(x) any(is.na(x)))

# Lots of N/A values so will omit in order to prevent any errors cropping up later
df = na.omit(df)
discrete_df = na.omit(discrete_df)
continuous_df = na.omit(continuous_df)

# Use leaps library to compare models with different variable combinations
#df_0 <- lm(srs_pcv.failure ~ 1, data=df)
#step(df_0, test = "F",
#     scope = ~ srs_coliform + srs_colony22 + srs_colony37 + srs_ecoli +
#       srs_free.chlorine + srs_icc + srs_tcc + srs_total.chlorine + srs_voloutcap + srs_region + srs_design.volumem3 +
#       srs_tank.construction + srs_total.risk.factor + srs_average.daily.flow + srs_current.storage.retention + srs_individual.sr.risk.factor +
#       srs_sr.chain.risk.factor + srs_fails_in_any_previous_year + srs_bacto.fails.risk.factor + srs_condition.risk.factor +
#       srs_secondary.disinfection.delivery + srs_secondary.disinfection.risk + srs_aow + srs_ooa + srs_stor_vol + srs_stor +
#       wtw_coliform + wtw_colony22 + wtw_colony37 + wtw_ecoli + wtw_free.chlorine + wtw_total.chlorine + wtw_sourcetype +
#       wtw_chloramination + wtw_floc + wtw_floctype + wtw_sw + wtw_hypo + wtw_raw.water.storage + wtw_raw.water.pre.treatment +
#       wtw_membrane + wtw_clarification + wtw_flotation + wtw_rgf + wtw_pressure.filters + wtw_slow.sand.filters + wtw_gac.filters +
#       wtw_filters + wtw_ph.adjustment + wtw_phosphate.dosing + wtw_ozonation + wtw_manganese.removal, direction="both")

# This suggests that the final model should contain only the following variables

df_final  <- read_csv(file = "Variable Selected.csv")

df_final <- subset(df_final, select = -c(X34, srs_ecoli))

# Prepare data for bnlearn

# integer type is not supported by bnlearn: change integer type to numeric
df_final[sapply(df_final, is.numeric)] <- lapply(df_final[sapply(df_final, is.numeric)], as.factor)

df_final[sapply(df_final, is.character)] <- lapply(df_final[sapply(df_final, is.character)], as.factor)

df_final = na.omit(df_final)

data<- as.data.frame(df_final)
hc(data)
plot(hc(data))


str(data)

# Structure learning algorithms
## Constraint-based algorithm

#use Grow-Shrink algorithm to create Bayesian network
gs.bn<-cextend(gs(df_final))
gs.bn
plot(gs.bn,radius=290,arrow=30)

# Incremental Association (iamb)
iamb.bn<-cextend(iamb(df_final))
iamb.bn
plot(iamb.bn,radius=270,arrow=30)

# Fast Incremental Association (fast.iamb)
fast.iamb.bn<-cextend(fast.iamb(df_final))
fast.iamb.bn
plot(fast.iamb.bn,radius=270,arrow=30)

# Interleaved Incremental Association (inter.iamb)
inter.iamb.bn<-cextend(inter.iamb(df_final))
inter.iamb.bn
plot(inter.iamb.bn,radius=270,arrow=30)

# Max-Min Parents and Children (mmpc)
mmpc.bn<-cextend(mmpc(df_final))
mmpc.bn
plot(mmpc.bn,radius=270,arrow=30)
              
## Score Based algorithm
# hill-climbing algorithm
hc.bn<-cextend(hc(data))
hc.bn
plot(hc.bn,radius=270,arrow=30)
score(hc.bn,data=data,type="bic")


# tabu search algorithm
tabu.bn<-tabu(data)
tabu.bn
plot(tabu.bn,radius=270,arrow=30)
score(tabu.bn,data=data,type="bic")


hc.fit<-bn.fit(hc.bn,data=data)
hc.fit$srs_pcv.failure

tabu.fit<-bn.fit(tabu.bn,data=data)
tabu.fit$srs_pcv.failure
 
# Cross Validation to select best algorithm
set.seed(1) # reproducible CV
# run hc search
hc_cv <- bn.cv(data, "hc",
               algorithm.args=list(score="bic"),
               loss = "logl",
               k=10, runs=10)

set.seed(1)
tabu_cv <- bn.cv(data, "tabu",
               algorithm.args=list(score="bic"),
               loss = "logl",
               k=10, runs=10)

set.seed(1)
gs_cv <- bn.cv(data, "gs",
               algorithm.args=list(test="mi"),
               loss = "logl",
               k=10, runs=10)

set.seed(1)
iamb_cv <- bn.cv(data, "iamb",
               algorithm.args=list(test="mi"),
               loss = "logl",
               k=10, runs=10)

set.seed(1)
mmpc_cv <- bn.cv(data, "mmpc",
                 algorithm.args=list(score="bic"),
                 loss = "logl",
                 k=10, runs=10)


plot(hc_cv, tabu_cv)


# hill climbing seemed to have a much lower loss than grow shrink which would suggest it's a preferable model

# for predicting srs_pcv.failure
set.seed(1)
gs_cv2 <- bn.cv(data, "hc",
                algorithm.args=list(test="mi"),
                loss = "pred-lw", loss.args = list(target = "srs_pcv.failure"),
                k=10, runs=10)

# grab one aic CV
observed <- gs_cv2[[1]][[1]][["observed"]]
predicted <- gs_cv2[[1]][[1]][["predicted"]]
table(predicted, observed)



## Parameter Learning

hc.bn<-tabu(df_final)
hc.fit<-bn.fit(hc.bn,data=df_final,method="bayes")
hc.fit$wtw_floctype
####view the parameters of the node srs_pcv.failure

bn.fit.dotplot(hc.fit$srs_aow)

## Inference

set.seed(1)
cpquery(hc.fit, event=(srs_pcv.failure == "1"), evidence=list(complexity == "1"), n=1e6)

#evidence = list(X= "yes",D ="yes"),method="lw",n=10^5)
set.seed(1)
failure.sample <- cpdist(hc.fit, nodes = "srs_pcv.failure", evidence = (wtw_floctype  == "2"), method="ls", n=10^5)
prop.table(table(failure.sample))
