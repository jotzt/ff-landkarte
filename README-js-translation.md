# Freifunk-Landkarte js-Version

This file contains the description of the R Project script and a collection of possible libraries which could be used for the implementation in js.

## Description of existing R-Project script

````
read data from nodes.json file obtained via freifunk-karte.de/data.php

extract relevant information from nodes.json (id, lat, lon, metacommunity, community)

write the router coordinates to a csv file

convert coordinates to some more or less equidistant metric 
    (i.e. EPSG:3857 - pseudo mercator projection)

cluster the coordinates for each metacommunity using the DBSCAN function with minimum cluster size of 4
    DBSCAN parameter: N_eps = 25000 (applicable to the EPSG:3857 projection)

deduplicate all uniqe geo-coordinates
    necessary for the computation of a Voronoi diagram
    if the Voronoi calculation still fails, a jitter with the magnitude of 1e-3 could be added to the coordinates

create a concave hull from each cluster
    concave hull parameter: alpha = 0.2

convert the concave hull to a simple undirected graph

create a spatial object from the graph

add a small buffer to the spatial object

write the spatial objects to a shapefile 
````

## Resources and js Libraries 

### DBSCAN
https://en.wikipedia.org/wiki/DBSCAN

https://github.com/upphiminn/jDBSCAN

http://www.philippe-fournier-viger.com/spmf/

### Concave Hull
https://github.com/AndriiHeonia/hull

### Manipulate Graphs
https://github.com/tantalor/graphjs

https://github.com/cpettitt/graphlib

### Spatial Data
https://github.com/turfjs/turf

https://github.com/manuelbieh/Geolib
