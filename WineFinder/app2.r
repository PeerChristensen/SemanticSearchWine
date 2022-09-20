
library(shiny)
library(shinyWidgets)
library(shinythemes)
library(h2o)
library(dplyr)
library(DT)
library(FNN)
library(vroom)

df   <- vroom::vroom("data/wine_reviews.csv") %>% select(-id)
vecs <- vroom::vroom("data/wine_reviews_vectors.csv") %>% select(-id)

countries <- df %>%
  distinct(country) %>%
  arrange(country) %>%
  pull(country)

h2o.init()
h2o.no_progress()
model_path <- "/Users/peerchristensen/Desktop/Projects/Wine/models/wine_model_02"
model <- h2o.loadModel(model_path)

ui <- fluidPage(theme = shinytheme("sandstone"),
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
                  sidebarPanel(width = 3,
                               
                               pickerInput("countries",
                                           h4("Countries"),
                                           choices  = countries,
                                           selected = countries,   
                                           options = list(`actions-box` = TRUE, 
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
                                           value = 5)
                  ),
                  
                  mainPanel(
                    textInput("text",
                              label = h3(em("How do you like your wine?")),
                              value = "",
                              width = "80%",
                              placeholder = "You may describe features such as appearance, flavours and structure"),
                    #  textOutput("text"), 
                    actionButton("go", h2(strong(icon("glass-cheers"))),
                                 width="80px",
                                 style='padding:1px;'),
                    hr(),
                    dataTableOutput('table'),
                    HTML(
                      paste(
                        h4(strong("Data source")),
                        "The data was scraped from WineEnthusiast in June, 2017",'<br/>',
                        "For more information please visit", a('Kaggle', target='_blank', href='https://www.kaggle.com/zynicide/wine-reviews'),'<br/>'
                      ))
                  )
                )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  observeEvent(c(input$go,input$hits,input$countries,input$points), {
    
    new <- tibble(text = input$text) %>%
      as.h2o()
    
    words <- h2o.tokenize(new$text, split= " ")
    
    new_vecs <- h2o.transform_word2vec(model, words, aggregate_method = "AVERAGE") %>%
      as_tibble()
    
    # Filter data
    df_filter <- df %>% 
      mutate(id = 1:nrow(df)) %>%
      select(id,everything())
    
    vecs2_filter <- vecs %>% 
      mutate(id = 1:nrow(vecs)) %>%
      select(id,everything())
    
    df_filter <- df_filter %>%
      filter(country %in% input$countries,
             points >= input$points)
    
    ids <- df_filter %>% pull(id)
    
    vecs2_filter <- vecs2_filter %>% filter(id %in% ids) %>% select(-id)
    
    vecs2_filter <- rbind(vecs2_filter, new_vecs)
    
    ind <-  tryCatch({
      knnx.index(vecs2_filter[-nrow(vecs2_filter),-1], vecs2_filter[nrow(vecs2_filter),-1], k=input$hits+1) %>% as.vector()
    }, error=function(e) NULL) 
    
    
    #dist <- knnx.dist(vecs2, vecs2[nrow(vecs2),], k=5) %>% as.vector()
    
    recommendations <- df_filter[ind[-1],-1] 
    
    # output$text <- renderText({ input$text })
    observeEvent(input$go,{
      output$table <- renderDataTable({
        
        recommendations
        
      },escape = FALSE)
      
    })})
}

# Run the application 
shinyApp(ui = ui, server = server)
