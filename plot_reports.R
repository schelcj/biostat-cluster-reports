png(filename="cluster_reports.png", bg="white", height=900, width=800)
par(mfrow=c(2,2))

# cluster utilization graphs
line_colors <- c("brown","chocolate","maroon","green","red","blue")
util_data   <- read.table('cluster_util/cluster_util.dat', header=T, sep=",")
u_range     <- range(0, util_data$allocated, util_data$down, util_data$plnd_down, util_data$idle, util_data$reserved, util_data$reported)

plot(util_data$allocated,  type="o", lty=1, pch=20, ann=F, axes=F, ylim=u_range, col=line_colors[1])
lines(util_data$down,      type="o", lty=2, pch=21, col=line_colors[2])
lines(util_data$plnd_down, type="o", lty=3, pch=22, col=line_colors[3])
lines(util_data$idle,      type="o", lty=4, pch=23, col=line_colors[4])
lines(util_data$reserved,  type="o", lty=5, pch=24, col=line_colors[5])
lines(util_data$reported,  type="o", lty=6, pch=25, col=line_colors[6])

axis(1, 1:12, lab=F)
text(axTicks(1), par("usr")[3] - 2, pos=1, offset=1.0, srt=0, adj=1, labels=util_data$date[seq(1,12,2)], xpd=T, cex=0.7)
axis(2, las=1, cex.axis=0.8)

title('Cluster Utilization')
title(ylab="CPU Minutes", font.main="3", col.lab=rgb(0,0.5,0))
legend(8, u_range[2], c("Allocated", "Down", "Planned Down", "Idle", "Reserved", "Reported"), col=line_colors, lty=1:6, pch=20:25)
box()

# waitime graphs
wait_data <- read.table('wait_idle_time/waittime.dat', header=T, sep=",")
w_range <- range(0, wait_data$avg_wait, wait_data$avg_job_duration)

plot(wait_data$avg_wait, type="o", col="blue", ann=F, axes=F, cex.lab=0.8)
axis(1, 1:12, lab=F)
text(axTicks(1), par("usr")[3] - 2, pos=1, offset=1.0, srt=0, adj=1, labels=wait_data$start_date, xpd=T, cex=0.7)
axis(2, las=1, cex.axis=0.8)
lines(wait_data$avg_job_duration, type="o", col="red", lty=2, pch=22)
title("Waittime")
title(ylab="Wallclock Minutes", font.main="3", col.lab=rgb(0,0.5,0))
legend(1, w_range[2], c("Avg Job Wait","Avg Job Duration"), cex=0.8, col=c("blue","red"), pch=21:22, lty=1:2)
box()

plot(wait_data$total_jobs, type="o", col="blue", axes=F, ann=F)
axis(1, 1:12, lab=F)
text(axTicks(1), par("usr")[3] - 2, pos=1, offset=1.0, srt=0, adj=1, labels=wait_data$start_date, xpd=T, cex=0.7)
axis(2, las=1, cex.axis=0.8)
title("Total Jobs Submitted")
title(ylab="Jobs", font.main="3", col.lab=rgb(0,0.5,0))
box()

dev.off()
