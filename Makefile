all: cluster_util_report top_usage

cluster_util_report: 
	$(MAKE) -C cluster_util/

top_usage:
	$(MAKE) -C top_usage/
