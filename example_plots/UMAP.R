library(ggplot2)
library(dplyr)


## grab legened from any ggplot
get_leg = function(a.gplot){
  tmp <- ggplot_gtable(ggplot_build(a.gplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  legend
}


## load data
plt_umap<-read.csv("data/UMAP.csv")
plt_umap$lineage_clusters<-as.character(plt_umap$lineage_clusters)

## make tiny fancy axes
len_x_bar<-((range(plt_umap$umap_1))[2]-(range(plt_umap$umap_1))[1])/10
len_y_bar<-((range(plt_umap$umap_2))[2]-(range(plt_umap$umap_2))[1])/10
arr <- list(x = min(plt_umap$umap_1)-2, y = min(plt_umap$umap_2)-2, x_len = len_x_bar, y_len = len_y_bar)

## grab a legend and add to main plot with cowplot
forlegned_plot<-ggplot(plt_umap, aes(umap_1,umap_2))+
  geom_point(aes(fill=lineage_clusters),size=2, shape=21)+xlab("UMAP 1")+ylab("UMAP 2")+
  scale_fill_manual(values = c("#F3C300", "#875692", "#F38400", "#A1CAF1", "#BE0032", "#654522", "#8DB600","#008856"), name = "Cluster")+
  theme_bw()+
  theme(legend.text = element_text(size=5),
        legend.title = element_text(size=6))

nice_legend<-get_leg(forlegned_plot)

## actual UMAP
fanciest_UMAP<-ggplot(plt_umap, aes(umap_1,umap_2))+
  geom_point(size = 0.06, colour= "black", stroke = 1)+
  geom_point(aes(color=lineage_clusters),size=0.05)+xlab("UMAP 1")+ylab("UMAP 2")+
  scale_color_manual(values = c("#F3C300", "#875692", "#F38400", "#A1CAF1", "#BE0032", "#654522", "#8DB600","#008856"))+
  annotate("segment", 
           x = arr$x, xend = arr$x + c(arr$x_len, 0), 
           y = arr$y, yend = arr$y + c(0, arr$y_len), size=0.25,color="black",
           arrow = arrow(type = "closed", length = unit(2, 'pt'))) +
  theme_void()+theme(plot.margin = margin(0.25,0.25,0.25,0.25, "cm"),
                     axis.title.x = element_text(size=5,hjust = 0.05),
                     axis.title.y = element_text(size=5,hjust = 0.05,angle = 90),
                     legend.position = "none")

fanciest_UMAP <- fanciest_UMAP + annotate("text",x = min(plt_umap$umap_1)+(0.95*len_x_bar)-1, y = min(plt_umap$umap_2)+(0.5*len_y_bar)-2, label=paste0("n = ",comma(nrow(plt_umap))), size=2)

plot_grid(fanciest_UMAP,nice_legend, rel_widths = c(5,2))

ggsave("figures/fancy_UMAP.png", w=5, h=3.5)





