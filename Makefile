GPLOT=/home/schelcj/src/gplot-1.3

cluster_util:
	rm -f data/*.data
	rm -f charts/cluster_util.ps
	perl ./cluster_util.pl
	$(GPLOT)/gplot.pl --type ps --title "Cluster Utilization" \
		-outfile charts/cluster_util.ps \
		-fontsize 2 \
		-xlabel "Month" \
		-ylabel "CPU Minutes * 1000000" \
		-dateformat '%m' \
		-color blue  -name Idle      -thickness 2 -point uptriangle data/idle.data \
		-color red   -name Reserved  -thickness 2 -point uptriangle data/reserved.data \
		-color green -name Reported  -thickness 2 -point uptriangle data/reported.data \
		-color black -name Allocated -thickness 2 -point uptriangle data/allocated.data 


