library(shiny)
library(httr)
library(tidyverse)
library(jsonlite)
library(bizdays)

#adapcação da funçao ewma do wilson freitas
ewma.func <- function(rets, lambda) {
  sig.p <- 0
  sig.s <- vapply(rets[-1], function(r) sig.p <<- sig.p*lambda + (r^2)*(1 - lambda), 0)
  
  with_na <- c(c(NA,NA),sig.s)
  
  return(with_na)
}

#recupera PTAX da api do BCB
query <- GET("https://api.bcb.gov.br/dados/serie/bcdata.sgs.1/dados/ultimos/365?formato=json")
json  <- jsonlite::fromJSON(rawToChar(query$content))

#dataframe, datas tipo date, valor tipo numeric
df <- as.data.frame(json)
df$data <- as.Date(df$data, "%d/%m/%Y")
df$valor <- as.numeric(df$valor)

#proximo dia util, retornos, adiciona linha em df
next_bu <- offset(df$data[length(df$data)],1,"Brazil/ANBIMA")
df <- mutate(df, retornos = (valor - lag(valor))/lag(valor))
df[nrow(df) + 1,] = list(next_bu, NA, NA)

#calcula a vol e adiciona no df
vol <- ewma.func(df$retornos, 0.94)
df <- cbind(df, vol = vol[1:length(vol)-1])

#write.csv(df,'df.csv')

