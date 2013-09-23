report <- read.table('report.dat', header=T, sep=",")
users  <- unique(report$user)
colors <- data.frame(user=users, color=rainbow(length(users)))

pdf('estimated_job_time.pdf')

plot(
  x=1,
  y=1,
  type="n",
  main="Job Time (Wallclock Minutes)",
  xlab="Requested",
  ylab="Elapsed",
  xlim=range(0, max(report$time_requested)),
  ylim=range(0, max(report$time_elapsed)),
)

abline(1,1,col="gray60")

plot_user <- function(uniqname) {
  ureport <- subset(report, user == uniqname)
  ucolor  <- subset(colors, user == uniqname)

  points(
    ureport$time_requested,
    ureport$time_elapsed,
    pch=19,
    cex=0.5,
    col=ucolor$color
  )
}

lapply(users, plot_user)
par(xpd=TRUE)
legend(-1400, -1600, colors$user, pch=19, cex=0.8, col=colors$color, ncol=(length(users) / 2))

dev.off()
