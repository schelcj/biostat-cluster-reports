line_colors <- c("brown","chocolate","maroon","green","red","blue")
util_data   <- read.table('cluster_util.dat', header=T, sep=",")
u_range     <- range(0, util_data$allocated, util_data$down, util_data$plnd_down, util_data$idle, util_data$reserved, util_data$reported)

png(filename="cluster_util.png", bg="white")

plot(util_data$allocated,  type="o", lty=1, pch=20, ann=F, axes=F, ylim=u_range, col=line_colors[1])
lines(util_data$down,      type="o", lty=2, pch=21, col=line_colors[2])
lines(util_data$plnd_down, type="o", lty=3, pch=22, col=line_colors[3])
lines(util_data$idle,      type="o", lty=4, pch=23, col=line_colors[4])
lines(util_data$reserved,  type="o", lty=5, pch=24, col=line_colors[5])
lines(util_data$reported,  type="o", lty=6, pch=25, col=line_colors[6])

axis(1, 1:12, lab=F)
text(axTicks(1), par("usr")[3] - 2, pos=1, offset=1.0, srt=0, adj=1, labels=util_data$date, xpd=T, cex=0.7)
axis(2, las=1, cex.axis=0.8)

title('Cluster Utilization')
legend(8, u_range[2], c("Allocated", "Down", "Planned Down", "Idle", "Reserved", "Reported"), col=line_colors, lty=1:6, pch=20:25)
box()

dev.off()
