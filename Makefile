all: cluster_util_report top_usage percent_util

cluster_util_report: 
	$(MAKE) -C cluster_util/

top_usage:
	$(MAKE) -C top_usage/

percent_util:
	$(MAKE) -C percent_util/
