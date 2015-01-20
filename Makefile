all: clean cluster_util_report top_usage_report percent_util_report wait_idle_time_report total_jobs_report job_duration_report duration_vs_waittime_report compile

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

job_duration_report:
	$(MAKE) -C job_duration/

duration_vs_waittime_report:
	$(MAKE) -C duration_vs_waittime/

estimated_time_report:
	$(MAKE) -C estimated_time/

compile:
	cp cluster_util/*.pdf reports/
	cp top_usage/*.xls reports/
	cp top_usage/*.pdf reports
	cp percent_util/*.xls reports/
	cp wait_idle_time/{*.pdf,*.xls} reports/
	cp total_jobs/report.pdf reports/total_jobs.pdf
	cp job_duration/*.pdf reports/
	cp duration_vs_waittime/report.pdf reports/duration_vs_waittime.pdf
	cp duration_vs_waittime/report.dat reports/duration_vs_waittime.csv
	cd reports ; pdflatex ./plot.tex 1>/dev/null
	$(MAKE) -C reports/

clean:
	rm -f reports/*.pdf reports/*.xls reports/*.dvi reports/*.aux reports/*.log
	$(MAKE) -C cluster_util/ clean
	$(MAKE) -C top_usage/ clean
	$(MAKE) -C percent_util/ clean
	$(MAKE) -C wait_idle_time/ clean
	$(MAKE) -C total_jobs/ clean
	$(MAKE) -C job_duration/ clean
	$(MAKE) -C duration_vs_waittime/ clean
