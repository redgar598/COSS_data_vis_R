library(gridExtra)
library(reshape2)

heat_scree_plot<-function(Loadings, Importance, right_marg, left_marg){
  
  if(missing(right_marg)) {
    right_marg=2.25} 
  
  if(missing(left_marg)) {
    left_marg=1} 
  
  pca_df<-data.frame(variance=Importance, PC=seq(1:length(Importance)))
  
  scree<-ggplot(pca_df[which(pca_df$PC<=(PCs_to_view)),],aes(PC,variance))+
    geom_bar(stat = "identity",color="black",fill="grey")+theme_bw()+
    theme(axis.text.y = element_text(size =15, color="black"),
          axis.text.x = element_blank(),
          axis.ticks.x = element_blank(),
          axis.title = element_text(size =18),
          plot.margin=unit(c(1.25,2.8,-0.2,2.8),"cm"))+ylab("Variance")+
    scale_x_continuous(breaks = seq(1,PCs_to_view,1))+xlab("")
  
  
  #### Heat
  ## correlate meta with PCS
  ## Run anova of each PC on each meta data variable
  
  
  aov_PC_meta <- lapply(1:ncol(meta_categorical), function(covar) sapply(1:ncol(Loadings), 
                                                                         function(PC) 
                                                                           summary(aov(Loadings[, PC] ~ meta_categorical[, covar]))[[1]]$"Pr(>F)"[1]))
  cor_PC_meta <- suppressWarnings(lapply(1:ncol(meta_continuous), function(covar) sapply(1:ncol(Loadings), 
                                                                        function(PC) (cor.test(Loadings[, PC], as.numeric(meta_continuous[, 
                                                                                                                                          covar]), alternative = "two.sided", method = "spearman", na.action = na.omit)$p.value))))
  names(aov_PC_meta) <- colnames(meta_categorical)
  names(cor_PC_meta) <- colnames(meta_continuous)
  aov_PC_meta <- do.call(rbind, aov_PC_meta)
  cor_PC_meta <- do.call(rbind, cor_PC_meta)
  aov_PC_meta <- rbind(aov_PC_meta, cor_PC_meta)
  aov_PC_meta <- as.data.frame(aov_PC_meta)
  
  #adjust
  aov_PC_meta_adjust<-aov_PC_meta[,1:ncol(aov_PC_meta)]
  
  #reshape
  avo<-aov_PC_meta_adjust[,1:PCs_to_view]
  avo_heat_num<-apply(avo,2, as.numeric)
  avo_heat<-as.data.frame(avo_heat_num)
  avo_heat$meta<-rownames(avo)
  avo_heat_melt<-melt(avo_heat, id=c("meta"))
  
  # cluster meta data
  meta_var_order<-unique(avo_heat_melt$meta)[rev(ord)]
  avo_heat_melt$meta <- factor(avo_heat_melt$meta, levels = meta_var_order)
  
  # color if sig
  avo_heat_melt$Pvalue<-sapply(1:nrow(avo_heat_melt), function(x) if(avo_heat_melt$value[x]<=0.001){"<=0.001"}else{
    if(avo_heat_melt$value[x]<=0.01){"<=0.01"}else{
      if(avo_heat_melt$value[x]<=0.05){"<=0.05"}else{">0.05"}}})
  
  levels(avo_heat_melt$variable)<-sapply(1:PCs_to_view, function(x) paste("PC",x, sep="" ))
  
  heat<-ggplot(avo_heat_melt, aes(variable,meta, fill = Pvalue)) +
    geom_tile(color = "black",size=0.5) +
    theme_gray(8)+scale_fill_manual(values=c("#084594","#4292c6","#9ecae1","#deebf7"), name="P Value")+
    theme(axis.text = element_text(size =16, color="black"),
          axis.title = element_text(size =18),
          legend.text = element_text(size =16),
          legend.title = element_text(size =16),
          legend.position = c(1.23, 0.75), legend.justification = c(1,1),
          plot.margin=unit(c(-0.3,right_marg,1,left_marg),"cm"),
          panel.background = element_blank(),
          panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank())+
    xlab("Principal Component")+ylab(NULL)
  
  grid.arrange(scree, heat, ncol=1,heights = c(3, 4))#
}