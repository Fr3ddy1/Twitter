# Twitter

Extracción Data desde Twitter
-----------------------------

Cargo librerías a usar,

    library(rtweet)

    ## Warning: package 'rtweet' was built under R version 3.5.2

    library(lubridate)

    ## 
    ## Attaching package: 'lubridate'

    ## The following object is masked from 'package:base':
    ## 
    ##     date

En este ejemplo se trabajará con la API de Twitter, las credenciales de
la misma se pueden obtener al registrarse en la página
<https://developer.twitter.com>, donde el usuario se deberá registrar y
solicitar el acceso, de esta manera se va a conocer los valores de las
variables "appname", "key", "secret", "acces\_t" y "access\_s",

    twitter_token <- create_token(app = appname, consumer_key = key,
                                  consumer_secret = secret,
                                  access_token = acces_t ,access_secret = access_s)

Una vez definidas estas credenciales usando la función "create\_token"
conseguimos el acceso a Twitter. En este ejemplo se va a explicar el
proceso de extraer información desde twitter, en este caso vamos a
extraer el precio del Dolar Today a partir de la información publicada
en la cuenta "@InformeDolar". Así usamos la función "get\_timeline" para
obtener esta informacion, para este caso usaremos un "n=10", pues sólo
nos interesa conocer la información mas reciente,

    #Busco tweets
    datos_new <- get_timeline(user = "@InformeDolar", n = 10, parse = TRUE,
                              check = TRUE, include_rts = FALSE)

    #selecciono columnas útiles
    datos_new <- datos_new[,c(1,3,4,5,17)]
    head(datos_new)

    ## # A tibble: 6 x 5
    ##   user_id    created_at          screen_name  text                 hashtags
    ##   <chr>      <dttm>              <chr>        <chr>                <list>  
    ## 1 104330396… 2019-09-06 14:00:03 InformeDolar "Tasas #USDVES\n\nD… <chr [1…
    ## 2 104330396… 2019-09-06 12:00:08 InformeDolar "Dólar paralelo en … <chr [1…
    ## 3 104330396… 2019-09-06 00:00:02 InformeDolar "Tasas #USDVES\n\nA… <chr [1…
    ## 4 104330396… 2019-09-05 22:00:08 InformeDolar "Dólar paralelo en … <chr [1…
    ## 5 104330396… 2019-09-05 19:00:03 InformeDolar "Tasas #USDVES\n\nA… <chr [1…
    ## 6 104330396… 2019-09-05 17:00:11 InformeDolar "Dólar paralelo en … <chr [1…

Luego de obtener la data, sólo elijo la data que considero necesaria,
para ello sólo selecciono las comunas 1, 3, 4, 5 y 17. Despues de esto,
elinimo algunas filas que no necesitaré e insertaré una columna
denominada "fecha", la cual crearé a partir de la columna "created\_at".

    #dejo solo tweets necesarios
    datos_new <- datos_new[-which(is.na(datos_new$hashtags)),]

    #agrego columna fecha, la extraigo de la columna "created_at"
    datos_new$date <- date(datos_new$created_at)
    datos_new$date <- as.factor(datos_new$date)
    head(datos_new)

    ## # A tibble: 5 x 6
    ##   user_id   created_at          screen_name  text            hashtags date 
    ##   <chr>     <dttm>              <chr>        <chr>           <list>   <fct>
    ## 1 10433039… 2019-09-06 14:00:03 InformeDolar "Tasas #USDVES… <chr [1… 2019…
    ## 2 10433039… 2019-09-06 00:00:02 InformeDolar "Tasas #USDVES… <chr [1… 2019…
    ## 3 10433039… 2019-09-05 19:00:03 InformeDolar "Tasas #USDVES… <chr [1… 2019…
    ## 4 10433039… 2019-09-05 14:00:03 InformeDolar "Tasas #USDVES… <chr [1… 2019…
    ## 5 10433039… 2019-09-05 00:00:03 InformeDolar "Tasas #USDVES… <chr [1… 2019…

Es importante señalar que normalmente para cada día existen tres
reportes de precio uno en la mañana, otro al mediodía y otro al final de
la tarde, con el fin de sólo considerar el precio del final de la tarde,
se realiza el siguiente proceso. A grandes razgos este proceso utiliza
la información de la columna "created\_at" para saber cual es la
información más reciente en undía en específico, una vez determinado
esto se procede a guardar su ubicción en la data original. Este proceso
se repite con todos los días considerados en la data.

    le <- levels(datos_new$date)
    ind <- rep(0,length(le))

    for(i in 1:length(le)){
      a <- which(le[i]==datos_new$date)
      a1 <- max(datos_new$created_at[a])
      ind[i] <- which(a1==datos_new$created_at)
    }

    #nueva data
    data_nueva <- data.frame(fecha1=le,fecha2=datos_new$created_at[ind],texto=datos_new$text[ind])
    head(data_nueva)

    ##       fecha1              fecha2
    ## 1 2019-09-05 2019-09-05 19:00:03
    ## 2 2019-09-06 2019-09-06 14:00:03
    ##                                                                                                                                                                                                                        texto
    ## 1 Tasas #USDVES\n\nAirTM: 19163.20\nDolarSatoshi: 19295.47\nBolivarCucuta: 20516.00\nDolarToday: 20963.11\nDolarTrue_: 21178.38\nCotizaciones_: 22964.28\nCambios_Cucuta: 23214.00\n\nPromedio general (USD): BsS. 21,042.06
    ## 2 Tasas #USDVES\n\nDolarSatoshi: 19320.02\nDolarTrue_: 19525.79\nAirTM: 19836.00\nBolivarCucuta: 20516.00\nDolarToday: 21051.03\nCotizaciones_: 22964.28\nCambios_Cucuta: 23214.00\n\nPromedio general (USD): BsS. 20,918.16

Luego de esto creo una variable vacia para guardar la información
obtenida y ordeno la data de la fecha más antigua a la mas reciente,

    #creo col donde guardare nueva información
    data_nueva$d_today <- rep(0,nrow(data_nueva))

    #ordeno
    data_nueva <- data_nueva[order(data_nueva$fecha2,decreasing = TRUE),]

    head(data_nueva)

    ##       fecha1              fecha2
    ## 2 2019-09-06 2019-09-06 14:00:03
    ## 1 2019-09-05 2019-09-05 19:00:03
    ##                                                                                                                                                                                                                        texto
    ## 2 Tasas #USDVES\n\nDolarSatoshi: 19320.02\nDolarTrue_: 19525.79\nAirTM: 19836.00\nBolivarCucuta: 20516.00\nDolarToday: 21051.03\nCotizaciones_: 22964.28\nCambios_Cucuta: 23214.00\n\nPromedio general (USD): BsS. 20,918.16
    ## 1 Tasas #USDVES\n\nAirTM: 19163.20\nDolarSatoshi: 19295.47\nBolivarCucuta: 20516.00\nDolarToday: 20963.11\nDolarTrue_: 21178.38\nCotizaciones_: 22964.28\nCambios_Cucuta: 23214.00\n\nPromedio general (USD): BsS. 21,042.06
    ##   d_today
    ## 2       0
    ## 1       0

Finalmente, realizo un proceso de búsqueda de la palabra "DolarToday" en
la columna "texto" para así extraer el precio del mismo, así el precio
del primer día es,

    #Busco "DolarToday:" para extraer precio
    p <- as.character(data_nueva$texto[1])
    p

    ## [1] "Tasas #USDVES\n\nDolarSatoshi: 19320.02\nDolarTrue_: 19525.79\nAirTM: 19836.00\nBolivarCucuta: 20516.00\nDolarToday: 21051.03\nCotizaciones_: 22964.28\nCambios_Cucuta: 23214.00\n\nPromedio general (USD): BsS. 20,918.16"

    n1 <- regexpr('DolarToday', p)[1]
    n1

    ## [1] 100

    n2 <- as.numeric(substr(p, n1+12, n1+18))
    n2

    ## [1] 21051

Por su parte el precio más reciente es,

    #Busco "DolarToday:" para extraer precio
    p <- as.character(data_nueva$texto[2])
    p

    ## [1] "Tasas #USDVES\n\nAirTM: 19163.20\nDolarSatoshi: 19295.47\nBolivarCucuta: 20516.00\nDolarToday: 20963.11\nDolarTrue_: 21178.38\nCotizaciones_: 22964.28\nCambios_Cucuta: 23214.00\n\nPromedio general (USD): BsS. 21,042.06"

    n1 <- regexpr('DolarToday', p)[1]
    n1

    ## [1] 79

    n2 <- as.numeric(substr(p, n1+12, n1+18))
    n2

    ## [1] 20963.1

Así mediante este proceso es posible extraer información muy útil
mediante la API de Twitter y el programa R. Para este caso se realizó
una consulta sobre un usuario en específico, en caso de querer más
información el límite de esta API ronda los 3200 tweets.

