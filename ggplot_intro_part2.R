#########
## Required R Functions from ggplot and reshape
#########
library(reshape2)
library(ggplot2)
library(cowplot)



##########
# 1. Load example dataset
##########
# This data is on crop types, average farm prices (in dollars per tonne), average yields (in kilograms per hectare), 
#total production (in metric tonnes), seeded areas (in both acres and hectares), and the total farm value (in dollars).
farm_data<-read.csv("data/farm_production_dataset.csv")

## look at data structure
head(farm_data)
nrow(farm_data)
table(farm_data$REF_DATE)

# is it a lot of data so lets just look at one year for now
farm_data_1984<-farm_data[which(farm_data$REF_DATE=="1984"),]
nrow(farm_data_1984)

# how does farm size vary between crop types?
ggplot(farm_data_1984, aes(Type.of.crop, Production..metric.tonnes.))+
  geom_boxplot()

# there is so much text on the x axis so lets rotate it
ggplot(farm_data_1984, aes(Type.of.crop, Production..metric.tonnes.))+
  geom_boxplot()+ 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

# order the plot by maximum farm size
ggplot(farm_data_1984, aes(reorder(Type.of.crop, Production..metric.tonnes., max), Production..metric.tonnes.))+
  geom_boxplot()+ 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

# order the plot by median farm size
ggplot(farm_data_1984, aes(reorder(Type.of.crop, Production..metric.tonnes., median), Production..metric.tonnes.))+
  geom_boxplot()+ 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))


## lets add a layer with the individual measures for each farm (and remove the outlier points plotted by default with boxplots)
ggplot(farm_data_1984, aes(reorder(Type.of.crop, Production..metric.tonnes., median), Production..metric.tonnes.))+
  geom_boxplot(outlier.shape=NA)+ # remove the outlier points that come with the boxplot layer 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  geom_point()

## But the points are overlapping so lets spread them out
ggplot(farm_data_1984, aes(reorder(Type.of.crop, Production..metric.tonnes., median), Production..metric.tonnes.))+
  geom_boxplot(outlier.shape=NA)+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  geom_jitter()

## But not THAT spread out
ggplot(farm_data_1984, aes(reorder(Type.of.crop, Production..metric.tonnes., median), Production..metric.tonnes.))+
  geom_boxplot(outlier.shape=NA)+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  geom_jitter(width=0.25)

## General beautification
ggplot(farm_data_1984, aes(reorder(Type.of.crop, Production..metric.tonnes., median), Production..metric.tonnes.))+
  geom_boxplot(outlier.shape=NA, fill="grey")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  geom_jitter(width=0.25)+
  ylab("Seeded Area (hectares)")+xlab("Province")


## Now lets color by province type, but we will only color the points, boxplots stay grey
head(farm_data_1984)

ggplot(farm_data_1984, aes(reorder(Type.of.crop, Production..metric.tonnes., median), Production..metric.tonnes.))+
  geom_boxplot(outlier.shape=NA, fill="grey")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  geom_jitter(aes(fill=GEO), width=0.25, shape=21)+
  ylab("Seeded Area (hectares)")+xlab("Province")

# move legend
ggplot(farm_data_1984, aes(reorder(Type.of.crop, Production..metric.tonnes., median), Production..metric.tonnes.))+
  geom_boxplot(outlier.shape=NA, fill="grey")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        legend.position = "bottom")+
  geom_jitter(aes(fill=GEO), width=0.25, shape=21)+
  ylab("Seeded Area (hectares)")+xlab("Province")

# What is your favorite province making a lot of? We can highlight it with colour
ggplot(farm_data_1984, aes(reorder(Type.of.crop, Production..metric.tonnes., median), Production..metric.tonnes.))+
  geom_boxplot(outlier.shape=NA, fill="grey")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        legend.position = "bottom")+
  geom_jitter(aes(fill=GEO), width=0.25, shape=21)+
  ylab("Seeded Area (hectares)")+xlab("Province")+
  scale_fill_manual(values=c("grey","red","grey","grey","grey","grey","grey","grey","grey","grey"))



##########
# 2. what about other years?
##########

#here are the minimal bits of code we need to go from raw data to 1986 plot
farm_data_1984<-farm_data[which(farm_data$REF_DATE=="1984"),]
farm_data_1984<-farm_data_1984[which(!(is.na(farm_data_1984$Production..metric.tonnes.))),]

ggplot(farm_data_1984, aes(reorder(Type.of.crop, Production..metric.tonnes., median), Production..metric.tonnes.))+
  geom_boxplot(outlier.shape=NA, fill="grey")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        legend.position = "bottom")+
  geom_jitter(aes(fill=GEO), width=0.25, shape=21)+
  ylab("Seeded Area (hectares)")+xlab("Province")+
  scale_fill_manual(values=c("grey","red","grey","grey","grey","grey","grey","grey","grey","grey"))

## so lets change to another year
farm_data_1983<-farm_data[which(farm_data$REF_DATE=="1983"),]
farm_data_1983_noNA<-farm_data_1983[which(!(is.na(farm_data_1984$Production..metric.tonnes.))),]

ggplot(farm_data_1983_noNA, aes(reorder(Type.of.crop, Production..metric.tonnes., median), Production..metric.tonnes.))+
  geom_boxplot(outlier.shape=NA, fill="grey")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        legend.position = "bottom")+
  geom_jitter(aes(fill=GEO), width=0.25, shape=21)+
  ylab("Seeded Area (hectares)")+xlab("Province")+
  scale_fill_manual(values=c("grey","red","grey","grey","grey","grey","grey","grey","grey","grey"))


# but that is a lot of copying and pasting and duplicated code
# a perfect opportunity to write a FUNCTION


##########
# 3. Write a function to make a plot
##########

#basic structure
function_name <- function(arguments) { 
  functional_code # does the plotting etc
}


# for the farm plot 
farm_hectare_plot <- function(year) {
  # subset data to one year wiht NA removed
  farm_data_yr<-farm_data[which(farm_data$REF_DATE==year),]
  farm_data_yr_noNA<-farm_data_yr[which(!(is.na(farm_data_yr$Production..metric.tonnes.))),]
  # make plot based on the argument year
  ggplot(farm_data_yr_noNA, aes(reorder(Type.of.crop, Production..metric.tonnes., median), Production..metric.tonnes.))+
    geom_boxplot(outlier.shape=NA, fill="grey")+
    theme_bw()+
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
          legend.position = "bottom")+
    geom_jitter(aes(fill=GEO), width=0.25, shape=21)+
    ylab("Seeded Area (hectares)")+xlab("Province")+ggtitle(year)+
    scale_fill_manual(values=c("grey","red","grey","grey","grey","grey","grey","grey","grey","grey"))
}


# run it on a year
farm_hectare_plot(1912) #simpler times
farm_hectare_plot(1947)
farm_hectare_plot(1984)
