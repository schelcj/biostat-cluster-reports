all: clean report plot

report:
	perl ./report.pl

clean:
	rm -f *.xls *.dat *.eps *.pdf

plot:
	Rscript ./plot.R 1>/dev/null
