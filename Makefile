all: cluster_util_report top_usage_report percent_util_report wait_idle_time_report compile

cluster_util_report: 
	$(MAKE) -C cluster_util/

top_usage_report:
	$(MAKE) -C top_usage/

percent_util_report:
	$(MAKE) -C percent_util/

wait_idle_time_report:
	$(MAKE) -C wait_idle_time/

compile:
	cp cluster_util/chart.pdf reports/
	cp top_usage/top_usage.xls reports/
	cp percent_util/percent_util.xls reports/
	cp percent_util/percent_util_by_month.xls reports/
	cp wait_idle_time/wait_idle_time.xls reports/
