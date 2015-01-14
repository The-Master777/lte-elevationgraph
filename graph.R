#!/usr/bin/Rscript

brewer_colors = TRUE # Set to FALSE to use manual colors

args <- commandArgs(trailingOnly = TRUE)
help <- ("--help" %in% args) || ("-h" %in% args) || ("-?" %in% args);

# Print usage
if(length(args) <= 3 || help) {
	cat("usage: Rscript graph.R csv out h0 h1 [h2, ...]\n")
	cat("  csv:     path to csv-file having two columns named 'distance_km' and 'height_m'\n")
	cat("  out:     path of png-file the plot is saved to\n")
	cat("  h0:      height of local antenna\n")
	cat("  h1:      height of first tower-antenna\n")
	cat("  hn:      height of n-th tower-antenna\n")
	cat("  --help:  print this help\n\n")
	cat("Generate your csv-file at http://geo.ebp.ch/gelaendeprofil/\n\n")
	
	if(help) {
		stop("")
	}
}

# Path of default CSV file
# Needs to have two columns, named 'distance_km' and 'height_m'
csv <- if(length(args) > 0) args[1] else "./hoehe.csv"
col_dist = "distance_km"
col_height = "height_m"

# Example-heights of LTE antenna + towers
h0 = 11.8 # height of local antenna
h1 = 15.6 # height of LTE tower 1
h2 = 26.7 # height of LTE tower 2
h3 = 33.7 # height of LTE tower 3

hh = sort(c(h1,h2,h3))

# Use arguments
if(length(args) > 3) {
	h0 = as.numeric(args[3])
	hh = sort(as.numeric(args[4:length(args)]))
}

# Load colors
if(brewer_colors) {
	if(!"RColorBrewer" %in% installed.packages()) {
		install.packages("RColorBrewer")
	}

	require("RColorBrewer")

	hcol = brewer.pal(length(hh), "Set1") # Use brewer.pal.info for reference .. or google :)
} else {
	hcol = c("darkgreen", "purple", "navy")
}

# Load data
d <- na.omit(read.csv(file=csv,sep=",",head=TRUE))
df <- data.frame(d[col_dist]*1000, d[col_height])

colnames(df) <- c("d", "h")

height0 = df$h[1]
height1 = tail(df$h, n = 1)

max_x = max(df$d)

# Create ground-plot
#

if(length(args) > 3) {
	options(device="png")
	png(args[2], width=13, height=5.5, units="in", res=150)
} else {
	dev.new(width=13, height=5.5)
}

ymin = min(df$h)
ymax = max(c(height0+h0, height1+max(hh), max(df$h)))

plot(c(), c(), xlim=c(0, max_x), ylim=c(ymin, ymax*1.01), xlab="Distanz [m]", ylab="Höhe [m]")

grid(nx = NULL, ny = NULL, col = "lightgray", lty = "solid", lwd = par("lwd"))

# Fill ground area
xx <- c(df$d, rev(df$d))
yy <- c(rep(0, nrow(df)), rev(df$h))
polygon(xx, yy, col=rgb(30, 144, 255, 80, maxColorValue=255))

lines(df, lwd=2.5, col="dodgerblue3")

format.meter <- function(value) {
	return(gsub("\\.", ",", sprintf("%.2fm", value)))
}

draw.tower <- function(h, hbase = h, hextra = 0, col = "blue", posx=max_x, hx=height1){
	df0 <- data.frame(c(0, posx), c(height0+h0, hx+h))

	points(df0, col=col)
	lines(df0, col=col)

	df1 <- data.frame(c(posx, posx), c(hx, hx+h))

	points(df1, col=col)
	lines(df1, col=col)

	text(posx-80, hx+hbase/2+hextra, format.meter(h), col="red")
}

# Draw line of sight for h0 to h1
#draw.tower(h1)
#
# Draw line of sight for h0 to h2
#draw.tower(h2, (h2-h1), h1, "purple")
#
# Draw line of sight for h0 to h3
#draw.tower(h3, (h3-h2), h2, "darkgreen")

# Draw line of sight for h0 to all LTE towers
for(i in 1:length(hh)) {
	current = hh[i]
	lasth = if(i > 1) hh[i - 1] else 0
	col = if(length(hcol) >= i) hcol[i] else "darkblue"
	
	draw.tower(current, (current - lasth), lasth, col)
}

# Draw info for local LTE antenna
df0 <- data.frame(c(0, 0), c(height0, height0+h0))

points(df0, col="red")
lines(df0, col="red")

text(80, height0+h0/2, format.meter(h0), col="red")
