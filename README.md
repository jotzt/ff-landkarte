# Freifunk-Landkarte
Mit der ff-landkarte lässt sich die Verbreitung der Freifunk-(Meta-)Communities einfach visualisieren. Siehe auch: https://forum.freifunk.net/t/freifunk-landkarte/5181

- Download R Project: https://www.r-project.org/ Fertige Pakete sind in den meisten Linux-Distributionen enthalten:
  - `apt-get install r-base` 
- Die folgenden Pakete müssen in R installiert sein:
  * jsonlite
  * fpc
  * sp
  * rgeos
  * rgdal
  * maptools
  * alphahull
  * igraph

- Download der Daten der Freifunk-Karte: 
````
  $ wget -O data.json http://www.freifunk-karte.de/data.php
````

- R Project starten und das Skript "ff-landkarte.R" ausführen. Z. B. mit 
````
  > setwd("Verzeichnis der nodes.json")
  > source("ff-landkarte.R")
````
 * Das Skript und die JSON-Datei sollten sich dazu im gleichen Verzeichnis befinden, andernfalls müssen die Pfade    angepasst werden. 

- Dadurch werden im Verzeichnis zwei Dateien erzeugt:
  * router.csv   - Alle Router aus der Freifunk-Karte mit Koordinaten
  * gch.shp      - Shapefile mit den berechneten Bereichen der Metacommunities (zum Anzeigen kann z. B. http://mapshaper.org verwendet werden)
