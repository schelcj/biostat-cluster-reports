GPLOT=/home/schelcj/src/gplot-1.3

all: clean report plot ps2pdf

report:
	perl ./report.pl

plot:
	$(GPLOT)/gplot.pl \
		-type ps \
		-title "Biostatistics Cluster Utilization for the last year" \
		-outfile chart.ps \
		-font 'helvetica' \
		-fontsize 12 \
		-tfontsize 10 \
		-xlabel "" \
		-ylabel "CPU Minutes (Unit 1M)" \
		-dateformat '%y/%m' \
		-thickness 2 \
		-style lines \
		-color blue    -name Idle           idle.data \
		-color red     -name Reserved       reserved.data \
		-color green   -name Reported       reported.data \
		-color cyan    -name Allocated      allocated.data  \
		-color black   -name Down           down.data \
		-color magenta -name 'Planned Down' plnd_down.data

clean:
	rm -f *.data chart.ps chart.png

ps2pdf:
	ps2pdf chart.ps
