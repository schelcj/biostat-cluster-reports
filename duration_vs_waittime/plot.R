build_reports <- function(file) {
  report <- read.table(file, header=T, sep=",")
  period <- sub('^report-', '', sub('.dat$', '', file))
  pdf(paste('report-', period, '.pdf', sep=''))
  plot(report$duration, report$waittime, xlab="Duration (Hours)", ylab="Waittime (Hours)", main=period, pch=19, cex=0.25, col="blue")
  dev.off()
}
lapply(list.files(path='.', pattern='.dat$'), build_reports)
