
library(reshape2)
library(ggplot2)
library(cowplot)
library(scales)

bfro<-read.csv("data/bfro_locations.csv")

## covert time stamp to date
bfro$date<-sapply(1:nrow(bfro), function(x) strsplit(bfro$timestamp[x], "T")[[1]][1] )
bfro$date<-as.Date(bfro$date)

world <- map_data("world")

canusa <- subset(world, region %in% c("USA","Canada"))
## remove outlier coordinate
canusa<-canusa[which(canusa$long<0),]

ggplot() +
  geom_polygon(data = canusa, aes(x=long, y = lat, group = group), fill="grey90", color="white") +   theme_void()

# order by date so ggplot plots recent on "top"
bfro<-bfro[(order(bfro$date)),]

ggplot() +
  geom_polygon(data = canusa, aes(x=long, y = lat, group = group), fill="grey90", color="black", size=0.25) + 
  geom_point(aes(x = longitude, y = latitude, color=date),bfro, size=0.2) +
  coord_fixed(1)+
  theme_void()+scale_color_distiller(trans = "date", palette = "Spectral", direction = 1, name="Date of Sighting")+
  theme(plot.title = element_text(size = 16, face = "bold"))
ggsave("figures/bigfoot.png",  width = 9, height = 5)


