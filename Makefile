cvcm.osm: query.ovp
	curl -o $@ -X POST -d @$< "http://overpass-api.de/api/interpreter"

car.osm: cvcm.osm
	ln -s $< $@

bicycle.osm: cvcm.osm
	ln -s $< $@

foot.osm: cvcm.osm
	ln -s $< $@

car.osrm: car.osm
	docker run -t -v $(shell pwd):/data osrm/osrm-backend osrm-extract -p /opt/car.lua /data/car.osm
	docker run -t -v $(shell pwd):/data osrm/osrm-backend osrm-contract /data/car.osrm

bicycle.osrm: bicycle.osm
	docker run -t -v $(shell pwd):/data osrm/osrm-backend osrm-extract -p /opt/bicycle.lua /data/bicycle.osm
	docker run -t -v $(shell pwd):/data osrm/osrm-backend osrm-contract /data/bicycle.osrm

foot.osrm: foot.osm
	docker run -t -v $(shell pwd):/data osrm/osrm-backend osrm-extract -p /opt/foot.lua /data/foot.osm
	docker run -t -v $(shell pwd):/data osrm/osrm-backend osrm-contract /data/foot.osrm

car: car.osrm
	docker run -t -i -p 5888:5000 -v $(shell pwd):/data osrm/osrm-backend osrm-routed /data/car.osrm

bicycle: bicycle.osrm
	docker run -t -i -p 5888:5000 -v $(shell pwd):/data osrm/osrm-backend osrm-routed /data/bicycle.osrm

foot: foot.osrm
	docker run -t -i -p 5888:5000 -v $(shell pwd):/data osrm/osrm-backend osrm-routed /data/foot.osrm

dev:
	python -m SimpleHTTPServer 7181

clean:
	rm -rf car.*
	rm -rf bicycle.*
	rm -rf foot.*

purge: clean
	rm -rf cvcm.osm


.PHONY: car bicycle foot dev clean
