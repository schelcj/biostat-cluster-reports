line_colors <- c("brown","chocolate","maroon","green","red","blue")
util_data   <- read.table('cluster_util.dat', header=T, sep=",")
u_range     <- range(0, util_data$allocated, util_data$down, util_data$plnd_down, util_data$idle, util_data$reserved, util_data$reported)

pdf("cluster_util.pdf")

plot(util_data$allocated,  type="o", lty=1, pch=20, ann=F, axes=F, ylim=u_range, col=line_colors[1], lwd=2)
lines(util_data$down,      type="o", lty=2, pch=21, col=line_colors[2], lwd=2)
lines(util_data$plnd_down, type="o", lty=3, pch=22, col=line_colors[3], lwd=2)
lines(util_data$idle,      type="o", lty=4, pch=23, col=line_colors[4], lwd=2)
lines(util_data$reserved,  type="o", lty=5, pch=24, col=line_colors[5], lwd=2)
lines(util_data$reported,  type="o", lty=6, pch=25, col=line_colors[6], lwd=2)

axis(1, 1:12, lab=F)
text(axTicks(1), par("usr")[3] - 2, pos=1, offset=1.0, srt=0, adj=1, labels=util_data$date[seq(1,12,2)], xpd=T, cex=0.7)

axis(2, las=1, cex.axis=0.8, lab=F)
text(axTicks(2), par("usr")[3] - 1, pos=1, offset=1.0, srt=0, adj=1, labels=seq(0,20,5), xpd=T, cex=0.7)
title(ylab="CPU Minutes", font.main="3")

legend(8, u_range[2], c("Allocated", "Down", "Planned Down", "Idle", "Reserved", "Reported"), col=line_colors, lty=1:6, pch=20:25)
box()

dev.off()
