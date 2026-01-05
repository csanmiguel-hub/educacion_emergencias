##1. Cargar dataset

edu_df <- read.csv("/Users/julianavillabonaardila/Rwork/data_simulada_educacion.csv", stringsAsFactors = FALSE)

#Cargar e instalar librerías
install.packages("dplyr")
install.packages("tidyverse")
install.packages("lubridate")
library(dplyr)
library(tidyverse)
library(lubridate)


##2. Exploración de datos

glimpse(edu_df)
summary(edu_df)

unique(edu_df$Municipio)
edu_df %>% 
  count(Municipio) %>% 
  arrange(Municipio)

edu_df %>% 
  group_by(Genero) %>% 
  summarise(Total = n())

duplicados <- sum(duplicated(edu_df))

hist(edu_df$Edad, 
     main = "Detección de Outliers",
     xlab = "Edad", 
     col = "Red", 
     breaks = 20)


#Alertas encontradas 

#1. Fecha_Intervevncion no esta cargada con el tipo fecha 
#2. Edad tienen un mínimo negativo 
#3. Datos faltantes en Costo_Intervencion 
#4. Estandarizar nombres de municipios en valores únicos
#5. Estandarizar genero 
#6. 50 entradas duplicadas
#7. Datos atípicos en edad, negativos y mayores a 100 años

## 3.Copia de seguridad 

edu_clean <- edu_df

## 4. Limpieza de duplicados y tipo fecha
edu_clean <- edu_clean %>% distinct()

edu_clean <- edu_clean %>%
  mutate(Fecha_Intervencion = as.Date(Fecha_Intervencion))
  summary(edu_clean)
    
##5. Estandarización municipios
  
  edu_clean <- edu_clean %>%
  mutate(
    Municipio = str_trim(Municipio),
    Municipio = str_to_title(Municipio)
  ) %>%
    mutate(Municipio = case_when(
      Municipio == "Cucuta" ~ "Cúcuta",
      Municipio == "Tibú" ~ "Tibú", 
      is.na(Municipio) ~ "Sin Información", 
      Municipio == "Na" ~ "Sin Información", 
      TRUE ~ Municipio
    ))
 
##6. Estandarización Genero
  
  edu_clean <- edu_clean %>%
    mutate(Genero_Unificado = case_when(
      Genero %in% c("F", "mujer", "Femenino") ~ "Femenino",
      Genero %in% c("M", "hombre", "Masculino") ~ "Masculino",
      Genero %in% c("No binario") ~ "No binario",
      TRUE ~ "Sin Dato"
    ))
 
##7. Eliminar datos atípicos en edad
  
   edu_clean <- edu_clean %>%
    mutate(Edad_clean = ifelse(Edad < 0 | Edad > 100, NA, Edad))
   
##8. Asignar valor a valores vacíos en costo por tipo de actividad
   
   edu_clean <- edu_clean %>%
     group_by(Tipo_Actividad) %>%
     mutate(Costo_Media = ifelse(is.na(Costo_Intervencion),
                                    mean(Costo_Intervencion, na.rm = TRUE),
                                    Costo_Intervencion)) %>%
     ungroup()
   
  
##9. Crear nueva variable por grupos etarios
   
   edu_clean <- edu_clean %>%
     mutate(Grupo_Etario = case_when(
       Edad_clean <= 5 ~ "Primera Infancia",
       Edad_clean > 5 & Edad_clean <= 11 ~ "Infancia",
       Edad_clean > 11 & Edad_clean <= 17 ~ "Adolescencia",
       Edad_clean > 17 & Edad_clean <= 28 ~ "Joven",
       Edad_clean > 28 & Edad_clean <= 59 ~ "Adulto",
       TRUE ~ "Adulto Mayor"
     ))
   
##10. Exportar csv limpio
   
   df_final <- edu_clean %>%
     select(ID_Beneficiario, Fecha_Intervencion, Municipio, Tipo_Actividad, 
            Genero= Genero_Unificado, Edad = Edad_clean, Grupo_Etario, 
            Tipo_Poblacion, Costo_Intervencion, Costo_Media, Satisfaccion = Nivel_Satisfaccion)
   
   write.csv(df_final, "data_limpia_proyecto_educativo.csv", row.names = FALSE, fileEncoding = "UTF-8")
   
