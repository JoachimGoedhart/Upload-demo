#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(tidyverse)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Upload file(s) demo"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            fileInput(inputId = "file",
                      label = "Upload",
                      accept = c(".csv", ".txt"),
                      multiple = TRUE,
                      placeholder = "'Browse' or drop your file onto this box"),
            hr(),
            h4("Uploaded file(s):"),
            htmlOutput("fileNames")
        ),

        # Show a plot of the generated distribution
        mainPanel(
          tableOutput("dataFrame")
        )
    )
)

server <- function(input, output) {

    output$fileNames <- renderText({
      # Avoid error message while file is not uploaded yet
      if (is.null(input$file)) {
        return("<i>none</i>")
      } else {
        return(paste(">",input$file$name,"<br>"))
      }
    })
    
    output$dataFrame <- renderTable({
      if (is.null(input$file)) {
        return(NULL)
      } else {
        #read multiple files into a single dataframe
        df_file_list <- lapply(input$file$datapath, function(x) read.csv(x, na.strings = c("",".","NA", "NaN", "#N/A", "#VALUE!", "#DIV/0!", stringsAsFactors = TRUE)))
        
        #Take the filenames, remove anything after "." to get rid of extension
        #This info will be used to generate a column "dataset" that identifies the dataframe
        names(df_file_list) <- gsub(input$file$name, pattern="\\..*", replacement="")
        
        #Convert multiple files into a single dataframe
        df_input <- bind_rows(df_file_list, .id = "dataset")
      }
      
      
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
