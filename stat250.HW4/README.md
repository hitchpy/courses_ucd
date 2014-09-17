stat250_HW4
===========

Visualization with interactive plots

We go over generating SVG plots within R, post-editing and inserting into HTML to achieve 
interactive effects. Some D3 examples, using maps etc. 

**Note**:This is a direct adaptation from jcheng5's example code. Which doesn't have any documentation.

Here I use the most convenient way(with `shiny` package in R) to build a web page with interactive maps of Airline Delay data, plus several panels that can adjust itself when I click on different 
parts on the map. The whole process is packaged in `leaflet`, incorporating javascript library *Leaflet* and *Shiny* package in R.

To run the example, download the repository. open a R session. install `devtools` using 
`install.packages("devtools")`. Then install the latest `shiny` and `ShinyDash` from github:

>devtools::install_github("ShinyDash", "trestletech")

>devtools::install_github("leaflet-shiny", "jcheng5")

In order to do that, you might need R version greater than 3.0.2.

Then in R, `library(shiny)`. issue `runApp("Dir/to download folder/")` 

