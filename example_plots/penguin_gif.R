library(palmerpenguins)
library(ggplot2)
library(gganimate)



penguin_time<-ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g, color = species)
) +
  geom_point()+
  transition_time(year) +
  labs(subtitle = "Year: {frame_time}")+
  theme_bw()+
  labs(
    title = "Body mass and flipper length",
    subtitle = "Dimensions for Adelie, Chinstrap, and Gentoo Penguins Year: {frame_time}",
    x = "Flipper length (mm)", y = "Body mass (g)",
    color = "Species", shape = "Species"
  )+scale_color_manual(values=c("cornflowerblue","orange","black"))


animate(penguin_time, height = 500, width = 800, fps = 10, duration = 10,
        end_pause = 60, res = 100)
anim_save("figures/penguin_time.gif")