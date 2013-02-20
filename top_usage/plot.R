report <- read.table('report.dat', header=T, sep=',')

hist(report$cpu_min, breaks=50, xlab="CPU Minutes", ylab="Frequency", col="lightblue", main="Histogram of CPU Minutes")
