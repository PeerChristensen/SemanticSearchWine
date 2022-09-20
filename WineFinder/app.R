
library(tidyverse)
library(reticulate)
library(shiny)

reticulate::use_condaenv("wine_env")
reticulate::py_run_file("test.py")

model <- py$get_model()

embeddings <- py$load_embeddings(file='embeddings_msmarco-MiniLM-L-6-v3.npy')

df <- read_csv("wine_reviews.csv") %>%
    mutate(id = row_number() - 1)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Wine Finder"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            textInput("query", "Describe")
        ),

        # Show a plot of the generated distribution
        mainPanel(
           tableOutput("results")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$results <- renderTable({
        req(input$query)
        query_embedding <- py$get_embedding(input$query, model)
        
        matches <- py$get_matches(embeddings, query_embedding, k = 5)
        
        df %>%
            inner_join(matches, by = c("id" = "index")) %>%
            select(-id) %>%
            select(score, everything()) %>%
            arrange(desc(score))
        
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
