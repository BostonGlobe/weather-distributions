R:

	Rscript -e "rmarkdown::render('weather.Rmd')"
	open weather.html

R_deploy:

	cp weather.html /Volumes/www_html/multimedia/graphics/projectFiles/Rmd/
	rsync -rv weather_files /Volumes/www_html/multimedia/graphics/projectFiles/Rmd
	open http://private.boston.com/multimedia/graphics/projectFiles/Rmd/weather.html

clean:

	rm -rf data;
	mkdir data;
	mkdir data/input;
	mkdir data/output;

download:

	# download data from enigma API, in json format
	# pass it to jq, extract 'result' property
	# pass it to csvkit, convert to csv
	# save
	curl -g 'https://api.enigma.io/v2/data/${key}/us.gov.noaa.ncdc.consolidated.${year}/search/@station_id (USW00014739)' | \
		jq '.result' | \
		in2csv -f json > \
		data/input/${year}.csv

all: clean

	# call download year=number for 1936-2016
	number=1936 ; while [[ $$number -le 2016 ]] ; do \
		make download year=$$number ; \
		((number = number + 1)) ; \
	done

	# use csvkit to stack all csv files into one
	csvstack data/input/*.csv > data/output/data.csv
