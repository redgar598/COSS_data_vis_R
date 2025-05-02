
myColors_gtype <- c("darkgoldenrod1","lightskyblue")
color_possibilities_gtype<-c( "NrlKO","wt")
names(myColors_gtype) <- color_possibilities_gtype
fillscale_gtype <- scale_fill_manual(name="Genotype",
                               values = myColors_gtype, drop = T)
colscale_gtype <- scale_color_manual(name="Genotype",
                                         values = myColors_gtype, drop = T)




th <-   theme(axis.text=element_text(size=12),
              axis.title=element_text(size=14),
              strip.text = element_text(size = 12),
              legend.text=element_text(size=12),
              legend.title=element_text(size=14))
