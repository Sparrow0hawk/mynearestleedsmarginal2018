# my nearest leeds marginal ui.R
# 23-01-18
# includes google analytics script and .js bookmark
# UI

require(leaflet)


# anything going into fluidPage goes into app
ui <- fluidPage(
  tags$head(includeScript("./gtag1.js")),
  includeCSS("./mark6.1.css"),
  
  # UI title panel
  titlePanel("My Nearest Leeds 2018 Marginal"),
  # creates a side bar for postcode, button and slider
  sidebarLayout(

    sidebarPanel(
      
      tags$p("Welcome to my Nearest Leeds 2018 Marginal!"),
      tags$p("We've got all out council election this year
             so it's critical you help keep Leeds Labour!"),
      tags$p("Enter your postcode below and press search to
            find your nearest marginal."),
      tags$p(" "),
      
      # text input for postcode
      textInput("postcode","Enter postcode", NULL),
      
      # button to control map generation
      actionButton("go","Search"),
      
      tags$br(),
      tags$br(),
      
      tags$strong("Don't forget polling day is Thursday 3rd May!"),
      tags$p(" "),
      tags$a(id="#bookmark-this", href = "#",rel="sidebar", "Bookmark this page") 
      
    ),
    mainPanel(
      tags$body(includeScript("./bookmark1.js")),
      tags$style('#value{font-size: 20px;
                          text-align: center;
                          background-color: rgb(230, 0, 71);
                          color: white;
                          }
                 #link1{font-size: 20px;
                        text-align:center;
                        background-color: rgb(230, 0, 71);
                        color: white;
                        }'
                 ),
      tags$div(class="mex",
               tags$p(textOutput("value"),
                  #textOutput("value1"),
                htmlOutput("link1"))
               
      ),
      
      tags$br(),
      leafletOutput("mymap"),
      tags$style('#help1{font-size: 10px;
                        text-align: center;
                        font-family: open sans;
                        }'),
      tags$br(),
      tags$p(id = "help1", "Made by Alex Coleman ~ Found an error?",tags$a(id = "help1",href="mailto:alexcoleman@hunsletandriversidelabour.org.uk", "Email Me.")),
      tags$p(id = "help1", "If the page becomes unresponsive try refreshing your browser."),
      tags$p(id = "help1", "This page was made using Shiny.")
      
      
    )
  )
)
