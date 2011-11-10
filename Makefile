all: cluster_util_report top_usage_report percent_util_report compile

cluster_util_report: 
	$(MAKE) -C cluster_util/

top_usage_report:
	$(MAKE) -C top_usage/

percent_util_report:
	$(MAKE) -C percent_util/

compile:
	cp cluster_util/chart.pdf reports/
	cp top_usage/top_usage.xls reports/
	cp percent_util/percent_util.xls reports/
