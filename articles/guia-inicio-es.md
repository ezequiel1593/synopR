# Introducción a synopR

**2026-03-06**

El paquete **synopR** ha sido diseñado para transformar fácilmente
mensajes SYNOP en dataframes listos para ser analizados.

## Flujo de trabajo estándar

Todo lo que necesita
[`show_synop_data()`](https://ezequiel9315.github.io/synopR/reference/show_synop_data.md)
es un string vector o la columna de un dataframe, donde cada elemento
sea un mensaje SYNOP.

``` r
library(synopR)

data_input_vector <- c("AAXX 04003 87736 32965 00000 10204 20106 39982 40074 5//// 333 10266 20158 555 64169 65090 =",
                       "AAXX 01094 87736 NIL=",
                       "AAXX 03183 87736 32965 12708 10254 20052 30005 40098 5//// 80005 333 56000 81270 =")

my_data <- show_synop_data(data_input_vector, wmo_identifier = '87736')

print(my_data)
#> # A tibble: 3 × 54
#>   wmo_id   Day  Hour Cloud_base_height Visibility Total_cloud_cover
#>   <chr>  <dbl> <dbl>             <dbl>      <dbl>             <dbl>
#> 1 87736      4     0                 9         65                 0
#> 2 87736      1     9                NA         NA                NA
#> 3 87736      3    18                 9         65                 1
#> # ℹ 48 more variables: Wind_direction <dbl>, Wind_speed <dbl>,
#> #   Wind_speed_unit <chr>, Air_temperature <dbl>, Dew_point <dbl>,
#> #   Relative_humidity <dbl>, Station_pressure <dbl>, MSLP_GH <dbl>,
#> #   Present_weather <dbl>, Past_weather1 <dbl>, Past_weather2 <dbl>,
#> #   Precipitation_S1 <dbl>, Precip_period_S1 <dbl>, Cloud_amount_Nh <dbl>,
#> #   Low_clouds_CL <dbl>, Medium_clouds_CM <dbl>, High_clouds_CH <dbl>,
#> #   Max_temperature <dbl>, Min_temperature <dbl>, Ground_state <dbl>, …
```

Si un parámetro meteorológico no está presente en ninguno de los
mensajes, puedes usar el argumento `remove_empty_cols = TRUE` para
remover las columnas adicionales que se generan.

El argumento opcional `wmo_identifier` ofrece una ventaja significativa:
permite filtrar en caso de que tu archivo contenga mensajes de otras
estaciones.

El siguiente ejemplo, por cuestiones de simplicidad, sólo utiliza dos
mensajes, pero si estás trabajando con cientos de SYNOP, la posibilidad
de hacer un filtro desde esta función se vuelve extremadamente
conveniente.

``` r
library(synopR)
# Messages from 87736 and 87016
mixed_synop <- c("AAXX 01183 87736 12465 20000 10326 20215 39974 40064 5//// 60001 82100 333 56600 82818=",
                 "AAXX 04033 87016 41460 83208 10200 20194 39712 40114 50003 70292 888// 333 56699 82810 88615="
                 )

colorado_data <- show_synop_data(mixed_synop, wmo_identifier = '87736', remove_empty_cols = TRUE)
#> Warning in show_synop_data(mixed_synop, wmo_identifier = "87736",
#> remove_empty_cols = TRUE): 1 message(s) do not contain the identifier '87736'
#> and will be discarded.
knitr::kable(t(colorado_data))
```

|                       |                                                       |
|:----------------------|:------------------------------------------------------|
| wmo_id                | 87736                                                 |
| Day                   | 1                                                     |
| Hour                  | 18                                                    |
| Cloud_base_height     | 4                                                     |
| Visibility            | 65                                                    |
| Total_cloud_cover     | 2                                                     |
| Wind_direction        | 0                                                     |
| Wind_speed            | 0                                                     |
| Wind_speed_unit       | knots                                                 |
| Air_temperature       | 32.6                                                  |
| Dew_point             | 21.5                                                  |
| Relative_humidity     | 52.1                                                  |
| Station_pressure      | 997.4                                                 |
| MSLP_GH               | 1006.4                                                |
| Precipitation_S1      | 0                                                     |
| Precip_period_S1      | 6                                                     |
| Cloud_amount_Nh       | 2                                                     |
| Low_clouds_CL         | 1                                                     |
| Medium_clouds_CM      | 0                                                     |
| High_clouds_CH        | 0                                                     |
| Cloud_drift_direction | W - Stationary or No clouds - Stationary or No clouds |

Es una buena práctica chequear los mensajes en busca de estructuras no
estandarizadas. La función
[`check_synop()`](https://ezequiel9315.github.io/synopR/reference/check_synop.md)
se encarga de esto. Se asegurará que cada mensaje comience con “AAXX” y
termine con “=”, que no contenga caracteres inválidos (los caracteres
válidos, luego de remover “AAXX” y “=” son los números del 0 a 9, ‘/’ y
‘NIL’), y verifica que todos los grupos contengan 5 dígitos (excepto
para los identificadores ‘333’ y ‘555’).

La función
[`check_synop()`](https://ezequiel9315.github.io/synopR/reference/check_synop.md)
acepta un string vector o la columna de un data frame que
específicamente contiene los mensajes SYNOP. Un data frame de varias
columnas (cuando la columna con los SYNOP no se especifica
explícitamente) será aceptado \*\* si y solo si ese data frame es el
resultado directo de\*\*
[`parse_ogimet()`](https://ezequiel9315.github.io/synopR/reference/parse_ogimet.md).

``` r
library(synopR)

my_df <- data.frame(syn = c("AAXX 01183 87736 12465 20000 10326 20215 39974 40064 5//// 60001 82100 333 56600 82818=",
                            "AAXX 01183 87736 12465 20000 10326 20215 39974 40064 5//// 60001 82100 333 56600 82818="),
                    second_column = c(5,7))

check_synop(my_df) # Bien
#> # A tibble: 2 × 2
#>   is_valid error_log                                                
#>   <lgl>    <chr>                                                    
#> 1 FALSE    Missing AAXX | Missing '=' terminator | Invalid groups: 5
#> 2 FALSE    Missing AAXX | Missing '=' terminator | Invalid groups: 7

check_synop(my_df$syn) # Mal
#> # A tibble: 2 × 2
#>   is_valid error_log
#>   <lgl>    <chr>    
#> 1 TRUE     ""       
#> 2 TRUE     ""
```

Hasta el momento, todos nuestros mensajes tienen una estructura correcta
(incluso los NIL). Ahora, veamos que sucede cuando no.

``` r
library(synopR)

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
devuelve un tibble donde la primera columna indica si el SYNOP es válido
(TRUE) o no (FALSO), y una segunda columna, con el detalle del error
encontrado. En nuestro ejemplo:

- El primer SYNOP es correcto.
- Al segundo le falta un espacio entre el grupo 6 y el grupo 8 en la
  sección 1
- En el tercero, el grupo 2 de la sección 3 contiene sólamente 4 cifras
- Al cuarto mensaje le falta la terminación “=” (los SYNOP deben empezar
  con “AAXX” y terminar con “=”)
- El quinto es cualquier cosa menos un SYNIP

## Flujo de trabajo con Ogimet

Supongamos que necesitamos información meteorológica de la estación Rio
Colorado (identificador WMO: 87736) para lo cual recurrimos a
[Ogimet](https://www.ogimet.com/). Por simplicidad, sólo descargamos los
SYNOP del 1 de febrero del 2026, utilizando este
[link](https://www.ogimet.com/cgi-bin/getsynop?block=87736&begin=202602010300&end=202602012300).

Podremos ver que los mensajes descargados desde Ogimet no son SYNOP
“puros”, sino que tienen un agregado, donde se indica la estación
(87736) y la fecha y hora de la observación. Pero no hay problema,
porque la función
[`parse_ogimet()`](https://ezequiel9315.github.io/synopR/reference/parse_ogimet.md)
fue especialmente diseñada para manejar estas situaciones.

``` r
library(synopR)

data_input <- data.frame(synops = c("87736,2026,02,01,03,00,AAXX 01034 87736 NIL=",
                                    "87736,2026,02,01,06,00,AAXX 01064 87736 NIL=",
                                    "87736,2026,02,01,09,00,AAXX 01094 87736 NIL=",
                                    "87736,2026,02,01,12,00,AAXX 01123 87736 12965 31808 10240 20210 39992 40082 5//// 60104 82075 333 10282 20216 56055 82360=",
                                    "87736,2026,02,01,15,00,AAXX 01154 87736 NIL=",
                                    "87736,2026,02,01,18,00,AAXX 01183 87736 12465 20000 10326 20215 39974 40064 5//// 60001 82100 333 56600 82818=",
                                    "87736,2026,02,01,21,00,AAXX 01214 87736 NIL="))

# Escribit `parse_ogimet(data_input)` es incorrecto!
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

# Se añade la columna 'Year' para el Año
parse_ogimet(data_input$synops) |> show_synop_data(wmo_identifier = 87736, remove_empty_cols = TRUE)
#> # A tibble: 7 × 25
#>   wmo_id  Year Month   Day  Hour Cloud_base_height Visibility Total_cloud_cover
#>   <chr>  <dbl> <dbl> <dbl> <dbl>             <dbl>      <dbl>             <dbl>
#> 1 87736   2026     2     1     3                NA         NA                NA
#> 2 87736   2026     2     1     6                NA         NA                NA
#> 3 87736   2026     2     1     9                NA         NA                NA
#> 4 87736   2026     2     1    12                 9         65                 3
#> 5 87736   2026     2     1    15                NA         NA                NA
#> 6 87736   2026     2     1    18                 4         65                 2
#> 7 87736   2026     2     1    21                NA         NA                NA
#> # ℹ 17 more variables: Wind_direction <dbl>, Wind_speed <dbl>,
#> #   Wind_speed_unit <chr>, Air_temperature <dbl>, Dew_point <dbl>,
#> #   Relative_humidity <dbl>, Station_pressure <dbl>, MSLP_GH <dbl>,
#> #   Precipitation_S1 <dbl>, Precip_period_S1 <dbl>, Cloud_amount_Nh <dbl>,
#> #   Low_clouds_CL <dbl>, Medium_clouds_CM <dbl>, High_clouds_CH <dbl>,
#> #   Max_temperature <dbl>, Min_temperature <dbl>, Cloud_drift_direction <chr>
```

## Limitaciones

### Limitaciones generales

- Que un SYNOP tenga una estructura válida no significa que la
  información contenida en el mensaje sea correcta. El
  post-procesamiento de los datos y sus controles de calidad son tarea
  del usuario.

- El grupo 555, de difusión nacional, es ignorado, puesto que depende de
  cada país. Sin embargo, es posible que en futuras versiones de
  **synopR** se añadan funciones que permitan extraer datos de esta
  sección según las necesidades del usuario.

- No hay soporte para las secciones 222 y 444.
  [`show_synop_data()`](https://ezequiel9315.github.io/synopR/reference/show_synop_data.md)
  incorrectamente decodificará estos mensajes.

### Limitaciones específicas

Los siguientes parámetros meteorológicos no se decodifican
completamente, debido a que no producirían vectores estrictamente
numéricos, o a que el resultado sería muy extenso:

- Visibilidad horizontal `VV`
- Altura de la base de la nube más baja `h`
- Cobertura nubosa `N` y `Nh`, **pero** pueden ser directamente
  interpretados en octas (octavos), salvo cuando adoptan un valor de 9,
  en cuyo caso significa que el cielo no es visible debido a la niebla o
  a otro fenómeno meteorológico
- Tiempo presenta y pasado `ww`, `W1`, `W2`, descripción de las nubes
  `Cl`, `Cm`, `Ch`, descripción del suelo `E` y `E'`

No obstante, **Tablas con códigos están disponibles (en inglés)** en la
sección “Code Tables” para conversiones directas!

También deberías tener en cuenta que:

- Dirección del viento = 99 significa “dirección del viento variable”
- Velocidad del viento mayor a 99 unidades (m/s o nudos) no tienen
  soporte (en tales casos, el resultado final siempre será 99), pero es
  de esperarse que esto no produzca un error
- Si el grupo 2 de la sección 1 informa la humedad relativa en lugar del
  punto de rocío, el valor final en la columna Dew_point será NA
- Para la altura geopotencial, solamente se aceptan los niveles de
  presión de 850, 700 y 500 hPa (para otro nivel, dará NA)
- Se ignorarn los grupos 5 y 9 de la sección 1
- La precipitación imperceptible, codificada como 990, se la transforma
  en 0.01 (mm)
- La profundidad de la nieve, `sss`, se asume que tiene un valor entre 1
  y 996 (cm). ‘997’ significa ‘menos de 0.5 cm’
- Los grupos 5 (por ejemplo 55, 56, 57, etc…), 7, 8 y 9 de la sección 3
  son ignorados
