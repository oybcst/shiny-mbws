#Preprocess data for R Shiny
#Need to make dataframe for station name and location info, and for the actual data

#To append dataframes to list: list.append
library(rlist)
#Read Excel files
library(readxl)

#Location of Henrique's files from Notebook
csv_dir <- "~/watershed-simulated-vs-observed"
#Location of this shiny app
shiny_dir <- "~/shiny-mbws"

# Read a CSV file that has 'Station', 'Lat', 'Lon'
#load station locations
stations <- read.csv(file.path(csv_dir,"Locations.csv"))
#For the map, Station needs to be a string
stations$Station <- paste("Station",stations$Station)
head(stations)
#Add a unique id, to match a station click with corresponding data
stations$id <- c(1:length(stations$Station))

#---- Create a list of dataframes
dfnames <- c("Date","Observed","Simulated")
#Initialize empty list of data, and empty column for names
the_data <- list()
the_names <- c()

#---Read profile data
#Flow, Flow
df <- as.data.frame(read_xlsx(file.path(csv_dir,'Simulated_Flow_USGS02428400.xlsx')))
names(df) <- dfnames
the_names <- append(the_names,"Flow")
the_data <- list.append(the_data,df)

#Nitrate, NO3
df <- as.data.frame(read_xlsx(file.path(csv_dir,'Simulated_Nitrate_Loading_USGS02428400.xlsx')))
names(df) <- dfnames
the_names <- append(the_names,"NO3")
the_data <- list.append(the_data,df)

#Phosphate, PO4
df <- as.data.frame(read_xlsx(file.path(csv_dir,'Simulated_Phosphate_Loading_USGS02428400.xlsx')))
names(df) <- dfnames
the_names <- append(the_names,"PO4")
the_data <- list.append(the_data,df)

#Sediments, Sed
df <- as.data.frame(read_xlsx(file.path(csv_dir,'Simulated_Sediments_Loading_USGS02428400.xlsx')))
names(df) <- dfnames
the_names <- append(the_names,"Sed")
the_data <- list.append(the_data,df)

#Name list elements
names(the_data) <- the_names


#The name is so you can reference the list easier,e.g.
#the_data$NO3
#plot(the_data$NO3$Date,the_data$NO3$Observed)
#lines(the_data$NO3$Date,the_data$NO3$Simulated)

#I will just loop through stations and make copies, to have data at every station
df <- list()
for(i in stations$id){
  df <- list.append(df,the_data)
}

#Save for the Shiny app  
saveRDS(df,file=file.path(shiny_dir,"data.rds"))
saveRDS(stations,file=file.path(shiny_dir,"stations.rds"))
