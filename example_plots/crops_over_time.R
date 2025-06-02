#########
## Required R Functions from ggplot and reshape
#########
library(reshape2)
library(ggplot2)
library(cowplot)
library(ggstream)
library(dplyr)

      

# This data is on crop types, average farm prices (in dollars per tonne), average yields (in kilograms per hectare), 
#total production (in metric tonnes), seeded areas (in both acres and hectares), and the total farm value (in dollars).
farm_data<-read.csv("data/farm_production_dataset.csv")

head(farm_data)

cols<-c(
  "#e1a044",  # Barley
  "#582c0c",  # Beans, all dry (white and coloured)
  "#8a6742",  # Buckwheat
  "#FFD700",  # Canola (rapeseed)
  "#FFD700",  # Corn for grain
  "#EEE600",  # Corn for silage
  "#a7604c",  # Flaxseed
  "#C8A2C8",  # Lentils
  "#BDB76B",  # Mixed grains
  "#DAA520",  # Mustard seed
  "#f2eecb",  # Oats
  "#C0D9AF",  # Peas, dry
  "#a4691b",  # Rye, all
  "#ad7831",  # Rye, fall remaining
  "#b68748",  # Rye, spring
  "#A2D729",  # Soybeans
  "#8B0000",  # Sugar beets
  "#786f70",  # Sunflower seed
  "#f1b046",  # Tame hay
  "#F5DEB3",  # Wheat, all
  "#d6be90",  # Wheat, durum
  "#EEDC82",  # Wheat, spring
  "#e3d9a3"  # Wheat, winter remaining
)




farm_data_summed<-farm_data %>% group_by(REF_DATE, Type.of.crop) %>%  summarise(total_production = sum( Production..metric.tonnes.))

farm_data_summed$total_production_k<-farm_data_summed$total_production/1000000

ggplot(farm_data_summed, aes(REF_DATE, total_production_k, fill = Type.of.crop, label = Type.of.crop, color = Type.of.crop)) +
  geom_stream(type = "ridge", bw=0.6)+
  theme_minimal()+theme(legend.position = "bottom",
                        panel.grid.minor = element_blank())+
  scale_fill_manual(values=cols)+scale_color_manual(values=cols)+
  ylab("Total Production (Millions of Tonnes)")+xlab("Year")


ggsave("figures/farm_stream_plot.png",  width = 10, height = 6)
