
from numpy import load, save
import numpy as np
import pandas as pd
from torch import topk, from_numpy
from sentence_transformers import SentenceTransformer, util

def load_embeddings(file):
  embeddings = load(file)
  return embeddings

def get_model():
  model = SentenceTransformer("sentence-transformers/msmarco-MiniLM-L-6-v3")
  return model

def get_embedding(query, model):
  query_embedding = model.encode(query)
  return query_embedding

def get_matches(embeddings, query_embedding, k):
  cos_scores = util.cos_sim(query_embedding, embeddings)[0]
  top_results = topk(cos_scores, k=int(k))
  score = [round(float(score),4) for score in top_results[0]]
  index = [int(idx) for idx in top_results[1]]
  tuples = list(zip(index,score))
  df = pd.DataFrame(tuples, columns=['index','score'])
  return df

def to_tensor(df):
  return np.vstack(df)
  
# embeddings = load_embeddings("embeddings_msmarco-MiniLM-L-6-v3.npy")
# model = get_model()
# query = "Full-bodied with notes of red berries"
# query_embedding = get_embedding(query, model)
# matches = get_matches(embeddings, query_embedding, k = 5)
# 
# cos_scores = util.cos_sim(query_embedding, embeddings)[0]
# top_results = topk(cos_scores, k=5)

# df = pd.read_csv("wine_reviews.csv")
# for score, idx in zip(top_results[0], top_results[1]):
#   print(f"{int(idx)}, Score: {round(float(score), 4)}, \nText: {df.description[int(idx)]}\n")
