report <- read.table('report.dat', header=T, sep=',')
u_range <- range(0, report$avg_duration)

pdf('job_duration_hist.pdf')
hist(log(report$avg_duration), breaks=20, xlab="CPU Minutes", ylab="Frequency", col="lightblue", main="")
box()
dev.off()

pdf('job_duration_line.pdf')
plot(report$avg_duration, type="o", lwd=2, lty=1, pch=NA, col="blue", ann=F, axes=F, ylim=u_range)
axis(1, 1:52, lab=T)
title(ylab="Average Job Duration")                                                                                    
box()
dev.off()
