#########
## Required R Functions from ggplot and reshape
#########
library(reshape2)
library(ggplot2)
library(cowplot)


##########
# 1. Load example dataset
##########
# This data contains expression values for two genes measured at different developmental stages and in different genetic conditions
# Rows are genes; columns are samples

geneExp <- read.csv("data/GSE4051_2gene.csv", stringsAsFactors = FALSE, header=T)
head(geneExp)

# This data contains sample information 
# Rows are samples; columns are meta data variables (ID, development stage, genotype)
sampleInfo <- read.table("data/GSE4051_design.tsv", stringsAsFactors = FALSE, sep = "\t", header=T)
head(sampleInfo)


##########
# 2. Melt then Merge 
##########

# Melt it! Take wide format data and make it long format
geneExp_twoGene_longform<-melt(geneExp)
colnames(geneExp_twoGene_longform)<-c("gene", "sidChar","expression")

# What did melt even do though?
geneExp_twoGene
head(geneExp_twoGene_longform)
# Smushed it pretty much... this format is generally what ggplot prefers. 
# Factors (like gene) that you might like as categories along the X or values along the y (expression) should be in columns not rows

# what about sample information, that is important for the plotting
head(sampleInfo)

# Merge it!
# We want one big data frame, which contains the sample information and the expression values
# Here were will merge the sample information and expression values (melted) into one data frame
# Melting then merging is a common steps for data managing into ggplot
data_for_plot<-merge(sampleInfo,geneExp_twoGene_longform, by="sidChar" )
head(geneExp_twoGene_longform)
head(data_for_plot)


#############
# 3. Time to plot
#############

# Set the basic plot layout and axis (no plot type specified here)

# basic format: ggplot(data, aes(x_axis, y_axis))
ggplot(data_for_plot, aes(devStage, expression))  

### Scatter plot
ggplot(data_for_plot, aes(devStage, expression))+
  geom_point()# plot data as points

# what are those two obvious groups?
ggplot(data_for_plot, aes(devStage, expression, color=gene))+
  geom_point()

# but you can color by any column
ggplot(data_for_plot, aes(devStage, expression, color=devStage))+
  geom_point()

# Lets try different plot type
ggplot(data_for_plot, aes(devStage, expression, color=gene))+
  geom_boxplot()




# Nothing wrong with the boxplots, but lets go back to the points and try another way to split the data
# Instead of coloring by gene lets make a plot per gene
# This will focus the view on the changes over development and not the differences between genes. 
# so we can shift how we show the same data to emphasize those difference over development

ggplot(data_for_plot, aes(devStage, expression))+
  geom_point()

# facets splits the data into several of the same plot type
ggplot(data_for_plot, aes(devStage, expression))+
  geom_point()+
  facet_wrap(~gene)

# Now color has been freed up and can now be used for something else
# Remember we also have to genotpes of animals
ggplot(data_for_plot, aes(devStage, expression, color=gType))+
  geom_point()+
  facet_wrap(~gene)


# Pick better colors? 
# http://colorbrewer2.org
ggplot(data_for_plot, aes(devStage, expression, color=gType))+
  geom_point()+
  facet_wrap(~gene)+
  scale_color_manual(values=c("#41ab5d","#bdbdbd"))

# Make the legend Title meaningful
ggplot(data_for_plot, aes(devStage, expression, color=gType))+
  geom_point()+
  facet_wrap(~gene)+
  scale_color_manual(values=c("#41ab5d","#bdbdbd"), name="Genotype")


# I love ggplot but I don't like the default grey background
# This can be changed easily with some default theme settings (you can also start building our own theme someday)
# Generally I don't like the grey background because 
# I like to use grey for the WT or control points in my plots. To me grey suggests this is the less interesting group

ggplot(data_for_plot, aes(devStage, expression, color=gType))+
  geom_point()+
  facet_wrap(~gene)+
  scale_color_manual(values=c("#41ab5d","#bdbdbd"))+
  theme_bw() # my favourite

ggplot(data_for_plot, aes(devStage, expression, color=gType))+
  geom_point()+
  facet_wrap(~gene)+
  scale_color_manual(values=c("#41ab5d","#bdbdbd"))+
  theme_classic() # not my favourite, but also nice


# bigger points please
ggplot(data_for_plot, aes(devStage, expression, color=gType))+
  geom_point(size=2)+
  facet_wrap(~gene)+
  scale_color_manual(values=c("#41ab5d","#bdbdbd"))+
  theme_bw()

# since we have longtidunal data a trend line makes sense
ggplot(data_for_plot, aes(devStage, expression, color=gType))+
  geom_point(size=2)+
  facet_wrap(~gene)+
  scale_color_manual(values=c("#41ab5d","#bdbdbd"))+
  theme_bw()+
  geom_line()


# NOPE that isn't right! - why not? Here I would google image search for what you want 

# 'ggplot mean trend line'
#https://tinyurl.com/y244dd4t

ggplot(data_for_plot, aes(devStage, expression, color=gType, group=gType))+
  geom_point(size=2)+
  facet_wrap(~gene)+
  scale_color_manual(values=c("#41ab5d","#bdbdbd"))+
  theme_bw()+
  stat_summary(fun.y=median, geom="smooth", aes(group=gType), lwd=1)

#geom_line tries to connect all the individual data points, where as stat summary, summarizes the groups to a value. Here we chose median


# Lets forget about the developmental data and look instead of differences between genes

# basic format: ggplot(data, aes(x_axis, y_axis))
ggplot(data_for_plot, aes(gene, expression))+
  geom_point(size=2)+
  theme_bw()

# Add a boxplot
ggplot(data_for_plot, aes(gene, expression))+
  geom_boxplot()+
  geom_point(size=2)+
  theme_bw()

# Lets facet by genotype again
ggplot(data_for_plot, aes(gene, expression, color=gType))+
  geom_boxplot()+
  geom_point(size=2)+
  theme_bw()+ facet_wrap(~gType)+
  scale_color_manual(values=c("#41ab5d","#bdbdbd"), name="Genotype")

# the points are ovelapping so lets spread them out with jitter
ggplot(data_for_plot, aes(gene, expression, color=gType))+
  geom_boxplot()+
  geom_point(size=2, position = position_jitter(width=0.05))+
  theme_bw()+ facet_wrap(~gType)+
  scale_color_manual(values=c("#41ab5d","#bdbdbd"), name="Genotype")

# Violin plot with the boxplot to show the data distribution
ggplot(data_for_plot, aes(gene, expression, color=gType))+
  geom_violin()+
  geom_boxplot(width=0.25)+
  geom_point(size=2, position = position_jitter(width=0.05))+
  theme_bw()+ facet_wrap(~gType)+
  scale_color_manual(values=c("#41ab5d","#bdbdbd"), name="Genotype")


# generally nicer looking
# aes statements can also be added to specific layers of the plot but not others
# here we will color the boxplot and points but not the violin
ggplot(data_for_plot, aes(gene, expression))+
  geom_violin()+
  geom_boxplot(aes(color=gType),width=0.25)+
  geom_point(aes(color=gType),size=2, position = position_jitter(width=0.05))+
  theme_bw()+ facet_wrap(~gType)+
  scale_color_manual(values=c("#41ab5d","#bdbdbd"), name="Genotype")

## instead of color you can fill an element (note the scale_color_manual change to fill aswell)
ggplot(data_for_plot, aes(gene, expression))+
  geom_violin()+
  geom_boxplot(aes(fill=gType),width=0.25)+
  geom_point(aes(fill=gType),shape=21, size=2, position = position_jitter(width=0.05))+
  theme_bw()+ facet_wrap(~gType)+
  scale_fill_manual(values=c("#41ab5d","#bdbdbd"), name="Genotype")

## adjusting the look of the violin
ggplot(data_for_plot, aes(gene, expression))+
  geom_violin(fill="grey85", color="white")+
  geom_boxplot(aes(fill=gType),width=0.25)+
  geom_point(aes(fill=gType),shape=21, size=2, position = position_jitter(width=0.05))+
  theme_bw()+ facet_wrap(~gType)+
  scale_fill_manual(values=c("#41ab5d","#bdbdbd"), name="Genotype")

## Edit axis labels
ggplot(data_for_plot, aes(gene, expression))+
  geom_violin(fill="grey85", color="white")+
  geom_boxplot(aes(fill=gType),width=0.25)+
  geom_point(aes(fill=gType),shape=21, size=2, position = position_jitter(width=0.05))+
  theme_bw()+ facet_wrap(~gType)+
  scale_fill_manual(values=c("#41ab5d","#bdbdbd"), name="Genotype")+
  xlab("Gene")+ylab("Gene Expression")



## Now that we have something nice lets save it
ggsave("figures/violin_genotype_twogene.pdf",  width = 8, height = 6)
ggsave("figures/violin_genotype_twogene.jpeg",  width = 8, height = 6)




  


## Another way to look at the same data
ggplot(data_for_plot, aes(expression, fill=gene))+
  geom_density()+theme_bw()+
  scale_fill_manual(values=c("#41ab5d","#bdbdbd"), name="Genotype")+
  xlab("Gene Expression")

# add transparency with alpha
ggplot(data_for_plot, aes(expression, fill=gene))+
  geom_density(alpha=0.5)+theme_bw()+
  scale_fill_manual(values=c("#41ab5d","#bdbdbd"), name="Genotype")+
  xlab("Gene Expression")


#################
# 4. Combining two plots (using cowplot)
#################

## plot 1
# Expression of both genes over development
data_for_plot_onegene<-data_for_plot[which(data_for_plot$gene=="1429028_at"),]


ggplot(data_for_plot_onegene, aes(devStage, expression))+
  geom_point(aes(fill=gType),size=3, shape=21, color="black")+
  scale_fill_manual(values=c("#41ab5d","#bdbdbd"), name="Genotype")+
  theme_bw()+xlab("Developmental Stage")+ylab("Gene Expression")

# assign the plot to a object name
scatter<-ggplot(data_for_plot_onegene, aes(devStage, expression))+
  geom_point(aes(fill=gType),size=3, shape=21, color="black")+
  scale_fill_manual(values=c("#41ab5d","#bdbdbd"), name="Genotype")+
  theme_bw()+xlab("Developmental Stage")+ylab("Gene Expression")

## plot 2
# Expression values density plot

ggplot(data_for_plot_onegene, aes(expression))+
  geom_density(aes(fill=gType),color="black", alpha=0.5)+
  scale_fill_manual(values=c("#41ab5d","#bdbdbd"), name="Genotype")+
  theme_bw()+xlab("Gene Expression")

ggplot(data_for_plot_onegene, aes(expression))+
  geom_density(aes(fill=gType),color="black", alpha=0.5)+
  scale_fill_manual(values=c("#41ab5d","#bdbdbd"), name="Genotype")+
  theme_bw()+xlab("Gene Expression")+coord_flip()

density<-ggplot(data_for_plot_onegene, aes(expression))+
  geom_density(aes(fill=gType),color="black", alpha=0.5)+
  scale_fill_manual(values=c("#41ab5d","#bdbdbd"), name="Genotype")+
  theme_bw()+xlab("Gene Expression")+coord_flip()



# remove scatter legend
scatter<-ggplot(data_for_plot_onegene, aes(devStage, expression))+
  geom_point(aes(fill=gType),size=3, shape=21, color="black")+
  scale_fill_manual(values=c("#41ab5d","#bdbdbd"), name="Genotype", guide="none")+
  theme_bw()+xlab("Developmental Stage")+ylab("Gene Expression")

#remove density xlab
density<-ggplot(data_for_plot_onegene, aes(expression))+
  geom_density(aes(fill=gType),color="black", alpha=0.5)+
  scale_fill_manual(values=c("#41ab5d","#bdbdbd"), name="Genotype")+
  theme_bw()+xlab("")+coord_flip()

plot_grid(scatter, density, ncol=2, rel_widths=c(2,1))


