library(ggplot2)
library(RColorBrewer)
library(scales)
library(gridExtra)


th <-   theme(axis.text=element_text(size=12),
              axis.title=element_text(size=14),
              strip.text.x = element_text(size = 12),
              legend.text=element_text(size=12),
              legend.title=element_text(size=14))


makeVolcano<-function(pvalue, deltabeta, dB_threshold, pval_threshold, legend_title, xlimit){
  #VOLCANO PLOT
  volcano<-data.frame(Pvalue=pvalue, Delta_Beta=deltabeta)
  
  #Thresholds 
  dB<-dB_threshold #delta beta cutoff
  Pv<-pval_threshold #Pvalue cutoff
  
  sta_delbeta<-deltabeta[which(pvalue<=pval_threshold)] 
  sta_delbeta<-sta_delbeta[abs(sta_delbeta)>=dB]
  
  print(paste("Increased Expression", length(sta_delbeta[which(sta_delbeta>=dB)]), sep=": "))
  print(paste("Decreased Expression", length(sta_delbeta[which(sta_delbeta<=(-dB))]) , sep=": "))
  
  volcano<-volcano[complete.cases(volcano),]
  
#set color thresholds
    color3<-sapply(1:nrow(volcano), function(x) if(volcano$Pvalue[x]<=Pv){
    if(abs(volcano$Delta_Beta[x])>dB){
      if(volcano$Delta_Beta[x]>dB){"Increased Expression\n(with Potential Biological Impact)"}else{"Decreased Expression\n (with Potential Biological Impact)"}
    }else{if(volcano$Delta_Beta[x]>0){"Increased Expression"}else{"Decreased Expression"}}}else{"Not Significantly Different"})
  
  volcano$Interesting_CpG3<-color3
  
  
  # COLORS! define here so they are consistent between plots
  # so even if you don't have CpGs in a color catagory the pattern will be maintained
  myColors <- c(muted("red", l=80, c=30),"red",muted("blue", l=70, c=40),"blue", "grey")
  
  color_possibilities<-c("Decreased Expression",
                         "Decreased Expression\n (with Potential Biological Impact)",
                         "Increased Expression",
                         "Increased Expression\n(with Potential Biological Impact)",
                         "Not Significantly Different")
  
  names(myColors) <- color_possibilities
  colscale <- scale_color_manual(name = legend_title,
                                 values = myColors, drop = FALSE)
  
  
  #omg
  volcano_plot<-ggplot(volcano, aes(Delta_Beta, -log10(Pvalue), color=Interesting_CpG3))+
    geom_point(shape=19, size=1)+theme_bw()+
    colscale+
    geom_vline(xintercept=c(-dB,dB), color="grey60")+
    geom_hline(yintercept=-log10(Pv), color="grey60")+
    ylab("P Value (-log10)")+xlab("Fold Change")+xlim(-xlimit, xlimit)+
    theme(plot.margin=unit(c(1,1,1,2),"cm"))+ th+
    guides(color = guide_legend(override.aes = list(size = 4)))
  
  # p val dis
  pval_dis<-ggplot()+geom_histogram(aes(pvalue),fill="grey90", color="black")+theme_bw()+xlab("Nominal P Value")+th+
    theme(plot.margin=unit(c(1,8.75,-0.6,1.5),"cm"))+ylab("CpG Count")
  
  grid.arrange(pval_dis, volcano_plot, ncol=1,heights = c(2, 6))#
  
}