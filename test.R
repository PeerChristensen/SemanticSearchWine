library(tidyverse)
library(reticulate)
reticulate::use_condaenv("wine_env")
reticulate::py_run_file("test.py")

df <- read_csv("wine_reviews.csv") %>%
  mutate(id = row_number() - 1)

model <- py$get_model()

embeddings <- py$load_embeddings(file='embeddings_msmarco-MiniLM-L-6-v3.npy')

query <- "Full-bodied with notes of red berries"

query_embedding <- py$get_embedding(query, model)

matches <- py$get_matches(embeddings, query_embedding, k = 5)

df %>%
  inner_join(matches, by = c("id" = "index")) %>%
  select(-id) %>%
  select(score, everything()) %>%
  arrange(desc(score))

