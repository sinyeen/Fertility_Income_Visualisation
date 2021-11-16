# R-shinny Visualisation - Link between Fertility Rate and Income
## Introduction

This shiny application is designed to interactively visualise the relationship between income and fertility based on the collected data which are wrangled and presented in the `Data Table` Tab. The main question for the visualization project is “Why is fertility rate higher in poor countries?”, and the sub-questions of it are “How education, child mortality rate, and social security system affect the fertility rates?” and “How gross domestic product (GDP) plays a role in the distribution of these three factors?” 

<br>

## Navigation - Six Interfaces

1. Main page: The main page provide introduction of the application, the source of data used, application usage for each design, and shiny package used for the application. 

2. User guide: This section contains instructions for viewing and exploring the narrative visualisaiton.

3. Design 1: Contains a map and a regression plot with statistical summary of the plot.

4. Design 2: Contains Boxplots, two histograms and  a scatterplot with bestfit line.

5. Design 3: Bar charts and four scatterplots

6. Data Table: Wrangled and cleaned dataset used in the application.

<br>

## Data
Data Wrangling and data cleansing are carried out to clean, restructure and enrich the raw data into one format that is suitable for data analysis. The final dataset is presented in the `Data Table` Tab. The data used by this shiny application are:

**Dataset 1:** GDP per capita across regions 1960 – 2019. It is a tabular data containing 265  rows x 64 column. [Link](https://data.worldbank.org/indicator/NY.GDP.MKTP.CD)

**Dataset 2:** Fertility rates (Total, births per women) across regions 1960 – 2019. It is a tabular data that contains 265 rows x 64 columns. [Link](https://data.worldbank.org/indicator/SP.DYN.TFRT.IN)

**Dataset 3:** National average learning outcomes across regions 1700 – 2015. Is is a tabular data that contains 20251 rows x 6 columns. [Link](https://ourworldindata.org/grapher/learning-outcomes-1985-vs-2015)

**Dataset 4:** Mean years of schooling across regions 1870 – 2017. It is a tabular data that contains 7764 rows x 4 columns. [Link](https://ourworldindata.org/grapher/learning-outcomes-1985-vs-2015)

**Dataset 5:** Infant mortality rates cross the globe (total, deaths/1000 live births) 1960 – 2019. It is a tabular data containing 264  rows x 64 columns. [Link](https://data.worldbank.org/indicator/SP.DYN.IMRT.IN)

<br>

## Application usage
As mentioned above, the shiny application consists of 3 main interactive designs. All of the combinations are able to provide a solution for all questions. Each combination is able to present the detailed relationships between the education and child mortality rate with the GDP and fertility rate.

<br>

### Design 1: Map and regression plot
**Map** 
The map provides a clear display of the selected variables in each country. The different in the values of the variables can be differentiated with the colour gradient and the size of the circles. The darker and larger of the colour and circle size respective, the larger the value of the selected variables. 

**Regression plot**
The regression plot and the summary statistics can indicate how correlated are the selected variables. The plot provides an overall display a general trend that gives a clear idea of how education and child mortality rate are effected by the GDP and how these two variables affect the fertility rate, and their corresponding correlation.

### Design 2: Boxplots, histograms and scatterplot

**Boxplots** provide a good way to view the values of each variable by different categorical variables. For example, if the X-axis of the boxplot is chosen as “Income Levels”, the distribution of the values of the selected variables (y-axis) can be compared with different income groups, if the X-axis of the boxplot is chosen as “Region”, the distribution of the values of the selected variables (y-axis) can be compared with different regions of the world. 

**Scatterplot** can show the relationship between different numerical variables and see how each variable affect one another. By grouping the categorical variables in different colours, the trend of different groups (i.e., regions and income levels) can be easily compared. ‘

**Histograms** show the distribution of the selected variables for the scatterplot. Although histograms are not able to show the relationship between the variable, it is good to see the general distribution of the selected variables for the scatterplot. Also, by looking at the mode of the histograms, the user know the most count of the value of the selected variables.

### Design 3: Bar charts and scatterplots

**Bar Chart** can provide an overall comparison on the fertility rate with different income group and regions within specific income group. It is a two levels bar chart that enable user to see how the fertility rate of different country regions from different income group differ from each other. For example, if the user select the bar of "Low income", some of the trend such as Mean Schooling Year vs log(GDP) will not show a correlated trend due to the extreme and low variation of values. "Lower middle income" and "Upper middle income" on the other hand will give a better closed to linear trend. 

**Scatterplots** combine with the drill down function of bar chart to present the general trend of each variable in different income group and regions within specific income group. From the plots, user is able to indicate how fertility rate is affected by the mean schooling year and mortality rate, and how mean schooling year and mortality rate are affected by the GDP. 

<br>

## Package dependencies & credits

This application depends on R-package functions mainly leaflet, ggplot2, and Shiny.  

### Package dependencies:  
```
shinydashboard
shiny
dplyr
readr
readxl
plotly
shiny
ggplot2
dplyr
shinythemes
openintro
plotly
DT
dplyr
readxl
leaflet
```
