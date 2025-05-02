####################
## Sourcing a complex script
###################

# Typically I source complex functions of plots that I will want to use for many different analyses
source("volcano.R") 
# Open volcano.R and see that is it 70 lines, that means it is 70 lines I don't have to explicitly repeat everytime I want to make a volcano plot

# this sourced code call for these libraries
library(ggplot2)
library(reshape2)
library(RColorBrewer)
library(scales)
library(gridExtra)


# Pull some data for a volcano plot
toptable<-read.csv("data/differential_expression.csv")
head(toptable)

# make a volcano
# The function I wrote is called makeVolcano which I now feed new data into
# arguments that makeVolcano takes are "pvalue, deltabeta, dB_threshold, pval_threshold, legend_title, xlimit" 
makeVolcano(toptable$P.Value, toptable$logFC, 2, 0.005, "Wildtype vs Mutant", 6)




####################
## Step by step breakdown of a complex plot (volcano plot example)
###################

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


  
#### 5 make the scree plot (histogram of pvalues above volcano plot)

  pval_dis<-ggplot()+geom_histogram(aes(volcano$Pvalue),fill="grey90", color="black")+theme_bw()+xlab("Nominal P Value")+th+
    theme(plot.margin=unit(c(1,8.75,-0.6,1.5),"cm"))+ylab("CpG Count")
  
  pval_dis

  

#### 6 Combine with grid arrange
grid.arrange(pval_dis, volcano_plot, ncol=1,heights = c(2, 6))#





####################
## EXAMPLE 2
###################
#The "dslabs" package contains the data for this plot 

install.packages("dslabs")

library(dslabs)
library(dplyr)
library(ggplot2)
data(us_contagious_diseases)
head(us_contagious_diseases)

the_disease <- "Measles"
dat <- us_contagious_diseases %>%
  filter(!state%in%c("Hawaii","Alaska") & disease == the_disease) %>%
  mutate(rate = count / population * 10000 * 52 / weeks_reporting) 

jet.colors <- colorRampPalette(c("#F0FFFF", "cyan", "#007FFF", "yellow", "#FFBF00", "orange", "red", "#7F0000"), bias = 2.25)

dat %>% mutate(state = reorder(state, desc(state))) %>%
  ggplot(aes(year, state, fill = rate)) +
  geom_tile(color = "white", size = 0.35) +
  scale_x_continuous(expand = c(0,0)) +
  scale_fill_gradientn(colors = jet.colors(16), na.value = 'white') +
  geom_vline(xintercept = 1963, col = "black") +
  theme_minimal() + 
  theme(panel.grid = element_blank()) +
  coord_cartesian(clip = 'off') +
  ggtitle(the_disease) +
  ylab("") +
  xlab("") +  
  theme(legend.position = "bottom", text = element_text(size = 8)) + 
  annotate(geom = "text", x = 1963, y = 50.5, label = "Vaccine introduced", size = 3, hjust = 0)


####################
## EXAMPLE 3
###################

load("data/gene_expression_PCA_data.RData")

library(gridExtra)
library(reshape2)
library(ggplot2)

# This is another example where I source a script. Take a look into Heat_scree_plot_generic.R to understand the elements to bring this plot together
source("Heat_scree_plot_generic.R")

head(sampleInfo)

sampleInfo$devStage_days<-as.factor(sampleInfo$devStage)
levels(sampleInfo$devStage_days)<-c(30,-16,10,2,6)
sampleInfo$devStage_days<-as.numeric(as.character(sampleInfo$devStage_days))

meta_categorical <- sampleInfo[, c(2,4)]  # input column numbers in meta that contain categorical variables
meta_continuous <- as.data.frame(sampleInfo[, c(5)] ) # input column numbers in meta that contain continuous variables
colnames(meta_categorical) <- c("Subject","Genotype")
colnames(meta_continuous) <- c("Age (Days)")

PCs_to_view<-10

ord<-1:length(c(colnames(meta_categorical),colnames(meta_continuous)))# Order for the meat data variables

heat_scree_plot(Loadings, Importance, 3.5, 2.25)


####################
## EXAMPLE 4
###################

library(gridExtra)
library(grid)
library(ggplot2)

## Generate data to look like mutational data from patients
    set.seed(1)
    pt_id = c(1:279) # DEFINE PATIENT IDs
    smoke = rbinom(279,1,0.5) # DEFINE SMOKING STATUS
    hpv = rbinom(279,1,0.3) # DEFINE HPV STATUS
    data = data.frame(pt_id, smoke, hpv) # PRODUCE DATA FRAME
    
    data$site = sample(1:4, 279, replace = T)
    data$site[data$site == 1] = "Hypopharynx"
    data$site[data$site == 2] = "Larynx"
    data$site[data$site == 3] = "Oral Cavity"
    data$site[data$site == 4] = "Oropharynx"
    data$site_known = 1 
    
    data$freq = sample(1:1000, 279, replace = F)

## Make the actual plot
bar <- ggplot(data, aes(x = pt_id, y = freq)) + geom_bar(stat = "identity", color="#293c59", fill="#293c59") +theme_classic()+     
  theme(axis.title.x = element_blank(), axis.ticks.x = element_blank(), axis.text.x = element_blank()) + 
  ylab("Number of Mutations")
# DEFINE BINARY PLOTS

smoke_status <- ggplot(data, aes(x=pt_id, y=smoke)) + geom_bar(fill="#bf1e15",stat="identity") + 
  theme(legend.position = "none", axis.title.x = element_blank(), axis.ticks.x = element_blank(), axis.text.x = element_blank(),
        panel.grid.major = element_blank(), panel.grid.minor = element_blank()) + ylab("Smoking\nStatus")

hpv_status <- ggplot(data, aes(x=pt_id, y = hpv)) + geom_bar(fill="#bf1e15",stat="identity") + 
  theme(legend.position = "none", axis.title.x = element_blank(), axis.ticks.x = element_blank(), axis.text.x = element_blank(),
        panel.grid.major = element_blank(), panel.grid.minor = element_blank()) + ylab("HPV\nStatus")

site_status <- ggplot(data, aes(x=pt_id, y=site_known, fill = site)) +     geom_bar(stat="identity")+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+ 
  scale_fill_brewer(palette = "Spectral", name="Sample Site")+
  xlab("Patient ID")+ylab("Sample\nSite")


# move legend to the side
get_leg = function(a.gplot){
  tmp <- ggplot_gtable(ggplot_build(a.gplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  legend
}

# Get legend as a separate grob
leg = get_leg(site_status)

# Add a theme element to change the plot margins to remove white space between the plots
thm = theme(plot.margin=unit(c(0,0,0,0),"lines"))

# Left-align the four plots 
# Adapted from: https://stackoverflow.com/a/13295880/496488
gA <- ggplotGrob(bar + thm)
gB <- ggplotGrob(smoke_status + thm)
gC <- ggplotGrob(hpv_status + thm)
gD <- ggplotGrob(site_status + theme(plot.margin=unit(c(0,0,0,0), "lines")) + 
                   guides(fill=FALSE))

maxWidth = grid::unit.pmax(gA$widths[2:5], gB$widths[2:5], gC$widths[2:5], gD$widths[2:5])
gA$widths[2:5] <- as.list(maxWidth)
gB$widths[2:5] <- as.list(maxWidth)
gC$widths[2:5] <- as.list(maxWidth)
gD$widths[2:5] <- as.list(maxWidth)

# Lay out plots and legend
p = grid.arrange(arrangeGrob(gA,gB,gC,gD, heights=c(0.5,0.1,0.1,0.2)),
                 leg, ncol=2, widths=c(0.8,0.2))
    

####################
## EXAMPLE 5
###################

library(rafalib)
library(ggplot2)
library(grid)
library(gridExtra)

#load data
geneExp <- read.table("data/GSE4051_data.tsv", stringsAsFactors = FALSE, sep = "\t", header=T)
sampleInfo <- read.table("data/GSE4051_design.tsv", stringsAsFactors = FALSE, sep = "\t", header=T)

## cluster samples based on gene expression
d <- dist(t(geneExp))
hc <- hclust(d, method = "complete") 

## define colors for clustering labels
sampleInfo$col_devstage<-as.factor(sampleInfo$devStage)
colors<-c("#440154FF", "#31688EFF", "#21908CFF", "#35B779FF","#B8DE29FF")

levels(sampleInfo$col_devstage)<-colors
sampleInfo$col_devstage<-as.character(sampleInfo$col_devstage)

# make the color bar at the bottom
dend <- as.dendrogram(hc)
rectanle<-ggplot()+geom_rect(aes(xmin=1:nrow(sampleInfo), xmax=1:nrow(sampleInfo)+1, ymin=0, ymax=1, 
                                 fill=sampleInfo$devStage[match(labels(dend),sampleInfo$sidChar)]), color="black", alpha=0.5) +
  theme_bw()+scale_fill_manual(values=colors, name="Developmental\nStage")+theme(legend.position = c(1.07, 6),
                                                                                 axis.title=element_blank(),
                                                                                 axis.text=element_blank(),
                                                                                 axis.ticks=element_blank(),
                                                                                 panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
                                                                                 panel.background = element_blank(), axis.line = element_blank(),
                                                                                 panel.border = element_blank())+
  geom_vline(xintercept=17, size=1)+geom_vline(xintercept=24, size=1)+
  geom_vline(xintercept=34, size=1)+ylim(-0.5,1.5)



par(mfcol = c(1,1), mar=c(5,6,3,6), oma=c(0,0,0,0))
plot.new()

# plot dendogram
myplclust(hc, labels=sampleInfo$sidNum, lab.col=sampleInfo$col_devstage, cex=1.2, main="")

# combine all elements
vp <- viewport(height = unit(0.1,"npc"), width=unit(0.77, "npc"), 
               just = c("center","top"), y = 0.14, x = 0.5)
print(rectanle, vp = vp)
