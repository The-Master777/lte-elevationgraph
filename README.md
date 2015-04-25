# LTE-ElevationGraph
[R-Script](http://www.r-project.org/) generating custom elevation-profile graphs for use with lte / wifi antennas

### Elevation-Profile CSV

Generate your csv-file at http://geo.ebp.ch/gelaendeprofil/

### Usage

Start with `Rscript graph.R ARGUMENTS`:

```text
usage: graph.R csv out h0 h1 [h2, ...]
  csv:     path to csv-file having two columns named 'distance_km' and 'height_m'
  out:     path of png-file the plot is saved to
  h0:      height of local antenna
  h1:      height of first tower-antenna
  hn:      height of n-th tower-antenna
  --help:  print this help
```

### Example graph

<img src="https://raw.githubusercontent.com/The-Master777/lte-elevationgraph/master/example.png" width="585px" height="248px" />
