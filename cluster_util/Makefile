all: clean report plot

report:
	perl ./report.pl

plot:
	Rscript ./cluster_util.R 1>/dev/null

clean:
	rm -f *.dat *.png
