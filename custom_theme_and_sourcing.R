library(reshape2)
library(ggplot2)

##########
## Remake plot from yesterday
##########

# Read in Data
geneExp <- read.table("data/GSE4051_data.tsv", stringsAsFactors = FALSE, sep = "\t", header=T)
sampleInfo <- read.table("data/GSE4051_design.tsv", stringsAsFactors = FALSE, sep = "\t", header=T)

# Shape and format
geneExp_twoGene<-geneExp[c("1429028_at","1416119_at"),]
geneExp_twoGene$gene<-rownames(geneExp_twoGene)
geneExp_twoGene_longform<-melt(geneExp_twoGene)
colnames(geneExp_twoGene_longform)<-c("gene", "sidChar","expression")
data_for_plot<-merge(sampleInfo,geneExp_twoGene_longform, by="sidChar" )

ggplot(data_for_plot, aes(gene, expression))+
  geom_violin(fill="grey85", color="white")+
  geom_boxplot(aes(fill=gType),width=0.25)+
  geom_point(aes(fill=gType),shape=21, size=2, position = position_jitter(width=0.05))+
  theme_bw()+ facet_wrap(~gType)+ xlab("Gene")+ylab("Gene Expression")+
  scale_fill_manual(values=c("#41ab5d","#bdbdbd"), name="Genotype")
 



#open pretty_plots.R

source("pretty_plots.R")

# add the custom color palette
ggplot(data_for_plot, aes(gene, expression))+
  geom_violin(fill="grey85", color="white")+
  geom_boxplot(aes(fill=gType),width=0.25)+
  geom_point(aes(fill=gType),shape=21, size=2, position = position_jitter(width=0.05))+
  theme_bw()+ facet_wrap(~gType)+xlab("Gene")+ylab("Gene Expression")+
  fillscale_gtype

# add custom theme
ggplot(data_for_plot, aes(gene, expression))+
  geom_violin(fill="grey85", color="white")+
  geom_boxplot(aes(fill=gType),width=0.25)+
  geom_point(aes(fill=gType),shape=21, size=2, position = position_jitter(width=0.05))+
  theme_bw()+ facet_wrap(~gType)+xlab("Gene")+ylab("Gene Expression")+
  fillscale_gtype + th


# Copy and paste before tinkering
# try and look along development and between genes


##############
## add text to a plot
##############

data_for_plot_onegene<-data_for_plot[which(data_for_plot$gene=="1429028_at"),]


ggplot(data_for_plot_onegene, aes(gType, expression))+
  geom_violin(fill="grey85", color="white")+
  geom_boxplot(aes(fill=gType),width=0.25)+
  geom_point(aes(fill=gType),shape=21, size=2, position = position_jitter(width=0.05))+
  theme_bw()+xlab("Gene")+ylab("Gene Expression")+
  fillscale_gtype + th

# calculate medians 
med_Gene_gType<-tapply(data_for_plot$expression, list(data_for_plot$gType), median)
med_Gene_gType

# difference in medians
difference<-med_Gene_gType[1]-med_Gene_gType[2]
lab<-paste("difference = ", round(difference, 3) )

ggplot(data_for_plot_onegene, aes(gType, expression))+
  geom_violin(fill="grey85", color="white")+
  geom_boxplot(aes(fill=gType),width=0.25)+
  geom_point(aes(fill=gType),shape=21, size=2, position = position_jitter(width=0.05))+
  theme_bw()+xlab("Gene")+ylab("Gene Expression")+
  fillscale_gtype + th +
  annotate("text", x=1.5, y=9.75, label = lab, size = 5, color="grey20")
  


  
