library("jsonlite")
library("fpc")
library("sp")
library("rgeos")
library("rgdal")
library("maptools")
library("alphahull")
library("igraph")

# Wechsel in das Arbeitsverzeichnis, ggf. anpassen
# setwd("~/Karten/WLAN")

# Projektion für Geodaten
P4S.latlon <- CRS("+proj=longlat +datum=WGS84 +no_defs")
P4S.psmerc <- CRS("+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs
")

# JSON-Daten einlesen
data.ffmap <- fromJSON("data.json", flatten=TRUE)
router <- data.ffmap$allTheRouters
router <- transform(router, lat=as.numeric(lat), long=as.numeric(long), clients=as.integer(clients))

# Namen der Communities einkürzen
comms <- data.ffmap$communities
for (i in names(comms)) {
	comms[[i]]$name <- gsub("Freifunk ","",comms[[i]]$name)
	comms[[i]]$name <- gsub("Freifunk","",comms[[i]]$name)
	comms[[i]]$name <- gsub(" e.V.","",comms[[i]]$name)
	comms[[i]]$name <- gsub(".freifunk.net","",comms[[i]]$name)

	comms[[i]]$meta <- gsub("Freifunk Rheinland e.V. - Domäne Wupper","Wupper",comms[[i]]$meta)
	comms[[i]]$meta <- gsub("Freifunk ","",comms[[i]]$meta)
	comms[[i]]$meta <- gsub("Freifunk","",comms[[i]]$meta)
	comms[[i]]$meta <- gsub(" e.V.","",comms[[i]]$meta)
	comms[[i]]$meta <- gsub(" e. V.","",comms[[i]]$meta)
	comms[[i]]$meta <- gsub(".freifunk.net","",comms[[i]]$meta)
	comms[[i]]$meta <- gsub("Domäne ","",comms[[i]]$meta)
	comms[[i]]$meta <- gsub(" Initiative","",comms[[i]]$meta)
}

# Communities ohne 'Metacommunity' bekommen ihren eigenen Namen
for (i in 1:length(router$id)) {
	router$comm.name[i] <- comms[router$community[i]][[1]]$name
	if (comms[router$community[i]][[1]]$meta != FALSE) { 
		router$meta[i] <- comms[router$community[i]][[1]]$meta
	}
	else router$meta[i] <- comms[router$community[i]][[1]]$name
}


# Crop Boundary Box (N40-N60, E0-E20)
router <- router[router$long>0,]
router <- router[router$long<20,]
router <- router[router$lat>40,]
router <- router[router$lat<60,]

# Router-Daten in CSV-Datei schreiben 
write.csv(router, file="router.csv")


# Clustering (Communities)
# router$pre.co <- 0
# for (i in unique(router$community)) {
	# ds <- dbscan(
		# spTransform(SpatialPoints(router[router$community==i,][,c("long","lat")], proj4string=P4S.latlon), P4S.psmerc)@coords,
		# eps=2.5e4, MinPts=3, showplot=0
	# ) 
	# pre.co <- predict(ds, router[router$community==i])
	# router[router$community==i,]$pre.co <- pre.co
# }


# Clustering (Meta-Communities)
router$pre <- 0
for (i in unique(router$meta)) {
	ds <- dbscan(
		spTransform(SpatialPoints(router[router$meta==i,][,c("long","lat")], proj4string=P4S.latlon), P4S.psmerc)@coords,
		eps=2.5e4, MinPts=4, showplot=0
	) 
	pre <- predict(ds, router[router$meta==i])
	router[router$meta==i,]$pre <- pre
}


# Router-Koordinaten als Geodaten formatieren
# router.sp <- SpatialPointsDataFrame(router[c("long","lat")],data=as.data.frame(router[,c("name","status","clients","meta","community","comm.name","pre","pre.co")]), proj4string=P4S.latlon)
router.sp <- SpatialPointsDataFrame(router[c("long","lat")],data=as.data.frame(router[,c("name","status","clients","meta","community","comm.name","pre")]), proj4string=P4S.latlon)

# Koordinaten-Duplikate entfernen (für alphahull erforderlich)
router.sp <- remove.duplicates(router.sp)

# # Liste der einzelnen Community-Cluster
# rcomm <- unique(router[router$pre.co > 0,][c("community","comm.name","pre.co")])
# gch.co.list <- list()

# Liste der einzelnen Meta-Cluster
rmeta <- unique(router[router$pre > 0,][c("meta","pre")])
gch.list <- list()

# # Konkave Hüllen um die Cluster berechnen (= Gebiete der Freifunk-Communities)
# for (i in 1:dim(rcomm)[1])  {
	# rdata <- router.sp[router.sp$community==rcomm$community[i],][router.sp[router.sp$community==rcomm$community[i],]$pre.co==rcomm$pre.co[i],]
	# #rdata <- router.sp[router.sp$community==rcomm$community[i],]
	# if (dim(rdata)[1] > 3) {	
		# # calculate concave hull
		# gch.as <- ashape(jitter(rdata@coords, 1e-3), alpha=0.20) 
		# gch.c <- graph.edgelist(cbind(as.character(gch.as$edges[, "ind1"]), as.character(gch.as$edges[,"ind2"])), directed = FALSE)
		# # modify the graph to obtain one single circular graph
		# while (sum(degree(gch.c)==1) > 0) {
			# gch.c <- delete.vertices(gch.c, degree(gch.c)==1)
		# }
		# if ((sum(degree(gch.c)) > 3) != 0) {
			# gch.c <- delete.vertices(gch.c, degree(gch.c) > 3)
		# }
		# #if (sum(degree(gch.c) > 2) > 1) {
		# #	gch.c <- delete.vertices(gch.c, names(degree(gch.c) > 2)[(degree(gch.c) > 2)][1])
		# #}
	    # if (!is.connected(gch.c)) gch.c <- decompose.graph(gch.c, mode="weak", max.comps=1, min.vertices=4)[[1]]
	    # # delete one edge to open the circular graph	
		# if (sum(degree(gch.c)==1) == 0) gch.g <- gch.c - E(gch.c)[1] else gch.g <- gch.c
	    # # find chain end points
    	   # ends <- names(which(degree(gch.g) == 1))
        # path <- get.shortest.paths(gch.g, ends[1], ends[2])[[1]][[1]]
        # # this is an index into the points
        # gch.path <- as.numeric(V(gch.c)[path]$name)
        # # join the ends
        # gch.path <- c(gch.path, gch.path[1])
	    # gch.c <- gch.as$x[gch.path,]
	
	    # gch <- gBuffer(SpatialPolygons(list(Polygons(list(Polygon(gch.c)), ID="1")),proj4string=P4S.latlon),width=0.01)
	    # gch@polygons[[1]]@ID <- rownames(rcomm)[i]
	# } 
	# else {
		# gch <- gBuffer(rdata, width=0.03)
		# gch@polygons[[1]]@ID <- rownames(rcomm)[i]
	# } 
	
# #	plot(gch)
	# gch.co.list[i] <- gch@polygons[[1]]
# }

# Konkave Hüllen um die Cluster berechnen (= Gebiete der Freifunk-Metacommunities)
for (i in 1:dim(rmeta)[1])  {
	rdata <- router.sp[router.sp$meta==rmeta$meta[i],][router.sp[router.sp$meta==rmeta$meta[i],]$pre==rmeta$pre[i],]
	#rdata <- router.sp[router.sp$meta==rmeta$meta[i],]
	if (dim(rdata)[1] > 3) {	
		# calculate concave hull
		# gch.as <- ashape(jitter(rdata@coords, 1e-3), alpha=0.20) 
		gch.as <- ashape(jitter(rdata@coords, 1e-3), alpha=0.20) 
		gch.c <- graph.edgelist(cbind(as.character(gch.as$edges[, "ind1"]), as.character(gch.as$edges[,"ind2"])), directed = FALSE)
		# modify the graph to obtain one single circular graph
		while (sum(degree(gch.c)==1) > 0) {
			gch.c <- delete.vertices(gch.c, degree(gch.c)==1)
		}
		if ((sum(degree(gch.c)) > 3) != 0) {
			gch.c <- delete.vertices(gch.c, degree(gch.c) > 3)
		}
		if (sum(degree(gch.c) > 2) > 1) {
			gch.c <- delete.vertices(gch.c, names(degree(gch.c) > 2)[(degree(gch.c) > 2)][1])
		}
	    if (!is.connected(gch.c)) gch.c <- decompose.graph(gch.c, mode="weak", max.comps=1, min.vertices=4)[[1]]
	    # delete one edge to open the circular graph	
		if (sum(degree(gch.c)==1) == 0) gch.g <- gch.c - E(gch.c)[1] else gch.g <- gch.c
	    # find chain end points
    	   ends <- names(which(degree(gch.g) == 1))
        path <- get.shortest.paths(gch.g, ends[1], ends[2])[[1]][[1]]
        # this is an index into the points
        gch.path <- as.numeric(V(gch.c)[path]$name)
        # join the ends
        gch.path <- c(gch.path, gch.path[1])
	    gch.c <- gch.as$x[gch.path,]
	
	    gch <- gBuffer(SpatialPolygons(list(Polygons(list(Polygon(gch.c)), ID="1")),proj4string=P4S.latlon),width=0.03)
	    gch@polygons[[1]]@ID <- rownames(rmeta)[i]
	} 
	else {
		gch <- gBuffer(rdata, width=0.03)
		gch@polygons[[1]]@ID <- rownames(rmeta)[i]
	} 
	
#	plot(gch)
	gch.list[i] <- gch@polygons[[1]]
}

# Gebiete in Geodaten wandeln und in Datei schreiben
# gch.co.sp <- SpatialPolygons(gch.co.list, proj4string=P4S.latlon)
# gch.co.df.sp <- SpatialPolygonsDataFrame(gch.co.sp, data=rcomm)

gch.sp <- SpatialPolygons(gch.list, proj4string=P4S.latlon)
gch.df.sp <- SpatialPolygonsDataFrame(gch.sp, data=rmeta)

# writePolyShape(gch.co.df.sp, "gch-co")
writePolyShape(gch.df.sp, "gch")
