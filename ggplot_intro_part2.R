#########
## Required R Functions from ggplot and reshape
#########
library(reshape2)
library(ggplot2)
library(cowplot)



##########
# 1. Load example dataset
##########
# This data is ....... [farming]
farm_data<-read.csv("data/farm_production_dataset.csv")


## look at data structure
head(farm_data)
nrow(farm_data)
table(farm_data$REF_DATE)

# is it a lot of data so lets just look at one year for now
farm_data_1984<-farm_data[which(farm_data$REF_DATE=="1984"),]
nrow(farm_data_1984)

# how does farm size vary between crop types?
ggplot(farm_data_1984, aes(Type.of.crop, Seeded.area..hectares.))+
  geom_boxplot()

# why that warning?
farm_data_1984$Seeded.area..acres.
# there are some NA values in the data so lets remove the rows for those farms

farm_data_1984_noNA<-farm_data_1984[which(!(is.na(farm_data_1984$Seeded.area..hectares.))),]

# plot with new data frame
ggplot(farm_data_1984_noNA, aes(Type.of.crop, Seeded.area..hectares.))+
  geom_boxplot()


# there is so much text on the x axis so lets rotate it
ggplot(farm_data_1984_noNA, aes(Type.of.crop, Seeded.area..hectares.))+
  geom_boxplot()+ 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

# order the plot by maximum farm size
ggplot(farm_data_1984_noNA, aes(reorder(Type.of.crop, Seeded.area..hectares., max), Seeded.area..hectares.))+
  geom_boxplot()+ 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

# order the plot by median farm size
ggplot(farm_data_1984_noNA, aes(reorder(Type.of.crop, Seeded.area..hectares., median), Seeded.area..hectares.))+
  geom_boxplot()+ 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))


## lets add a layer with the individual measures for each farm (and remove the outlier points plotted by default with boxplots)
ggplot(farm_data_1984_noNA, aes(reorder(Type.of.crop, Seeded.area..hectares., median), Seeded.area..hectares.))+
  geom_boxplot(outlier.shape=NA)+ # remove the outlier points that come with the boxplot layer 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  geom_point()

## But the points are overlapping so lets spread them out
ggplot(farm_data_1984_noNA, aes(reorder(Type.of.crop, Seeded.area..hectares., median), Seeded.area..hectares.))+
  geom_boxplot(outlier.shape=NA)+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  geom_jitter()

## But not THAT spread out
ggplot(farm_data_1984_noNA, aes(reorder(Type.of.crop, Seeded.area..hectares., median), Seeded.area..hectares.))+
  geom_boxplot(outlier.shape=NA)+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  geom_jitter(width=0.25)

## General beautification
ggplot(farm_data_1984_noNA, aes(reorder(Type.of.crop, Seeded.area..hectares., median), Seeded.area..hectares.))+
  geom_boxplot(outlier.shape=NA)+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  geom_jitter(width=0.25)+
  ylab("Seeded Area (hectares)")+xlab("Province")


## Now lets color by province type, but we will only color the points
head(farm_data_1984_noNA)

ggplot(farm_data_1984_noNA, aes(reorder(Type.of.crop, Seeded.area..hectares., median), Seeded.area..hectares.))+
  geom_boxplot(outlier.shape=NA)+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  geom_jitter(aes(fill=GEO), width=0.25, shape=21)+
  ylab("Seeded Area (hectares)")+xlab("Province")

# move legend
ggplot(farm_data_1984_noNA, aes(reorder(Type.of.crop, Seeded.area..hectares., median), Seeded.area..hectares.))+
  geom_boxplot(outlier.shape=NA)+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        legend.position = "bottom")+
  geom_jitter(aes(fill=GEO), width=0.25, shape=21)+
  ylab("Seeded Area (hectares)")+xlab("Province")

# What is your favorite province making a lot of? We can highlight it with colour
ggplot(farm_data_1984_noNA, aes(reorder(Type.of.crop, Seeded.area..hectares., median), Seeded.area..hectares.))+
  geom_boxplot(outlier.shape=NA)+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        legend.position = "bottom")+
  geom_jitter(aes(fill=GEO), width=0.25, shape=21)+
  ylab("Seeded Area (hectares)")+xlab("Province")+
  scale_fill_manual(values=c("grey","red","grey","grey","grey","grey","grey","grey","grey","grey"))



