
from numpy import load, save
import numpy as np
import pandas as pd
from torch import topk, from_numpy
from sentence_transformers import SentenceTransformer, util


def load_embeddings(file):
  embeddings = load(file)
  return embeddings


def get_model():
  model = SentenceTransformer("/model")
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
  
