# this sourced code call for these libraries
library(ggplot2)
library(reshape2)
library(RColorBrewer)
library(scales)
library(gridExtra)


# Pull some data for a volcano plot
toptable<-read.csv("data/differential_expression.csv")
head(toptable)



#### 1 set a custom theme for both plots with larger text
th <-   theme(axis.text=element_text(size=12),
              axis.title=element_text(size=14),
              strip.text.x = element_text(size = 12),
              legend.text=element_text(size=12),
              legend.title=element_text(size=14))


#### 2 shape the pvalue and fold change values for plotting

# anywhere this script says "delta beta" think fold change. I use DNA methylation data and therefoe delta betas instead of fold change

# build a data frame that will form the basis for the plots
volcano<-data.frame(Pvalue=toptable$P.Value, Delta_Beta=toptable$logFC)

# Set thresholds for lines on the plot
dB<-2 #delta beta cutoff (foldchange)
Pv<-0.005 #Pvalue cutoff


# Pull the significant number of genes for a helpful output statement 
# this is optional but I like when I write functions for them to have output statements as well as a plot
sta_delbeta<-toptable$logFC[which(toptable$P.Value<=Pv)] 
sta_delbeta<-sta_delbeta[abs(sta_delbeta)>=dB]
print(paste("Increased Expression", length(sta_delbeta[which(sta_delbeta>=dB)]), sep=": "))
print(paste("Decreased Expression", length(sta_delbeta[which(sta_delbeta<=(-dB))]) , sep=": "))

# Final data shape for scatter and bar plot, this removes NA values
volcano<-volcano[complete.cases(volcano),]



#### 3 Set the color labels based in the p value and delta bet thresholds

# This makes life so much easier when adjusting colors or levels at which colors change
color3<-sapply(1:nrow(volcano), function(x) if(volcano$Pvalue[x]<=Pv){
  if(abs(volcano$Delta_Beta[x])>dB){
    if(volcano$Delta_Beta[x]>dB){"Increased Expression\n(with Potential Biological Impact)"}else{"Decreased Expression\n (with Potential Biological Impact)"}
  }else{if(volcano$Delta_Beta[x]>0){"Increased Expression"}else{"Decreased Expression"}}}else{"Not Significantly Different"})

volcano$color3<-color3

# Here I set a custom color palette for the plot
# so even if you don't have genes exceeding the thresholds in a color catagory the pattern will be maintained across volcano plots made with your function
myColors <- c(muted("red", l=80, c=30),"red",muted("blue", l=70, c=40),"blue", "grey")

color_possibilities<-c("Decreased Expression",
                       "Decreased Expression\n (with Potential Biological Impact)",
                       "Increased Expression",
                       "Increased Expression\n(with Potential Biological Impact)",
                       "Not Significantly Different")

names(myColors) <- color_possibilities
colscale <- scale_color_manual(name = "Wildtype vs Mutant",
                               values = myColors, drop = FALSE)



#### 4 make the volcano
volcano_plot<-ggplot(volcano, aes(Delta_Beta, -log10(Pvalue), color=color3))+
  geom_point(shape=19, size=1)+theme_bw()+
  colscale+
  geom_vline(xintercept=c(-dB,dB), color="grey60")+
  geom_hline(yintercept=-log10(Pv), color="grey60")+
  ylab("P Value (-log10)")+xlab("Fold Change")+xlim(-6, 6)+
  theme(plot.margin=unit(c(1,1,1,2),"cm"))+ th+
  guides(color = guide_legend(override.aes = list(size = 4)))

# the plot is assigned to and object so it can be combined with other plots in a grid, but to see it in R studio
volcano_plot

ggsave("figures/volcano.png",  width = 9, height = 5)


