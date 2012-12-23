all:
	rm -fr compiled/*
	cp -r lib/* compiled
	cp -r src/*.js compiled
	node_modules/coffee-script/bin/coffee -c -o compiled src
	node compiled/server.js

build:
	# TODO: add the copy/coffeescript step
	node ~/r.js -o client/buildconfig.js

dev:
	node_modules/coffee-script/bin/coffee --watch --compile -o compiled src
