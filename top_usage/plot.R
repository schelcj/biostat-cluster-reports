report <- read.table('report.dat', header=T, sep=',')

pdf('cpu_minutes.pdf')
hist(log(report$cpu_min), breaks=50, xlab="CPU Minutes", col="lightblue", main="")
box()
dev.off()
