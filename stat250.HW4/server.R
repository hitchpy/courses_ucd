library(leaflet)
library(ggplot2)
library(maps)

## Loading the data
Dest = c('IND','LAX','SFO','JFK')
ArrDelay = c(32,-44,22,-29)
Lat = c(39.717, 33.94, 37.62,40.63 )
Long = c(-86.29, -118.40, -122.37, -73.7789 )
mydata = data.frame(Dest, ArrDelay, Lat, Long)


shinyServer(function(input, output, session) {

  makeReactiveBinding('selectedCity')
  
  # Define some reactives for accessing the data
  
  CitiesInBounds <- reactive({
    if (is.null(input$map_bounds))
      return(mydata[FALSE,])
    bounds <- input$map_bounds
    latRng <- range(bounds$north, bounds$south)
    lngRng <- range(bounds$east, bounds$west)
    
    subset(mydata,
	
           Lat >= latRng[1] & Lat <= latRng[2] &
             Long >= lngRng[1] & Long <= lngRng[2])
  })
  
  
  # Create the map; this is not the "real" map, but rather a proxy
  # object that lets us control the leaflet map on the page.
  map <- createLeafletMap(session, 'map')
  
  observe({
    if (is.null(input$map_click))
      return()
    selectedCity <<- NULL
  })
  
  radiusFactor <- 70000
  observe({
    map$clearShapes()
    cities <- CitiesInBounds()

    if (nrow(cities) == 0)
      return()
    
    map$addCircle(
      cities$Lat,
      cities$Long,
      abs(cities[["ArrDelay"]]) * radiusFactor / max(5, input$map_zoom)^2,
      row.names(cities),
      list(
        weight=1.2,
        fill=TRUE,
        color=ifelse(cities[["ArrDelay"]]< 0,'red','#4A9')
      )
    )
  })
  
  observe({
    event <- input$map_shape_click
    if (is.null(event))
      return()
    map$clearPopups()
    
    isolate({
      cities <- CitiesInBounds()
      city <- cities[row.names(cities) == event$id,]
      selectedCity <<- city
      content <- as.character(tagList(
        tags$strong(city$Dest),
        tags$br(),
        prettyNum(city[["ArrDelay"]], big.mark=',')
      ))
      map$showPopup(event$lat, event$lng, content, event$id)
    })
  })
  
  output$desc <- reactive({
    if (is.null(input$map_bounds))
      return(list())
    list(
      lat = mean(c(input$map_bounds$north, input$map_bounds$south)),
      lng = mean(c(input$map_bounds$east, input$map_bounds$west)),
      zoom = input$map_zoom

    )
  })
  
 output$data <- renderTable({
   if (nrow(CitiesInBounds()) == 0)
     return(NULL)
   
   data.frame(
     Airport = CitiesInBounds()$Dest,
     Arrival_Delay = CitiesInBounds()$ArrDelay )
 }, include.rownames = FALSE)
 
 
 output$cityTimeSeriesLabel <- renderText({
   if (is.null(selectedCity)) {
     'Delays for all visible airports'
   } else {
     paste('Barplot for selected airport ',
           selectedCity$Dest,
           ', ',
           selectedCity$ArrDelay,
           sep='')
   }
 })
 
 output$cityTimeSeries <- renderPlot({
   cities <- NULL
   if (!is.null(selectedCity))
     cities <- selectedCity
   else
     cities <- CitiesInBounds()
   
   airports = as.character(cities$Dest)
   delay = cities$ArrDelay
   barplot(delay, names.arg = airports)
   
   
   })
  
  
  
 })