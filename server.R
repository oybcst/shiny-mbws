#Mobile Bay Watershed: Modeled vs Measured
#for NOAA RESTORE, award NA19NOS4510194
#R Shiny App: L.L. Lowe, 2023
#Outputs from SWAT and by Henrique

#server.R makes calculations based on values from the user interface
#The dashboard version of Shiny
library(shinydashboard)
#To filter dataframes
library(dplyr)

#Sets output based on input from ui
function(input, output, session) {
  
  #---Initializations-----
  
  #Start an empty plot window with a 'click me' message
  output$timeplot <- renderPlot({
    plot(1,type="n",xlab="",ylab="",xaxt="n",yaxt="n")
    mtext("Click a station to start a plot.",side=3,line=-4,cex=1.5,col="#006CD1")
   })
  
  #Start the map
  output$map <- renderLeaflet({
                 leaflet()  %>%
                 addTiles() %>%
                 setView(lng = -87.550548, lat = 31.61515849, zoom = 6)
    })
  
  #---Observations----
  
  #Watch for changes in Variable and Color By and redraw the map
  observe({

    #Redraw the map
    leafletProxy("map", data = mb_stations) %>%
          clearShapes() %>%
          clearControls() %>%
          addMarkers(~Lon, ~Lat, label=~Station,layerId=~id, group="Stations",
                        popup = ~Station)
    })

  #If the map is clicked, make a plot
  observe({
        event <- input$map_marker_click
        #If nothing is clicked, do nothing.
        if (is.null(event)) return()
        #Event id is a index that defines data and station name
        isolate({GetPlot(event$id)})
    })

  #If the map is clicked, display Lat/Lon for location
  observe({
        #Event id is a index that defines data and station name
        event <- input$map_marker_click
        isolate({
             #GetIndicies returns lat/lon
             gid <- GetIndicies(event$id)
             content <- as.character(HTML(sprintf("Lat = %01.2f Lon = %01.2f",gid$lat,gid$lon)))
           })
         if (is.null(event)) content <- "None Selected"
         #Display the location's lat/lon
         output$plotwin <- renderUI({HTML(content)})
      return()
    })#End observe

  
  #---Functions-------
  
  #Function to get lat/lon to display on dashboard  
  GetIndicies <- function(id) { 
    whichlon <- mb_stations$Lon[id]
    whichlat <- mb_stations$Lat[id]
    which <- list("lon"=whichlon,"lat"=whichlat)
    return(which)
  }      
  
  #Function to make the plot 
  GetPlot <- function(inode) { 
    #The Plot!
    output$timeplot <- renderPlot({
      #For the chosen variable, define data and plot limits
      if(input$var == "Flow"){
         df<- mb_model[[inode]]$Flow
         #Filter based on time slider
         df <- df %>% filter(Date >=input$timeRange[1] & Date <=input$timeRange[2])
         #Define 'Time'
         Time <- df$Date
         Surf <- df$Simulated
         Bot  <- df$Observed
         mainlabel=paste("Flow - ",mb_stations$Station[inode]) #stn is station name
         ylabel = "Flow"
         msurf = "Simulated Flow"
         mbot = "Observed Flow"
      }else if(input$var == "NO3") {
        df<- mb_model[[inode]]$NO3
        #Filter based on time slider
        df <- df %>% filter(Date >=input$timeRange[1] & Date <=input$timeRange[2])
        #Define 'Time'
        Time <- df$Date
        Surf <- df$Simulated
        Bot  <- df$Observed
        mainlabel=paste("NO3 - ",mb_stations$Station[inode]) #stn is station name
        ylabel = "NO3"
        msurf = "Simulated NO3"
        mbot = "Observed NO3"
      }else if(input$var == "PO4"){
        df<- mb_model[[inode]]$PO4
        #Filter based on time slider
        df <- df %>% filter(Date >=input$timeRange[1] & Date <=input$timeRange[2])
        #Define 'Time'
        Time <- df$Date
        Surf <- df$Simulated
        Bot  <- df$Observed
        mainlabel=paste("PO4 - ",mb_stations$Station[inode]) #stn is station name
        ylabel = "PO4"
        msurf = "Simulated PO4"
        mbot = "Observed PO4"
      }else if(input$var == "Sed"){
        df<- mb_model[[inode]]$Sed
        #Filter based on time slider
        df <- df %>% filter(Date >=input$timeRange[1] & Date <=input$timeRange[2])
        #Define 'Time'
        Time <- df$Date
        Surf <- df$Simulated
        Bot  <- df$Observed
        mainlabel=paste("Sed - ",mb_stations$Station[inode]) #stn is station name
        ylabel = "Sed"
        msurf = "Simulated Sed"
        mbot = "Observed Sed"
      }
      #Hex codes for surface and bottom lines and text
      colsurf <- "#006CD1"    #Blue
      colbot <- "#994F00"     #Brown
      
      #Find Surface min,max,mean and format label
      is_min <- format(min(Surf),digits=3)
      is_max <- format(max(Surf),digits=3)
      is_mean <- format(mean(Surf),digits=3)
      surf_label <- paste("Simulated: min=",is_min,"mean=",is_mean,"max=",is_max)
      #Find Bottom min,max,mean and format label
      ib_min <- format(min(Bot),digits=3)
      ib_max <- format(max(Bot),digits=3)
      ib_mean <- format(mean(Bot),digits=3)
      bot_label <- paste("Observed:  min=",ib_min,"mean=",ib_mean,"max=",ib_max)
      #Ylimits for plot
        ymi <- min(min(Surf),min(Bot))
        yma <- max(max(Surf),max(Bot))
    
      #Plot timeseries for surface   
      plot(Time,Surf,main=mainlabel,ylab=ylabel,cex=0.3,type="l",
            col=colsurf,bg=colsurf,ylim = c(ymi,yma),xlabel="")
      #Add timeseries for bottom
      points(Time,Bot,pch=20,cex=0.3,col=colbot,bg=colbot)
      #Format time for x-axis
      axis.Date(1, Time,format="%b %d")
      #Add additional info as text
      mtext(msurf, side=3, line=1, col=colsurf, cex=1, adj=0)
      mtext(mbot, side=3, line=1, col=colbot, cex=1, adj=1)
      mtext(surf_label, side=1, line=3, col=colsurf, cex=1, adj=0)
      mtext(bot_label, side=1, line=4, col=colbot, cex=1, adj=0)
    }) #End of 'render plot'
  } #End function 'GetPlot'
  
}
