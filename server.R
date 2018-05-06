# my nearest leeds marginal server
# renders map each time only with constituencies of interest

library(shiny)
library(leaflet)
library(googleway)
library(sp)
library(dplyr)
library(rgeos)

options(shiny.sanitize.errors = FALSE)

load("./testdata1.RData", envir=.GlobalEnv)

server <- function(input, output, session) {
  
  # create colour palette for map
  pal <- colorFactor(palette = polpartycol,
                     levels(df_2016maj$PoliticalPartyLabel))
  
  # create labels for each ward based on 2016 results
  labels <- sprintf(
    "<strong>%s</strong><br/>%g majority<br/>%s",
    df_2016maj$ConstituencyLabel, df_2016maj$Majority, df_2016maj$PoliticalPartyLabel
  ) %>% lapply(htmltools::HTML)
  
  # pressing button on empty postcode input now creates map for centred leeds address
  # additional functionality would be to wildcard several leeds addresses aimed at under populated
  # key seats
  points <- eventReactive(input$go, {
    if (input$postcode == ""){
      a <- lst[sample(c(1,3,5))]
    } else
      a <- google_geocode(as.character(input$postcode), key = # insert google geocode API key
                            )},
    ignoreNULL= TRUE)
  
  output$mymap <- renderLeaflet({
    leafletOptions(maxZoom = 10)  
    leaflet() %>%
      addTiles() %>%
      addPolygons(data = leedswards,
                  stroke = TRUE,
                  color = "black",
                  fillColor = ~pal(df_2016maj$PoliticalPartyLabel), 
                  fillOpacity=0.3,
                  dashArray = 5,
                  weight = 2,
                  group = "wards",
                  label = labels)
  })
  
  observeEvent(input$go, {
    
    if (!is.null(points)) {
      
      points_a <- cbind(lon = points()$results$geometry$location$lng, lat = points()$results$geometry$location$lat)
      
      points_sp <- SpatialPoints(points_a)
      
      points_df <- data.frame(apply(gDistance(points_sp, leedswards, byid = TRUE),1,min))
      
      df_2016maj <- cbind(df_2016maj,points_df)
      
      names(df_2016maj) <- c("Year",   #1
                             "Ward",   #2
                             "Party",  #3
                             "Majority", #4
                             "PerMaj",   #5
                             "Link",     #6
                             "Constituency",  #7
                             "Distance from points")  #8
      
      # NEW SECTION RESOLVING PLOTTING CRASH FOR POSTCODES OUTSIDE OF LEEDS
      # pulls out the constituency of postcode entered
      if (0 %in% df_2016maj[,8]){
        my_const <- filter(df_2016maj,df_2016maj[,8]==0)
        
        # creates a variable of inputted constituency
        my_const <- my_const$Constituency
      }else
        my_const <- "Other"
      # END OF NEW SECTION
      
      df_2016majclose <- df_2016maj
      
      # filter list for only key seat list
      df_2016majclose <- df_2016majclose %>%
        filter(Ward %in% c("Pudsey","Ardsley and Robin Hood","Morley South",
                           "Rothwell", "Weetwood","Horsforth",
                           "Garforth and Swillington", "Farnley and Wortley"))
      
      # checks whether inputted postcode constituency is present in
      # key seats list, to ensure within constituency filter
      if(my_const %in% df_2016majclose$Constituency){
        df_2016majclose <- df_2016majclose %>%
          filter(Constituency %in% my_const)
      }
      
      flt_df_2016majclose <- arrange(df_2016majclose, 
                                     df_2016majclose[,8])
      
      df_2016majmap <- leedswards[as.character(leedswards$WD13NM) %in%
                                    as.character(flt_df_2016majclose$Ward[1]),]
      
      
      labels1 <- sprintf(
        "<strong>%s</strong><br/>%g majority<br/>%s",
        df_2016majmap$WD13NM, flt_df_2016majclose$Majority[1], as.character(flt_df_2016majclose$Party[1])
      ) %>% lapply(htmltools::HTML)
    }
    
    output$mymap <- renderLeaflet({
      leaflet() %>%
        addTiles() %>%
        addPolygons(data = df_2016majmap,
                    stroke = TRUE,
                    color = "black",
                    fillColor = ~pal(df_2016majclose$Party[df_2016majclose$Ward %in% df_2016majmap$WD13NM]), 
                    fillOpacity=0.7,
                    weight = 2,
                    label = labels1) %>%
        addMarkers(data = points()$results$geometry$location)
    })
    
    
    output$value <- renderText({ 
      c("Your nearest marginal is",as.character(flt_df_2016majclose$Ward[1]))
      })
    
    output$link1 <- renderUI({
      str1 <- paste("Click")
      str2 <- paste("for events in that ward.")
      lnk <- paste("<a href=",as.character(flt_df_2016majclose$Link[1]),"target='_blank'",
                   "onclick=","ga('send','event','click','link','IKnow',1)",">here</a>")
                   HTML(paste(str1,lnk,str2))
                   })
    
  })
}
