all: clean cluster_util_report top_usage_report percent_util_report wait_idle_time_report compile

cluster_util_report: 
	$(MAKE) -C cluster_util/

top_usage_report:
	$(MAKE) -C top_usage/

percent_util_report:
	$(MAKE) -C percent_util/

wait_idle_time_report:
	$(MAKE) -C wait_idle_time/

compile:
	find ./ -name '*.pdf' -exec cp {} reports/ \;
	find ./ -name '*.xls' -exec cp {} reports/ \;
	cd reports ; pdflatex ./plot.tex 1>/dev/null

clean:
	rm reports/*.pdf reports/*.xls reports/*.dvi reports/*.aux reports/*.log
