line_colors <- c("brown","chocolate","maroon","green","red","blue")
util_data   <- read.table('cluster_util.dat', header=T, sep=",")
u_range     <- range(0, util_data$allocated, util_data$down, util_data$plnd_down, util_data$idle, util_data$reserved, util_data$reported)

pdf("cluster_util.pdf")

plot(util_data$allocated,  type="o", lwd=2, lty=1, pch=20, col=line_colors[1], ann=F, axes=F, ylim=u_range)
lines(util_data$down,      type="o", lwd=2, lty=2, pch=21, col=line_colors[2])
lines(util_data$plnd_down, type="o", lwd=2, lty=3, pch=22, col=line_colors[3])
lines(util_data$idle,      type="o", lwd=2, lty=4, pch=23, col=line_colors[4])
lines(util_data$reserved,  type="o", lwd=2, lty=5, pch=24, col=line_colors[5])
lines(util_data$reported,  type="o", lwd=2, lty=6, pch=25, col=line_colors[6])

axis(1, 1:12, lab=F)
text(axTicks(1), par("usr")[3] - 2, pos=1, offset=1.0, srt=0, adj=1, labels=util_data$date[seq(1,12,2)], xpd=T, cex=0.8)

axis(2, at=c(0,1,2,3,4), labels=c("0","5","10","15","20"), cex=0.8, tick=TRUE, line=NA, pos=NA)

title(ylab="CPU Minutes")
legend(8, u_range[2], c("Allocated", "Down", "Planned Down", "Idle", "Reserved", "Reported"), col=line_colors, lty=1:6, pch=20:25)
box()

dev.off()
