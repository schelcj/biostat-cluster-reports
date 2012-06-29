all: clean report plot

report:
	perl ./report.pl

clean:
	rm -f *.xls *.dat *.png

plot:
	Rscript ./waittime.R 1>/dev/null
