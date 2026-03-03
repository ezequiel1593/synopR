library(hexSticker)
library(ggplot2)
library(showtext) # Para fuentes personalizadas

font_add_google("Roboto", "roboto")
font_add_google("Fira Code", "firacode")
showtext_auto()

# Datos para el texto SYNOP (izquierda)
df_code <- data.frame(
  text = c("AAXX 01183", "87736 11463", "41813 10330", "39982 40072"),
  x = rep(-0.35, 4),
  y = seq(0.8, 0.2, length.out = 4)
)

# Datos para la tabla (derecha)
df_table_border <- data.frame(
  x = c(0.65, 1.25, 0.65, 0.65),
  y = c(0.8, 0.8, 0.1, 0.8),
  xend = c(1.25, 1.25, 1.25, 0.65),
  yend = c(0.8, 0.1, 0.1, 0.1)
)

# Líneas para las divisiones interiores (verticales)
df_table_v_lines <- data.frame(
  x = c(0.85, 1.05),
  y = c(0.1, 0.1),
  xend = c(0.85, 1.05),
  yend = c(0.8, 0.8)
)

# Líneas para las divisiones interiores (horizontales)
df_table_h_lines <- data.frame(
  x = c(0.65, 0.65, 0.65),
  y = c(0.6, 0.4, 0.2),
  xend = c(1.25, 1.25, 1.25),
  yend = c(0.6, 0.4, 0.2)
)

p <- ggplot() +

  geom_text(data = df_code, aes(x = x, y = y, label = text),
            family = "firacode", color = "white", alpha = 0.4, size = 3, hjust = 0) +

  geom_segment(aes(x = 0.15, y = 0.5, xend = 0.55, yend = 0.5),
               arrow = arrow(length = unit(0.4, "cm"), type = "closed"),
               color = "white", size = 2) +

  geom_segment(data = df_table_border, aes(x = x, y = y, xend = xend, yend = yend),
               color = "white", size = 1.3) +

  geom_segment(data = df_table_v_lines, aes(x = x, y = y, xend = xend, yend = yend),
               color = "white", size = 1.1) +

  geom_segment(data = df_table_h_lines, aes(x = x, y = y, xend = xend, yend = yend),
               color = "white", size = 1.1) +

  scale_x_continuous(limits = c(-0.4, 1.3)) +
  scale_y_continuous(limits = c(0, 1)) +
  theme_void() +
  theme_transparent()

# Sticker final
sticker(p, package="synopR",
        p_size=28,
        p_family = "roboto",
        p_color = "white",
        p_y = 1.45,
        s_x=1, s_y=0.85,
        s_width=1.4, s_height=1,
        h_fill="#15803D",
        h_color="#166534",
        h_size = 1.8,
        spotlight = TRUE,
        l_alpha = 0.15,
        filename="man/figures/logo.png")

