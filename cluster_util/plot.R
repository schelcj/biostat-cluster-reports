line_colors <- c("brown","chocolate","maroon","green","red","blue")
util_data   <- read.table('cluster_util.dat', header=T, sep=",")
u_range     <- range(0, util_data$allocated, util_data$down, util_data$plnd_down, util_data$idle, util_data$reserved, util_data$reported)

pdf("cluster_util.pdf")

plot(util_data$allocated,  type="o", lwd=2, lty=1, pch=NA, col=line_colors[1], ann=F, axes=F, ylim=u_range)
lines(util_data$down,      type="o", lwd=2, lty=2, pch=NA, col=line_colors[2])
lines(util_data$plnd_down, type="o", lwd=2, lty=3, pch=NA, col=line_colors[3])
lines(util_data$idle,      type="o", lwd=2, lty=4, pch=NA, col=line_colors[4])
lines(util_data$reserved,  type="o", lwd=2, lty=5, pch=NA, col=line_colors[5])
lines(util_data$reported,  type="o", lwd=2, lty=6, pch=NA, col=line_colors[6])

axis(1, 1:12, lab=T)
axis(2, at=axTicks(2), labels=seq(0, length(axTicks(2))^2, 5), cex=0.8, tick=TRUE, line=NA, pos=NA)

title(ylab=expression(paste("CPU Minutes ",10^6,sep="")))
legend(1, u_range[2], c("Allocated", "Down", "Planned Down", "Idle", "Reserved", "Reported"), col=line_colors, lty=1:6)
box()

dev.off()
