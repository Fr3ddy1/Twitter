#Forma de extraer en tiempo real datos de dolar today
library(rtweet)
library(lubridate)

# Identificación y obtención de tokens
appname <- "Fred23"
key     <- "XXXXX"
secret  <- "XXXXX"
acces_t <- "XXXXX"
access_s <- "XXXXX"

twitter_token <- create_token(app = appname, consumer_key = key,
                              consumer_secret = secret,
                              access_token = acces_t ,access_secret = access_s)


#Busco tweets
datos_new <- get_timeline(user = "@InformeDolar", n = 10, parse = TRUE,
                          check = TRUE, include_rts = FALSE)


#selecciono columnas útiles
datos_new <- datos_new[,c(1,3,4,5,17)]

#dejo solo tweets necesarios
datos_new <- datos_new[-which(is.na(datos_new$hashtags)),]

#agrego columna fecha, la extraigo de la columna "created_at"
datos_new$date <- date(datos_new$created_at)
datos_new$date <- as.factor(datos_new$date)

le <- levels(datos_new$date)
ind <- rep(0,length(le))

for(i in 1:length(le)){
  a <- which(le[i]==datos_new$date)
  a1 <- max(datos_new$created_at[a])
  ind[i] <- which(a1==datos_new$created_at)
}

#nueva data
data_nueva <- data.frame(fecha1=le,fecha2=datos_new$created_at[ind],texto=datos_new$text[ind])

#creo col donde guardare nueva información
data_nueva$d_airtm <- rep(0,nrow(data_nueva))
data_nueva$d_today <- rep(0,nrow(data_nueva))

#ordeno
data_nueva <- data_nueva[order(data_nueva$fecha2,decreasing = TRUE),]

#Busco "TheAirTM:" y "DolarToday:" para extraer precio
p <- as.character(data_nueva$texto[1])

n1 <- regexpr('DolarToday', p)[1]
n2 <- as.numeric(substr(p, n1+12, n1+18))
n2
