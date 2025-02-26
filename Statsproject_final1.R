#Code for Stats project on factors behind inequality

###########################################################################################

library(ggplot2)
library(dplyr)


#download the data set including all countries
combined_last_10 = read.csv(file.choose())
attach(combined_last_10)

#filter out to leave only countries in Europe 
europe_data <- subset(combined_last_10, continent == "Europe")
attach(europe_data)

any(europe_data == 0) #check for missing values (returned FALSE) 


#PRELIMINARY PLOTS OF THE DATA 


#gini coefficient against democracy index score
ggplot(europe_data, aes(x = demox_eiu, y = gini_index)) +
  geom_point() +
  labs(title = "Scatter Plot of Gini Index vs. Democracy Index Score in Europe",
       x = "EIU Democracy score",
       y = "Gini Index")

cor(europe_data$demox_eiu, europe_data$gini_index) #-0.341642

#gini coefficient against income per person
ggplot(europe_data, aes(x = income_per_person, y = gini_index)) +
  geom_point() +
  labs(title = "Scatter Plot of Gini Index vs Income per Person in Europe",
       x = "Income per Person",
       y = "Gini Index")
cor(europe_data$income_per_person, europe_data$gini_index) #-0.206086

#gini coefficient against investment as a percentage of gdp 
ggplot(europe_data, aes(x = invest_._gdp, y = gini_index)) +
  geom_point() +
  labs(title = "Scatter Plot of Gini Index vs. Investment as a percentage of GDP in Europe",
       x = "Investment as a percentage of GDP",
       y = "Gini Index")
cor(europe_data$invest_._gdp, europe_data$gini_index) #-0.05655719

#gini coefficient against tax as a percentage of GDP
ggplot(europe_data, aes(x = tax_._gdp, y = gini_index)) +
  geom_point() +
  labs(title = "Scatter Plot of Gini Index vs. Tax as a Percentage of GDP in Europe",
       x = "Tax as a percentage of GDP",
       y = "Gini Index")
cor(europe_data$tax_._gdp, europe_data$gini_index) #-0.2358074

#MULTILINEAR REGRESSION

regression <- lm(gini_index ~ demox_eiu + income_per_person + invest_._gdp + tax_._gdp, data = europe_data)
summary(regression)

#check for normality and homoscedasticity of the residuals (our assumptions for a linear model)

residuals <- resid(regression)

#qqplot 
qqnorm(residuals)
qqline(residuals)

#histogram
hist(residuals, main = "Histogram of Residuals", xlab = "Residuals")

#shapiro-wilk test for normality of residuals 
shapiro.test(residuals)

#Residuals vs Fitted plot (homoscedasticity check)
plot(fitted(regression), residuals, main = "Residuals vs Fitted Values", xlab = "Fitted Values", ylab = "Residuals")

bptest(regression) #Breusch-Pagan test for homoscedasticity of the residuals 


#HYPOTHESIS TEST - Difference between Europe and the rest of the world 

rest_of_world <- subset(combined_last_10, continent != "Europe")
attach(rest_of_world)

RoF_gini <- rest_of_world$gini_index
E_gini <- europe_data$gini_index

#checking normality of gini_index values 

qqnorm(RoF_gini)
qqline(RoF_gini)

qqnorm(E_gini)
qqline(E_gini)

shapiro.test(RoF_gini)
shapiro.test(E_gini)

#checking the variances

variance_RoW <- var(RoF_gini, na.rm = TRUE)
variance_E <- var(E_gini, na.rm = TRUE)

#asymptotic t-test (two-tailed)

asym_test_result <- t.test(RoF_gini, E_gini)

##############################################################################################

#See how gini index has changed over this period (For intrigue)
gini_annual_average <- aggregate(gini_index ~ year, data = europe_data, FUN = mean, na.rm = TRUE)
ggplot(gini_annual_average, aes(x = year, y = gini_index)) + 
  geom_point(color = "red", size = 3) +
  geom_line(color = "red") +
  labs(title = "Annual mean gini index in Europe (2006-2016)",
       x = "year",
       y = "mean gini index")

