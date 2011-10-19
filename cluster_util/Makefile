GPLOT=/home/schelcj/src/gplot-1.3

all: clean report plot

report:
	perl ./report.pl

plot:
	$(GPLOT)/gplot.pl --type ps --title "Cluster Utilization" \
		-outfile chart.ps \
		-fontsize 2 \
		-xlabel "Month" \
		-ylabel "CPU Minutes (Unit 1M)" \
		-dateformat '%m' \
		-thickness 5 \
		-color blue  -name Idle      -thickness 2 -point uptriangle idle.data \
		-color red   -name Reserved  -thickness 2 -point uptriangle reserved.data \
		-color green -name Reported  -thickness 2 -point uptriangle reported.data \
		-color black -name Allocated -thickness 2 -point uptriangle allocated.data 

clean:
	rm -f *.data chart.ps chart.png
