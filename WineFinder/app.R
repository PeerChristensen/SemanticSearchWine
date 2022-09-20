
library(tidyverse)
library(reticulate)
library(shiny)
library(vroom)
library(shinythemes)
library(shinyWidgets)

reticulate::use_condaenv("wine_env")
reticulate::py_run_file("python_functions.py")

model <- py$get_model()

embeddings <- py$load_embeddings(file='embeddings_msmarco-MiniLM-L-6-v3.npy')

df <- vroom("wine_reviews.csv") %>% 
    mutate(id = row_number() - 1) 

countries <- df %>%
    distinct(country) %>%
    arrange(country) %>%
    pull(country)

# Define any Python packages needed for the app here:
# PYTHON_DEPENDENCIES = c('pip', 'numpy', 'pandas', 'torch', 'sentence-transformers')
# 
# virtualenv_dir = Sys.getenv('VIRTUALENV_NAME')
# python_path = Sys.getenv('PYTHON_PATH')
#     
# # Create virtual env and install dependencies
# reticulate::virtualenv_create(envname = virtualenv_dir, python = python_path)
# reticulate::virtualenv_install(virtualenv_dir, packages = PYTHON_DEPENDENCIES, ignore_installed=TRUE)
# reticulate::use_virtualenv(virtualenv_dir, required = T)


ui <- fluidPage(
    theme = shinytheme("sandstone"),
    tags$head(tags$style(HTML(c("a {color: darkred}",
                                #  "#go , #go:active{background-color:darkred;
                                #   -webkit-box-shadow: 0px;
                                #    box-shadow: 0px;}", # just for reference
                                "h1 {
                                              font-family: 'Lobster',cursive, bold;
                                              font-weight: 600;
                                              line-height: 1.5;
                                              font-size: 60px;
                                              color: darkred}",
                                ".irs-bar,
                                           .irs-bar-edge,
                                           .irs-single,
                                           .irs-grid-pol {
                                              background: darkred;
                                              border-color: darkred;}",
                                ".btn {
                                                background-color:darkred;}",
                                ".btn:active, .btn:focus,.btn:focus:active {
                                         background-color:black;
                                              outline: 0;
                                              box-shadow: none;
                                            }"
                                
                                
    )))),
    titlePanel(h1("Wine Finder")),
    sidebarLayout(
        mainPanel(
            textInput("query",
                      label = h3(em("How do you like your wine?")),
                      value = "",
                      width = "80%",
                      placeholder = "Describe what kind of wine you like.."),
            actionButton("go", h2(strong(icon("glass-cheers"))),
                         width="80px",
                         style='padding:1px;'),
            hr(),
            dataTableOutput('table'),
            HTML(paste(h4(strong("Data source")),
                       "The data was scraped from WineEnthusiast in June, 2017",'<br/>',
                       "For more information please visit", a('Kaggle', target='_blank', href='https://www.kaggle.com/zynicide/wine-reviews'),'<br/>'
            ))
        ),
        sidebarPanel(
            width = 3,
            h3("narrow down your search"),
            pickerInput("countries",
                        h4("Countries"),
                        choices  = countries,
                        selected = countries,
                        options = list(
                            `actions-box` = TRUE,
                            `live-search` = TRUE,
                            `live-search-placeholder` = "Search Countries"),
                        multiple = T),
            sliderInput("points",
                        h4("Min points given"),
                        min = min(df$points),
                        max = max(df$points),
                        value = min(df$points)),
            sliderInput("hits",
                        h4("Max number of wines"),
                        min = 1,
                        max = 20,
                        value = 5
                        )
                    )
                )
)


# Define server logic required to draw a histogram
server <- function(input, output) {

    #observeEvent(c(input$go,input$hits,input$countries,input$points), {
    observeEvent(input$go, {
            
    output$table <- renderDataTable({
        
        req(input$query)
        query_embedding <- py$get_embedding(input$query, model)
        
        # embeddings <- df %>%
        #     filter(country %in% input$countries,
        #            points >= input$points) %>%
        #     select(starts_with("V")) %>%
        #     select(-variety) %>%
        #     as.matrix()
        
        matches <- py$get_matches(embeddings, query_embedding, k = input$hits)
        
        df %>%
            inner_join(matches, by = c("id" = "index")) %>%
            select(-id) %>%
            filter(country %in% input$countries,
                   points >= input$points) %>%
            select(score, everything()) %>%
            arrange(desc(score))
    })
    }
)
}
# Run the application 
shinyApp(ui = ui, server = server)


