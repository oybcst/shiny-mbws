#Mobile Bay Watershed: Modeled vs Measured
#for NOAA RESTORE, award NA19NOS4510194
#Initial R Shiny App: L.L. Lowe, 2023
#Outputs from SWAT and by Henrique

#ui.R is User Interface
#Libraries:
#The dashboard version of Shiny
library(shinydashboard)
#Leaflet is for the interactive map
library(leaflet)
#The error messages are usually due to time zone warnings.
options( warn = -1 )


#Begin entire displayed webpage
dashboardPage(
  
  #Header is title of the page
  dashboardHeader(title = "Mobile Bay Watershed"),   

  #A sidebar is default, need to disable for single page
  dashboardSidebar(disable = TRUE),
  
  #The Dashboard is contained in the Page
  dashboardBody(
    #Makes the map and plot take 65% and 50% vertical height of browser window
    tags$style(type = "text/css", "#map {height: calc(40vh) !important;}"),
    tags$style(type = "text/css", "#timeplot {height: calc(40vh) !important;}"),
    
    #Main row - entire window
    fluidRow(
      box(width=12,solidHeader=TRUE,status="primary",plotOutput("timeplot"))
    ),
    #Next row - map, variable, location, and slider
    fluidRow(
      column(width=4,
        box(width=NULL, solidHeader=TRUE,status="primary",
        leafletOutput("map"))),
          #Add the slider, modify times as needed
      #Choose the variable
      column(width=2,align="center",
             radioButtons("var", "Variable",
                          choices = list("Flow" = "Flow", "NO3" = "NO3", "PO4" = "PO4", "Sed" = "Sed"),
                          selected = "Flow")),
          column(width=6,align="center",
                sliderInput("timeRange", label = "Time range", timeFormat="%F", 
                              min = as.POSIXct("1982-01-01",tz = 'UTC'),
                              max = as.POSIXct("2023-12-2",tz = 'UTC'),
                              value = c(as.POSIXct("1982-01-01",tz = 'UTC'),
                                        as.POSIXct("2023-12-2",tz = 'UTC'))))
     #close second row in left column, close left column, close first row
         )
    


  )#-- End dashboard Body
)#-- End dashboard Page