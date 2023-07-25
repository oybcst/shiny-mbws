#stations.rds has Station, Lat, Lon, ID
#data.rds is list [1:ID] of of a list [Flow,NO3,PO4,Sed] of dataframes (Date,Observed,Simulated)
mb_model <- readRDS("data.rds")
mb_stations <- readRDS("stations.rds")