
# import library
library(shinydashboard)
library(shiny)
library(dplyr)
library(readr)
library(readxl)
library(plotly)
library(shiny)
library(ggplot2)
library(dplyr)
library(shinythemes)
library(openintro)
library(plotly)
library(DT)
library(dplyr)
library(readxl)
library(leaflet)
library(reshape2)

# laod data
gdp <- read.csv("average-real-gdp-per-capita-across-countries-and-regions.csv")
fertility<- read.csv("children-born-per-woman.csv")
school <- read.csv("mean-years-of-schooling-1.csv")
world_data <- read.csv("world_country_and_usa_states_latitude_and_longitude_values.csv")
region <- read_excel("CLASS.xls")
child_mort <- read.csv("child-mortality-igme.csv")

# data wrangling
region <- region[-c(1, 2, 3,4,5), ] 
region <- region[ ,c(3,4,6,7)] 


names(gdp)[names(gdp) == "Code"] <- "ISO3"
names(fertility)[names(fertility) == "Code"] <- "ISO3"
names(school)[names(school) == "Code"] <- "ISO3"
names(child_mort)[names(child_mort) == "Code"] <- "ISO3"
names(world_data)[names(world_data) == "country"] <- "Entity"
names(region)[names(region) == "...3"] <- "Entity"
names(region)[names(region) == "...6"] <- "Region"
names(region)[names(region) == "...7"] <- "Income_Level"



gdp <- melt(gdp, id = c("Entity", "ISO3", "Year"), 
            variable.name = "Indicator", Value.name = "Value")
#gdp$Value <- as.numeric(gdp$Value)
fertility <- melt(fertility, id = c("Entity", "ISO3", "Year"), 
                  variable.name = "Period", Value.name = "Value")
school <- melt(school, id = c("Entity", "ISO3", "Year"), 
               variable.name = "Period", Value.name = "Value")


gdp["DataType"] <- rep("gdp", nrow(gdp))
fertility["DataType"] <- rep("fertility", nrow(fertility))
school["DataType"] <- rep("school", nrow(school))

dff <- merge(gdp, fertility, by=c("Entity","ISO3", "Year")) # NA's match
dff <- merge(dff, school, by=c("Entity","ISO3", "Year")) # NA's match
dff <- merge(dff, child_mort, by=c("Entity", "Year")) # NA's match


dff <- merge(dff, world_data, by="Entity") 
dff <- merge(dff, region, by="Entity") 

names(dff)[names(dff) == "value.x"] <- "GDP"
names(dff)[names(dff) == "value.y"] <- "Fertility_Rate"
names(dff)[names(dff) == "value"] <- "Mean_Schooling_Year"
names(dff)[names(dff) == "Mortality.rate..under.5..per.1.000.live.births."] <- "child_mortality_rate"


#enrich df
dff$GDP <- as.numeric(dff$GDP)
dff$GDP <- log10(dff$GDP)
dff$child_mortality_rate <- as.numeric(dff$child_mortality_rate)
dff$child_mortality_rate <- log10(dff$child_mortality_rate)
dff$fertility_rate1 <- as.numeric(dff$Fertility_Rate)
dff$fertility_rate1 <- log10(dff$Fertility_Rate)
dff$Mean_Schooling_Year1 <- as.numeric(dff$Mean_Schooling_Year)
dff$Mean_Schooling_Year1 <- log10(dff$Mean_Schooling_Year)


categories <- unique(dff$Income_Level)

#Add CSS styling to descriptions
my_css <- "

#descriptionreg {
color: darkred; font-size: 18px; font-style: bold;}

#descriptionbox {
color: darkred; font-size: 18px; font-style: bold;}

#description {
color: darkred; font-size: 18px; font-style: bold;}

#descriptiontukey {
color: darkred; font-size: 18px; font-style: bold;}
"




# ui function

ui <- dashboardPage(
  dashboardHeader(disable = T),
  dashboardSidebar(disable = T),
  dashboardBody(box(width=12,
                    tabBox(width=12,id="tabBox_next_previous",
                           
                           tabPanel("Main Page", fluidRow(column(8,includeMarkdown('user_guide.rmd')))),
                           tabPanel("Map and Regression",p(fluidRow(
                             box(width = 60, includeMarkdown('usemap.Rmd')),
                             # set title
                             titlePanel("Map and Regression Plot Interactive Visualisation"),
    
                            
                             box(title = "Variable Selection", status = "warning", solidHeader = TRUE, width = 3,height = "500px",
                                 #first input
                                 # h3("Choose the Variables"),      # Third level header: Plotting
                                 # Select variable for y-axis
                                 selectInput(inputId = "y1", 
                                             label = "Choose the colour scale variables (Y-axis):",
                                             choices = c("GDP" = "GDP", "Fertility" ="Fertility_Rate", "Mean Schooling Year" = "Mean_Schooling_Year", "Child Mortality Rate" = "child_mortality_rate"), 
                                             selected = "Fertility"),
                                 #second input(choices depend on the choice for the first input)
                                 # Select variable for x-axis
                                 selectInput(inputId = "x1", 
                                             label = "Choose the size scale variables (X-axis):",
                                             choices = c("GDP" = "GDP", "Fertility" ="Fertility_Rate", "Mean Schooling Year" = "Mean_Schooling_Year", "Child Mortality Rate" = "child_mortality_rate"), 
                                             selected = "GDP"),
                                 # Set alpha level
                                 sliderInput(inputId = "alpha1", 
                                             label = "Alpha:", 
                                             min = 0, max = 1, 
                                             value = 1),
                                 # Set point size
                                 sliderInput(inputId = "size1", 
                                             label = "Size:", 
                                             min = 0, max = 5, 
                                             value = 1),
                             ),
                             
                             # Show the output of the requested sensor 
                             box( "Interactive Map", width = 9, height = "500px",background = "teal",

                                  leafletOutput(outputId = "mymap")),
                             box(title = "Regression Plot", width = 12,background = "orange",
                                 h3("Summary Statistics and Simple Linear Regression"),    # Third level header: Regression
                                 h4("Using Scatterplot Y and X axis."),    # Fourth level header: Regression
                                 textOutput(outputId = "correlation"),
                                 htmlOutput(outputId = "avgs"),
                                 textOutput(outputId = "descriptionreg"),
                                 verbatimTextOutput(outputId = "lmoutput"),
                                 h3("Regression Plots"),    # Third level header: Regression Plots
                                 plotlyOutput(outputId = "regline"),
                                 plotOutput(outputId = "regplots")
                             )
                           ))),
                           tabPanel("Boxplot and Scatterplot",p(fluidPage(theme = shinytheme("sandstone"),
                                                                          
                                                                          # Add the CSS style to the Shiny app
                                                                          tags$style(my_css),
                                                                          
                                                                          titlePanel("Analysis of the Fertility and Income with Boxplots and Scatterplots"),
                                                                          
                                                                          # Sidebar layout with a input and output definitions 
                                                                          sidebarLayout(
                                                                            
                                                                            # Inputs
                                                                            sidebarPanel(
                                                                              
                                                                              h3("Plotting"),    # Third level header: Plotting
                                                                              # Select variable for y-axis
                                                                              selectInput(inputId = "y2", 
                                                                                          label = "Y-axis:",
                                                                                          choices = c("GDP" = "GDP", "Fertility" ="Fertility_Rate", "Mean Schooling Year" = "Mean_Schooling_Year", "Child Mortality Rate" = "child_mortality_rate"), 
                                                                                          selected = "Fertility"),
                                                                              
                                                                              # Select variable for x-axis
                                                                              selectInput(inputId = "x2", 
                                                                                          label = "Scatterplot X-axis:",
                                                                                          choices = c("GDP" = "GDP", "Fertility" ="Fertility_Rate", "Mean Schooling Year" = "Mean_Schooling_Year", "Child Mortality Rate" = "child_mortality_rate"), 
                                                                                          selected = "GDP"),
                                                                              
                                                                              # Select variable for w-axis Boxplot
                                                                              selectInput(inputId = "w", 
                                                                                          label = "Boxplot X-axis:",
                                                                                          choices = c("Region" = "Region", "Income Level" = "Income_Level"), 
                                                                                          selected = "Income Level"),
                                                                              
                                                                              # Select variable for color
                                                                              selectInput(inputId = "z", 
                                                                                          label = "Color by:",
                                                                                          choices = c("Region" = "Region","Income Level" = "Income_Level"),
                                                                                          selected = "Region"),
                                                                              
                                                                              # Add checkbox for best fit line
                                                                              checkboxInput("fit", "Add best fit line to Scatterplot", TRUE),
                                                                              
                                                                              # Set alpha level
                                                                              sliderInput(inputId = "alpha", 
                                                                                          label = "Alpha:", 
                                                                                          min = 0, max = 1, 
                                                                                          value = 1),
                                                                              
                                                                              # Set point size
                                                                              sliderInput(inputId = "size", 
                                                                                          label = "Size:", 
                                                                                          min = 0, max = 5, 
                                                                                          value = 1),
                                                                              
                                                                              # Bin width for Histogram
                                                                              sliderInput(inputId = "binsin",
                                                                                          label = "Number of bins for histogram:",
                                                                                          min = 1,
                                                                                          max = 50,
                                                                                          value = 20)),
                                                                 
                                                                            
                                                                            # Outputs
                                                                            mainPanel(
                                                                              tabsetPanel(type="tabs",
                                                                                          
                                                                                          tabPanel(title = "User Guide", includeMarkdown('use.Rmd')),
                                                                                          
                                                                                          #Tab 1 Plots
                                                                                          tabPanel(title="Plots",
                                                                                                   h3("Boxplot"),    # Third level header: Boxplot
                                                                                                   plotOutput(outputId = "boxplot"),
                                                                                                   textOutput(outputId = "descriptionbox"),
                                                                                                   br(),                 # Single line break for a little bit of visual separation
                                                                                                   h3("Scatterplot"),    # Third level header: Scatterplot
                                                                                                   plotlyOutput(outputId = "scatterplot"),
                                                                                                   textOutput(outputId = "description"),
                                                                                                   br(),                 # Single line break for a little bit of visual separation
                                                                                                   br(),                 # Single line break for a little bit of visual separation
                                                                                                   br()),                 # Single line break for a little bit of visual separation),
                                                                                          
                                                                                          #Tab 2 Histograms
                                                                                          tabPanel(title="Histograms",
                                                                                                   h3("Histogram for selected X value"),    # Third level header: Densityplot
                                                                                                   plotlyOutput(outputId = "histogramplot"),
                                                                                                   br(),                 # Single line break for a little bit of visual separation
                                                                                                   h3("Histogram for selected Y value"),    # Third level header: Scatterplot
                                                                                                   plotlyOutput(outputId = "histogramplottwo"))
                                                                              ))
                                                                          )
                           ))),
                           tabPanel("Bar Chart and Scatterplots",p(fluidPage(
                             box(width = 60, includeMarkdown('bar.Rmd')),
                             titlePanel("Bar charts and scatterplots"),
                             
                             fixedRow(
                               column(12,plotlyOutput("bar")),
                               fixedRow((uiOutput("back")),
                                        box(plotlyOutput("time")),
                                        box(plotlyOutput("time1")),
                                        box(plotlyOutput("time2")),
                                        box(plotlyOutput("time3")))
                               
                             )
                           ))),
                           tabPanel("Tab4",title="Data Table",
                                    h3("Data table"),     # Third level header: Data table
                                    h5("Click the button Show (on left) to see the data by your specified number of rows"),     # Fifth level header
                                    DT::dataTableOutput("datatable"),
                                    box(width = 60, includeMarkdown('ref.Rmd')))
                    ),
                    tags$script("
                       $('body').mouseover(function() {
                       list_tabs=[];
                       $('#tabBox_next_previous li a').each(function(){
                       list_tabs.push($(this).html())
                       });
                       Shiny.onInputChange('List_of_tab', list_tabs);})
                       "
                    )
  ),
  uiOutput("Next_Previous")
  ))




Previous_Button=tags$div(actionButton("Prev_Tab",HTML('<div class="col-sm-4"><i class="fa fa-angle-double-left fa-2x"></i></div>
                                                                  ')))
Next_Button=div(actionButton("Next_Tab",HTML('<div class="col-sm-4"><i class="fa fa-angle-double-right fa-2x"></i></div>')))


server <- function(input, output,session) {
  output$Next_Previous=renderUI({
    tab_list=input$List_of_tab[-length(input$List_of_tab)]
    nb_tab=length(tab_list)
    if (which(tab_list==input$tabBox_next_previous)==nb_tab)
      column(1,offset=1,Previous_Button)
    else if (which(tab_list==input$tabBox_next_previous)==1)
      column(1,offset = 10,Next_Button)
    else
      div(column(1,offset=1,Previous_Button),column(1,offset=8,Next_Button))
    
  })
  observeEvent(input$Prev_Tab,
               {
                 tab_list=input$List_of_tab
                 current_tab=which(tab_list==input$tabBox_next_previous)
                 updateTabsetPanel(session,"tabBox_next_previous",selected=tab_list[current_tab-1])
               }
  )
  observeEvent(input$Next_Tab,
               {
                 tab_list=input$List_of_tab
                 current_tab=which(tab_list==input$tabBox_next_previous)
                 updateTabsetPanel(session,"tabBox_next_previous",selected=tab_list[current_tab+1])
               }
  )
  current_category <- reactiveVal()
  
  # report sales by category, unless a category is chosen
  sales_data <- reactive({
    if (!length(current_category())) {
      sd <- dff %>% group_by(Income_Level) %>% summarise(me = mean(Fertility_Rate))
      return(sd)
    }
    dff %>%
      filter(Income_Level %in% current_category()) %>%
      group_by(Region) %>% summarise(me = mean(Fertility_Rate))
  })
  
  
  
  # the pie chart
  output$bar <- renderPlotly({
    d <- setNames(sales_data(), c("x", "fertility_rate1"))
    
    plot_ly(d) %>%
      add_bars(x = ~x, y = ~fertility_rate1, color = ~x) %>%
      layout(title = current_category() )
  })
  
  # sschool vs gdp
  sales_data_time <- reactive({
    if (!length(current_category())) {
      return(count(dff, Income_Level, GDP, wt = Mean_Schooling_Year))
    }
    dff %>%
      filter(Income_Level %in% current_category()) %>%
      select(Region, GDP, Mean_Schooling_Year)
    #count(Region, GDP, wt = Mean_Schooling_Year)
  })
  
  # mortality vs gdp
  mort_time <- reactive({
    if (!length(current_category())) {
      return(count(dff, Income_Level, GDP, wt = child_mortality_rate))
    }
    dff %>%
      filter(Income_Level %in% current_category()) %>%
      select(Region, GDP, child_mortality_rate)
    #count(Region, GDP, wt = child_mortality_rate)
  })
  
  #fertility vs school
  school_f <- reactive({
    if (!length(current_category())) {
      return(count(dff, Income_Level,Mean_Schooling_Year , wt = Fertility_Rate))
    }
    dff %>%
      filter(Income_Level %in% current_category()) %>%
      select(Region, Mean_Schooling_Year, Fertility_Rate)
    #count(Region, Mean_Schooling_Year, wt = Fertility_Rate)
  })
  
  #fertility vs mort
  mort_f <- reactive({
    if (!length(current_category())) {
      return(count(dff, Income_Level, child_mortality_rate, wt = Fertility_Rate))
    }
    dff %>%
      filter(Income_Level %in% current_category()) %>%
      select(Region, child_mortality_rate, Fertility_Rate)
    #count(Region, child_mortality_rate, wt = Fertility_Rate)
  })
  
  
  output$time <- renderPlotly({
    d <- setNames(sales_data_time(), c("color", "x", "y"))
    fig <- plot_ly(d, x = ~x, y = ~y, type = 'scatter', color = ~color)
    fig <- fig %>% layout(title = 'Mean Year of Schooling vs log(GDP)',
                          xaxis = list(title = 'GDP per capita ($)',
                                       zeroline = TRUE),
                          yaxis = list(title = 'Mean Year of Schooling (years)'))
    
    fig
  })
  
  output$time1 <- renderPlotly({
    d <- setNames(mort_time(), c("color", "x", "y"))
    fig1 <- plot_ly(d, x = ~x, y = ~y, type = 'scatter', color = ~color)
    fig1 <- fig1 %>% layout(title = 'Child Mortality Rate vs log(GDP)',
                            xaxis = list(title = 'GDP per capita ($)',
                                         zeroline = TRUE),
                            yaxis = list(title = 'Child Mortality Rate'))
    
    fig1
  })
  
  
  output$time2 <- renderPlotly({
    d <- setNames(school_f(), c("color", "x", "y"))
    fig2 <- plot_ly(d, x = ~x, y = ~y, type = 'scatter', color = ~color)
    fig2 <- fig2 %>% layout(title = 'Fertility Rate vs Mean Year of Schooling',
                            xaxis = list(title = 'Mean Year of Schooling (years)',
                                         zeroline = TRUE),
                            yaxis = list(title = 'Fertility Rate (Child per women)'))
    
    fig2
  })
  
  
  output$time3 <- renderPlotly({
    d <- setNames(mort_f(), c("color", "x", "y"))
    yhat <- fitted(lm(y ~ x, data = d))
    fig3 <- plot_ly(d, x = ~x, y = ~y, type = 'scatter', color = ~color)
    fig3 <- fig3 %>% add_lines(y = ~yhat)
    fig3 <- fig3 %>% layout(title = 'Fertility Rate vs Child Mortality Rate',
                            xaxis = list(title = 'Child Mortality Rate (Child death per 1000 birth)',
                                         zeroline = TRUE),
                            yaxis = list(title = 'Fertility Rate (Child per women)'))
    
    fig3
  })
  
  
  # update the current category when appropriate
  observe({
    cd <- event_data("plotly_click")$x
    if (isTRUE(cd %in% categories)) current_category(cd)
  })
  
  # populate back button if category is chosen
  output$back <- renderUI({
    if (length(current_category())) 
      actionButton("clear", "Back", icon("chevron-left"))
  })
  
  # clear the chosen category on back button press
  observeEvent(input$clear, current_category(NULL))
  
  marker_scale <- 1.5
  
  #define the color pallate for the magnitidue of the earthquake
  pal <- colorNumeric(
    palette = "YlGnBu",
    domain = dff$Fertility_Rate)
  
  output$mymap <- renderLeaflet({
    
    leaflet(data = dff) %>% 
      addTiles()%>%
      addCircleMarkers(
        lng = ~longitude, lat = ~latitude,
        radius = ~ dff[, input$x1]*marker_scale,
        color  = ~pal(dff[, input$y1]),
        stroke = FALSE, fillOpacity = 0.5,
        label = ~Fertility_Rate)  %>%
      addLegend(position = "bottomright", pal = pal, values = dff$Fertility_Rate,
                title = "Fertility Rate",
                opacity = 1)
  })
  # Create text output stating the correlation between the two ploted 
  output$correlation <- renderText({
    r <- round(cor(dff[, input$x1], dff[, input$y1], use = "pairwise"), 3)
    paste0("Correlation between ",input$x1, " and ", input$y1, " = ", r, ".")
  })
  
  # Calculate averages
  output$avgs <- renderUI({
    avg_x <- dff %>% pull(input$x1) %>% mean() %>% round(2)
    avg_y <- dff %>% pull(input$y1) %>% mean() %>% round(2)
    HTML(
      paste("Average", input$x1, "=", avg_x),
      "<br/>",
      paste("Average", input$y1, "=", avg_y)
    )
  })
  
  # Create descriptive text
  output$descriptionreg <- renderText({
    paste0("The regression below is between the dependent variable ", 
           input$y1, " and the independent variable ", input$x1, "")
  })  
  
  # Create regression output
  output$lmoutput <- renderPrint({
    x <- dff %>% pull(input$x1)
    y <- dff %>% pull(input$y1)
    print(summary(lm(y ~ x, data = dff)), digits = 3, signif.stars = FALSE)
  })
  
  # Create regression line
  output$regline <- renderPlotly({
    ggplotly({
      ggplot(data = dff, aes_string(x = input$x1, y = input$y1)) +
        geom_point(alpha = input$alpha1, size1 = input$size, color="red")+
        geom_smooth(method='lm')+theme_minimal()
    })
  })
  
  # Create regression plots
  output$regplots <- renderPlot({
    x <- dff %>% pull(input$x1)
    y <- dff %>% pull(input$y1)
    par(mfrow=c(2,2))
    plot(lm(y ~ x, data = dff))
    
  })
  
  
  # Create boxplot object the plotOutput function is expecting
  output$boxplot <- renderPlot({
    ggplot(data = dff, aes_string(x = input$w, y = input$y2, color=input$z)) +
      geom_boxplot(fill="peachpuff")+theme_minimal()
  })
  
  # Create descriptive text
  output$descriptionbox <- renderText({
    paste0("The plot above visualizes the relationship between ", 
           input$w, " and ", input$y2, ", conditional on ", input$z, ".")
  })
  
  # Create scatterplot object the plotlyOutput function is expecting
  output$scatterplot <- renderPlotly({
    ggplotly({
      p <- ggplot(data = dff, aes_string(x = input$x2, y = input$y2, color=input$z)) +
        geom_point(alpha = input$alpha, size = input$size)+theme_minimal()
      
      #if check box selected plot best fit line
      if (input$fit) {
        p <- p + geom_smooth(method = "lm")
      }
      p
      
    })
  })
  
  # Create descriptive text
  output$description <- renderText({
    paste0("The plot above visualizes the relationship between ", 
           input$x2, " and ", input$y2, ", conditional on ", input$z, ".")
  })
  
  # Create histogram
  output$histogramplot <- renderPlotly({
    ggplotly({
      ggplot(data = dff, aes_string(x = input$x2)) +
        geom_histogram(bins=input$binsin, color="black", fill="seagreen1")+theme_minimal()
    })
  })
  
  # Create histogram2
  output$histogramplottwo <- renderPlotly({
    ggplotly({
      ggplot(data = dff, aes_string(x = input$y2)) +
        geom_histogram(bins=input$binsin, color="black", fill="plum1")+theme_minimal()
    }) 
  })
  
  
  # Output data table
  output$datatable <- DT::renderDataTable({
    dff
    
  })
  
  
}





shinyApp(ui, server)