# Introducción a synopR

**2026-03-04**

El paquete **synopR** ha sido diseñado para transformar fácilmente
mensajes SYNOP en dataframes listos para ser analizados.

## Flujo de trabajo con Ogimet

Decodificar mensajes SYNOP con **synopR** es muy sencillo. Supongamos
que necesitamos información meteorológica de la estación Rio Colorado
(identificador WMO: 87736) para lo cual recurrimos a
[Ogimet](https://www.ogimet.com/). Por simplicidad, sólo descargamos los
SYNOP del 1 de febrero del 2026, utilizando este
[link](https://www.ogimet.com/cgi-bin/getsynop?block=87736&begin=202602010300&end=202602012300).
Guardamos la información en un .txt y leemos este archivo con
readLines().

``` r
# Tenemos el archivo con los datos
archivos_synop <- tempfile(fileext = ".txt")
writeLines(c("87736,2026,02,01,03,00,AAXX 01034 87736 NIL=",
"87736,2026,02,01,06,00,AAXX 01064 87736 NIL=",
"87736,2026,02,01,09,00,AAXX 01094 87736 NIL=",
"87736,2026,02,01,12,00,AAXX 01123 87736 12965 31808 10240 20210 39992 40082 5//// 60104 82075 333 10282 20216 56055 82360=",
"87736,2026,02,01,15,00,AAXX 01154 87736 NIL=",
"87736,2026,02,01,18,00,AAXX 01183 87736 12465 20000 10326 20215 39974 40064 5//// 60001 82100 333 56600 82818=",
"87736,2026,02,01,21,00,AAXX 01214 87736 NIL="), archivos_synop)

# Lectura del archivo
data_input <- data.frame(synops = readLines(archivos_synop)) # Dataframe con una sola columna

print(data_input)
#>                                                                                                                       synops
#> 1                                                                               87736,2026,02,01,03,00,AAXX 01034 87736 NIL=
#> 2                                                                               87736,2026,02,01,06,00,AAXX 01064 87736 NIL=
#> 3                                                                               87736,2026,02,01,09,00,AAXX 01094 87736 NIL=
#> 4 87736,2026,02,01,12,00,AAXX 01123 87736 12965 31808 10240 20210 39992 40082 5//// 60104 82075 333 10282 20216 56055 82360=
#> 5                                                                               87736,2026,02,01,15,00,AAXX 01154 87736 NIL=
#> 6             87736,2026,02,01,18,00,AAXX 01183 87736 12465 20000 10326 20215 39974 40064 5//// 60001 82100 333 56600 82818=
#> 7                                                                               87736,2026,02,01,21,00,AAXX 01214 87736 NIL=
```

Tenemos un dataframe con una sola columna y tantas filas como mensajes.
Sin embargo, podemos ver dos particularidades. La primera, es que hay
mensajes NIL, sin contenido. La segunda, es que NO son SYNOP puros, sino
que previamente tienen un agregado que hace Ogimet, donde se indica la
estación (87736) y la fecha y hora de la observación. Pero no hay
problema, porque podemos usar la función
[`parse_ogimet()`](https://ezequiel9315.github.io/synopR/reference/parse_ogimet.md),
especialmente diseñada para separar este agregado del mensaje SYNOP.

``` r
library(synopR)

# Notar que `parse_ogimet()` toma como argumento un character vector, es incorrecto hacer `show_synop_data(data_input)`
data_from_ogimet <- parse_ogimet(data_input$synops) 

print(data_from_ogimet)
#> # A tibble: 7 × 5
#>    Year Month Day_Ogimet Hour_Ogimet Raw_synop                                  
#>   <dbl> <dbl>      <dbl>       <dbl> <chr>                                      
#> 1  2026     2          1           3 AAXX 01034 87736 NIL=                      
#> 2  2026     2          1           6 AAXX 01064 87736 NIL=                      
#> 3  2026     2          1           9 AAXX 01094 87736 NIL=                      
#> 4  2026     2          1          12 AAXX 01123 87736 12965 31808 10240 20210 3…
#> 5  2026     2          1          15 AAXX 01154 87736 NIL=                      
#> 6  2026     2          1          18 AAXX 01183 87736 12465 20000 10326 20215 3…
#> 7  2026     2          1          21 AAXX 01214 87736 NIL=
```

Antes de decodificar los mensajes, quizás sea conveniente chequear la
estructura de los SYNOP. Por ejemplo, puede pasar que, por error,
algunos de los grupos no estén separados por un espacio, o que contengan
4 cifras en lugar de 5. La función
[`check_synop()`](https://ezequiel9315.github.io/synopR/reference/check_synop.md)
se encargará de esto.

``` r

check_synop(data_from_ogimet$Raw_synop)
#> # A tibble: 7 × 2
#>   is_valid error_log
#>   <lgl>    <chr>    
#> 1 TRUE     ""       
#> 2 TRUE     ""       
#> 3 TRUE     ""       
#> 4 TRUE     ""       
#> 5 TRUE     ""       
#> 6 TRUE     ""       
#> 7 TRUE     ""

check_synop(data_from_ogimet)
#> # A tibble: 7 × 2
#>   is_valid error_log
#>   <lgl>    <chr>    
#> 1 TRUE     ""       
#> 2 TRUE     ""       
#> 3 TRUE     ""       
#> 4 TRUE     ""       
#> 5 TRUE     ""       
#> 6 TRUE     ""       
#> 7 TRUE     ""
```

[`check_synop()`](https://ezequiel9315.github.io/synopR/reference/check_synop.md)
toma como argumento un character vector o la columna de un dataframe
donde están los SYNOP. Un dataframe de varias columnas sin indicación de
cual es la columna de los SYNOP es aceptado **solo y solo si ese
dataframe es el resultado de**
[`parse_ogimet()`](https://ezequiel9315.github.io/synopR/reference/parse_ogimet.md).

``` r

my_df <- data.frame(syn = c("AAXX 01183 87736 12465 20000 10326 20215 39974 40064 5//// 60001 82100 333 56600 82818=",
                            "AAXX 01183 87736 12465 20000 10326 20215 39974 40064 5//// 60001 82100 333 56600 82818="),
                    second_column = c(5,7))

check_synop(my_df)
#> # A tibble: 2 × 2
#>   is_valid error_log                                                
#>   <lgl>    <chr>                                                    
#> 1 FALSE    Missing AAXX | Missing '=' terminator | Invalid groups: 5
#> 2 FALSE    Missing AAXX | Missing '=' terminator | Invalid groups: 7

check_synop(my_df$syn)
#> # A tibble: 2 × 2
#>   is_valid error_log
#>   <lgl>    <chr>    
#> 1 TRUE     ""       
#> 2 TRUE     ""
```

Hasta ahora, nuestros mensajes tienen una estructura correcta (aunque
algunos sean NIL). Veamos que pasa cuando no la tienen.

``` r

check_synop(c("AAXX 01183 87736 12465 20000 10326 20215 39974 40064 5//// 60001 82100 333 56600 82818=",
              "AAXX 01183 87736 12465 20000 10326 20215 39974 40064 5//// 6000182100 333 56600 82818=",
              "AAXX 01183 87736 12465 20000 10326 2021 39974 40064 5//// 60001 82100 333 56600 82818=",
              "AAXX 01183 87736 12465 20000 10326 20215 39974 40064 5//// 60001 82100 333 56600 82818",
              "Not a synop message="))
#> # A tibble: 5 × 2
#>   is_valid error_log                                              
#>   <lgl>    <chr>                                                  
#> 1 TRUE     ""                                                     
#> 2 FALSE    "Invalid groups: 6000182100"                           
#> 3 FALSE    "Invalid groups: 2021"                                 
#> 4 FALSE    "Missing '=' terminator"                               
#> 5 FALSE    "Missing AAXX | Invalid groups: Not, a, synop, message"
```

[`check_synop()`](https://ezequiel9315.github.io/synopR/reference/check_synop.md)
devuelve un tibble que en su primera columna informa la validez (TRUE) o
no (FALSE) de cada synop, y en su segunda columna, el error encontrado.
El primer SYNOP es correcto. En el segundo no hay un espacio entre los
grupos 6 y 8 de la sección 1. En el tercero, el grupo 2 de la sección 3
tiene sólo 4 cifras. En el cuarto, no termina con un “=” (recordar que
*siempre* deben comenzar con “AAXX” y terminar con un “=”). El quinto,
es cualquier cosa menos un SYNOP.

Ya estamos listos para extraer la información contenida en los mensajes.
La función
[`show_synop_data()`](https://ezequiel9315.github.io/synopR/reference/show_synop_data.md)
es la que se pondrá manos a la obra.

``` r

my_data <- show_synop_data(data_from_ogimet, wmo_identifier = '87736')

knitr::kable(t(my_data))
```

|                    |       |       |       |        |       |        |       |
|:-------------------|:------|:------|:------|:-------|:------|:-------|:------|
| wmo_id             | 87736 | 87736 | 87736 | 87736  | 87736 | 87736  | 87736 |
| Year               | 2026  | 2026  | 2026  | 2026   | 2026  | 2026   | 2026  |
| Month              | 2     | 2     | 2     | 2      | 2     | 2      | 2     |
| Day                | 1     | 1     | 1     | 1      | 1     | 1      | 1     |
| Hour               | 3     | 6     | 9     | 12     | 15    | 18     | 21    |
| Cloud_base_height  | NA    | NA    | NA    | 9      | NA    | 4      | NA    |
| Visibility         | NA    | NA    | NA    | 65     | NA    | 65     | NA    |
| Total_cloud_cover  | NA    | NA    | NA    | 3      | NA    | 2      | NA    |
| Wind_direction     | NA    | NA    | NA    | 18     | NA    | 0      | NA    |
| Wind_speed         | NA    | NA    | NA    | 8      | NA    | 0      | NA    |
| Air_temperature    | NA    | NA    | NA    | 24.0   | NA    | 32.6   | NA    |
| Dew_point          | NA    | NA    | NA    | 21.0   | NA    | 21.5   | NA    |
| Station_pressure   | NA    | NA    | NA    | 999.2  | NA    | 997.4  | NA    |
| Sea_level_pressure | NA    | NA    | NA    | 1008.2 | NA    | 1006.4 | NA    |
| Present_weather    | NA    | NA    | NA    | NA     | NA    | NA     | NA    |
| Past_weather1      | NA    | NA    | NA    | NA     | NA    | NA     | NA    |
| Past_weather2      | NA    | NA    | NA    | NA     | NA    | NA     | NA    |
| Precipitation_S1   | NA    | NA    | NA    | 10     | NA    | 0      | NA    |
| Precip_period_S1   | NA    | NA    | NA    | 24     | NA    | 6      | NA    |
| Cloud_amount_Nh    | NA    | NA    | NA    | 2      | NA    | 2      | NA    |
| Low_clouds_CL      | NA    | NA    | NA    | 0      | NA    | 1      | NA    |
| Medium_clouds_CM   | NA    | NA    | NA    | 7      | NA    | 0      | NA    |
| High_clouds_CH     | NA    | NA    | NA    | 5      | NA    | 0      | NA    |
| Max_temperature    | NA    | NA    | NA    | 28.2   | NA    | NA     | NA    |
| Min_temperature    | NA    | NA    | NA    | 21.6   | NA    | NA     | NA    |
| Ground_state       | NA    | NA    | NA    | NA     | NA    | NA     | NA    |
| Ground_temperature | NA    | NA    | NA    | NA     | NA    | NA     | NA    |
| Snow_ground_state  | NA    | NA    | NA    | NA     | NA    | NA     | NA    |
| Snow_depth         | NA    | NA    | NA    | NA     | NA    | NA     | NA    |
| Precipitation_S3   | NA    | NA    | NA    | NA     | NA    | NA     | NA    |
| Precip_period_S3   | NA    | NA    | NA    | NA     | NA    | NA     | NA    |

El argumento `wmo_identifier` puede parecer molesto, pero tiene una
ventaja. Permite filtrar en caso de que hayan mensajes de otras
estaciones. Si bien en el siguiente ejemplo, por cuestiones de
simplicidad, tenemos un vector con solamente 2 mensajes, si estás
trabajando con miles y miles de SYNOP de varias estaciones, que la
función permita aplicar este tipo de filtro podría ser muy conveniente.

``` r

# Mensaje de la estación 87736 y de la estación 87016.
mixed_synop <- c("AAXX 01183 87736 12465 20000 10326 20215 39974 40064 5//// 60001 82100 333 56600 82818=",
                 "AAXX 04033 87016 41460 83208 10200 20194 39712 40114 50003 70292 888// 333 56699 82810 88615="
                 )

colorado_data <- show_synop_data(mixed_synop, wmo_identifier = '87736')
#> Warning in show_synop_data(mixed_synop, wmo_identifier = "87736"): 1 message(s)
#> do not contain the identifier '87736' and will be discarded.
print(colorado_data)
#> # A tibble: 1 × 29
#>   wmo_id   Day  Hour Cloud_base_height Visibility Total_cloud_cover
#>   <chr>  <dbl> <dbl>             <dbl>      <dbl>             <dbl>
#> 1 87736      1    18                 4         65                 2
#> # ℹ 23 more variables: Wind_direction <dbl>, Wind_speed <dbl>,
#> #   Air_temperature <dbl>, Dew_point <dbl>, Station_pressure <dbl>,
#> #   Sea_level_pressure <dbl>, Present_weather <dbl>, Past_weather1 <dbl>,
#> #   Past_weather2 <dbl>, Precipitation_S1 <dbl>, Precip_period_S1 <dbl>,
#> #   Cloud_amount_Nh <dbl>, Low_clouds_CL <dbl>, Medium_clouds_CM <dbl>,
#> #   High_clouds_CH <dbl>, Max_temperature <dbl>, Min_temperature <dbl>,
#> #   Ground_state <dbl>, Ground_temperature <dbl>, Snow_ground_state <dbl>, …
```

## Flujo de trabajo estándar

Todo lo que necesita
[`show_synop_data()`](https://ezequiel9315.github.io/synopR/reference/show_synop_data.md)
es un character vector o la columna de un dataframe, donde cada elemento
es un SYNOP.

``` r

data_input_vector <- c("AAXX 04003 87736 32965 00000 10204 20106 39982 40074 5//// 333 10266 20158 555 64169 65090 =",
                       "AAXX 01094 87736 NIL=",
                       "AAXX 03183 87736 32965 12708 10254 20052 30005 40098 5//// 80005 333 56000 81270 =")

my_data <- show_synop_data(data_input_vector, wmo_identifier = '87736')

print(my_data)
#> # A tibble: 3 × 29
#>   wmo_id   Day  Hour Cloud_base_height Visibility Total_cloud_cover
#>   <chr>  <dbl> <dbl>             <dbl>      <dbl>             <dbl>
#> 1 87736      4     0                 9         65                 0
#> 2 87736      1     9                NA         NA                NA
#> 3 87736      3    18                 9         65                 1
#> # ℹ 23 more variables: Wind_direction <dbl>, Wind_speed <dbl>,
#> #   Air_temperature <dbl>, Dew_point <dbl>, Station_pressure <dbl>,
#> #   Sea_level_pressure <dbl>, Present_weather <dbl>, Past_weather1 <dbl>,
#> #   Past_weather2 <dbl>, Precipitation_S1 <dbl>, Precip_period_S1 <dbl>,
#> #   Cloud_amount_Nh <dbl>, Low_clouds_CL <dbl>, Medium_clouds_CM <dbl>,
#> #   High_clouds_CH <dbl>, Max_temperature <dbl>, Min_temperature <dbl>,
#> #   Ground_state <dbl>, Ground_temperature <dbl>, Snow_ground_state <dbl>, …
```

El grupo 555, de difusión nacional, es ignorado, puesto que depende de
cada país. Sin embargo, es posible que en futuras versiones de
**synopR** se añadan funciones que permitan extraer datos de esta
sección según las necesidades del usuario.

## Limitaciones

**synopR** no trabaja con las secciones 222 y 444. Otras limitaciones y
suposiciones pueden ser encontradas en el repositorio oficial en
[Github](https://github.com/ezequiel1593/synopR).
