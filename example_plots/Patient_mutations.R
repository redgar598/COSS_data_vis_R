
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

