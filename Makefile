all: clean cluster_util_report top_usage_report percent_util_report wait_idle_time_report total_jobs_report compile

cluster_util_report: 
	$(MAKE) -C cluster_util/

top_usage_report:
	$(MAKE) -C top_usage/

percent_util_report:
	$(MAKE) -C percent_util/

wait_idle_time_report:
	$(MAKE) -C wait_idle_time/

total_jobs_report:
	$(MAKE) -C total_jobs/

compile:
	cp cluster_util/*.pdf reports/
	cp top_usage/*.xls reports/
	cp percent_util/*.xls reports/
	cp wait_idle_time/{*.pdf,*.xls} reports/
	cp total_jobs/report.pdf reports/total_jobs.pdf
	cd reports ; pdflatex ./plot.tex 1>/dev/null
	$(MAKE) -C reports/

clean:
	rm -f reports/*.pdf reports/*.xls reports/*.dvi reports/*.aux reports/*.log
