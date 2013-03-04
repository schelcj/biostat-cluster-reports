report <- read.table('report.dat', header=T, sep=",")
attach(report)
plot(duration, waittime, xlab="Duration", ylab="Waittime", pch=19, cex=0.5, col="blue")
