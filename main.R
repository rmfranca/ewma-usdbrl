library(shiny)
library(httr)
library(tidyverse)
library(jsonlite)


query <- GET("https://api.bcb.gov.br/dados/serie/bcdata.sgs.1/dados/ultimos/400?formato=json")
json <- jsonlite::fromJSON(rawToChar(query$content))

df <- flatten(as.data.frame(json))