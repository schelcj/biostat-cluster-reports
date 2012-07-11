all: clean report plot

report:
	perl ./report.pl

plot:
	Rscript ./plot.R 1>/dev/null

clean:
	rm -f *.dat *.eps
