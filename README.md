# Freifunk-Landkarte
Mit der ff-landkarte lässt sich die Verbreitung der Freifunk-(Meta-)Communities einfach visualisieren. Siehe auch: https://forum.freifunk.net/t/freifunk-landkarte/5181

- Download R Project: https://www.r-project.org/ Fertige Pakete sind in den meisten Linux-Distributionen enthalten
- Die folgenden Pakete müssen in R installiert sein:
  * jsonlite
  * fpc
  * sp
  * rgeos
  * rgdal
  * maptools
  * alphahull
  * igraph

- Download der Daten der Freifunkt-Karte: 
  > wget -O data.json http://www.freifunk-karte.de/data.php
 
- R Project starten und das Skript "FF-communities.R" ausführen. Z. B. mit 
  > setwd("Verzeichnis der data.json")
  > source("FF-communities.R")

- Dadurch werden im Verzeichnis zwei Dateien erzeugt:
  * router.csv    Alle Router aus der Freifunk-Karte mit Koordinaten
  * gch.shp       Shapefile mit den berechneten Bereichen der Metacommunities
